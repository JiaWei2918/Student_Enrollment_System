USE StudentEnrollmentSystem;
GO

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DatabaseVersion')
AND NOT EXISTS (
    SELECT 1 FROM DatabaseVersion 
    WHERE ScriptName = 'v1_06_CreateFinanceTables.sql'
)
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        CREATE TABLE Invoice (
            InvoiceID INT IDENTITY(1,1) PRIMARY KEY,
            InvoiceNumber VARCHAR(50) UNIQUE NOT NULL,
            StudentID INT NOT NULL,
            SemesterID INT NOT NULL,
            IssueDate DATE NOT NULL,
            DueDate DATE NOT NULL,
            TotalAmount DECIMAL(10,2) NOT NULL,
            Description TEXT,
            Status VARCHAR(20) CHECK (Status IN ('Draft','Issued','Paid','Overdue','Cancelled')) DEFAULT 'Draft',

            FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
            FOREIGN KEY (SemesterID) REFERENCES Semester(SemesterID)
        );

        CREATE TABLE Payment (
            PaymentID INT IDENTITY(1,1) PRIMARY KEY,
            InvoiceID INT NOT NULL,
            StudentID INT NOT NULL,
            Amount DECIMAL(10,2) NOT NULL,
            PaymentDate DATETIME DEFAULT GETDATE(),
            PaymentMethod VARCHAR(20) CHECK (PaymentMethod IN ('Credit Card','Online Banking','Bank Transfer')),
            Status VARCHAR(20) CHECK (Status IN ('Pending','Completed','Failed','Refunded')) DEFAULT 'Pending',
            TransactionID VARCHAR(100) UNIQUE NULL,
            PaymentGatewayRef VARCHAR(100) NULL,

            FOREIGN KEY (InvoiceID) REFERENCES Invoice(InvoiceID),
            FOREIGN KEY (StudentID) REFERENCES Student(StudentID)
        );

        CREATE TABLE Receipt (
            ReceiptID INT IDENTITY(1,1) PRIMARY KEY,
            PaymentID INT UNIQUE NOT NULL,
            ReceiptNumber VARCHAR(50) UNIQUE NOT NULL,
            IssueDate DATETIME DEFAULT GETDATE(),
            Amount DECIMAL(10,2) NOT NULL,
            PaymentDetails TEXT,

            FOREIGN KEY (PaymentID) REFERENCES Payment(PaymentID)
        );

        CREATE TABLE AdjustmentNote (
            AdjustmentID INT IDENTITY(1,1) PRIMARY KEY,
            PaymentID INT NOT NULL,
            AdjustmentType VARCHAR(20) CHECK (AdjustmentType IN ('Refund','Additional Charge','Correction')),
            Amount DECIMAL(10,2) NOT NULL,
            Reason TEXT,
            AdjustmentDate DATETIME DEFAULT GETDATE(),
            ApprovedBy INT NOT NULL,

            FOREIGN KEY (PaymentID) REFERENCES Payment(PaymentID),
            FOREIGN KEY (ApprovedBy) REFERENCES Administrator(AdminID)
        );

        INSERT INTO DatabaseVersion (ScriptName)
        VALUES ('v1_06_CreateFinanceTables.sql');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO