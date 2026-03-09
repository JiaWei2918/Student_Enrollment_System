<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddDropHistory.aspx.cs" Inherits="StudentEnrollmentSystem.Student.AddDropHistory" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Enrollment History</title>
</head>
<body>
    <form runat="server">
        <h2>My Enrollment History</h2>

        <asp:GridView ID="gvHistory" runat="server" AutoGenerateColumns="False">

        <Columns>

        <asp:BoundField DataField="CourseCode" HeaderText="Course Code" />
        <asp:BoundField DataField="CourseName" HeaderText="Course Name" />
        <asp:BoundField DataField="CreditHours" HeaderText="Credits" />
        <asp:BoundField DataField="SemesterName" HeaderText="Semester" />
        <asp:BoundField DataField="AcademicYear" HeaderText="Year" />
        <asp:BoundField DataField="Status" HeaderText="Status" />
        <asp:BoundField DataField="EnrollmentDate" HeaderText="Date" DataFormatString="{0:yyyy-MM-dd}" />

        </Columns>

        </asp:GridView>
    </form>
</body>
</html>
