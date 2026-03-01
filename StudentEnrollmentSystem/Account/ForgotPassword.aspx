<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" Inherits="StudentEnrollmentSystem.Account.ForgotPassword" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Forgot Password</title>
</head>
<body>
    <form runat="server">
        <h2>Forgot Password</h2>

        <asp:TextBox ID="txtUsername" runat="server" Placeholder="Username"></asp:TextBox><br /><br />

        <asp:TextBox ID="txtEmail" runat="server" Placeholder="Email"></asp:TextBox><br /><br />

        <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" Placeholder="New Password"></asp:TextBox><br /><br />

        <asp:Button ID="btnReset" runat="server" Text="Reset Password"
            OnClick="btnReset_Click" />

        <br /><br />
        <asp:Label ID="lblMessage" runat="server" Font-Bold="true"></asp:Label>
    </form>
</body>
</html>
