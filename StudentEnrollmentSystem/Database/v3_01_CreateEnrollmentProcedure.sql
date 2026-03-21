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

AND NOT EXISTS (
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

-- Enroll Courses (Student) --
CREATE OR ALTER PROCEDURE sp_EnrollCoursesBatch
    @StudentID INT,
    @OfferingIDs VARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    DECLARE @tbl TABLE (OfferingID INT PRIMARY KEY)

    INSERT INTO @tbl
    SELECT DISTINCT TRY_CAST(value AS INT)
    FROM STRING_SPLIT(@OfferingIDs, ',')
    WHERE TRY_CAST(value AS INT) IS NOT NULL

    IF NOT EXISTS (SELECT 1 FROM @tbl)
    BEGIN
        ROLLBACK
        SELECT 'NO_SELECTION'
        RETURN
    END

    DECLARE @SemesterID INT

    SELECT @SemesterID = MIN(SemesterID)
    FROM CourseOffering
    WHERE OfferingID IN (SELECT OfferingID FROM @tbl)

    IF EXISTS (
        SELECT 1 FROM CourseOffering
        WHERE OfferingID IN (SELECT OfferingID FROM @tbl)
        AND SemesterID <> @SemesterID
    )
    BEGIN
        ROLLBACK
        SELECT 'DIFFERENT_SEMESTER'
        RETURN
    END

    DECLARE @MaxCredits INT
    DECLARE @CurrentCredits INT

    SELECT @MaxCredits = MaxCredits
    FROM Semester
    WHERE SemesterID = @SemesterID

    SELECT @CurrentCredits = ISNULL(SUM(c.CreditHours),0)
    FROM Enrollment e
    JOIN CourseOffering co ON e.OfferingID = co.OfferingID
    JOIN Course c ON co.CourseID = c.CourseID
    WHERE e.StudentID = @StudentID
    AND e.Status = 'Enrolled'
    AND co.SemesterID = @SemesterID

    IF EXISTS (
        SELECT 1 FROM @tbl t
        JOIN CourseOffering co ON t.OfferingID = co.OfferingID
        WHERE (
            SELECT COUNT(*)
            FROM Enrollment e
            WHERE e.OfferingID = co.OfferingID
            AND Status = 'Enrolled'
        ) >= co.Capacity
    )
    BEGIN
        ROLLBACK
        SELECT 'FULL'
        RETURN
    END

    IF EXISTS (
        SELECT 1
        FROM @tbl t
        JOIN CourseSchedule cs2 ON t.OfferingID = cs2.OfferingID
        JOIN Enrollment e ON e.StudentID = @StudentID AND e.Status = 'Enrolled'
        JOIN CourseSchedule cs1 ON e.OfferingID = cs1.OfferingID
        WHERE cs1.DayOfWeek = cs2.DayOfWeek
        AND cs1.StartTime < cs2.EndTime
        AND cs1.EndTime > cs2.StartTime
    )
    BEGIN
        ROLLBACK
        SELECT 'CLASH'
        RETURN
    END

    DECLARE @NewCredits INT

    SELECT @NewCredits = SUM(c.CreditHours)
    FROM @tbl t
    JOIN CourseOffering co ON t.OfferingID = co.OfferingID
    JOIN Course c ON co.CourseID = c.CourseID

    IF (@CurrentCredits + ISNULL(@NewCredits, 0)) > @MaxCredits
    BEGIN
        ROLLBACK
        SELECT 'CREDIT_LIMIT'
        RETURN
    END

    INSERT INTO Enrollment (StudentID, OfferingID, Status)
    SELECT @StudentID, t.OfferingID, 'Enrolled'
    FROM @tbl t
    WHERE NOT EXISTS (
        SELECT 1 FROM Enrollment e
        WHERE e.StudentID = @StudentID
        AND e.OfferingID = t.OfferingID
        AND e.Status = 'Enrolled'
    )

    DECLARE @TotalAmount DECIMAL(10,2)
    
    SELECT @TotalAmount = SUM(ISNULL(c.Fee, 0))
    FROM @tbl t
    JOIN Courseoffering co ON t.OfferingID = co.OfferingID
    JOIN Course c ON co.CourseID = c.CourseID

    DECLARE @InvoiceID INT

    SELECT @InvoiceID = InvoiceID
    FROM Invoice
    WHERE StudentID = @StudentID
    AND SemesterID = @SemesterID

    IF @InvoiceID IS NULL
    BEGIN
        DECLARE @InvoiceNumber VARCHAR(50)
        SET @InvoiceNumber = 'INV-' + FORMAT(GETDATE(),'yyyyMMddHHmmss')

        INSERT INTO Invoice
        (InvoiceNumber, StudentID, SemesterID, IssueDate, DueDate, TotalAmount, Status)
        VALUES
        (@InvoiceNumber, @StudentID, @SemesterID, GETDATE(), DATEADD(DAY,7,GETDATE()), @TotalAmount, 'Issued')
    END
    ELSE
    BEGIN
        UPDATE Invoice
        SET TotalAmount = TotalAmount + @TotalAmount
        WHERE InvoiceID = @InvoiceID
    END

    COMMIT

    SELECT 'SUCCESS'

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