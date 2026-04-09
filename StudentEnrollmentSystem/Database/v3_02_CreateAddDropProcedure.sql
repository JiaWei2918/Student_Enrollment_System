USE StudentEnrollmentSystem;
GO

CREATE OR ALTER PROCEDURE sp_AddDropBatch
    @StudentID INT,
    @OfferingIDs VARCHAR(MAX),
    @Action VARCHAR(10)
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
    DECLARE @AddEnd DATE
    DECLARE @DropEnd DATE
    DECLARE @MaxCredits INT
    DECLARE @CurrentCredits INT = 0

    SELECT TOP 1
        @SemesterID = s.SemesterID,
        @AddEnd = s.AddPeriodEnd,
        @DropEnd = s.DropPeriodEnd,
        @MaxCredits = s.MaxCredits
    FROM CourseOffering co
    JOIN Semester s ON co.SemesterID = s.SemesterID
    WHERE co.OfferingID IN (SELECT OfferingID FROM @tbl)

    SELECT @CurrentCredits = ISNULL(SUM(c.CreditHours),0)
    FROM Enrollment e
    JOIN CourseOffering co ON e.OfferingID = co.OfferingID
    JOIN Course c ON co.CourseID = c.CourseID
    WHERE e.StudentID = @StudentID
    AND e.Status = 'Enrolled'
    AND co.SemesterID = @SemesterID

    DECLARE @TotalAmount DECIMAL(10,2) = 0

    -------------------------------------------------
    -- ADD COURSES
    -------------------------------------------------
    IF @Action = 'ADD'
    BEGIN
        DECLARE @NewCredits INT = 0

        SELECT @NewCredits = SUM(c.CreditHours)
        FROM @tbl t
        JOIN CourseOffering co ON t.OfferingID = co.OfferingID
        JOIN Course c ON co.CourseID = c.CourseID

        IF (@CurrentCredits + ISNULL(@NewCredits,0)) > @MaxCredits
        BEGIN
            ROLLBACK
            SELECT 'CREDIT_LIMIT'
            RETURN
        END

        DECLARE @OfferingID INT

        DECLARE curAdd CURSOR FOR SELECT OfferingID FROM @tbl
        OPEN curAdd
        FETCH NEXT FROM curAdd INTO @OfferingID

        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF EXISTS (
                SELECT 1
                FROM CourseOffering co
                WHERE co.OfferingID = @OfferingID
                AND (
                    SELECT COUNT(*) FROM Enrollment
                    WHERE OfferingID = @OfferingID AND Status='Enrolled'
                ) >= co.Capacity
            )
            BEGIN
                ROLLBACK
                SELECT 'FULL'
                RETURN
            END

            IF EXISTS (
                SELECT 1 FROM Enrollment
                WHERE StudentID = @StudentID
                AND OfferingID = @OfferingID
                AND Status='Enrolled'
            )
            BEGIN
                FETCH NEXT FROM curAdd INTO @OfferingID
                CONTINUE
            END

            -- Late Add
            IF GETDATE() > @AddEnd
            BEGIN
                INSERT INTO AddDropHistory
                (StudentID, OfferingID, ActionType, RequestStatus)
                VALUES
                (@StudentID, @OfferingID, 'Add', 'Pending')

                FETCH NEXT FROM curAdd INTO @OfferingID
                CONTINUE
            END

            INSERT INTO Enrollment (StudentID, OfferingID, Status)
            VALUES (@StudentID, @OfferingID, 'Enrolled')

            INSERT INTO AddDropHistory
            (StudentID, OfferingID, ActionType, RequestStatus, ApprovedDate)
            VALUES
            (@StudentID, @OfferingID, 'Add', 'Approved', GETDATE())

            DECLARE @Fee DECIMAL(10,2)

            SELECT @Fee = ISNULL(c.Fee,0)
            FROM CourseOffering co
            JOIN Course c ON co.CourseID = c.CourseID
            WHERE co.OfferingID = @OfferingID

            SET @TotalAmount += @Fee

            FETCH NEXT FROM curAdd INTO @OfferingID
        END

        CLOSE curAdd
        DEALLOCATE curAdd
    END

    -------------------------------------------------
    -- DROP COURSES
    -------------------------------------------------
    ELSE IF @Action = 'DROP'
    BEGIN
        DECLARE @OfferingID2 INT

        DECLARE curDrop CURSOR FOR SELECT OfferingID FROM @tbl
        OPEN curDrop
        FETCH NEXT FROM curDrop INTO @OfferingID2

        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF GETDATE() > @DropEnd
            BEGIN
                INSERT INTO AddDropHistory
                (StudentID, OfferingID, ActionType, RequestStatus)
                VALUES
                (@StudentID, @OfferingID2, 'Drop', 'Pending')

                FETCH NEXT FROM curDrop INTO @OfferingID2
                CONTINUE
            END

            UPDATE Enrollment
            SET Status = 'Dropped'
            WHERE StudentID = @StudentID
            AND OfferingID = @OfferingID2
            AND Status = 'Enrolled'

            IF @@ROWCOUNT > 0
            BEGIN
                INSERT INTO AddDropHistory
                (StudentID, OfferingID, ActionType, RequestStatus, ApprovedDate)
                VALUES
                (@StudentID, @OfferingID2, 'Drop', 'Approved', GETDATE())

                DECLARE @Fee2 DECIMAL(10,2)

                SELECT @Fee2 = ISNULL(c.Fee,0)
                FROM CourseOffering co
                JOIN Course c ON co.CourseID = c.CourseID
                WHERE co.OfferingID = @OfferingID2

                SET @TotalAmount -= @Fee2
            END

            FETCH NEXT FROM curDrop INTO @OfferingID2
        END

        CLOSE curDrop
        DEALLOCATE curDrop
    END

    -------------------------------------------------
    -- INVOICE UPDATE
    -------------------------------------------------
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
    c.CreditHours,
    s.SemesterName,   
    co.Capacity,
    e.Status,
    e.EnrollmentDate AS EnrolledDate,
    COUNT(*) OVER() AS TotalEnrolled,
    SUM(c.CreditHours) OVER() AS TotalCredits
FROM Enrollment e
JOIN CourseOffering co ON e.OfferingID = co.OfferingID
JOIN Course c ON co.CourseID = c.CourseID
JOIN Semester s ON co.SemesterID = s.SemesterID
WHERE e.StudentID = @StudentID
AND s.Status = 'Active'
AND s.Status = 'Enrolled'

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