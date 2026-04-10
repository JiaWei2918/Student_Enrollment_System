USE StudentEnrollmentSystem;
GO

-- Get Student Statement --
CREATE OR ALTER PROCEDURE sp_GetStudentStatement
    @StudentID INT
AS
BEGIN
SET NOCOUNT ON;
    WITH Transactions AS
    (
        SELECT
            CAST(NULL AS DATE) AS TransDate,
            'Opening Balance' AS TransType,
            '' AS Reference,
            CAST(0 AS DECIMAL(10,2)) AS Debit,
            CAST(0 AS DECIMAL(10,2)) AS Credit,
            0 AS SortOrder

        UNION ALL

        SELECT
            CAST(i.IssueDate AS DATE),
            'Invoice',
            i.InvoiceNumber,
            i.TotalAmount,
            CAST(0 AS DECIMAL(10,2)),
            1
        FROM Invoice i
        WHERE i.StudentID = @StudentID

        UNION ALL

        SELECT
            CAST(p.PaymentDate AS DATE),
            'Payment',
            r.ReceiptNumber,
            CAST(0 AS DECIMAL(10,2)),
            p.Amount,
            2
        FROM Payment p
        JOIN Receipt r ON p.PaymentID = r.PaymentID
        WHERE p.StudentID = @StudentID
        AND p.Status = 'Completed'

        UNION ALL

        SELECT
            CAST(a.AdjustmentDate AS DATE),
            a.AdjustmentType,
            r.ReceiptNumber,
            CASE 
                WHEN a.AdjustmentType = 'Additional Charge' THEN a.Amount
                WHEN a.AdjustmentType = 'Correction' AND a.Amount > 0 THEN a.Amount
                ELSE 0
            END,
            CASE 
                WHEN a.AdjustmentType = 'Refund' THEN a.Amount
                WHEN a.AdjustmentType = 'Correction' AND a.Amount < 0 THEN ABS(a.Amount)
                ELSE 0
            END,
            3
        FROM AdjustmentNote a
        JOIN Payment p ON a.PaymentID = p.PaymentID
        JOIN Receipt r ON p.PaymentID = r.PaymentID
        WHERE p.StudentID = @StudentID
    )

    SELECT
        TransDate,
        TransType,
        Reference,
        Debit,
        Credit,

        SUM(Debit - Credit) OVER (
            ORDER BY TransDate, SortOrder, Reference
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS Balance,

        SUM(Debit)  OVER () AS TotalDebits,
        SUM(Credit) OVER () AS TotalCredits
    FROM Transactions
    ORDER BY TransDate, SortOrder, Reference
END
GO

-- Get Student Timetable --
CREATE OR ALTER PROCEDURE sp_GetStudentTimetable
    @StudentID INT,
    @SemesterID INT
AS
BEGIN
    SELECT
        c.CourseCode,
        c.CourseName,
        cs.DayOfWeek,
        CONVERT (VARCHAR(5), cs.StartTime, 108) AS StartTime,
        CONVERT (VARCHAR(5), cs.EndTime, 108) AS EndTime,
        cs.Venue,
        co.Lecturer
    FROM Enrollment e
    JOIN CourseOffering co ON e.OfferingID = co.OfferingID
    JOIN Course c ON co.CourseID = c.CourseID
    JOIN CourseSchedule cs ON co.OfferingID = cs.OfferingID
    WHERE e.StudentID = @StudentID
        AND co.SemesterID = @SemesterID
        AND e.Status = 'Enrolled'
    ORDER BY
        CASE cs.DayOfWeek
            WHEN 'Monday' THEN 1
            WHEN 'Tuesday' THEN 2
            WHEN 'Wednesday' THEN 3
            WHEN 'Thursday' THEN 4
            WHEN 'Friday' THEN 5
            WHEN 'Saturday' THEN 6
        END,
        cs.StartTime;

END
GO

-- Get Registration Summary --
CREATE OR ALTER PROCEDURE sp_GetRegistrationSummary
    @StudentID INT,
    @SemesterID INT
AS
BEGIN
    SELECT 
        COUNT(*) AS TotalSubjects,
        ISNULL(SUM(c.CreditHours),0) AS TotalCredits
    FROM Enrollment e
    INNER JOIN CourseOffering co ON e.OfferingID = co.OfferingID
    INNER JOIN Course c ON co.CourseID = c.CourseID
    WHERE e.StudentID = @StudentID
        AND co.SemesterID = @SemesterID
        AND e.Status = 'Enrolled';
END
GO

-- Check Time Clash --
CREATE OR ALTER PROCEDURE sp_CheckTimeClash
    @StudentID INT,
    @OfferingID INT
AS
BEGIN
    SELECT COUNT(*)
    FROM Enrollment e
    JOIN CourseSchedule cs1 ON e.OfferingID = cs1.OfferingID
    JOIN CourseSchedule cs2 ON cs2.OfferingID = @OfferingID
    WHERE e.StudentID = @StudentID
    AND cs1.DayOfWeek = cs2.DayofWeek
    AND (
        cs1.StartTime < cs2.EndTime
        AND cs1.EndTime > cs2.StartTime
    )
END
GO

IF NOT EXISTS (
    SELECT 1 FROM DatabaseVersion
    WHERE ScriptName = 'v3_04_CreateStatementProcedure.sql'
)
BEGIN
    INSERT INTO DatabaseVersion (ScriptName)
    VALUES ('v3_04_CreateStatementProcedure.sql');
END
GO