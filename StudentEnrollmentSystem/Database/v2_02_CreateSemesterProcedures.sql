USE StudentEnrollmentSystem;
GO

-- Add Semester --
CREATE OR ALTER PROCEDURE sp_AddSemester
    @SemesterName VARCHAR(50),
    @AcademicYear INT,
    @StartDate DATE,
    @EndDate DATE,
    @AddPeriodStart DATE = NULL,
    @AddPeriodEnd DATE = NULL,
    @DropPeriodStart DATE = NULL,
    @DropPeriodEnd DATE = NULL,
    @Status VARCHAR(20),
    @MaxCredits INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM Semester
        WHERE SemesterName = @SemesterName
        AND AcademicYear = @AcademicYear
    )
    BEGIN
        SELECT 'DUPLICATE' AS Result;
        RETURN;
    END

    IF YEAR(@StartDate) <> @AcademicYear
       OR YEAR(@EndDate) <> @AcademicYear
    BEGIN
        SELECT 'INVALID_YEAR' AS Result
        RETURN
    END

    IF @EndDate < @StartDate
    BEGIN
        SELECT 'INVALID_SEMESTER_RANGE' AS Result
        RETURN
    END

    IF @AddPeriodStart IS NOT NULL AND @AddPeriodEnd IS NOT NULL
    BEGIN
        IF @AddPeriodEnd < @AddPeriodStart
        BEGIN
            SELECT 'INVALID_ADD_PERIOD'
            RETURN
        END

        IF @AddPeriodStart < DATEADD(DAY, -7, @StartDate)
        BEGIN
            SELECT 'ADD_TOO_EARLY'
            RETURN
        END

        IF @AddPeriodEnd > DATEADD(DAY, 14, @StartDate)
        BEGIN
            SELECT 'ADD_TOO_LATE'
            RETURN
        END
    END

    IF @DropPeriodStart IS NOT NULL AND @DropPeriodEnd IS NOT NULL
    BEGIN
        IF @DropPeriodEnd < @DropPeriodStart
            OR @DropPeriodStart < @StartDate
            OR @DropPeriodEnd > @EndDate
        BEGIN
            SELECT 'INVALID_DROP_PERIOD' AS Result
            RETURN
        END
    END

    IF @Status = 'Active'
    BEGIN
        UPDATE Semester
        SET Status = 'Closed'
        WHERE Status = 'Active';
    END

    INSERT INTO Semester
    (SemesterName, AcademicYear, StartDate, EndDate, AddPeriodStart, AddPeriodEnd,
     DropPeriodStart, DropPeriodEnd, Status, MaxCredits)
    VALUES
    (@SemesterName, @AcademicYear, @StartDate, @EndDate, @AddPeriodStart, @AddPeriodEnd,
     @DropPeriodStart, @DropPeriodEnd, @Status, @MaxCredits);

    SELECT 'SUCCESS' AS Result;
END
GO

-- Update Semester --
CREATE OR ALTER PROCEDURE sp_UpdateSemester
    @SemesterID INT,
    @SemesterName VARCHAR(50),
    @AcademicYear INT,
    @StartDate DATE,
    @EndDate DATE,
    @AddPeriodStart DATE = NULL,
    @AddPeriodEnd DATE = NULL,
    @DropPeriodStart DATE = NULL,
    @DropPeriodEnd DATE = NULL,
    @Status VARCHAR(20),
    @MaxCredits INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM Semester
        WHERE SemesterName = @SemesterName
        AND AcademicYear = @AcademicYear
        AND SemesterID <> @SemesterID
    )
    BEGIN
        SELECT 'DUPLICATE' AS Result;
        RETURN;
    END

    IF YEAR(@StartDate) <> @AcademicYear
       OR YEAR(@EndDate) <> @AcademicYear
    BEGIN
        SELECT 'INVALID_YEAR' AS Result
        RETURN
    END

    IF @EndDate < @StartDate
    BEGIN
        SELECT 'INVALID_SEMESTER_RANGE' AS Result
        RETURN
    END

    IF @AddPeriodStart IS NOT NULL AND @AddPeriodEnd IS NOT NULL
    BEGIN
        IF @AddPeriodEnd < @AddPeriodStart
        BEGIN
            SELECT 'INVALID_DROP_PERIOD'
            RETURN
        END

        IF @DropPeriodStart < @StartDate
        BEGIN
            SELECT 'DROP_BEFORE_SEMESTER'
            RETURN
        END

        IF @DropPeriodEnd > DATEADD(DAY, 14, @StartDate)
        BEGIN
            SELECT 'DROP_TOO_LATE'
            RETURN
        END
    END

    IF @DropPeriodStart IS NOT NULL AND @DropPeriodEnd IS NOT NULL
    BEGIN
        IF @DropPeriodEnd < @DropPeriodStart
           OR @DropPeriodStart < @StartDate
           OR @DropPeriodEnd > @EndDate
        BEGIN
            SELECT 'INVALID_DROP_PERIOD' AS Result
            RETURN
        END
    END

    IF @Status = 'Active'
    BEGIN
        UPDATE Semester
        SET Status = 'Closed'
        WHERE Status = 'Active'
        AND SemesterID <> @SemesterID;
    END

    UPDATE Semester
    SET SemesterName = @SemesterName,
        AcademicYear = @AcademicYear,
        StartDate = @StartDate,
        EndDate = @EndDate,
        AddPeriodStart = @AddPeriodStart,
        AddPeriodEnd = @AddPeriodEnd,
        DropPeriodStart = @DropPeriodStart,
        DropPeriodEnd = @DropPeriodEnd,
        Status = @Status,
        MaxCredits = @MaxCredits
    WHERE SemesterID = @SemesterID;

    SELECT 'SUCCESS' AS Result;
END
GO

-- Delete Semester --
CREATE OR ALTER PROCEDURE sp_DeleteSemester
    @SemesterID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM CourseOffering
        WHERE SemesterID = @SemesterID
    )
    BEGIN
        SELECT 'HAS_OFFERINGS' AS Result;
        RETURN;
    END

    DELETE FROM Semester
    WHERE SemesterID = @SemesterID;

    SELECT 'SUCCESS' AS Result;
END
GO

-- Get All Semester Info --
CREATE OR ALTER PROCEDURE sp_GetAllSemesters
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM Semester
    ORDER BY AcademicYear DESC, SemesterName;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM DatabaseVersion
    WHERE ScriptName = 'v2_02_CreateSemesterProcedures.sql'
)
BEGIN
    INSERT INTO DatabaseVersion (ScriptName)
    VALUES ('v2_02_CreateSemesterProcedures.sql');
END
GO