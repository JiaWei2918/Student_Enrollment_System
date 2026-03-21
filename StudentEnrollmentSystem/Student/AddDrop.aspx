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
            padding: 6px 12px;
            cursor: pointer;
        }

        .btnAdd:hover {
            background: #1e7e34;
        }

        .btnDrop {
            background: #dc3545;
            color: white;
            border: none;
            padding: 6px 12px;
            cursor: pointer;
        }

        .btnDrop:hover {
            background: #b52a37;
        }

        .message {
            margin-top: 15px;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <h2>Add / Drop Courses</h2>

        <h3>Current Semester: <asp:Label ID="lblSemester" runat="server" Font-Bold="true"></asp:Label></h3>
        <h4>Add Period: <asp:Label ID="lblAddPeriod" runat="server"></asp:Label></h4>
        <h4>Drop Period: <asp:Label ID="lblDropPeriod" runat="server"></asp:Label></h4>
        <br />
        <h2>Add Courses</h2>

        <asp:GridView ID="gvAvailable" runat="server" AutoGenerateColumns="False">
            <Columns>
                <asp:TemplateField>
                    <ItemTemplate>
                        <asp:CheckBox ID="chkAdd" runat="server" />
                        <asp:HiddenField ID="hfOfferingID" runat="server" Value='<%# Eval("OfferingID") %>' />
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:BoundField DataField="CourseCode" HeaderText="Course Code" />
                <asp:BoundField DataField="CourseName" HeaderText="Course Name" />
                <asp:BoundField DataField="Capacity" HeaderText="Capacity" />
                <asp:BoundField DataField="EnrolledCount" HeaderText="Enrolled" />
                <asp:BoundField DataField="SeatsLeft" HeaderText="Seats Left" />

            </Columns>
        </asp:GridView>

        <br />
        <asp:Button ID="btnAddSelected" runat="server"
            Text="Add Selected"
            CssClass="btnAdd" OnClick="btnAddSelected_Click" />

        <hr />

        <h2>Drop Courses</h2>
        <asp:GridView ID="gvMyCourses" runat="server" AutoGenerateColumns="False">

            <Columns>
                 <asp:TemplateField>
                     <ItemTemplate>
                         <asp:CheckBox ID="chkDrop" runat="server" />
                         <asp:HiddenField ID="hfOfferingID" runat="server" Value='<%# Eval("OfferingID") %>' />
                     </ItemTemplate>
                 </asp:TemplateField>

                <asp:BoundField DataField="CourseCode" HeaderText="Course Code" />
                <asp:BoundField DataField="CourseName" HeaderText="Course Name" />
                <asp:BoundField DataField="Status" HeaderText="Status" />
            </Columns>
        </asp:GridView>
        
        <br />

        <asp:Button ID="btnDropSelected" runat="server"
            Text="Drop Selected"
            CssClass="btnDrop"
            Onclick="btnDropSelected_Click"
            OnClientClick="return confirm('Are you sure you want to drop this course?');" />

        <br />

        <asp:Label ID="lblMessage" runat="server" CssClass="message"></asp:Label>
    </form>
</body>
</html>
