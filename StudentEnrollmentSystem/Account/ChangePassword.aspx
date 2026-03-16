<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ChangePassword.aspx.cs" Inherits="StudentEnrollmentSystem.Account.ChangePassword" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Change Password</title>
</head>
<body>
    <form runat="server">
    <h2>Change Password</h2>

    <asp:Label ID="lblMessage" runat="server" Font-Bold="true"></asp:Label>

    <table>
        <tr>
            <td>Current Password</td>
            <td>
                <asp:TextBox ID="txtCurrentPassword" runat="server" TextMode="Password" />
                <asp:RequiredFieldValidator
                    ControlToValidate="txtCurrentPassword"
                    ErrorMessage="Required"
                    ForeColor="Red"
                    runat="server" />
            </td>
        </tr>

        <tr>
            <td>New Password</td>
            <!--<small>Password must be at least 6 characters.</small>-->
            <td>
                <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" />
                <asp:RequiredFieldValidator
                    ControlToValidate="txtNewPassword"
                    ErrorMessage="Required"
                    ForeColor="Red"
                    runat="server" />

                <!--<asp:RegularExpressionValidator
                    ControlToValidate="txtNewPassword"
                    ValidationExpression="^.{6,}$"
                    ErrorMessage="Password must be at least 6 characters"
                    ForeColor="Red"
                    runat="server" />-->
            </td>
        </tr>

        <tr>
            <td>Confirm Password</td>
            <td>
                <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" />
                <asp:CompareValidator
                    ControlToValidate="txtConfirmPassword"
                    ControlToCompare="txtNewPassword"
                    ErrorMessage="Passwords do not match"
                    ForeColor="Red"
                    runat="server" />
            </td>
        </tr>

        <tr>
            <td></td>
            <td>
                <asp:Button
                    ID="btnChangePassword"
                    runat="server"
                    Text="Change Password"
                    OnClick="btnChangePassword_Click" />
            </td>
        </tr>
    </table>
</form>
</body>
</html>
