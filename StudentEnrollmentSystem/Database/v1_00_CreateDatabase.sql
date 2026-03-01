IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'StudentEnrollmentSystem')
BEGIN
    CREATE DATABASE StudentEnrollmentSystem;
END
GO

USE StudentEnrollmentSystem;
GO