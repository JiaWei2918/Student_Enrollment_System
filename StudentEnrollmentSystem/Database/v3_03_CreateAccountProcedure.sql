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
        Email = @Email,
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

IF NOT EXISTS (
    SELECT 1 FROM DatabaseVersion
    WHERE ScriptName = 'v3_03_CreateAccountProcedure.sql'
)
BEGIN
    INSERT INTO DatabaseVersion (ScriptName)
    VALUES ('v3_03_CreateAccountProcedure.sql');
END
GO