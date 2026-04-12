<%@ Page Title="Login" Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="StudentEnrollmentSystem.Account.Login" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Student Enrollment System — Login</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet" />

    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            min-height: 100vh;
            font-family: 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #1e3a8a 0%, #1d4ed8 30%, #6366f1 65%, #9333ea 100%);
            display: flex; align-items: center; justify-content: center;
            padding: 24px;
            position: relative; overflow: hidden;
        }

        body::before {
            content: '';
            position: fixed; top: -120px; right: -120px;
            width: 400px; height: 400px;
            background: rgba(255,255,255,0.06);
            border-radius: 50%; pointer-events: none;
        }

        body::after {
            content: '';
            position: fixed; bottom: -100px; left: -100px;
            width: 320px; height: 320px;
            background: rgba(255,255,255,0.04);
            border-radius: 50%; pointer-events: none;
        }

        .login-card {
            width: 100%; max-width: 440px;
            background: #fff;
            border-radius: 24px;
            overflow: hidden;
            box-shadow: 0 32px 64px rgba(0,0,0,0.25);
            position: relative; z-index: 1;
            animation: cardIn 0.4s ease;
        }

        @keyframes cardIn {
            from { opacity: 0; transform: translateY(20px) scale(0.97); }
            to   { opacity: 1; transform: translateY(0)    scale(1); }
        }

        .card-header {
            background: linear-gradient(135deg, #1d4ed8 0%, #6366f1 55%, #9333ea 100%);
            padding: 36px 40px 32px;
            text-align: center; color: #fff;
            position: relative; overflow: hidden;
        }

        .card-header::before {
            content: '';
            position: absolute; top: -48px; right: -48px;
            width: 160px; height: 160px;
            background: rgba(255,255,255,0.08); border-radius: 50%;
        }

        .card-header::after {
            content: '';
            position: absolute; bottom: -32px; left: -32px;
            width: 120px; height: 120px;
            background: rgba(255,255,255,0.05); border-radius: 50%;
        }

        .header-icon {
            width: 72px; height: 72px; border-radius: 20px;
            background: rgba(255,255,255,0.2);
            border: 1px solid rgba(255,255,255,0.3);
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto 18px;
            backdrop-filter: blur(8px);
            position: relative; z-index: 1;
        }

        .header-icon i { font-size: 32px; color: #fff; }

        .card-header h1 {
            font-size: 24px; font-weight: 700; margin-bottom: 6px;
            position: relative; z-index: 1;
        }

        .card-header p {
            font-size: 14px; color: rgba(255,255,255,0.8);
            position: relative; z-index: 1;
        }

        .role-pills {
            display: flex; justify-content: center; gap: 8px;
            margin-top: 18px; position: relative; z-index: 1;
        }

        .role-pill {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 4px 12px; border-radius: 99px;
            font-size: 12px; font-weight: 600;
            background: rgba(255,255,255,0.18);
            border: 1px solid rgba(255,255,255,0.25); color: #fff;
        }

        .role-pill i { font-size: 11px; }

        .card-body { padding: 36px 40px 32px; }

        .form-group { margin-bottom: 20px; }

        .form-label {
            display: block; font-size: 13px; font-weight: 600;
            color: #374151; margin-bottom: 6px;
        }

        .input-wrap { position: relative; }

        .input-icon {
            position: absolute; left: 14px; top: 50%;
            transform: translateY(-50%);
            color: #94a3b8; font-size: 15px; pointer-events: none;
        }

        .form-input {
            width: 100%; padding: 12px 44px 12px 42px;
            border: 1.5px solid #e2e8f0; border-radius: 12px;
            font-size: 14px; color: #0f172a; background: #f8fafc;
            outline: none; transition: border-color 0.2s, box-shadow 0.2s, background 0.2s;
            font-family: inherit;
        }

        .form-input:focus {
            border-color: #6366f1;
            box-shadow: 0 0 0 3px rgba(99,102,241,0.14);
            background: #fff;
        }

        .form-input:disabled {
            background: #f1f5f9; color: #94a3b8; cursor: not-allowed;
        }

        .eye-btn {
            position: absolute; right: 12px; top: 50%;
            transform: translateY(-50%);
            background: none; border: none; cursor: pointer;
            color: #94a3b8; font-size: 15px; padding: 4px;
            transition: color 0.2s;
        }

        .eye-btn:hover { color: #475569; }

        .validator-msg { display: block; font-size: 12px; color: #b91c1c; margin-top: 4px; }

        .forgot-row {
            text-align: right; margin-top: -12px; margin-bottom: 20px;
        }

        .forgot-link {
            font-size: 13px; font-weight: 600; color: #6366f1;
            text-decoration: none; transition: color 0.2s;
        }

        .forgot-link:hover { color: #4338ca; }

        .btn-login {
            width: 100%; padding: 13px;
            background: linear-gradient(90deg, #1d4ed8, #6366f1, #9333ea);
            background-size: 200% auto;
            color: #fff; border: none; border-radius: 12px;
            font-size: 15px; font-weight: 700; cursor: pointer;
            box-shadow: 0 6px 20px rgba(99,102,241,0.4);
            transition: background-position 0.4s, box-shadow 0.2s, opacity 0.2s;
            letter-spacing: 0.3px;
        }

        .btn-login:hover:not(:disabled) {
            background-position: right center;
            box-shadow: 0 10px 28px rgba(99,102,241,0.5);
        }

        .btn-login:disabled {
            background: #e2e8f0; color: #94a3b8;
            box-shadow: none; cursor: not-allowed;
        }

        .msg-box {
            display: flex; align-items: flex-start; gap: 10px;
            padding: 13px 16px; border-radius: 11px;
            font-size: 13px; font-weight: 600; margin-top: 16px;
        }

        .msg-box i { font-size: 14px; margin-top: 1px; flex-shrink: 0; }
        .msg-error   { background: #fef2f2; border: 1px solid #fecaca; color: #b91c1c; }
        .msg-warning { background: #fffbeb; border: 1px solid #fde68a; color: #92400e; }
        .msg-success { background: #f0fdf4; border: 1px solid #bbf7d0; color: #15803d; }

        .countdown-wrap { margin-top: 12px; }

        .countdown-bar {
            height: 5px; background: #fee2e2; border-radius: 99px;
            overflow: hidden; margin-bottom: 6px;
        }

        .countdown-fill {
            height: 100%;
            background: linear-gradient(90deg, #ef4444, #f97316);
            border-radius: 99px;
            transition: width 1s linear;
        }

        #countdown {
            font-size: 13px; font-weight: 600; color: #b91c1c;
            text-align: center;
        }

        .card-footer {
            padding: 16px 40px 28px;
            text-align: center;
            border-top: 1px solid #f1f5f9;
            font-size: 12px; color: #94a3b8;
        }

        .accent-strip {
            height: 4px;
            background: linear-gradient(90deg, #1d4ed8 0%, #6366f1 50%, #9333ea 100%);
        }

        @media (max-width: 480px) {
            body { padding: 16px; align-items: flex-start; padding-top: 40px; }
            .card-body  { padding: 28px 24px 24px; }
            .card-header { padding: 28px 24px 24px; }
            .card-footer { padding: 14px 24px 24px; }
        }
    </style>
    
    <script type="text/javascript">
        var lockTotal = 0;

        function startLockTimer(lockUntil) {
            var lockTime = new Date(lockUntil).getTime();
            lockTotal = lockTime - new Date().getTime();

            var timer = setInterval(function () {
                var now = new Date().getTime();
                var distance = lockTime - now;

                if (distance <= 0) {
                    clearInterval(timer);
                    enableForm();

                    document.getElementById('countdown').innerHTML = "";
                    document.getElementById('countdownFill').style.width = '0%';
                    var lbl = document.getElementById('<%= lblMessage.ClientID %>');
                    lbl.className = 'msg-box msg-success';
                    lbl.innerHTML = '<i class="fa fa-check-circle"></i> Account unlocked. You can login now.';
                    return;
                }

                var minutes = Math.floor(distance / (1000 * 60));
                var seconds = Math.floor((distance % (1000 * 60)) / 1000);

                document.getElementById('countdown').innerHTML =
                    "Account locked. Try again in " + minutes + "m " + seconds + "s";

                var pct = Math.max(0, (distance / lockTotal) * 100);
                document.getElementById('countdownFill').style.width = pct + '%';
            }, 1000);
        }

        function enableForm() {
            document.getElementById('<%= txtUsername.ClientID %>').disabled = false;
            document.getElementById('<%= txtPassword.ClientID %>').disabled = false;
            document.getElementById('<%= btnLogin.ClientID %>').disabled = false;
        }

        function toggleEye(inputId, btn) {
            var input = document.getElementById(inputId);
            var icon = btn.querySelector('i');
            if (input.type === 'password') {
                input.type = 'text';
                icon.className = 'fa fa-eye-slash';
            } else {
                input.type = 'password';
                icon.className = 'fa fa-eye';
            }
        }

        window.onload = function () {
            var lbl = document.getElementById('<%= lblMessage.ClientID %>');
            if (!lbl || !lbl.innerText.trim()) return;

            var text = lbl.innerText.trim();
            var isLocked = text.toLowerCase().indexOf('lock') > -1;
            var isSuccess = text.toLowerCase().indexOf('now') > -1 ||
                text.toLowerCase().indexOf('success') > -1;

            if (isSuccess)
                styleMsg(lbl, 'success', 'fa-check-circle', text);
            else if (isLocked)
                styleMsg(lbl, 'warning', 'fa-lock', text);
            else
                styleMsg(lbl, 'error', 'fa-exclamation-circle', text);
        };

        function styleMsg(lbl, type, icon, text) {
            lbl.className = 'msg-box msg-' + type;
            lbl.innerHTML = '<i class="fa ' + icon + '"></i><span>' + text + '</span>';
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="login-card">
            <div class="accent-strip"></div>

            <div class="card-header">
                <div class="header-icon">
                    <i class="fa fa-graduation-cap"></i>
                </div>
                <h1>Student Enrollment System</h1>
                <p>Sign in to access your account</p>
                <div class="role-pills">
                    <span class="role-pill">
                        <i class="fa fa-user-graduate"></i> Student
                    </span>
                    <span class="role-pill">
                        <i class="fa fa-user-shield"></i> Admin
                    </span>
                </div>
            </div>

            <div class="card-body">

                <div class="form-group">
                    <label class="form-label" for="<%= txtUsername.ClientID %>">Username</label>
                    <div class="input-wrap">
                        <i class="fa fa-user input-icon"></i>
                        <asp:TextBox ID="txtUsername" runat="server"
                            CssClass="form-input"
                            placeholder="Enter your username"
                            AutoPostBack="true"
                            OnTextChanged="txtUsername_TextChanged" />
                    </div>
                    <asp:RequiredFieldValidator ID="rfvUsername" runat="server"
                        ControlToValidate="txtUsername"
                        ErrorMessage="Username is required."
                        CssClass="validator-msg" Display="Dynamic" />
                </div>

                <div class="form-group">
                    <label class="form-label" for="<%= txtPassword.ClientID %>">Password</label>
                    <div class="input-wrap">
                        <i class="fa fa-lock input-icon"></i>
                        <asp:TextBox ID="txtPassword" runat="server"
                            CssClass="form-input"
                            TextMode="Password"
                            placeholder="Enter your password" />
                        <button type="button" class="eye-btn"
                            onclick="toggleEye('<%= txtPassword.ClientID %>', this)">
                            <i class="fa fa-eye"></i>
                        </button>
                    </div>
                    <asp:RequiredFieldValidator ID="rfvPassword" runat="server"
                        ControlToValidate="txtPassword"
                        ErrorMessage="Password is required."
                        CssClass="validator-msg" Display="Dynamic" />
                </div>

                <div class="forgot-row">
                    <asp:HyperLink ID="lnkForgot" runat="server"
                        NavigateUrl="~/Account/ForgotPassword.aspx"
                        CssClass="forgot-link">
                        Forgot Password?
                    </asp:HyperLink>
                </div>

                <asp:Button ID="btnLogin" runat="server"
                    Text="Sign In"
                    CssClass="btn-login"
                    OnClick="btnLogin_Click" />

                <asp:Label ID="lblMessage" runat="server" />

                <div class="countdown-wrap" id="countdownWrap" style="display:none;">
                    <div class="countdown-bar">
                        <div class="countdown-fill" id="countdownFill" style="width:100%;"></div>
                    </div>
                    <div id="countdown"></div>
                </div>
            </div>

            <div class="card-footer">
                &copy; <%= DateTime.Now.Year %> Student Enrollment System. All rights reserved.
            </div>
        </div>
    </form>

    <script>
        var _origStartLock = startLockTimer;

        startLockTimer = function (lockUntil) {
            document.getElementById('countdownWrap').style.display = 'block';
            _origStartLock(lockUntil);
        };
    </script>
</body>
</html>
