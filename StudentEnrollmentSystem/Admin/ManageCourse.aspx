<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageCourse.aspx.cs" Inherits="StudentEnrollmentSystem.Admin.ManageCourse" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Manage Course</title>
</head>
<body>
    <form runat="server">
        <h2>Manage Course</h2>
        <asp:HiddenField ID="hfCourseID" runat="server" />

        <div>
            Course Code:
            <asp:TextBox ID="txtCourseCode" runat="server" />
        </div>

        <div>
            Course Name:
            <asp:TextBox ID="txtCourseName" runat="server" />
        </div>

        <div>
            Description:
            <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" />
        </div>

        <div>
            Credit Hours:
            <asp:TextBox ID="txtCreditHours" runat="server" />
        </div>

        <div>
            Prerequisite Course:
            <asp:DropDownList ID="ddlPrerequisite" runat="server"></asp:DropDownList>
        </div>

        <br />

        <asp:Button ID="btnAdd" runat="server" Text="Add Course" OnClick="btnAdd_Click" />

        <asp:Button ID="btnCancel" runat="server" Text="Cancel" OnClick="btnCancel_Click" CausesValidation="false" />

        <br /><br />

        <asp:Label ID="lblMessage" runat="server" Font-Bold="true" />

        <hr />

        <asp:GridView ID="gvCourse" runat="server" AutoGenerateColumns="False" DataKeyNames="CourseID" OnRowCommand="gvCourse_RowCommand">
            <Columns>
                <asp:BoundField DataField="CourseID" HeaderText="ID" />
                <asp:BoundField DataField="CourseCode" HeaderText="Code" />
                <asp:BoundField DataField="CourseName" HeaderText="Name" />
                <asp:BoundField DataField="CreditHours" HeaderText="Credits" />
                <asp:BoundField DataField="PrerequisiteName" HeaderText="Prerequisite" />

                <asp:TemplateField>
                    <ItemTemplate>
                        <asp:Button ID="btnEdit" runat="server"
                            Text="Edit"
                            CommandName="EditCourse"
                            CommandArgument='<%# Eval("CourseID") %>' />
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField>
                    <ItemTemplate>
                        <asp:Button ID="btnDelete" runat="server"
                            Text="Delete"
                            CommandName="DeleteCourse"
                            CommandArgument='<%# Eval("CourseID") %>' />
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </form>
</body>
</html>
