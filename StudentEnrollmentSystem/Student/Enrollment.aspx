<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Enrollment.aspx.cs" Inherits="StudentEnrollmentSystem.Student.Enrollment" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Course Enrollment</title>

    <style>
        body{
            font-family: Arial;
            margin:40px;
        }

        h2{
            color:#333;
        }

        .grid{
            margin-top:20px;
        }

        .btn{
            padding:6px 12px;
            background-color:#007bff;
            color:white;
            border:none;
            cursor:pointer;
        }

        .btn:hover{
            background-color:#0056b3;
        }

        .message{
            margin-top:15px;
            font-weight:bold;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <h2>Course Enrollment</h2>

        Welcome, <asp:Label ID="lblStudentName" runat="server" Font-Bold="true"></asp:Label>

        <br />
        
        <b>Current Semester:</b><asp:Label ID="lblSemester" runat="server" Font-Bold="true"></asp:Label>

        <br />

        <b>Enrollment Period:</b><asp:Label ID="lblAddPeriod" runat="server" Font-Bold="true"></asp:Label>

        <br /><br />

        <b>Total Credits:</b>
        <asp:Label ID="lblTotalCredits" runat="server" Font-Bold="true"></asp:Label>

        <br /><br />

        <h3>Available Courses</h3>

        <asp:GridView ID="gvCourses" runat="server" AutoGenerateColumns="False" CssClass="grid"
            EmptyDataText="No available courses."
            OnRowCommand="gvCourses_RowCommand"
            OnRowDataBound="gvCourses_RowDataBound">
            <Columns>
                <asp:BoundField DataField="CourseCode" HeaderText="Course Code" />
                <asp:BoundField DataField="CourseName" HeaderText="Course Name" />
                <asp:BoundField DataField="CreditHours" HeaderText="Credits" />
                <asp:BoundField DataField="SemesterName" HeaderText="Semester" />
                <asp:BoundField DataField="Capacity" HeaderText="Capacity" />
                <asp:BoundField DataField="EnrolledCount" HeaderText="Enrolled" />
                <asp:BoundField DataField="SeatsLeft" HeaderText="Seats Left" />

                <asp:TemplateField HeaderText="Action">
                    <ItemTemplate>
                        <asp:Button 
                            ID="btnEnroll"
                            runat="server"
                            Text="Enroll"
                            CssClass="btn"
                            CommandName="Enroll"
                            CommandArgument='<%# Eval("OfferingID") %>' 
                            OnClientClick="return confirm('Confirm course enrollment?');" />
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>

        <br />

        <h3>My Enrolled Courses</h3>

        <asp:GridView ID="gvMyCourses" runat="server" AutoGenerateColumns="False" EmptyDataText="You have not enrolled in any courses.">
           <Columns>
                <asp:BoundField DataField="CourseCode" HeaderText="Course Code"/>
                <asp:BoundField DataField="CourseName" HeaderText="Course Name"/>
                <asp:BoundField DataField="CreditHours" HeaderText="Credits"/>
                <asp:BoundField DataField="SemesterName" HeaderText="Semester"/>
                <asp:BoundField DataField="Status" HeaderText="Status"/>
            </Columns>
        </asp:GridView>

        <asp:Label ID="lblMessage" runat="server" CssClass="message" ></asp:Label>
    </form>
</body>
</html>
