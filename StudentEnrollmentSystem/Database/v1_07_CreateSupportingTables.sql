USE StudentEnrollmentSystem;
GO

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DatabaseVersion')
AND NOT EXISTS (
    SELECT 1 FROM DatabaseVersion 
    WHERE ScriptName = 'v1_07_CreateSupportingTables.sql'
)
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        CREATE TABLE EnrollmentRule (
            RuleID INT IDENTITY(1,1) PRIMARY KEY,
            RuleType VARCHAR(30) CHECK (RuleType IN ('Max Credits','Prerequisite Check','Add Period','Drop Period')),
            RuleValue VARCHAR(100) NOT NULL,
            SemesterID INT NOT NULL,
            CreatedBy INT NOT NULL,
            CreatedDate DATETIME DEFAULT GETDATE(),

            FOREIGN KEY (SemesterID) REFERENCES Semester(SemesterID),
            FOREIGN KEY (CreatedBy) REFERENCES Administrator(AdminID)
        );

        CREATE TABLE StudentProfile (
            ProfileID INT IDENTITY(1,1) PRIMARY KEY,
            StudentID INT UNIQUE NOT NULL,
            Address VARCHAR(255),
            DateOfBirth DATE,
            Nationality VARCHAR(50),
            CreatedAt DATETIME2 DEFAULT SYSDATETIME(),
            UpdatedAt DATETIME2 DEFAULT SYSDATETIME()

            FOREIGN KEY (StudentID) REFERENCES Student(StudentID)
        );

        CREATE TABLE BankDetail (
            BankDetailID INT IDENTITY(1,1) PRIMARY KEY,
            StudentID INT NOT NULL,
            BankName VARCHAR(100) NOT NULL,
            AccountNumber VARCHAR(50) NOT NULL,
            AccountHolderName VARCHAR(100) NOT NULL,
            AccountType VARCHAR(20),
            IsPrimary BIT DEFAULT 0,
            AddedDate DATETIME DEFAULT GETDATE(),

            FOREIGN KEY (StudentID) REFERENCES Student(StudentID)
        );

        CREATE TABLE Enquiry (
            EnquiryID INT IDENTITY(1,1) PRIMARY KEY,
            StudentID INT NOT NULL,
            Subject VARCHAR(100) NOT NULL,
            Message NVARCHAR(MAX) NOT NULL,
            CreatedAt DATETIME DEFAULT GETDATE(),
            Status VARCHAR(20) CHECK (Status IN ('Pending','In Progress','Resolved','Closed')) DEFAULT 'Pending',
            Response NVARCHAR(MAX) NULL,
            RespondedBy INT NULL,
            ResponseDate DATETIME NULL,

            FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
            FOREIGN KEY (RespondedBy) REFERENCES Administrator(AdminID)
        );

        CREATE TABLE TeachingEvaluation (
            EvaluationID INT IDENTITY(1,1) PRIMARY KEY,
            StudentID INT NOT NULL,
            OfferingID INT NOT NULL,
            Rating INT CHECK (Rating BETWEEN 1 AND 5) NOT NULL,
            LecturerRating INT CHECK (LecturerRating BETWEEN 1 AND 5),
            CourseRating INT CHECK (CourseRating BETWEEN 1 AND 5),
            Comment NVARCHAR(MAX),
            SubmittedAt DATETIME DEFAULT GETDATE(),
            IsAnonymous BIT DEFAULT 0,

            FOREIGN KEY (StudentID) REFERENCES Student(StudentID)
        );

        INSERT INTO DatabaseVersion (ScriptName)
        VALUES ('v1_07_CreateSupportingTables.sql');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO