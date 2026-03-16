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

IF NOT EXISTS (
    SELECT 1 FROM DatabaseVersion
    WHERE ScriptName = 'v3_03_CreateAccountProcedure.sql'
)
BEGIN
    INSERT INTO DatabaseVersion (ScriptName)
    VALUES ('v3_03_CreateAccountProcedure.sql');
END
GO