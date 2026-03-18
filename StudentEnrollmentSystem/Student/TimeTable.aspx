<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TimeTable.aspx.cs" Inherits="StudentEnrollmentSystem.Student.TimeTable" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Timetable & Registration Summary</title>

    <style>
        .card {
            border: 1px solid #ddd;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 15px;
        }

        .grid-cell {
            padding: 5px;
            border-radius: 5px;
            background: #e3f2fd;
        }
    </style>
</head>
<body>
    <form runat="server">
        <h2>📅 Registration Summary & Timetable</h2>

        <asp:Label ID="lblMessage" runat="server" ForeColor="Red"></asp:Label>

        <br />

        Semester:
        <asp:DropDownList ID="ddlSemester" runat="server" 
            AutoPostBack="true" OnSelectedIndexChanged="ddlSemester_SelectedIndexChanged">
        </asp:DropDownList>

        <asp:Button ID="btnExport" runat="server" Text="Export PDF" 
            Onclick="btnExport_Click" />

        <br /><br />

        <asp:Panel ID="pnlSummary" runat="server" Visible="false" CssClass="card">
            <h3>Summary</h3>
            <asp:Label ID="lblSummary" runat="server" Font-Bold="true"></asp:Label>
        </asp:Panel>

        <asp:Panel ID="pnlTimetable" runat="server" Visible="false" CssClass="card">
            <h3>Timetable (List)</h3>

            <asp:GridView ID="gvTimetable" runat="server" AutoGenerateColumns="False" BorderWidth="1">
                <Columns>
                    <asp:BoundField DataField="CourseCode" HeaderText="Code" />
                    <asp:BoundField DataField="CourseName" HeaderText="Course" />
                    <asp:BoundField DataField="DayOfWeek" HeaderText="Day" />
                    <asp:BoundField DataField="StartTime" HeaderText="Start" />
                    <asp:BoundField DataField="EndTime" HeaderText="End" />
                    <asp:BoundField DataField="Venue" HeaderText="Venue" />
                    <asp:BoundField DataField="Lecturer" HeaderText="Lecturer" />
                </Columns>
            </asp:GridView>
        </asp:Panel>

        <asp:Panel ID="pnlGrid" runat="server" Visible="false" CssClass="card">
            <h3>Weekly Timetable</h3>

            <asp:GridView ID="gvGrid" runat="server" AutoGenerateColumns="False" BorderWidth="1">
                <Columns>
                    <asp:BoundField DataField="TimeSlot" HeaderText="Time" />
                    <asp:BoundField DataField="Monday" HeaderText="Monday" HtmlEncode="false" />
                    <asp:BoundField DataField="Tuesday" HeaderText="Tuesday" HtmlEncode="false" />
                    <asp:BoundField DataField="Wednesday" HeaderText="Wednesday" HtmlEncode="false" />
                    <asp:BoundField DataField="Thursday" HeaderText="Thursday" HtmlEncode="false" />
                    <asp:BoundField DataField="Friday" HeaderText="Friday" HtmlEncode="false" />
                    <asp:BoundField DataField="Saturday" HeaderText="Saturday" HtmlEncode="false" />
                </Columns>
            </asp:GridView>
        </asp:Panel>
    </form>
</body>
</html>
