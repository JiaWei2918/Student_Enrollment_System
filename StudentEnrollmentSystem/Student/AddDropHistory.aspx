<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddDropHistory.aspx.cs" Inherits="StudentEnrollmentSystem.Student.AddDropHistory" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Stuent Add / Drop History</title>
</head>
<body>
    <form runat="server">
        <h2>My Add / Drop History</h2>

        <asp:Label ID="lblMessage" runat="server" ForeColor="Red"></asp:Label>

        <asp:GridView ID="gvHistory" runat="server" AutoGenerateColumns="False" BorderWidth="1"
                      BorderColor="#ccc" GridLines="Both" CellPading="6" EmptyDataText="No Add/Drop history found.">
        <Columns>
            <asp:BoundField DataField="CourseCode" HeaderText="Course Code" />
            <asp:BoundField DataField="CourseName" HeaderText="Course Name" />
            <asp:BoundField DataField="CreditHours" HeaderText="Credits" />
            <asp:BoundField DataField="SemesterName" HeaderText="Semester" />
            <asp:BoundField DataField="AcademicYear" HeaderText="Year" />

            <asp:BoundField DataField="ActionType" HeaderText="Action" />
            <asp:BoundField DataField="ActionDate" HeaderText="Request Date"
                            DataFormatString="{0:yyyy-MM-dd HH:mm}" 
                            NullDisplayText="-" />

            <asp:BoundField DataField="RequestStatus" HeaderText="Status" />
            <asp:BoundField DataField="ApprovedByName" HeaderText="Approved By" 
                            NullDisplayText="-" />

            <asp:BoundField DataField="ApprovedDate" HeaderText="Approved Date"
                            DataFormatString="{0:yyyy-MM-dd HH:mm}" />
        </Columns>
        </asp:GridView>
    </form>
</body>
</html>
