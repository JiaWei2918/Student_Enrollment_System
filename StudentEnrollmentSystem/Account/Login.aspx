<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="StudentEnrollmentSystem.Account.Login" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Login</title>
    
    <script type="text/javascript">
        function startLockTimer(lockUntil) {
            var lockTime = new Date(lockUntil).getTime();

            var timer = setInterval(function () {

                var now = new Date().getTime();
                var distance = lockTime - now;

                if (distance <= 0) {

                    clearInterval(timer);

                    document.getElementById('<%= txtUsername.ClientID %>').disabled = false;
                    document.getElementById('<%= txtPassword.ClientID %>').disabled = false;
                    document.getElementById('<%= btnLogin.ClientID %>').disabled = false;

                    document.getElementById('countdown').innerHTML = "";
                    document.getElementById('<%= lblMessage.ClientID %>').innerHTML = "You can login now.";

                    return;
                }

                var minutes = Math.floor(distance / (1000 * 60));
                var seconds = Math.floor((distance % (1000 * 60)) / 1000);

                document.getElementById('countdown').innerHTML =
                    "Account locked. Try again in " + minutes + "m " + seconds + "s";

            }, 1000);
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="login-container">
            <h2>Login</h2>

            <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" Placeholder="Username"></asp:TextBox>
            <asp:RequiredFieldValidator ID="rfvUsername" runat="server" ControlToValidate="txtUsername" 
                ErrorMessage="Username required" ForeColor="Red" Display="Dynamic" />
            <br />

            <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" Placeholder="Password"></asp:TextBox>
            <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword" 
                ErrorMessage="Password required" ForeColor="Red" Display="Dynamic" />
            <br /><br />

            <asp:Button ID="btnLogin" runat="server" Text="Login" CssClass="btn btn-primary" OnClick="btnLogin_Click" />

            <br /><br />

            <asp:HyperLink ID="lnkForgot" runat="server" NavigateUrl="~/Account/ForgotPassword.aspx">Forgot Password?</asp:HyperLink>
            <br /><br />
            <asp:Label ID="lblMessage" runat="server" ForeColor="Red" Font-Bold="true"></asp:Label>
            <div id="countdown" style="color:red;font-weight:bold;"></div>
        </div>
    </form>
</body>
</html>
