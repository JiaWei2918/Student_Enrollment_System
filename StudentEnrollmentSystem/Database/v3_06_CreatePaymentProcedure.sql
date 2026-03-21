USE StudentEnrollmentSystem;
GO

-- Get Student Invoices --
CREATE OR ALTER PROCEDURE sp_GetStudentInvoices
    @StudentID INT
AS
BEGIN
    SELECT 
        InvoiceID,
        InvoiceNumber,
        TotalAmount,
        Status,
        DueDate
    FROM Invoice
    WHERE StudentID = @StudentID
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

    IF @Random < 80
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

        IF (@Paid + @Amount = @Total)
        BEGIN
            UPDATE Invoice SET Status = 'Paid'
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
CREATE OR ALTER PROCEDURE sp_GetPaymentHistory
    @StudentID INT
AS
BEGIN
    SELECT 
        i.InvoiceNumber,
        p.Amount,
        p.PaymentMethod,
        p.Status,
        p.PaymentDate,
        r.ReceiptNumber
    FROM Payment p
    JOIN Invoice i ON p.InvoiceID = i.InvoiceID
    LEFT JOIN Receipt r ON p.PaymentID = r.PaymentID
    WHERE p.StudentID = @StudentID
    ORDER BY p.PaymentDate DESC
END
GO

-- Create or Update Invoices --
CREATE OR ALTER PROCEDURE sp_CreateOrUpdateInvoice
    @StudentID INT,
    @OfferingID INT,
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

IF NOT EXISTS (
    SELECT 1 FROM DatabaseVersion
    WHERE ScriptName = 'v3_06_CreatePaymentProcedure.sql'
)
BEGIN
    INSERT INTO DatabaseVersion (ScriptName)
    VALUES ('v3_06_CreatePaymentProcedure.sql');
END
GO