USE StudentEnrollmentSystem;
GO

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DatabaseVersion')
AND NOT EXISTS (
    SELECT 1 FROM DatabaseVersion 
    WHERE ScriptName = 'v1_02_CreateCoreTables.sql'
)
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        CREATE TABLE UserAccount (
            UserID INT IDENTITY(1,1) PRIMARY KEY,
            Username VARCHAR(50) UNIQUE NOT NULL,
            PasswordHash VARCHAR(255) NOT NULL,
            Role VARCHAR(20) CHECK (Role IN ('Student', 'Admin')) NOT NULL,
            Status VARCHAR(20) CHECK (Status IN ('Active', 'Inactive', 'Suspended')) DEFAULT 'Active',
            FailedAttempts INT DEFAULT 0,
            LockUntil DATETIME NULL,
            LastLogin DATETIME NULL,
            CreatedAt DATETIME DEFAULT GETDATE()
        );

        CREATE TABLE Student (
            StudentID INT IDENTITY(1,1) PRIMARY KEY,
            UserID INT UNIQUE NOT NULL,
            MatricNo VARCHAR(20) UNIQUE NOT NULL,
            FullName VARCHAR(100) NOT NULL,
            Email VARCHAR(100) UNIQUE NOT NULL,
            Phone VARCHAR(20),
            Program VARCHAR(50),
            Section VARCHAR(10),
            EnrollmentDate DATE,
            Status VARCHAR(20) CHECK (Status IN ('Active', 'Inactive', 'Graduated')) DEFAULT 'Active',
            CONSTRAINT FK_Student_UserAccount 
                FOREIGN KEY (UserID) REFERENCES UserAccount(UserID)
        );

        CREATE TABLE Administrator (
            AdminID INT IDENTITY(1,1) PRIMARY KEY,
            UserID INT UNIQUE NOT NULL,
            FullName VARCHAR(100) NOT NULL,
            Email VARCHAR(100) NOT NULL,
            Department VARCHAR(50),
            CONSTRAINT FK_Admin_UserAccount 
                FOREIGN KEY (UserID) REFERENCES UserAccount(UserID)
        );

        INSERT INTO DatabaseVersion (ScriptName)
        VALUES ('v1_02_CreateCoreTables.sql');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO