USE StudentEnrollmentSystem;
GO

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DatabaseVersion')
AND NOT EXISTS (
    SELECT 1 FROM DatabaseVersion 
    WHERE ScriptName = 'v2_01_AddSemesterRule.sql'
)
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        ALTER TABLE Semester
        ADD CONSTRAINT UQ_Semester UNIQUE (SemesterName, AcademicYear);

        INSERT INTO DatabaseVersion (ScriptName)
        VALUES ('v2_01_AddSemesterRule.sql');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO