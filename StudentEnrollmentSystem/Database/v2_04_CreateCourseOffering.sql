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
        @Status, 
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

    UPDATE CourseOffering
    SET Lecturer = @Lecturer,
        AvailableSeats = CASE 
                             WHEN @Capacity - (Capacity - AvailableSeats) < 0 THEN 0
                             ELSE @Capacity - (Capacity - AvailableSeats)
                         END,
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