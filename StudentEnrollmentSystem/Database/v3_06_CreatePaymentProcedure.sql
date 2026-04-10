USE StudentEnrollmentSystem;
GO

-- Get Student Invoices --
CREATE OR ALTER PROCEDURE sp_GetStudentInvoices
    @StudentID INT
AS
BEGIN
SET NOCOUNT ON;
    WITH InvoiceBase AS
    (
        SELECT 
            i.InvoiceID,
            i.InvoiceNumber,
            i.IssueDate,
            i.DueDate,
            i.TotalAmount,
            ISNULL(SUM(p.Amount), 0) AS PaidAmount,
            i.TotalAmount - ISNULL(SUM(p.Amount), 0) AS Balance,
            i.Status
        FROM Invoice i
        LEFT JOIN Payment p
            ON i.InvoiceID = p.InvoiceID
            AND p.Status = 'Completed'
        WHERE i.StudentID = @StudentID
        GROUP BY
            i.InvoiceID, i.InvoiceNumber, i.IssueDate,
            i.DueDate, i.TotalAmount, i.Status
    )

    SELECT 
        InvoiceID,
        InvoiceNumber,
        IssueDate,
        DueDate,
        TotalAmount,
        PaidAmount,
        Balance,
        Status,
        SUM(
            CASE WHEN Status IN ('Issued', 'Partial', 'Overdue')
                THEN Balance ELSE 0
            END
        ) OVER() AS TotalOutstanding
    FROM InvoiceBase
    ORDER BY IssueDate DESC
END
GO

-- Make Payment --
CREATE OR ALTER PROCEDURE sp_MakePayment
    @InvoiceID INT,
    @StudentID INT,
    @Amount DECIMAL(10,2),
    @PaymentMethod VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Total DECIMAL(10,2);
    DECLARE @Paid DECIMAL(10,2);

    SELECT @Total = TotalAmount
    FROM Invoice WHERE InvoiceID = @InvoiceID;

    SELECT @Paid = ISNULL(SUM(Amount),0)
    FROM Payment WHERE InvoiceID = @InvoiceID AND Status = 'Completed';

    IF (@Paid + @Amount > @Total)
    BEGIN
        SELECT 'OVERPAY';
        RETURN;
    END

    BEGIN TRANSACTION;

    DECLARE @Random INT = ABS(CHECKSUM(NEWID())) % 100
    DECLARE @Status VARCHAR(20)

    IF @Random < 85
        SET @Status = 'Completed'
    ELSE
        SET @Status = 'Failed'

    DECLARE @PaymentID INT

    INSERT INTO Payment
    (InvoiceID, StudentID, Amount, PaymentMethod, Status, TransactionID)
    VALUES
    (@InvoiceID, @StudentID, @Amount, @PaymentMethod, @Status, NEWID());

    SET @PaymentID = SCOPE_IDENTITY();

    IF @Status = 'Completed'
    BEGIN
        INSERT INTO Receipt
        (PaymentID, ReceiptNumber, Amount, PaymentDetails)
        VALUES
        (@PaymentID, 'RCPT-' + FORMAT(GETDATE(), 'yyyyMMddHHmmss'), @Amount, @PaymentMethod);

        SET @Paid = @Paid + @Amount

        IF @Paid = @Total
        BEGIN
            UPDATE Invoice SET Status = 'Paid'
            WHERE InvoiceID = @InvoiceID;
        END
        ELSE IF @Paid < @Total
        BEGIN
            UPDATE Invoice
            SET Status = 'Issued'
            WHERE InvoiceID = @InvoiceID;
        END
    END

    COMMIT;

    IF @Status = 'Completed'
        SELECT 'SUCCESS'
    ELSE
        SELECT 'FAILED'

END
GO

-- Get Student Payment History --
CREATE OR ALTER PROCEDURE sp_GetStudentPaymentHistory
    @StudentID INT
AS
BEGIN
    SELECT 
        p.PaymentID,
        i.InvoiceNumber,
        p.Amount,
        p.PaymentMethod,
        p.Status,
        p.PaymentDate,
        COUNT(*) OVER() AS TotalPayments,
        SUM(p.Amount) OVER() AS TotalPaid,
        SUM(CASE WHEN YEAR(p.PaymentDate) = YEAR(GETDATE())
                THEN 1 ELSE 0 END) OVER() AS YearPayments
    FROM Payment p
    JOIN Invoice i ON p.InvoiceID = i.InvoiceID
    WHERE p.StudentID = @StudentID
    AND p.Status = 'Completed'
    ORDER BY p.PaymentDate DESC
END
GO

-- Get Student Receipt --
CREATE OR ALTER PROCEDURE sp_GetReceiptDetails
    @PaymentID INT
AS
BEGIN
    SELECT 
        r.ReceiptNumber,
        i.InvoiceNumber,
        p.Amount,
        p.PaymentMethod,
        p.PaymentDate,
        p.TransactionID
    FROM Receipt r
    JOIN Payment p ON r.PaymentID = p.PaymentID
    JOIN Invoice i ON p.InvoiceID = i.InvoiceID
    WHERE p.PaymentID = @PaymentID
    AND p.Status = 'Completed'
END
GO

-- Create or Update Invoices --
CREATE OR ALTER PROCEDURE sp_CreateOrUpdateInvoice
    @StudentID INT,
    @SemesterID INT,
    @CourseFee DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @InvoiceID INT;

    SELECT @InvoiceID = InvoiceID
    FROM Invoice
    WHERE StudentID = @StudentID
    AND SemesterID = @SemesterID
    AND Status IN ('Draft','Issued');

    IF @InvoiceID IS NULL
    BEGIN
        INSERT INTO Invoice
        (
            InvoiceNumber,
            StudentID,
            SemesterID,
            IssueDate,
            DueDate,
            TotalAmount,
            Status
        )
        VALUES
        (
            'INV-' + FORMAT(GETDATE(),'yyyyMMddHHmmss'),
            @StudentID,
            @SemesterID,
            GETDATE(),
            DATEADD(DAY, 14, GETDATE()),
            @CourseFee,
            'Issued'
        );
    END
    ELSE
    BEGIN
        UPDATE Invoice
        SET TotalAmount = TotalAmount + @CourseFee
        WHERE InvoiceID = @InvoiceID;
    END
END
GO

-- Get Student Adjustment --
CREATE OR ALTER PROCEDURE sp_GetStudentAdjustmentHistory
    @StudentID INT
AS
BEGIN
    SELECT 
        r.ReceiptNumber,
        a.AdjustmentType,
        CASE
            WHEN a.AdjustmentType = 'Refund'
                THEN -a.Amount
            ELSE a.Amount
        END AS Amount,
        a.Reason,
        a.AdjustmentDate,
        ad.FullName AS ApprovedByName
    FROM AdjustmentNote a
    JOIN Payment p ON a.PaymentID = p.PaymentID
    JOIN Receipt r ON p.PaymentID = r.PaymentID
    JOIN Administrator ad ON a.ApprovedBy = ad.AdminID
    WHERE p.StudentID = @StudentID
    ORDER BY a.AdjustmentDate DESC
END
GO

IF NOT EXISTS (
    SELECT 1 FROM DatabaseVersion
    WHERE ScriptName = 'v3_06_CreatePaymentProcedure.sql'
)
BEGIN
    INSERT INTO DatabaseVersion (ScriptName)
    VALUES ('v3_06_CreatePaymentProcedure.sql');
END
GO