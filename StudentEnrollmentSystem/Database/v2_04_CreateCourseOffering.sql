USE StudentEnrollmentSystem;
GO

-- Add Course Offer --
CREATE OR ALTER PROCEDURE sp_AddCourseOffering
    @CourseID INT,
    @SemesterID INT,
    @Lecturer VARCHAR(100),
    @Capacity INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM CourseOffering
        WHERE CourseID = @CourseID
        AND SemesterID = @SemesterID
    )
    BEGIN
        SELECT 'DUPLICATE'
        RETURN
    END

    IF EXISTS (
        SELECT 1 FROM Semester
        WHERE SemesterID = @SemesterID
        AND Status = 'Closed'
    )
    BEGIN
        SELECT 'SEMESTER_CLOSED'
        RETURN
    END

    INSERT INTO CourseOffering
    (
        CourseID,
        SemesterID,
        Lecturer,
        Capacity,
        Status
    )
    VALUES
    (
        @CourseID,
        @SemesterID,
        @Lecturer,
        @Capacity,
        'Open'
    )

    SELECT 'SUCCESS'
END
GO

-- Update Course Offer --
CREATE OR ALTER PROCEDURE sp_UpdateCourseOffering
    @OfferingID INT,
    @Lecturer VARCHAR(100),
    @Capacity INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Enrolled INT

    SELECT @Enrolled = COUNT(*)
    FROM Enrollment
    WHERE OfferingID = @OfferingID
    AND Status = 'Enrolled'

    IF @Capacity < @Enrolled
    BEGIN
        SELECT 'CAPACITY_TOO_SMALL'
        RETURN
    END

    UPDATE CourseOffering
    SET
        Lecturer = @Lecturer,
        Capacity = @Capacity
    WHERE OfferingID = @OfferingID

    SELECT 'SUCCESS'
END
GO

-- Delete Course Offer --
CREATE OR ALTER PROCEDURE sp_DeleteCourseOffering
    @OfferingID INT
AS
BEGIN
    IF EXISTS
    (
        SELECT 1
        FROM Enrollment
        WHERE OfferingID = @OfferingID
        AND Status = 'Enrolled'
    )
    BEGIN
        SELECT 'HAS_ENROLLMENTS'
        RETURN
    END

    DELETE FROM CourseOffering
    WHERE OfferingID = @OfferingID

    SELECT 'SUCCESS'
END
GO

-- Get All Course Offer --
CREATE OR ALTER PROCEDURE sp_GetAllCourseOfferings
AS
BEGIN
    SELECT 
        co.OfferingID,
        c.CourseCode,
        c.CourseName,
        s.SemesterName,
        s.AcademicYear,
        co.Lecturer,
        co.Capacity,

        COUNT(e.EnrollmentID) AS EnrolledStudents,
        (co.Capacity - COUNT(e.EnrollmentID)) AS SeatsLeft,

        CASE 
            WHEN (co.Capacity - COUNT(e.EnrollmentID)) <= 0 THEN 'FULL'
            ELSE 'Open'
        END AS Status
    FROM CourseOffering co
    INNER JOIN Course c ON co.CourseID = c.CourseID
    INNER JOIN Semester s ON co.SemesterID = s.SemesterID
    LEFT JOIN Enrollment e
        ON co.OfferingID = e.OfferingID
        AND e.Status = 'Enrolled'

    GROUP BY
    co.OfferingID,
    c.CourseCode,
    c.CourseName,
    s.SemesterName,
    s.AcademicYear,
    co.Lecturer,
    co.Capacity

    ORDER BY
    s.AcademicYear DESC,
    s.SemesterName,
    c.CourseCode;

END
GO

IF NOT EXISTS (
    SELECT 1 FROM DatabaseVersion
    WHERE ScriptName = 'v2_04_CreateCourseOffering.sql'
)
BEGIN
    INSERT INTO DatabaseVersion (ScriptName)
    VALUES ('v2_04_CreateCourseOffering.sql');
END
GO