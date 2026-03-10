USE StudentEnrollmentSystem;
GO

CREATE OR ALTER PROCEDURE sp_ResetPassword
    @Username VARCHAR(50),
    @Email VARCHAR(100),
    @NewPasswordHash VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UserID INT;

    SELECT @UserID = UA.UserID
    FROM UserAccount UA
    INNER JOIN Student S 
        ON UA.UserID = S.UserID
    WHERE UA.Username = @Username
      AND S.Email = @Email;

    IF @UserID IS NULL
    BEGIN
        SELECT 'INVALID_INFO' AS Result;
        RETURN;
    END

    UPDATE UserAccount
    SET PasswordHash = @NewPasswordHash,
        FailedAttempts = 0,
        LockUntil = NULL
    WHERE UserID = @UserID;

    SELECT 'SUCCESS' AS Result;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM DatabaseVersion
    WHERE ScriptName = 'v1_08_CreateResetPasswordProcedures.sql'
)
BEGIN
    INSERT INTO DatabaseVersion (ScriptName)
    VALUES ('v1_08_CreateResetPasswordProcedures.sql');
END
GO