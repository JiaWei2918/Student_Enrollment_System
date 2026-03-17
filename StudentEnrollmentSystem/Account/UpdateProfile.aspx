<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UpdateProfile.aspx.cs" Inherits="StudentEnrollmentSystem.Account.UpdateProfile" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Update Profile</title>
</head>
<body>
    <form runat="server">
        <h2>Update Profile</h2>

        <asp:Label ID="lblMessage" runat="server" Font-Bold="true"></asp:Label>

        <table>
            <tr>
                <td>Full Name</td>
                <td>
                    <asp:TextBox ID="txtFullName" runat="server" MaxLength="100" />
                    <asp:RequiredFieldValidator
                        ControlToValidate="txtFullName"
                        ErrorMessage="Required"
                        ForeColor="Red"
                        runat="server" />
                </td>
            </tr>

            <tr>
                <td>Email</td>
                <td>
                    <asp:TextBox ID="txtEmail" runat="server" MaxLength="100" />
                    <asp:RequiredFieldValidator
                        ControlToValidate="txtEmail"
                        ErrorMessage="Required"
                        ForeColor="Red"
                        runat="server" />

                    <asp:RegularExpressionValidator
                        ControlToValidate="txtEmail"
                        ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                        ErrorMessage="Invalid email"
                        ForeColor="Red"
                        runat="server" />
                </td>
            </tr>

            <tr>
                <td>Phone</td>
                <td>
                    <asp:TextBox ID="txtPhone" runat="server" MaxLength="20" />
                </td>
            </tr>

            <tr>
                <td>Program</td>
                <td>
                    <asp:TextBox ID="txtProgram" runat="server" MaxLength="50" />
                </td>
            </tr>

            <tr>
                <td>Section</td>
                <td>
                    <asp:TextBox ID="txtSection" runat="server" MaxLength="10" />
                </td>
            </tr>

            <tr>
                <td>Address</td>
                <td>
                    <asp:TextBox ID="txtAddress" runat="server" Width="250px" MaxLength="255" />
                </td>
            </tr>

            <tr>
                <td>Date of Birth</td>
                <td>
                    <asp:TextBox ID="txtDOB" runat="server" TextMode="Date" />
                </td>
            </tr>

            <tr>
                <td>Nationality</td>
                <td>
                    <asp:TextBox ID="txtNationality" runat="server" MaxLength="50" />
                </td>
            </tr>

            <tr>
                <td></td>
                <td>
                    <asp:Button
                        ID="btnUpdate"
                        runat="server"
                        Text="Update Profile"
                        OnClick="btnUpdate_Click" 
                        OnClientClick="if (!Page_ClientValidate()) return false; this.disable=true; this.value='Updating...';" />
                </td>
            </tr>
        </table>
    </form>
</body>
</html>
