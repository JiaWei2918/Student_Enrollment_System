<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="StudentEnrollmentSystem.Admin.Dashboard" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Dashboard</title>
</head>
<body>
    <form id="form1" runat="server">
        <h2>Admin Dashboard</h2>

        <asp:Label ID="lblWelcome" runat="server"
            Font-Bold="true" Font-Size="Large"></asp:Label>

        <hr />

        <h3>System Overview</h3>
        <table border="1" cellpadding="10">
            <tr>
                <td>Total Students</td>
                <td><asp:Label ID="lblTotalStudents" runat="server" /></td>
            </tr>
            <tr>
                <td>Total Courses</td>
                <td><asp:Label ID="lblTotalCourses" runat="server" /></td>
            </tr>
            <tr>
                <td>Total Semesters</td>
                <td><asp:Label ID="lblTotalSemesters" runat="server" /></td>
            </tr>
            <tr>
                <td>Total Offerings</td>
                <td><asp:Label ID="lblTotalOfferings" runat="server" /></td>
            </tr>
        </table>

        <hr />

        <h3>Quick Management</h3>
        <asp:HyperLink ID="lnkSemester" runat="server"
            NavigateUrl="~/Admin/ManageSemester.aspx">
            Manage Semester
        </asp:HyperLink><br /><br />

        <asp:HyperLink ID="lnkCourse" runat="server"
            NavigateUrl="~/Admin/ManageCourse.aspx">
            Manage Course
        </asp:HyperLink><br /><br />

        <asp:HyperLink ID="lnkOffering" runat="server"
            NavigateUrl="~/Admin/ManageCourseOffering.aspx">
            Manage Course Offering
        </asp:HyperLink><br /><br />

         <asp:HyperLink ID="lnkStudent" runat="server"
             NavigateUrl="~/Admin/ManageStudent.aspx">
             Manage Students
         </asp:HyperLink><br /><br />

        <asp:Button ID="btnLogout" runat="server"
            Text="Logout"
            OnClick="btnLogout_Click" />
    </form>
</body>
</html>
