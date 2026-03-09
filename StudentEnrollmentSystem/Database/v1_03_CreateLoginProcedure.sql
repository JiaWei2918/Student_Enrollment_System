USE StudentEnrollmentSystem;
GO

IF NOT EXISTS (
    SELECT 1 FROM DatabaseVersion 
    WHERE ScriptName = 'v1_03_CreateLoginProcedure.sql'
)
BEGIN
    EXEC('
    CREATE PROCEDURE sp_LoginUser
        @Username VARCHAR(50),
        @PasswordHash VARCHAR(255)
    AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE @UserID INT,
                @Role VARCHAR(20),
                @FailedAttempts INT,
                @LockUntil DATETIME

        SELECT 
            @UserID = UserID,
            @Role = Role,
            @FailedAttempts = FailedAttempts,
            @LockUntil = LockUntil
        FROM UserAccount
        WHERE Username = @Username

        IF @UserID IS NULL
        BEGIN
            SELECT ''INVALID_USER'' AS Result
            RETURN
        END

        IF @LockUntil IS NOT NULL AND @LockUntil > GETDATE()
        BEGIN
            SELECT ''LOCKED'' AS Result
            RETURN
        END

        IF EXISTS (
            SELECT 1 FROM UserAccount
            WHERE Username = @Username
            AND PasswordHash = @PasswordHash
        )
        BEGIN
            UPDATE UserAccount
            SET FailedAttempts = 0,
                LockUntil = NULL,
                LastLogin = GETDATE()
            WHERE UserID = @UserID

            DECLARE @FullName VARCHAR(100), @StudentID INT;

            IF @Role = ''Student''
            BEGIN
                SELECT @FullName = FullName, @StudentID = StudentID
                FROM Student
                WHERE UserID = @UserID;
            END
            ELSE IF @Role = ''Admin''
            BEGIN
                SELECT @FullName = FullName
                FROM Administrator
                WHERE UserID = @UserID;
            END

            SELECT ''SUCCESS'' AS Result, @UserID AS UserID, @Role AS Role, @FullName AS FullName, @StudentID AS StudentID;
        END
        ELSE
        BEGIN
            SET @FailedAttempts = @FailedAttempts + 1

            IF @FailedAttempts >= 3
            BEGIN
                UPDATE UserAccount
                SET FailedAttempts = 0,
                    LockUntil = DATEADD(MINUTE, 5, GETDATE())
                WHERE UserID = @UserID

                SELECT ''LOCKED'' AS Result
            END
            ELSE
            BEGIN
                UPDATE UserAccount
                SET FailedAttempts = @FailedAttempts
                WHERE UserID = @UserID

                SELECT ''WRONG_PASSWORD'' AS Result
            END
        END
    END
    ')

    INSERT INTO DatabaseVersion (ScriptName)
    VALUES ('v1_03_CreateLoginProcedure.sql');
END
GO