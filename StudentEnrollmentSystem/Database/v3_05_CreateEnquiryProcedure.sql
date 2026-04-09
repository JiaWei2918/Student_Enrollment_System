USE StudentEnrollmentSystem;
GO

-- Insert Student Enquiry --
CREATE OR ALTER PROCEDURE sp_InsertEnquiry
    @StudentID INT,
    @Subject NVARCHAR(100),
    @Message NVARCHAR(MAX)
AS
BEGIN
    INSERT INTO Enquiry (StudentID, Subject, Message)
    VALUES (@StudentID, @Subject, @Message);
END
GO

-- Get Student Enquiry --
CREATE OR ALTER PROCEDURE sp_GetStudentEnquiries
    @StudentID INT
AS
BEGIN
    SELECT 
        Subject,
        Message,
        Status,
        ISNULL(Response, '-') AS Response,
        FORMAT(CreatedAt, 'yyyy-MM-dd HH:mm') AS CreatedAt
    FROM Enquiry
    WHERE StudentID = @StudentID
    ORDER BY CreatedAt DESC;
END
GO

-- Duplicate Checking --
CREATE OR ALTER PROCEDURE sp_CheckDuplicateEnquiry
    @StudentID INT,
    @Message NVARCHAR(MAX)
AS
BEGIN
    SELECT COUNT(*) 
    FROM Enquiry
    WHERE StudentID = @StudentID
    AND Message = @Message
    AND DATEDIFF(MINUTE, CreatedAt, GETDATE()) < 5
END
GO

-- Get AvailableCourse with No Clash --
CREATE OR ALTER PROCEDURE sp_GetAvailableCourses_NoClash
    @StudentID INT,
    @SemesterID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        co.OfferingID,
        c.CourseCode,
        c.CourseName,
        co.Lecturer,

        STRING_AGG(
            RTRIM(cs.DayOfWeek) + ' ' + 
            CONVERT(VARCHAR(5), cs.StartTime, 108) + '-' +
            CONVERT(VARCHAR(5), cs.EndTime, 108),
            ', '
        ) AS Schedule,
        
        MIN(cs.StartTime) AS SortTime,
        COUNT(*) OVER() AS TotalAvailable
    FROM CourseOffering co
    INNER JOIN Course c ON co.CourseID = c.CourseID
    INNER JOIN CourseSchedule cs ON co.OfferingID = cs.OfferingID

    WHERE co.SemesterID = @SemesterID
    AND co.Status = 'Open'

    AND co.OfferingID NOT IN (
        SELECT OfferingID FROM Enrollment
        WHERE StudentID = @StudentID
        AND Status = 'Enrolled'
    )

    AND co.OfferingID IN (
        SELECT co2.OfferingID
        FROM CourseOffering co2
        LEFT JOIN Enrollment e2
            ON co2.OfferingID = e2.OfferingID AND e2.Status = 'Enrolled'
        GROUP BY co2.OfferingID, co2.Capacity
        HAVING COUNT(e2.EnrollmentID) < co2.Capacity
    )

    AND NOT EXISTS (
        SELECT 1
        FROM Enrollment e
        INNER JOIN CourseSchedule cs2 ON e.OfferingID = cs2.OfferingID
        WHERE e.StudentID = @StudentID
        AND e.Status = 'Enrolled'
        AND cs2.DayOfWeek = cs.DayOfWeek
        AND (
            cs2.StartTime < cs.EndTime
            AND cs2.EndTime > cs.StartTime
        )
    )

    GROUP BY co.OfferingID, c.CourseCode, c.CourseName, co.Lecturer
    ORDER BY SortTime;
END
GO

-- Get Enrolled Courses --
CREATE OR ALTER PROCEDURE sp_GetEnrolledCourses
    @StudentID INT,
    @SemesterID INT
AS
BEGIN
    SELECT 
        co.OfferingID,
        c.CourseCode
    FROM Enrollment e
    JOIN CourseOffering co ON e.OfferingID = co.OfferingID
    JOIN Course c ON co.CourseID = c.CourseID
    WHERE e.StudentID = @StudentID
    AND co.SemesterID = @SemesterID
    AND e.Status = 'Enrolled'

    AND co.OfferingID NOT IN (
        SELECT OfferingID FROM TeachingEvaluation
        WHERE StudentID = @StudentID
    )
END
GO

-- Submit Evaluation --
CREATE OR ALTER PROCEDURE sp_SubmitEvaluation
    @StudentID INT,
    @OfferingID INT,
    @Rating INT,
    @LecturerRating INT = NULL,
    @CourseRating INT = NULL,
    @Comment NVARCHAR(MAX),
    @IsAnonymous BIT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM Enrollment
        WHERE StudentID = @StudentID
        AND OfferingID = @OfferingID
        AND Status = 'Enrolled'
    )
    BEGIN
        SELECT 'NOT_ENROLLED'
        RETURN
    END

    IF EXISTS (
        SELECT 1 FROM TeachingEvaluation
        WHERE StudentID = @StudentID
        AND OfferingID = @OfferingID
    )
    BEGIN
        SELECT 'EXISTS'
        RETURN
    END

    INSERT INTO TeachingEvaluation
    (StudentID, OfferingID, Rating, LecturerRating, CourseRating, Comment, IsAnonymous)
    VALUES
    (@StudentID, @OfferingID, @Rating, @LecturerRating, @CourseRating, @Comment, @IsAnonymous);

    SELECT 'SUCCESS'
END
GO

-- Get Student Evaluations --
CREATE OR ALTER PROCEDURE sp_GetMyEvaluations
    @StudentID INT
AS
BEGIN
    SELECT 
        c.CourseCode,
        te.Rating,
        te.LecturerRating,
        te.CourseRating,
        te.Comment,
        te.SubmittedAt
    FROM TeachingEvaluation te
    JOIN CourseOffering co ON te.OfferingID = co.OfferingID
    JOIN Course c ON co.CourseID = c.CourseID
    WHERE te.StudentID = @StudentID
    ORDER BY te.SubmittedAt DESC
END
GO

IF NOT EXISTS (
    SELECT 1 FROM DatabaseVersion
    WHERE ScriptName = 'v3_05_CreateEnquiryProcedure.sql'
)
BEGIN
    INSERT INTO DatabaseVersion (ScriptName)
    VALUES ('v3_05_CreateEnquiryProcedure.sql');
END
GO