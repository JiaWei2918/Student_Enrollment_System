<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddDrop.aspx.cs" Inherits="StudentEnrollmentSystem.Student.AddDrop" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Add / Drop Course</title>

    <style>
        body {
            font-family: Arial;
            margin: 40px;
        }

        h2 {
            color: #333;
        }

        .btnAdd {
            background: #28a745;
            color: white;
            border: none;
            padding: 5px 10px;
            cursor: pointer;
        }

        .btnAdd:hover {
            background: #1e7e34;
        }

        .btnDrop {
            background: #dc3545;
            color: white;
            border: none;
            padding: 5px 10px;
            cursor: pointer;
        }

        .btnDrop:hover {
            background: #b52a37;
        }

        .status {
            font-weight: bold;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <h3>Current Semester: <asp:Label ID="lblSemester" runat="server" Font-Bold="true"></asp:Label></h3>
        <h4>Add Period: <asp:Label ID="lblAddPeriod" runat="server"></asp:Label></h4>
        <h4>Drop Period: <asp:Label ID="lblDropPeriod" runat="server"></asp:Label></h4>
        <br /><br />
        <h2>Add Courses</h2>

        <asp:GridView ID="gvAvailable" runat="server" AutoGenerateColumns="False"
            OnRowCommand="gvAvailable_RowCommand"
            OnRowDataBound="gvAvailable_RowDataBound">
            <Columns>
                <asp:BoundField DataField="CourseCode" HeaderText="Course Code" />
                <asp:BoundField DataField="CourseName" HeaderText="Course Name" />
                <asp:BoundField DataField="Capacity" HeaderText="Capacity" />
                <asp:BoundField DataField="EnrolledCount" HeaderText="Enrolled" />
                <asp:BoundField DataField="SeatsLeft" HeaderText="Seats Left" />

                <asp:TemplateField>
                    <ItemTemplate>
                        <asp:Button
                            ID="btnAdd"
                            runat="server"
                            Text="Add"
                            CssClass="btnAdd"
                            CommandName="AddCourse"
                            CommandArgument='<%# Eval("OfferingID") %>' />
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>

        <br /><br />

        <h2>Drop Courses</h2>
        <asp:GridView ID="gvMyCourses" runat="server" AutoGenerateColumns="False"
            OnRowCommand="gvMyCourses_RowCommand">

            <Columns>
                <asp:BoundField DataField="CourseCode" HeaderText="Course Code" />
                <asp:BoundField DataField="CourseName" HeaderText="Course Name" />
                <asp:BoundField DataField="Status" HeaderText="Status" />
                <asp:TemplateField HeaderText="Action">
                    <ItemTemplate>
                        <asp:Button
                            ID="btnDrop"
                            runat="server"
                            Text="Drop"
                            CssClass="btnDrop"
                            CommandName="DropCourse"
                            CommandArgument='<%# Eval("OfferingID") %>'
                            OnClientClick="return confirm('Are you sure you want to drop this course?');"
                            Visible='<%# Eval("Status").ToString() == "Enrolled" %>' />
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>

        <br />

        <asp:Label ID="lblMessage" runat="server"></asp:Label>
    </form>
</body>
</html>
