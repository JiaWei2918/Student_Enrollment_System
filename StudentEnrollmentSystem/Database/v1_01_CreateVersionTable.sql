USE StudentEnrollmentSystem;
GO

IF NOT EXISTS (
    SELECT * FROM sys.tables WHERE name = 'DatabaseVersion'
)
BEGIN
    CREATE TABLE DatabaseVersion (
        VersionID INT IDENTITY(1,1) PRIMARY KEY,
        ScriptName VARCHAR(200) NOT NULL UNIQUE,
        AppliedOn DATETIME DEFAULT GETDATE()
    );
END
GO