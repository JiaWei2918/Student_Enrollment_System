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

IF NOT EXISTS (
    SELECT 1 FROM DatabaseVersion
    WHERE ScriptName = 'v3_05_CreateEnquiryProcedure.sql'
)
BEGIN
    INSERT INTO DatabaseVersion (ScriptName)
    VALUES ('v3_05_CreateEnquiryProcedure.sql');
END
GO