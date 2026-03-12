USE StudentEnrollmentSystem;
GO

-- Get Available Course --
CREATE OR ALTER PROCEDURE sp_GetAvailableCourses
    @StudentID INT
AS
BEGIN
SET NOCOUNT ON;

SELECT 
    co.OfferingID,
    c.CourseCode,
    c.CourseName,
    c.CreditHours,
    s.SemesterName,
    co.Capacity,
    COUNT (e.EnrollmentID) AS EnrolledCount,

    CASE
        WHEN (co.Capacity - COUNT(e.EnrollmentID)) < 0 THEN 0
        ELSE (co.Capacity - COUNT(e.EnrollmentID))
    END AS SeatsLeft
FROM CourseOffering co
JOIN Course c ON co.CourseID = c.CourseID
JOIN Semester s ON co.SemesterID = s.SemesterID
LEFT JOIN Enrollment e
    ON co.OfferingID = e.OfferingID
    AND e.Status= 'Enrolled'

WHERE s.Status = 'Active'
AND NOT EXISTS
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
c.CreditHours,
s.SemesterName,
co.Capacity

ORDER BY c.CourseCode

END
GO

-- Enroll Course --
CREATE OR ALTER PROCEDURE sp_EnrollCourse
    @StudentID INT,
    @OfferingID INT
AS
BEGIN
SET NOCOUNT ON;

BEGIN TRY
BEGIN TRANSACTION

IF NOT EXISTS (
    SELECT 1 FROM CourseOffering
    WHERE OfferingID = @OfferingID
)
BEGIN
    SELECT 'ERROR'
    ROLLBACK
    RETURN
END

DECLARE @Capacity INT
DECLARE @CurrentCount INT
DECLARE @CurrentCredits INT
DECLARE @CourseCredits INT
DECLARE @MaxCredits INT
DECLARE @AddStart DATE
DECLARE @AddEnd DATE

-- Get course capacity --
SELECT 
    @Capacity = co.Capacity,
    @AddStart = s.AddPeriodStart,
    @AddEnd = s.AddPeriodEnd,
    @MaxCredits = s.MaxCredits
FROM CourseOffering co
JOIN Semester s ON co.SemesterID = s.SemesterID
WHERE co.OfferingID = @OfferingID
AND s.Status = 'Active'

IF @Capacity IS NULL
BEGIN
    SELECT 'ERROR'
    ROLLBACK
    RETURN
END

IF GETDATE() < @AddStart OR GETDATE() > @AddEnd
BEGIN
    SELECT 'ADD_CLOSED'
    ROLLBACK
    RETURN
END

-- Count current students --
SELECT @CurrentCount = COUNT(*)
FROM Enrollment
WHERE OfferingID = @OfferingID
AND Status = 'Enrolled'

-- Check capacity --
IF @CurrentCount >= @Capacity
BEGIN
    SELECT 'FULL'
    ROLLBACK
    RETURN
END

IF EXISTS(
    SELECT 1 FROM Enrollment
    WHERE StudentID = @StudentID
    AND OfferingID = @OfferingID
    AND Status = 'Enrolled'
)
BEGIN
    SELECT 'ALREADY_ENROLLED'
    ROLLBACK
    RETURN
END

-- Current student credits --
SELECT @CurrentCredits = ISNULL(SUM(c.CreditHours),0)
FROM Enrollment e
JOIN CourseOffering co ON e.OfferingID = co.OfferingID
JOIN Course c ON co.CourseID = c.CourseID
JOIN Semester s ON co.SemesterID = s.SemesterID
WHERE e.StudentID=@StudentID
AND e.Status='Enrolled'
AND s.Status='Active'

-- Credits of new course --
SELECT @CourseCredits = c.CreditHours
FROM CourseOffering co
JOIN Course c ON co.CourseID = c.CourseID
WHERE co.OfferingID=@OfferingID

IF (@CurrentCredits + @CourseCredits) > @MaxCredits
BEGIN
    SELECT 'CREDIT_LIMIT'
    ROLLBACK
    RETURN
END

INSERT INTO Enrollment (StudentID, OfferingID, Status)
VALUES (@StudentID, @OfferingID, 'Enrolled')

COMMIT TRANSACTION

SELECT 'SUCCESS'

END TRY
BEGIN CATCH

IF @@TRANCOUNT > 0
ROLLBACK TRANSACTION

SELECT 'ERROR'

END CATCH
END
GO

-- Get Enrolled Course --
CREATE OR ALTER PROCEDURE sp_GetStudentEnrollments
    @StudentID INT
AS
BEGIN

SELECT 
    c.CourseCode,
    c.CourseName,
    c.CreditHours,
    s.SemesterName,
    e.Status
FROM Enrollment e
INNER JOIN CourseOffering co 
    ON e.OfferingID = co.OfferingID
INNER JOIN Course c 
    ON co.CourseID = c.CourseID
LEFT JOIN Semester s 
    ON co.SemesterID = s.SemesterID
WHERE e.StudentID = @StudentID
AND e.Status='Enrolled'

END
GO

-- Get Student Credits --
CREATE OR ALTER PROCEDURE sp_GetStudentCredits
    @StudentID INT
AS
BEGIN
SET NOCOUNT ON;

DECLARE @ActiveSemesterID INT
DECLARE @MaxCredits INT

SELECT
    @ActiveSemesterID = SemesterID,
    @MaxCredits = MaxCredits
FROM Semester
WHERE Status = 'Active'

SELECT 
    ISNULL(SUM(c.CreditHours),0) AS TotalCredits,
    ISNULL(@MaxCredits,0) AS MaxCredits

FROM Enrollment e
JOIN CourseOffering co ON e.OfferingID = co.OfferingID
JOIN Course c ON co.CourseID = c.CourseID

WHERE e.StudentID = @StudentID
AND e.Status = 'Enrolled'
AND co.SemesterID = @ActiveSemesterID

END
GO

-- Get Active Semester --
CREATE OR ALTER PROCEDURE sp_GetActiveSemester
AS
BEGIN

SELECT
SemesterID,
SemesterName,
AcademicYear,
AddPeriodStart,
AddPeriodEnd,
DropPeriodStart,
DropPeriodEnd

FROM Semester
WHERE Status='Active'

END
GO

IF NOT EXISTS (
    SELECT 1 FROM DatabaseVersion
    WHERE ScriptName = 'v3_01_CreateEnrollmentProcedure.sql'
)
BEGIN
    INSERT INTO DatabaseVersion (ScriptName)
    VALUES ('v3_01_CreateEnrollmentProcedure.sql');
END
GO