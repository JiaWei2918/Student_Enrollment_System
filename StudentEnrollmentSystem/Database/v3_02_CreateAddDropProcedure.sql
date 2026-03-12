USE StudentEnrollmentSystem;
GO

-- Drop Course --
CREATE OR ALTER PROCEDURE sp_DropCourse
    @StudentID INT,
    @OfferingID INT
AS
BEGIN
SET NOCOUNT ON;

DECLARE @DropStart DATE
DECLARE @DropEnd DATE

SELECT
    @DropStart = s.DropPeriodStart,
    @DropEnd = s.DropPeriodEnd
FROM CourseOffering co
JOIN Semester s ON co.SemesterID = s.SemesterID
WHERE co.OfferingID = @OfferingID

IF GETDATE() < @DropStart OR GETDATE() > @DropEnd
BEGIN
    SELECT 'DROP_CLOSED' AS Result
    RETURN
END

BEGIN TRANSACTION

UPDATE Enrollment
SET Status = 'Dropped'
WHERE StudentID = @StudentID
AND OfferingID = @OfferingID
AND Status = 'Enrolled'

IF @@ROWCOUNT > 0
BEGIN
    COMMIT TRANSACTION
    SELECT 'SUCCESS' AS Result
END
ELSE
BEGIN
    ROLLBACK TRANSACTION
    SELECT 'NOT_FOUND' AS Result
END

END
GO

-- Get Enrolled Course --
CREATE OR ALTER PROCEDURE sp_GetMyCourses
    @StudentID INT
AS
BEGIN
SET NOCOUNT ON;

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
JOIN Semester s ON co.SemesterID = s.SemesterID
WHERE e.StudentID = @StudentID
AND e.Status = 'Enrolled'
AND s.Status = 'Active'

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