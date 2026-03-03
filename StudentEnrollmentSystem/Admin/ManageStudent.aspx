<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageStudent.aspx.cs" Inherits="StudentEnrollmentSystem.Admin.ManageStudent" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Manage Students</title>
</head>
<body>
    <form runat="server">
        <div class="container">
            <h2>Manage Students</h2>

            <asp:Label ID="lblMessage" runat="server" ForeColor="Red" Font-Bold="true"></asp:Label>

            <h3>Add Student</h3>
            <table>
                <tr>
                    <td>Matric No:</td>
                    <td><asp:TextBox ID="txtMatricNo" runat="server" /></td>
                </tr>
                <tr>
                    <td>Full Name:</td>
                    <td><asp:TextBox ID="txtFullName" runat="server" /></td>
                </tr>
                <tr>
                    <td>Email:</td>
                    <td><asp:TextBox ID="txtEmail" runat="server" /></td>
                </tr>
                <tr>
                    <td>Phone:</td>
                    <td><asp:TextBox ID="txtPhone" runat="server" /></td>
                </tr>
                <tr>
                    <td>Program:</td>
                    <td><asp:TextBox ID="txtProgram" runat="server" /></td>
                </tr>
                <tr>
                    <td>Section:</td>
                    <td><asp:TextBox ID="txtSection" runat="server" /></td>
                </tr>
                <tr>
                    <td>Enrollment Date:</td>
                    <td><asp:TextBox ID="txtEnrollmentDate" runat="server" TextMode="Date" /></td>
                </tr>
                <tr>
                    <td>Status:</td>
                    <td>
                        <asp:DropDownList ID="ddlStatus" runat="server">
                            <asp:ListItem Text="Active" Value="Active" />
                            <asp:ListItem Text="Inactive" Value="Inactive" />
                            <asp:ListItem Text="Graduated" Value="Graduated" />
                        </asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <asp:Button ID="btnAdd" runat="server" Text="Add Student" OnClick="btnAdd_Click" CssClass="btn btn-primary" />
                    </td>
                </tr>
            </table>

            <hr />

            <h3>All Students</h3>
            <asp:GridView ID="gvStudent" runat="server" AutoGenerateColumns="False" DataKeyNames="StudentID"
                OnRowEditing="gvStudent_RowEditing"
                OnRowCancelingEdit="gvStudent_RowCancelingEdit"
                OnRowUpdating="gvStudent_RowUpdating"
                OnRowDeleting="gvStudent_RowDeleting"
                CssClass="table table-bordered">
                <Columns>
                    <asp:BoundField DataField="MatricNo" HeaderText="Matric No" ReadOnly="True" />
                    <asp:BoundField DataField="FullName" HeaderText="Full Name" />
                    <asp:BoundField DataField="Email" HeaderText="Email" />
                    <asp:BoundField DataField="Phone" HeaderText="Phone" />
                    <asp:BoundField DataField="Program" HeaderText="Program" />
                    <asp:BoundField DataField="Section" HeaderText="Section" />
                    <asp:BoundField DataField="EnrollmentDate" HeaderText="Enrollment Date"
                        DataFormatString="{0:yyyy-MM-dd}" />
                    <asp:BoundField DataField="Status" HeaderText="Status" />
                    <asp:CommandField ShowEditButton="True" ShowDeleteButton="True" />
                </Columns>
            </asp:GridView>
        </div>
    </form>
</body>
</html>
