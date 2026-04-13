USE StudentEnrollmentSystem;
GO

CREATE OR ALTER PROCEDURE sp_LoginUser
    @Username VARCHAR(50),
    @PasswordHash VARCHAR(255)
AS
BEGIN
SET NOCOUNT ON;

DECLARE 
    @UserID INT,
    @Role VARCHAR(20),
    @StoredPassword VARCHAR(255),
    @FailedAttempts INT,
    @LockUntil DATETIME

SELECT
    @UserID = UserID,
    @Role = Role,
    @StoredPassword = PasswordHash,
    @FailedAttempts = FailedAttempts,
    @LockUntil = LockUntil
FROM UserAccount
WHERE Username = @Username

IF @UserID IS NULL
BEGIN
    SELECT 'INVALID' AS Result
    RETURN
END

IF @LockUntil IS NOT NULL AND @LockUntil <= GETDATE()
BEGIN
    UPDATE UserAccount
    SET LockUntil = NULL,
        FailedAttempts = 0
    WHERE UserID = @UserID

    SET @LockUntil = NULL
    SET @FailedAttempts = 0
END

IF @LockUntil IS NOT NULL AND @LockUntil > GETDATE()
BEGIN
    SELECT 'LOCKED' AS Result, @LockUntil AS LockUntil
    RETURN
END

IF @StoredPassword = @PasswordHash
BEGIN
    UPDATE UserAccount
    SET FailedAttempts = 0,
        LockUntil = NULL,
        LastLogin = GETDATE()
    WHERE UserID = @UserID

    DECLARE @FullName VARCHAR(100)
    DECLARE @StudentID INT = NULL
    DECLARE @AdminID INT = NULL

    IF @Role = 'Student'
    BEGIN
        SELECT 
            @FullName = FullName,
            @StudentID = StudentID
        FROM Student
        WHERE UserID = @UserID
    END
    ELSE IF @Role = 'Admin'
    BEGIN
        SELECT 
            @FullName = FullName,
            @AdminID = AdminID
        FROM Administrator
        WHERE UserID = @UserID
    END
    ELSE
    BEGIN
        SET @FullName = NULL
    END

    SELECT 
        'SUCCESS' AS Result,
        @UserID AS UserID,
        @Role AS Role,
        @FullName AS FullName,
        @StudentID AS StudentID,
        @AdminID AS AdminID
END
ELSE
BEGIN
    SET @FailedAttempts = @FailedAttempts + 1

    IF @FailedAttempts >= 3
    BEGIN
        DECLARE @NewLock DATETIME = DATEADD(MINUTE,5,GETDATE())

        UPDATE UserAccount
        SET FailedAttempts = 0,
            LockUntil = @NewLock
        WHERE UserID = @UserID

        SELECT 'LOCKED' AS Result, @NewLock AS LockUntil
    END
    ELSE
    BEGIN
        UPDATE UserAccount
        SET FailedAttempts = @FailedAttempts
        WHERE UserID = @UserID

        SELECT 'INVALID' AS Result
    END
END

END
GO

CREATE OR ALTER PROCEDURE sp_CheckUserLock
    @Username VARCHAR(50)
AS
BEGIN
SET NOCOUNT ON;

DECLARE @LockUntil DATETIME

SELECT @LockUntil = LockUntil
FROM UserAccount
WHERE Username = @Username

IF @LockUntil IS NOT NULL AND @LockUntil > GETDATE()
BEGIN
    SELECT 'LOCKED' AS Result, @LockUntil AS LockUntil
END
ELSE
BEGIN
    SELECT 'OK' AS Result
END

END
GO

IF NOT EXISTS (
    SELECT 1 FROM DatabaseVersion
    WHERE ScriptName = 'v1_03_CreateLoginProcedure.sql'
)
BEGIN
    INSERT INTO DatabaseVersion (ScriptName)
    VALUES ('v1_03_CreateLoginProcedure.sql');
END
GO