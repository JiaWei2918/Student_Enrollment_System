USE StudentEnrollmentSystem;
GO

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DatabaseVersion')
AND NOT EXISTS (
    SELECT 1 FROM DatabaseVersion 
    WHERE ScriptName = 'v1_05_CreateEnrollmentTables.sql'
)
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        CREATE TABLE Enrollment (
            EnrollmentID INT IDENTITY(1,1) PRIMARY KEY,
            StudentID INT NOT NULL,
            OfferingID INT NOT NULL,
            EnrollmentDate DATETIME DEFAULT GETDATE(),
            Status VARCHAR(20) CHECK (Status IN ('Enrolled','Dropped','Completed','Withdrawn')) DEFAULT 'Enrolled',
            Grade VARCHAR(2) NULL,
            GradePoints DECIMAL(3,2) NULL,

            FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
            FOREIGN KEY (OfferingID) REFERENCES CourseOffering(OfferingID),

            CONSTRAINT UQ_Enrollment UNIQUE (StudentID, OfferingID)
        );

        CREATE TABLE AddDropHistory (
            HistoryID INT IDENTITY(1,1) PRIMARY KEY,
            StudentID INT NOT NULL,
            OfferingID INT NOT NULL,
            ActionType VARCHAR(10) CHECK (ActionType IN ('Add','Drop')) NOT NULL,
            ActionDate DATETIME DEFAULT GETDATE(),
            Reason TEXT NULL,
            RequestStatus VARCHAR(15) CHECK (RequestStatus IN ('Pending', 'Approved', 'Rejected')) DEFAULT 'Pending',
            ApprovedBy INT NULL,
            ApprovedDate DATETIME NULL,

            FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
            FOREIGN KEY (OfferingID) REFERENCES CourseOffering(OfferingID),
            FOREIGN KEY (ApprovedBy) REFERENCES Administrator(AdminID)
        );

        INSERT INTO DatabaseVersion (ScriptName)
        VALUES ('v1_05_CreateEnrollmentTables.sql');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO