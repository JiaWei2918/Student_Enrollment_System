USE StudentEnrollmentSystem;
GO

-- Change Password --
CREATE OR ALTER PROCEDURE sp_ChangePassword
    @UserID INT,
    @CurrentPasswordHash VARCHAR(256),
    @NewPasswordHash VARCHAR(256)
AS
BEGIN
SET NOCOUNT ON;

IF NOT EXISTS (
    SELECT 1 FROM UserAccount
    WHERE UserID = @UserID
    AND PasswordHash = @CurrentPasswordHash
)
BEGIN
    SELECT 'INVALID_PASSWORD'
    RETURN
END

UPDATE UserAccount
SET PasswordHash = @NewPasswordHash
WHERE UserID = @UserID

SELECT 'SUCCESS'

END
GO

-- Get Student Profile --
CREATE OR ALTER PROCEDURE sp_GetStudentProfile
    @StudentID INT
AS
BEGIN
SET NOCOUNT ON;

SELECT
    s.FullName,
    s.Email,
    s.Phone,
    s.Program,
    s.Section,
    p.Address,
    p.DateOfBirth,
    p.Nationality
FROM Student s
LEFT JOIN StudentProfile p
    ON s.StudentID = p.StudentID
WHERE s.StudentID = @StudentID

END 
GO

-- Update Student Profile --
CREATE OR ALTER PROCEDURE sp_UpdateStudentProfile
    @StudentID INT,
    @FullName VARCHAR(100),
    @Email VARCHAR(100),
    @Phone VARCHAR(20),
    @Program VARCHAR(50),
    @Section VARCHAR(10),
    @Address VARCHAR(255),
    @DateOfBirth DATE,
    @Nationality VARCHAR(50)
AS
BEGIN
SET NOCOUNT ON;

IF EXISTS (
    SELECT 1 FROM Student
    WHERE Email = @Email AND StudentID <> @StudentID
)
BEGIN
    SELECT 'DUPLICATE_EMAIL'
    RETURN
END

BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE Student
    SET FullName = @FullName,
        Phone = @Phone,
        Program = @Program,
        Section = @Section
    WHERE StudentID = @StudentID;

    IF EXISTS (
        SELECT 1 FROM StudentProfile WHERE StudentID = @StudentID
    )
    BEGIN
        UPDATE StudentProfile
        SET Address = @Address,
            DateOfBirth = @DateOfBirth,
            Nationality = @Nationality,
            UpdatedAt = SYSDATETIME()
        WHERE StudentID = @StudentID;
    END
    ELSE
    BEGIN
        INSERT INTO StudentProfile
        (StudentID, Address, DateOfBirth, Nationality)
        VALUES
        (@StudentID, @Address, @DateOfBirth, @Nationality);
    END

    COMMIT;
    SELECT 'SUCCESS';
END TRY
BEGIN CATCH
    ROLLBACK
    SELECT 'ERROR';
END CATCH

END 
GO

-- Get Bank Details --
CREATE OR ALTER PROCEDURE sp_GetBankDetails
    @StudentID INT
AS
BEGIN
SET NOCOUNT ON;
    SELECT
        BankDetailID,
        BankName,
        '****' + RIGHT(AccountNumber, 4) AS AccountNumber,
        AccountHolderName,
        AccountType,
        IsPrimary,
        COUNT(*) OVER() AS BankCount
    FROM BankDetail
    WHERE StudentID = @StudentID
    ORDER BY IsPrimary DESC, BankDetailID ASC
END
GO

-- Save Bank Details --
CREATE OR ALTER PROCEDURE sp_SaveBankDetail
    @BankDetailID INT = NULL,
    @StudentID INT,
    @BankName VARCHAR(100),
    @AccountNumber VARCHAR(50),
    @AccountHolderName VARCHAR(100),
    @AccountType VARCHAR(20),
    @IsPrimary BIT
AS
BEGIN
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    IF EXISTS (
        SELECT 1 FROM BankDetail
        WHERE StudentID = @StudentID
        AND AccountNumber = @AccountNumber
        AND (@BankDetailID IS NULL OR BankDetailID <> @BankDetailID)
    )
    BEGIN
        SELECT 'DUPLICATE_ACCOUNT';
        RETURN;
    END

    IF @IsPrimary = 1
    BEGIN
        UPDATE BankDetail
        SET IsPrimary = 0
        WHERE StudentID = @StudentID;
    END

    IF @BankDetailID IS NULL
    BEGIN
        INSERT INTO BankDetail
        (StudentID, BankName, AccountNumber, AccountHolderName, AccountType, IsPrimary)
        VALUES
        (@StudentID, @BankName, @AccountNumber, @AccountHolderName, @AccountType, @IsPrimary);
    END
    ELSE
    BEGIN
        UPDATE BankDetail
        SET BankName = @BankName,
            AccountNumber = @AccountNumber,
            AccountHolderName = @AccountHolderName,
            AccountType = @AccountType,
            IsPrimary = @IsPrimary
        WHERE BankDetailID = @BankDetailID;
    END

    COMMIT;
    SELECT 'SUCCESS';
END TRY
BEGIN CATCH
    ROLLBACK;
    SELECT 'ERROR';
END CATCH

END
GO

-- Delete Bank Details --
CREATE OR ALTER PROCEDURE sp_DeleteBankDetail
    @BankDetailID INT
AS
BEGIN
    DELETE FROM BankDetail
    WHERE BankDetailID = @BankDetailID
END
GO

IF NOT EXISTS (
    SELECT 1 FROM DatabaseVersion
    WHERE ScriptName = 'v3_03_CreateAccountProcedure.sql'
)
BEGIN
    INSERT INTO DatabaseVersion (ScriptName)
    VALUES ('v3_03_CreateAccountProcedure.sql');
END
GO