<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TeachingEvaluation.aspx.cs" Inherits="StudentEnrollmentSystem.Student.TeachingEvaluation" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Teaching Evaluation</title>
</head>
<body>
    <form runat="server">
        <h2>📊 Teaching Evaluation</h2>

        <asp:Label ID="lblMsg" runat="server" Font-Bold="true"></asp:Label>

        <br />

        Semester:
        <asp:DropDownList ID="ddlSemester" runat="server" AutoPostBack="true"
            OnSelectedIndexChanged="ddlSemester_SelectedIndexChanged" />

        <br /><br />

        Course:
        <asp:DropDownList ID="ddlCourse" runat="server"></asp:DropDownList>

        <br /><br />

        Overall Rating:
        <asp:DropDownList ID="ddlRating" runat="server">
            <asp:ListItem Value="">-- Select --</asp:ListItem>
            <asp:ListItem>1</asp:ListItem>
            <asp:ListItem>2</asp:ListItem>
            <asp:ListItem>3</asp:ListItem>
            <asp:ListItem>4</asp:ListItem>
            <asp:ListItem>5</asp:ListItem>
        </asp:DropDownList>

        <br /><br />

        Lecturer Rating:
        <asp:DropDownList ID="ddlLecturerRating" runat="server">
            <asp:ListItem Value="">-- Select --</asp:ListItem>
            <asp:ListItem>1</asp:ListItem>
            <asp:ListItem>2</asp:ListItem>
            <asp:ListItem>3</asp:ListItem>
            <asp:ListItem>4</asp:ListItem>
            <asp:ListItem>5</asp:ListItem>
        </asp:DropDownList>

        <br /><br />

        Course Rating:
        <asp:DropDownList ID="ddlCourseRating" runat="server">
            <asp:ListItem Value="">-- Select --</asp:ListItem>
            <asp:ListItem>1</asp:ListItem>
            <asp:ListItem>2</asp:ListItem>
            <asp:ListItem>3</asp:ListItem>
            <asp:ListItem>4</asp:ListItem>
            <asp:ListItem>5</asp:ListItem>
        </asp:DropDownList>

        <br /><br />

        Comment:
        <br />
        <asp:TextBox ID="txtComment" runat="server" TextMode="MultiLine" Rows="4" Width="400"></asp:TextBox>

        <br /><br />

        <asp:CheckBox ID="chkAnonymous" runat="server" Text="Submit as Anonymous" />

        <br /><br />

        <asp:Button ID="btnSubmit" runat="server" Text="Submit Evaluation"
            OnClick="btnSubmit_Click" />

        <hr />

        <h3>My Evaluations</h3>

        <asp:GridView ID="gvEvaluation" runat="server" AutoGenerateColumns="false" BorderWidth="1">
            <Columns>
                <asp:BoundField DataField="CourseCode" HeaderText="Course" />
                <asp:BoundField DataField="Rating" HeaderText="Overall" />
                <asp:BoundField DataField="LecturerRating" HeaderText="Lecturer" />
                <asp:BoundField DataField="CourseRating" HeaderText="Course" />
                <asp:BoundField DataField="Comment" HeaderText="Comment" />
                <asp:BoundField DataField="SubmittedAt" HeaderText="Date" DataFormatString="{0:yyyy-MM-dd}" />
            </Columns>
        </asp:GridView>
    </form>
</body>
</html>
