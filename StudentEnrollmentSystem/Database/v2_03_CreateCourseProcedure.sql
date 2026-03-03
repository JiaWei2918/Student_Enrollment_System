USE StudentEnrollmentSystem;
GO

-- Add Course --
CREATE OR ALTER PROCEDURE sp_AddCourse
    @CourseCode VARCHAR(20),
    @CourseName VARCHAR(100),
    @Description TEXT,
    @CreditHours INT,
    @PrerequisiteCourseID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM Course
        WHERE CourseCode = @CourseCode
    )
    BEGIN
        SELECT 'DUPLICATE' AS Result;
        RETURN;
    END

    INSERT INTO Course
    (CourseCode, CourseName, Description, CreditHours, PrerequisiteCourseID)
    VALUES
    (@CourseCode, @CourseName, @Description, @CreditHours, @PrerequisiteCourseID);

    SELECT 'SUCCESS' AS Result;
END
GO

-- Update Course --
CREATE OR ALTER PROCEDURE sp_UpdateCourse
    @CourseID INT,
    @CourseCode VARCHAR(20),
    @CourseName VARCHAR(100),
    @Description TEXT,
    @CreditHours INT,
    @PrerequisiteCourseID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM Course
        WHERE CourseCode = @CourseCode
        AND CourseID <> @CourseID
    )
    BEGIN
        SELECT 'DUPLICATE' AS Result;
        RETURN;
    END

    UPDATE Course
    SET CourseCode = @CourseCode,
        CourseName = @CourseName,
        Description = @Description,
        CreditHours = @CreditHours,
        PrerequisiteCourseID = @PrerequisiteCourseID
    WHERE CourseID = @CourseID;

    SELECT 'SUCCESS' AS Result;
END
GO

-- Delete Course --
CREATE OR ALTER PROCEDURE sp_DeleteCourse
    @CourseID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM Course
        WHERE PrerequisiteCourseID = @CourseID
    )
    BEGIN
        SELECT 'USED_AS_PREREQUISITE' AS Result;
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM CourseOffering
        WHERE CourseID = @CourseID
    )
    BEGIN
        SELECT 'HAS_OFFERING' AS Result;
        RETURN;
    END

    DELETE FROM Course
    WHERE CourseID = @CourseID;

    SELECT 'SUCCESS' AS Result;
END
GO

-- Get All Courses --
CREATE OR ALTER PROCEDURE sp_GetAllCourses
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.CourseID,
        c.CourseCode,
        c.CourseName,
        c.CreditHours,
        ISNULL(p.CourseName, 'None') AS PrerequisiteName
    FROM Course c
    LEFT JOIN Course p
        ON c.PrerequisiteCourseID = p.CourseID
    ORDER BY c.CourseCode;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM DatabaseVersion
    WHERE ScriptName = 'v2_03_CreateCourseProcedure.sql'
)
BEGIN
    INSERT INTO DatabaseVersion (ScriptName)
    VALUES ('v2_03_CreateCourseProcedure.sql');
END
GO