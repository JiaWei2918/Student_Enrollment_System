USE StudentEnrollmentSystem;
GO

-- Drop Course --
CREATE OR ALTER PROCEDURE sp_DropCourse
    @StudentID INT,
    @OfferingID INT
AS
BEGIN
SET NOCOUNT ON;

UPDATE Enrollment
SET Status = 'Dropped'
WHERE StudentID = @StudentID
AND OfferingID = @OfferingID
AND Status = 'Enrolled'

IF @@ROWCOUNT > 0
BEGIN
    UPDATE CourseOffering
    SET AvailableSeats = AvailableSeats + 1
    WHERE OfferingID = @OfferingID

    SELECT 'SUCCESS' AS Result
END
ELSE
BEGIN
    SELECT 'NOT_FOUND' AS Result
END

END
GO

-- Get Available Courses --
CREATE OR ALTER PROCEDURE sp_GetAvailableCourses
    @StudentID INT
AS
BEGIN

SELECT 
    co.OfferingID,
    c.CourseCode,
    c.CourseName,
    co.Capacity,
    COUNT(e.EnrollmentID) AS Enrolled,
    (co.Capacity - COUNT(e.EnrollmentID)) AS SeatsLeft
FROM CourseOffering co
JOIN Course c ON co.CourseID = c.CourseID

LEFT JOIN Enrollment e
    ON co.OfferingID = e.OfferingID
    AND e.Status = 'Enrolled'

WHERE NOT EXISTS
(
    SELECT 1
    FROM Enrollment e2
    WHERE e2.StudentID = @StudentID
    AND e2.OfferingID = co.OfferingID
    AND e2.Status = 'Enrolled'
)
GROUP BY
co.OfferingID,
c.CourseCode,
c.CourseName,
co.Capacity

END
GO

-- Get Enrolled Course --
CREATE OR ALTER PROCEDURE sp_GetMyCourses
    @StudentID INT
AS
BEGIN

SELECT 
    e.EnrollmentID,
    co.OfferingID,
    c.CourseCode,
    c.CourseName,
    co.Capacity,
    e.Status,
    e.EnrollmentDate
FROM Enrollment e
JOIN CourseOffering co ON e.OfferingID = co.OfferingID
JOIN Course c ON co.CourseID = c.CourseID
WHERE e.StudentID = @StudentID

ORDER BY e.EnrollmentDate DESC

END
GO

-- Get Student Enrollment History --
CREATE OR ALTER PROCEDURE sp_GetStudentEnrollmentHistory
    @StudentID INT
AS
BEGIN

SELECT
    c.CourseCode,
    c.CourseName,
    c.CreditHours,
    s.SemesterName,
    s.AcademicYear,
    e.Status,
    e.EnrollmentDate
FROM Enrollment e
JOIN CourseOffering co ON e.OfferingID = co.OfferingID
JOIN Course c ON co.CourseID = c.CourseID
JOIN Semester s ON co.SemesterID = s.SemesterID
WHERE e.StudentID = @StudentID
ORDER BY e.EnrollmentDate DESC

END
GO

IF NOT EXISTS (
    SELECT 1 FROM DatabaseVersion
    WHERE ScriptName = 'v3_02_CreateAddDropProcedure.sql'
)
BEGIN
    INSERT INTO DatabaseVersion (ScriptName)
    VALUES ('v3_02_CreateAddDropProcedure.sql');
END
GO