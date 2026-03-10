<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" Inherits="StudentEnrollmentSystem.Account.ForgotPassword" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Forgot Password</title>
</head>
<body>
    <form runat="server">
        <h2>Forgot Password</h2>

        <asp:TextBox ID="txtUsername" runat="server" Placeholder="Username"></asp:TextBox>
        <asp:RequiredFieldValidator ID="rfvUsername" runat="server" ControlToValidate="txtUsername" 
            ErrorMessage="Username is required" ForeColor="Red" />
        <br /><br />

        <asp:TextBox ID="txtEmail" runat="server" Placeholder="Email"></asp:TextBox>
        <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" 
            ErrorMessage="Email is required" ForeColor="Red" />
        <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" 
            ErrorMessage="Invalid email format" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" ForeColor="Red" />
        <br /><br />

        <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" Placeholder="New Password"></asp:TextBox>
        <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtNewPassword" 
            ErrorMessage="Password is required" ForeColor="Red" />
        <br /><br />

        <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" Placeholder="Confirm Password"></asp:TextBox>
        <asp:RequiredFieldValidator ID="rfvConfirmPassword" runat="server" ControlToValidate="txtConfirmPassword" 
            ErrorMessage="Confirm password is required" ForeColor="Red" />
        <asp:CompareValidator ID="cvPassword" runat="server" ControlToValidate="txtConfirmPassword" 
            ControlToCompare="txtNewPassword" ErrorMessage="Passwords do not match" ForeColor="Red" />
        <br /><br />

        <asp:Button ID="btnReset" runat="server" Text="Reset Password"
            OnClick="btnReset_Click" CausesValidation="true"/>

        <br /><br />
        <asp:Label ID="lblMessage" runat="server" Font-Bold="true"></asp:Label>
    </form>
</body>
</html>
