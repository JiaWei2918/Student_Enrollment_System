USE StudentEnrollmentSystem;
GO

-- Drop Course --
CREATE OR ALTER PROCEDURE sp_DropCourse
    @StudentID INT,
    @OfferingID INT
AS
BEGIN
SET NOCOUNT ON;

BEGIN TRY
BEGIN TRANSACTION

DECLARE @DropStart DATE
DECLARE @DropEnd DATE

SELECT
    @DropStart = s.DropPeriodStart,
    @DropEnd = s.DropPeriodEnd
FROM CourseOffering co
JOIN Semester s ON co.SemesterID = s.SemesterID
WHERE co.OfferingID = @OfferingID
AND s.Status = 'Active'

IF GETDATE() > @DropEnd
BEGIN
    IF EXISTS (
        SELECT 1
        FROM AddDropHistory
        WHERE StudentID = @StudentID
        AND OfferingID = @OfferingID
        AND ActionType = 'Drop'
        AND RequestStatus = 'Pending'
    )
    BEGIN
        SELECT 'REQUEST_EXISTS'
        ROLLBACK
        RETURN
    END

    INSERT INTO AddDropHistory
    (StudentID, OfferingID, ActionType, RequestStatus)
    VALUES
    (@StudentID, @OfferingID, 'Drop', 'Pending')

    COMMIT
    SELECT 'PENDING_APPROVAL'
    RETURN
END

UPDATE Enrollment
SET Status = 'Dropped'
WHERE StudentID = @StudentID
AND OfferingID = @OfferingID
AND Status = 'Enrolled'

IF @@ROWCOUNT = 0
BEGIN
    ROLLBACK
    SELECT 'NOT_FOUND'
    RETURN
END

INSERT INTO AddDropHistory
(StudentID, OfferingID, ActionType, RequestStatus, ApprovedDate)
VALUES
(@StudentID, @OfferingID, 'Drop', 'Approved', GETDATE())

COMMIT

SELECT 'SUCCESS'

END TRY
BEGIN CATCH

IF @@TRANCOUNT > 0
ROLLBACK

SELECT 'ERROR'

END CATCH
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
AND s.Status = 'Active'

ORDER BY e.EnrollmentDate DESC

END
GO

-- Get Student Enrollment History --
CREATE OR ALTER PROCEDURE sp_GetStudentAddDropHistory
    @StudentID INT
AS
BEGIN
SET NOCOUNT ON;

SELECT
    c.CourseCode,
    c.CourseName,
    c.CreditHours,
    s.SemesterName,
    s.AcademicYear,
    h.ActionType,
    h.ActionDate,
    h.RequestStatus,
    a.FullName AS ApprovedByName,
    h.ApprovedDate
FROM AddDropHistory h
JOIN CourseOffering co ON h.OfferingID = co.OfferingID
JOIN Course c ON co.CourseID = c.CourseID
JOIN Semester s ON co.SemesterID = s.SemesterID
LEFT JOIN Administrator a ON h.ApprovedBy = a.AdminID
WHERE h.StudentID = @StudentID
ORDER BY h.ActionDate DESC

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