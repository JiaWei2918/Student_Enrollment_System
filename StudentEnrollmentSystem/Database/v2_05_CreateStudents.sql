USE StudentEnrollmentSystem;
GO

-- Add Students --
CREATE OR ALTER PROCEDURE sp_AddStudent
    @MatricNo VARCHAR(20),
    @FullName VARCHAR(100),
    @Email VARCHAR(100),
    @Phone VARCHAR(20),
    @Program VARCHAR(50),
    @Section VARCHAR(10),
    @EnrollmentDate DATE,
    @PasswordHash VARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    IF EXISTS (SELECT 1 FROM Student WHERE MatricNo = @MatricNo)
    BEGIN
        ROLLBACK;
        SELECT 'DUPLICATE_MATRIC';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Student WHERE Email = @Email)
    BEGIN
        ROLLBACK;
        SELECT 'DUPLICATE_EMAIL';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM UserAccount WHERE Username = @MatricNo)
    BEGIN
        ROLLBACK;
        SELECT 'DUPLICATE_USERNAME';
        RETURN;
    END

    DECLARE @UserID INT;

    INSERT INTO UserAccount
    (
        Username,
        PasswordHash,
        Role
    )
    VALUES
    (
        @MatricNo,
        @PasswordHash,
        'Student'
    );

    SET @UserID = SCOPE_IDENTITY();

    INSERT INTO Student
    (
        UserID,
        MatricNo,
        FullName,
        Email,
        Phone,
        Program,
        Section,
        EnrollmentDate,
        Status
    )
    VALUES
    (
        @UserID,
        @MatricNo,
        @FullName,
        @Email,
        @Phone,
        @Program,
        @Section,
        @EnrollmentDate,
        'Active'
    )

    COMMIT;
    SELECT 'SUCCESS';
END
GO

-- Update Students --
CREATE OR ALTER PROCEDURE sp_UpdateStudent
    @StudentID INT,
    @FullName VARCHAR(100),
    @Email VARCHAR(100),
    @Phone VARCHAR(20),
    @Program VARCHAR(50),
    @Section VARCHAR(10),
    @Status VARCHAR(20)
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

    UPDATE Student
    SET FullName = @FullName,
        Email = @Email,
        Phone = @Phone,
        Program = @Program,
        Section = @Section,
        Status = @Status
    WHERE StudentID = @StudentID

    SELECT 'SUCCESS'
END
GO

-- Delete Students --
CREATE OR ALTER PROCEDURE sp_DeleteStudent
    @StudentID INT
AS
BEGIN
    DECLARE @UserID INT;

    SELECT @UserID = UserID FROM Student
    WHERE StudentID = @StudentID;

    /*IF EXISTS (
        SELECT 1 FROM Enrollment WHERE StudentID = @StudentID
    )
    BEGIN
        SELECT 'HAS_ENROLLMENTS'
        RETURN
    END*/

    DELETE FROM Student
    WHERE StudentID = @StudentID;

    DELETE FROM UserAccount
    WHERE UserID = @UserID;

    SELECT 'SUCCESS';
END
GO

-- Get All Students --
CREATE OR ALTER PROCEDURE sp_GetAllStudents
AS
BEGIN
    SELECT 
        s.StudentID,
        s.MatricNo,
        s.FullName,
        s.Email,
        CASE WHEN s.Phone IS NULL OR LTRIM(RTRIM(s.Phone)) = ''
            THEN '-' ELSE s.Phone END AS Phone,

        CASE WHEN s.Program IS NULL OR LTRIM(RTRIM(s.Program)) = ''
            THEN '-' ELSE s.Program END AS Program,

        CASE WHEN s.Section IS NULL OR LTRIM(RTRIM(s.Section)) = ''
            THEN '-' ELSE s.Section END AS Section,
        s.EnrollmentDate,
        s.Status,
        u.Username
    FROM Student s
    INNER JOIN UserAccount u ON s.UserID = u.UserID
END
GO

IF NOT EXISTS (
    SELECT 1 FROM DatabaseVersion
    WHERE ScriptName = 'v2_05_CreateStudents.sql'
)
BEGIN
    INSERT INTO DatabaseVersion (ScriptName)
    VALUES ('v2_05_CreateStudents.sql');
END
GO