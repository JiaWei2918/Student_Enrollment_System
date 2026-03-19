<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TimetableMatching.aspx.cs" Inherits="StudentEnrollmentSystem.Student.TimetableMatching" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Tiemtable Matching</title>
</head>
<body>
    <form runat="server">
        <h2>🧠 Timetable Matching (No Clash)</h2>

        <asp:Label ID="lblMsg" runat="server" ForeColor="Red"></asp:Label>

        <br />

        Semester:
        <asp:DropDownList ID="ddlSemester" runat="server"></asp:DropDownList>

        <asp:Button ID="btnSearch" runat="server" Text="Find Available Courses"
            OnClick="btnSearch_Click" />

        <br /><br />

        <asp:GridView ID="gvCourses" runat="server" AutoGenerateColumns="False" 
            OnRowCommand="gvCourses_RowCommand" BorderWidth="1" GridLines="Both">

            <HeaderStyle BackColor="#2c3e50" ForeColor="White" />
            <RowStyle BackColor="#ecf0f1" />

            <Columns>
                <asp:BoundField DataField="CourseCode" HeaderText="Code" />
                <asp:BoundField DataField="CourseName" HeaderText="Course" />
                <asp:BoundField DataField="Schedule" HeaderText="Schedule" />
                <asp:BoundField DataField="Lecturer" HeaderText="Lecturer" />

                <asp:ButtonField Text="Enroll" CommandName="Enroll" ButtonType="Button" />
            </Columns>
        </asp:GridView>
    </form>
</body>
</html>
