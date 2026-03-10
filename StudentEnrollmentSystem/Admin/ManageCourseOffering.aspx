<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageCourseOffering.aspx.cs" Inherits="StudentEnrollmentSystem.Admin.ManageCourseOffering" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Manage Course Offering</title>
</head>
<body>
    <form runat="server">
        <asp:Label ID="lblMessage" runat="server" ForeColor="Red" />

        <h3>Add Course Offering</h3>

        Course:
        <asp:DropDownList ID="ddlCourse" runat="server" /><br />

        Semester:
        <asp:DropDownList ID="ddlSemester" runat="server" /><br />

        Lecturer:
        <asp:TextBox ID="txtLecturer" runat="server" /><br />

        Capacity:
        <asp:TextBox ID="txtCapacity" runat="server" /><br /><br />

        <asp:Button ID="btnAdd" runat="server" Text="Add Offering" OnClick="btnAdd_Click" />

        <hr />

        <h3>Course Offering List</h3>

        <asp:GridView ID="gvOffering" runat="server" AutoGenerateColumns="False"
            DataKeyNames="OfferingID"
            OnRowEditing="gvOffering_RowEditing"
            OnRowCancelingEdit="gvOffering_RowCancelingEdit"
            OnRowUpdating="gvOffering_RowUpdating"
            OnRowDeleting="gvOffering_RowDeleting"
            EmptyDataText="No course offerings found.">

            <Columns>
                <asp:BoundField DataField="CourseCode" HeaderText="Course Code" ReadOnly="True" />
                <asp:BoundField DataField="CourseName" HeaderText="Course Name" ReadOnly="True" />
                <asp:BoundField DataField="SemesterName" HeaderText="Semester" ReadOnly="True" />
                <asp:BoundField DataField="AcademicYear" HeaderText="Year" ReadOnly="True" />

                <asp:TemplateField HeaderText="Lecturer">
                    <ItemTemplate>
                        <%# Eval("Lecturer") %>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditLecturer" runat="server"
                            Text='<%# Bind("Lecturer") %>' />
                    </EditItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Capacity">
                    <ItemTemplate>
                        <%# Eval("Capacity") %>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditCapacity" runat="server"
                            Text='<%# Bind("Capacity") %>' />
                    </EditItemTemplate>
                </asp:TemplateField>

                <asp:BoundField DataField="EnrolledStudents" HeaderText="Enrolled" ReadOnly="True" />
                <asp:BoundField DataField="SeatsLeft" HeaderText="Seats Left" ReadOnly="True" />
                <asp:BoundField DataField="Status" HeaderText="Status" ReadOnly="True" />

                <asp:CommandField ShowEditButton="True" ShowDeleteButton="True" />
            </Columns>
        </asp:GridView>
    </form>
</body>
</html>
