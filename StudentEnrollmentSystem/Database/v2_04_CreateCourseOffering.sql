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
        AvailableSeats,
        Status
    )
    VALUES
    (
        @CourseID,
        @SemesterID,
        @Lecturer,
        @Capacity,
        @Capacity,
        'Open'
    )

    SELECT 'SUCCESS'
END
GO

-- Update Course Offer Status --
CREATE OR ALTER TRIGGER trg_UpdateOfferingStatus
ON CourseOffering
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE co
    SET Status = 
        CASE 
            WHEN co.AvailableSeats <= 0 THEN 'Full'
            ELSE 'Open'
        END
    FROM CourseOffering co
    INNER JOIN inserted i ON co.OfferingID = i.OfferingID
    WHERE co.Status <> 'Cancelled';
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

    SELECT @Enrolled = Capacity - AvailableSeats
    FROM CourseOffering
    WHERE OfferingID = @OfferingID

    IF @Capacity < @Enrolled
    BEGIN
        SELECT 'CAPACITY_TOO_SMALL'
        RETURN
    END

    UPDATE CourseOffering
    SET
        Lecturer = @Lecturer,
        Capacity = @Capacity,
        AvailableSeats = @Capacity - @Enrolled
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
        co.AvailableSeats,
        (co.Capacity - co.AvailableSeats) AS EnrolledStudents,
        co.Status
    FROM CourseOffering co
    INNER JOIN Course c ON co.CourseID = c.CourseID
    INNER JOIN Semester s ON co.SemesterID = s.SemesterID
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