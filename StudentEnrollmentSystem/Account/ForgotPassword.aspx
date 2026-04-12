<%@ Page Title="Forgot Password" Language="C#" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" Inherits="StudentEnrollmentSystem.Account.ForgotPassword" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Forgot Password — Student Enrollment System</title>
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
            position: relative; overflow-x: hidden;
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
            width: 100%; max-width: 460px;
            background: #fff; border-radius: 24px; overflow: hidden;
            box-shadow: 0 32px 64px rgba(0,0,0,0.25);
            position: relative; z-index: 1;
            animation: cardIn 0.4s ease;
        }

        @keyframes cardIn {
            from { opacity: 0; transform: translateY(20px) scale(0.97); }
            to   { opacity: 1; transform: translateY(0) scale(1); }
        }

        .accent-strip {
            height: 4px;
            background: linear-gradient(90deg, #1d4ed8 0%, #6366f1 50%, #9333ea 100%);
        }

        .card-header {
            background: linear-gradient(135deg, #1d4ed8 0%, #6366f1 55%, #9333ea 100%);
            padding: 32px 40px 28px;
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
            width: 64px; height: 64px; border-radius: 18px;
            background: rgba(255,255,255,0.2);
            border: 1px solid rgba(255,255,255,0.3);
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto 16px;
            position: relative; z-index: 1;
        }

        .header-icon i { font-size: 28px; color: #fff; }

        .card-header h1 {
            font-size: 22px; font-weight: 700; margin-bottom: 6px;
            position: relative; z-index: 1;
        }

        .card-header p {
            font-size: 13px; color: rgba(255,255,255,0.8);
            position: relative; z-index: 1;
        }

        .card-body { padding: 32px 40px 28px; }

        .form-group { margin-bottom: 18px; }

        .form-label {
            display: block; font-size: 13px; font-weight: 600;
            color: #374151; margin-bottom: 6px;
        }

        .input-wrap { position: relative; }

        .input-icon {
            position: absolute; left: 14px; top: 50%;
            transform: translateY(-50%);
            color: #94a3b8; font-size: 14px; pointer-events: none;
        }

        .form-input {
            width: 100%; padding: 11px 44px 11px 40px;
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

        .eye-btn {
            position: absolute; right: 12px; top: 50%;
            transform: translateY(-50%);
            background: none; border: none; cursor: pointer;
            color: #94a3b8; font-size: 14px; padding: 4px; transition: color 0.2s;
        }

        .eye-btn:hover { color: #475569; }

        .validator-msg { display: block; font-size: 12px; color: #b91c1c; margin-top: 4px; }

        .strength-wrap { margin-top: 8px; display: none; }
        .strength-bars  { display: flex; gap: 4px; margin-bottom: 4px; }

        .strength-bar   {
            flex: 1; height: 4px; border-radius: 99px;
            background: #e2e8f0; transition: background 0.3s;
        }

        .strength-bar.s1 { background: #ef4444; }
        .strength-bar.s2 { background: #f97316; }
        .strength-bar.s3 { background: #eab308; }
        .strength-bar.s4 { background: #22c55e; }
        .strength-label { font-size: 11px; color: #64748b; }

        .mismatch-hint { font-size: 12px; color: #b91c1c; margin-top: 4px; display: none; }
        .mismatch-hint.show { display: block; }

        .btn-reset {
            width: 100%; padding: 13px;
            background: linear-gradient(90deg, #1d4ed8, #6366f1, #9333ea);
            background-size: 200% auto;
            color: #fff; border: none; border-radius: 12px;
            font-size: 15px; font-weight: 700; cursor: pointer;
            box-shadow: 0 6px 20px rgba(99,102,241,0.4);
            transition: background-position 0.4s, box-shadow 0.2s;
            letter-spacing: 0.3px; margin-top: 8px;
        }

        .btn-reset:hover {
            background-position: right center;
            box-shadow: 0 10px 28px rgba(99,102,241,0.5);
        }

        .msg-box {
            display: flex; align-items: flex-start; gap: 10px;
            padding: 13px 16px; border-radius: 11px;
            font-size: 13px; font-weight: 600; margin-top: 16px;
        }

        .msg-box i { font-size: 14px; margin-top: 1px; flex-shrink: 0; }
        .msg-error   { background: #fef2f2; border: 1px solid #fecaca; color: #b91c1c; }
        .msg-success { background: #f0fdf4; border: 1px solid #bbf7d0; color: #15803d; }

        .back-row {
            text-align: center; margin-top: 20px;
            font-size: 13px; color: #64748b;
        }

        .back-link {
            font-weight: 700; color: #6366f1; text-decoration: none;
            transition: color 0.2s;
        }

        .back-link:hover { color: #4338ca; }
        .back-link i { margin-right: 4px; font-size: 12px; }

        .card-footer {
            padding: 14px 40px 24px;
            text-align: center;
            border-top: 1px solid #f1f5f9;
            font-size: 12px; color: #94a3b8;
        }

        @media (max-width: 480px) {
            body { padding: 16px; align-items: flex-start; padding-top: 32px; }
            .card-body   { padding: 24px 20px 20px; }
            .card-header { padding: 24px 20px 20px; }
            .card-footer { padding: 12px 20px 20px; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="login-card">
            <div class="accent-strip"></div>

            <div class="card-header">
                <div class="header-icon">
                    <i class="fa fa-key"></i>
                </div>
                <h1>Reset Password</h1>
                <p>Enter your details to reset your account password</p>
            </div>

            <div class="card-body">
                <div class="form-group">
                    <label class="form-label" for="<%= txtUsername.ClientID %>">Username</label>
                    <div class="input-wrap">
                        <i class="fa fa-user input-icon"></i>
                        <asp:TextBox ID="txtUsername" runat="server"
                            CssClass="form-input"
                            placeholder="Enter your username" />
                    </div>
                    <asp:RequiredFieldValidator ID="rfvUsername" runat="server"
                        ControlToValidate="txtUsername"
                        ErrorMessage="Username is required."
                        CssClass="validator-msg" Display="Dynamic" />
                </div>

                <div class="form-group">
                    <label class="form-label" for="<%= txtEmail.ClientID %>">Email Address</label>
                    <div class="input-wrap">
                        <i class="fa fa-envelope input-icon"></i>
                        <asp:TextBox ID="txtEmail" runat="server"
                            CssClass="form-input"
                            placeholder="Enter your registered email" />
                    </div>
                    <asp:RequiredFieldValidator ID="rfvEmail" runat="server"
                        ControlToValidate="txtEmail"
                        ErrorMessage="Email is required."
                        CssClass="validator-msg" Display="Dynamic" />
                    <asp:RegularExpressionValidator ID="revEmail" runat="server"
                        ControlToValidate="txtEmail"
                        ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                        ErrorMessage="Please enter a valid email address."
                        CssClass="validator-msg" Display="Dynamic" />
                </div>

                <div class="form-group">
                    <label class="form-label" for="<%= txtNewPassword.ClientID %>">New Password</label>
                    <div class="input-wrap">
                        <i class="fa fa-lock input-icon"></i>
                        <asp:TextBox ID="txtNewPassword" runat="server"
                            CssClass="form-input"
                            TextMode="Password"
                            placeholder="Enter new password"
                            onkeyup="checkStrength(this.value); checkMatch();" />
                        <button type="button" class="eye-btn"
                            onclick="toggleEye('<%= txtNewPassword.ClientID %>', this)">
                            <i class="fa fa-eye"></i>
                        </button>
                    </div>
                    <asp:RequiredFieldValidator ID="rfvPassword" runat="server"
                        ControlToValidate="txtNewPassword"
                        ErrorMessage="New password is required."
                        CssClass="validator-msg" Display="Dynamic" />

                    <div class="strength-wrap" id="strengthWrap">
                        <div class="strength-bars">
                            <div class="strength-bar" id="bar1"></div>
                            <div class="strength-bar" id="bar2"></div>
                            <div class="strength-bar" id="bar3"></div>
                            <div class="strength-bar" id="bar4"></div>
                        </div>
                        <span class="strength-label" id="strengthLabel"></span>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label" for="<%= txtConfirmPassword.ClientID %>">Confirm Password</label>
                    <div class="input-wrap">
                        <i class="fa fa-lock input-icon"></i>
                        <asp:TextBox ID="txtConfirmPassword" runat="server"
                            CssClass="form-input"
                            TextMode="Password"
                            placeholder="Confirm new password"
                            onkeyup="checkMatch();" />
                        <button type="button" class="eye-btn"
                            onclick="toggleEye('<%= txtConfirmPassword.ClientID %>', this)">
                            <i class="fa fa-eye"></i>
                        </button>
                    </div>
                    <asp:RequiredFieldValidator ID="rfvConfirmPassword" runat="server"
                        ControlToValidate="txtConfirmPassword"
                        ErrorMessage="Please confirm your password."
                        CssClass="validator-msg" Display="Dynamic" />
                    <asp:CompareValidator ID="cvPassword" runat="server"
                        ControlToValidate="txtConfirmPassword"
                        ControlToCompare="txtNewPassword"
                        ErrorMessage="Passwords do not match."
                        CssClass="validator-msg" Display="Dynamic" />
                    <div class="mismatch-hint" id="mismatchHint">Passwords do not match</div>
                </div>

                <asp:Button ID="btnReset" runat="server"
                    Text="Reset Password"
                    CssClass="btn-reset"
                    OnClick="btnReset_Click"
                    CausesValidation="true"
                    OnClientClick="return validateForm();" />

                <asp:Label ID="lblMessage" runat="server" />

                <div class="back-row">
                    Remember your password?
                    <a href="Login.aspx" class="back-link">
                        <i class="fa fa-arrow-left"></i> Back to Login
                    </a>
                </div>
            </div>

            <div class="card-footer">
                &copy; <%= DateTime.Now.Year %> Student Enrollment System. All rights reserved.
            </div>
        </div>
    </form>

    <script>
        function toggleEye(inputId, btn) {
            var input = document.getElementById(inputId);
            var icon  = btn.querySelector('i');
            if (input.type === 'password') {
                input.type     = 'text';
                icon.className = 'fa fa-eye-slash';
            } else {
                input.type     = 'password';
                icon.className = 'fa fa-eye';
            }
        }

        function checkStrength(val) {
            var wrap = document.getElementById('strengthWrap');
            if (!val) { wrap.style.display = 'none'; return; }
            wrap.style.display = 'block';

            var score = 0;
            if (val.length >= 8)                        score++;
            if (/[A-Z]/.test(val) && /[a-z]/.test(val)) score++;
            if (/\d/.test(val))                          score++;
            if (/[^a-zA-Z0-9]/.test(val))               score++;

            var labels = ['', 'Weak', 'Fair', 'Good', 'Strong'];
            var cls    = ['', 's1',   's2',   's3',   's4'   ];

            for (var i = 1; i <= 4; i++) {
                var bar = document.getElementById('bar' + i);
                bar.className = 'strength-bar' + (i <= score ? ' ' + cls[score] : '');
            }
            document.getElementById('strengthLabel').innerText =
                'Password strength: ' + (labels[score] || 'Too short');
        }

        function checkMatch() {
            var np = document.getElementById('<%= txtNewPassword.ClientID %>').value;
            var cp = document.getElementById('<%= txtConfirmPassword.ClientID %>').value;
            var el = document.getElementById('mismatchHint');
            if (cp && np !== cp) el.classList.add('show');
            else                  el.classList.remove('show');
        }

        function validateForm() {
            if (!Page_ClientValidate()) return false;
            var np = document.getElementById('<%= txtNewPassword.ClientID %>').value;
            var cp = document.getElementById('<%= txtConfirmPassword.ClientID %>').value;
            if (np !== cp) {
                document.getElementById('mismatchHint').classList.add('show');
                return false;
            }
            return true;
        }

        window.onload = function () {
            var lbl = document.getElementById('<%= lblMessage.ClientID %>');
            if (!lbl || !lbl.innerText.trim()) return;
            var text = lbl.innerText.trim();
            var isSuccess = lbl.style.color.indexOf('0, 128') > -1 ||
                lbl.style.color === 'green' ||
                text.toLowerCase().indexOf('success') > -1 ||
                text.toLowerCase().indexOf('redirect') > -1;
            lbl.className = isSuccess ? 'msg-box msg-success' : 'msg-box msg-error';
            lbl.innerHTML = '<i class="fa ' + (isSuccess ? 'fa-check-circle' : 'fa-exclamation-circle') +
                '"></i><span>' + text + '</span>';
        };
    </script>
</body>
</html>
