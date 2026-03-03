USE StudentEnrollmentSystem;
GO

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DatabaseVersion')
AND NOT EXISTS (
    SELECT 1 FROM DatabaseVersion 
    WHERE ScriptName = 'v1_04_CreateAcademicTables.sql'
)
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        CREATE TABLE Semester (
            SemesterID INT IDENTITY(1,1) PRIMARY KEY,
            SemesterName VARCHAR(50) NOT NULL,
            AcademicYear INT NOT NULL,
            StartDate DATE NOT NULL,
            EndDate DATE NOT NULL,
            AddPeriodStart DATE,
            AddPeriodEnd DATE,
            DropPeriodStart DATE,
            DropPeriodEnd DATE,
            Status VARCHAR(20) CHECK (Status IN ('Active', 'Closed', 'Planning')) DEFAULT 'Planning',
            MaxCredits INT DEFAULT 18
        );

        CREATE TABLE Course (
            CourseID INT IDENTITY(1,1) PRIMARY KEY,
            CourseCode VARCHAR(20) UNIQUE NOT NULL,
            CourseName VARCHAR(100) NOT NULL,
            Description TEXT,
            CreditHours INT NOT NULL,
            PrerequisiteCourseID INT NULL,

            CONSTRAINT FK_Course_Prerequisite
            FOREIGN KEY (PrerequisiteCourseID) REFERENCES Course(CourseID)
        );

        CREATE TABLE CourseOffering (
            OfferingID INT IDENTITY(1,1) PRIMARY KEY,
            CourseID INT NOT NULL,
            SemesterID INT NOT NULL,
            Lecturer VARCHAR(100),
            Capacity INT NOT NULL CHECK (Capacity > 0),
            AvailableSeats INT NOT NULL CHECK (AvailableSeats BETWEEN 0 AND Capacity),
            Status VARCHAR(20) CHECK (Status IN ('Open', 'Full', 'Cancelled')) DEFAULT 'Open',

            FOREIGN KEY (CourseID) REFERENCES Course(CourseID),
            FOREIGN KEY (SemesterID) REFERENCES Semester(SemesterID),

            CONSTRAINT UQ_CourseOffering UNIQUE (CourseID, SemesterID)
        );

        CREATE TABLE CourseSchedule (
            ScheduleID INT IDENTITY(1,1) PRIMARY KEY,
            OfferingID INT NOT NULL,
            DayOfWeek VARCHAR(10) CHECK (DayOfWeek IN ('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday')),
            StartTime TIME NOT NULL,
            EndTime TIME NOT NULL,
            Venue VARCHAR(50),

            FOREIGN KEY (OfferingID) REFERENCES CourseOffering(OfferingID)
        );

        INSERT INTO DatabaseVersion (ScriptName)
        VALUES ('v1_04_CreateAcademicTables.sql');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO