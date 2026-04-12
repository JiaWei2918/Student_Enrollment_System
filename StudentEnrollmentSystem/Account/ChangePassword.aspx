<%@ Page Title="Change Password" Language="C#" MasterPageFile="~/Student.Master" AutoEventWireup="true" CodeBehind="ChangePassword.aspx.cs" Inherits="StudentEnrollmentSystem.Account.ChangePassword" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<style>
    .cp-wrap { display: flex; flex-direction: column; gap: 28px; max-width: 680px; }

    .page-header h2 { font-size: 28px; font-weight: 700; color: #0f172a; margin: 0 0 4px; }
    .page-header p  { font-size: 14px; color: #64748b; margin: 0; }

    .msg-success {
        display: flex; align-items: center; gap: 10px;
        padding: 14px 18px; border-radius: 12px;
        background: #f0fdf4; border: 1px solid #bbf7d0;
        color: #15803d; font-size: 14px; font-weight: 600;
    }

    .msg-error {
        display: flex; align-items: center; gap: 10px;
        padding: 14px 18px; border-radius: 12px;
        background: #fef2f2; border: 1px solid #fecaca;
        color: #b91c1c; font-size: 14px; font-weight: 600;
    }

    .success-state {
        background: #fff; border-radius: 16px; padding: 56px 24px;
        border: 1px solid rgba(0,0,0,0.06);
        box-shadow: 0 4px 12px rgba(0,0,0,0.04);
        text-align: center;
    }

    .success-icon {
        width: 64px; height: 64px; border-radius: 50%;
        background: linear-gradient(135deg,#10b981,#14b8a6);
        display: flex; align-items: center; justify-content: center;
        margin: 0 auto 16px;
        box-shadow: 0 8px 20px rgba(16,185,129,0.3);
    }

    .success-icon i   { font-size: 28px; color: #fff; }
    .success-title    { font-size: 20px; font-weight: 700; color: #0f172a; margin-bottom: 8px; }
    .success-sub      { font-size: 14px; color: #64748b; }

    .card {
        background: #fff; border-radius: 16px; padding: 32px;
        border: 1px solid rgba(0,0,0,0.06);
        box-shadow: 0 4px 12px rgba(0,0,0,0.04);
    }

    .form-group { margin-bottom: 24px; }

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
        width: 100%; padding: 11px 44px 11px 40px;
        border: 1px solid #e2e8f0; border-radius: 12px;
        font-size: 14px; color: #0f172a; background: #f8fafc;
        outline: none; transition: border-color 0.2s, box-shadow 0.2s;
        box-sizing: border-box; font-family: inherit;
    }

    .form-input:focus {
        border-color: #6366f1;
        box-shadow: 0 0 0 3px rgba(99,102,241,0.12);
        background: #fff;
    }

    .eye-btn {
        position: absolute; right: 12px; top: 50%;
        transform: translateY(-50%);
        background: none; border: none; cursor: pointer;
        color: #94a3b8; font-size: 15px; padding: 4px;
        transition: color 0.2s;
    }

    .eye-btn:hover { color: #475569; }

    .validator-msg {
        display: block; font-size: 12px; color: #b91c1c;
        margin-top: 5px;
    }

    .strength-wrap { margin-top: 8px; }
    .strength-bars  { display: flex; gap: 4px; margin-bottom: 5px; }

    .strength-bar   {
        flex: 1; height: 5px; border-radius: 99px;
        background: #e2e8f0; transition: background 0.3s;
    }

    .strength-bar.s1 { background: #ef4444; }
    .strength-bar.s2 { background: #f97316; }
    .strength-bar.s3 { background: #eab308; }
    .strength-bar.s4 { background: #22c55e; }
    .strength-label { font-size: 12px; color: #64748b; }

    .req-box {
        background: #eff6ff; border: 1px solid #bfdbfe;
        border-radius: 12px; padding: 16px 18px; margin-top: 20px;
    }

    .req-title { font-size: 13px; font-weight: 700; color: #1e40af; margin-bottom: 10px; }
    .req-list  { list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 6px; }
    .req-item  { display: flex; align-items: center; gap: 8px; font-size: 13px; color: #1e40af; }
    .req-icon  { font-size: 14px; color: #93c5fd; transition: color 0.2s; }
    .req-icon.met { color: #16a34a; }

    .mismatch-hint { font-size: 12px; color: #b91c1c; margin-top: 5px; display: none; }
    .mismatch-hint.show { display: block; }

    .btn-row { display: flex; gap: 12px; margin-top: 8px; }

    .btn-cancel {
        flex: 1; padding: 12px;
        border: 2px solid #e2e8f0; border-radius: 12px;
        background: #fff; color: #374151;
        font-size: 14px; font-weight: 600; cursor: pointer;
        transition: all 0.2s;
    }

    .btn-cancel:hover { border-color: #94a3b8; background: #f8fafc; }

    .btn-submit {
        flex: 1; padding: 12px;
        background: linear-gradient(90deg,#6366f1,#9333ea);
        color: #fff; border: none; border-radius: 12px;
        font-size: 14px; font-weight: 600; cursor: pointer;
        box-shadow: 0 4px 14px rgba(99,102,241,0.3);
        transition: opacity 0.2s, box-shadow 0.2s;
    }

    .btn-submit:hover { opacity: 0.9; box-shadow: 0 8px 22px rgba(99,102,241,0.4); }

    .btn-submit:disabled {
        background: #e2e8f0; color: #94a3b8;
        box-shadow: none; cursor: not-allowed; opacity: 1;
    }
</style>

<div class="cp-wrap">
    <div class="page-header">
        <h2>Change Password</h2>
        <p>Update your account password</p>
    </div>

    <asp:Label ID="lblMessage" runat="server" />

    <asp:Panel ID="pnlSuccess" runat="server" style="display:none;">
        <div class="success-state">
            <div class="success-icon"><i class="fa fa-check"></i></div>
            <div class="success-title">Password Changed Successfully!</div>
            <div class="success-sub">
                Your password has been updated. Please use your new password on your next login.
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlForm" runat="server" style="display:block;">
        <div class="card">
            <div class="form-group">
                <label class="form-label" for="<%= txtCurrentPassword.ClientID %>">
                    Current Password
                </label>
                <div class="input-wrap">
                    <i class="fa fa-lock input-icon"></i>
                    <asp:TextBox ID="txtCurrentPassword" runat="server"
                        TextMode="Password"
                        CssClass="form-input"
                        placeholder="Enter current password" />
                    <button type="button" class="eye-btn"
                        onclick="toggleEye('<%= txtCurrentPassword.ClientID %>', this)">
                        <i class="fa fa-eye"></i>
                    </button>
                </div>
                <asp:RequiredFieldValidator
                    ControlToValidate="txtCurrentPassword"
                    ErrorMessage="Current password is required."
                    CssClass="validator-msg"
                    Display="Dynamic"
                    runat="server" />
            </div>

            <div class="form-group">
                <label class="form-label" for="<%= txtNewPassword.ClientID %>">
                    New Password
                </label>
                <div class="input-wrap">
                    <i class="fa fa-lock input-icon"></i>
                    <asp:TextBox ID="txtNewPassword" runat="server"
                        TextMode="Password"
                        CssClass="form-input"
                        placeholder="Enter new password"
                        onkeyup="checkStrength(this.value); checkMatch();" />
                    <button type="button" class="eye-btn"
                        onclick="toggleEye('<%= txtNewPassword.ClientID %>', this)">
                        <i class="fa fa-eye"></i>
                    </button>
                </div>
                <asp:RequiredFieldValidator
                    ControlToValidate="txtNewPassword"
                    ErrorMessage="New password is required."
                    CssClass="validator-msg"
                    Display="Dynamic"
                    runat="server" />

                <div class="strength-wrap" id="strengthWrap" style="display:none;">
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
                <label class="form-label" for="<%= txtConfirmPassword.ClientID %>">
                    Confirm New Password
                </label>
                <div class="input-wrap">
                    <i class="fa fa-lock input-icon"></i>
                    <asp:TextBox ID="txtConfirmPassword" runat="server"
                        TextMode="Password"
                        CssClass="form-input"
                        placeholder="Confirm new password"
                        onkeyup="checkMatch();" />
                    <button type="button" class="eye-btn"
                        onclick="toggleEye('<%= txtConfirmPassword.ClientID %>', this)">
                        <i class="fa fa-eye"></i>
                    </button>
                </div>
                <asp:CompareValidator
                    ControlToValidate="txtConfirmPassword"
                    ControlToCompare="txtNewPassword"
                    ErrorMessage="Passwords do not match."
                    CssClass="validator-msg"
                    Display="Dynamic"
                    runat="server" />
                <div class="mismatch-hint" id="mismatchHint">Passwords do not match</div>
            </div>

            <div class="req-box">
                <div class="req-title">Password Requirements:</div>
                <ul class="req-list">
                    <li class="req-item" id="req-len">
                        <i class="fa fa-circle req-icon" id="icon-len"></i>
                        At least 8 characters
                    </li>
                    <li class="req-item" id="req-case">
                        <i class="fa fa-circle req-icon" id="icon-case"></i>
                        Both uppercase and lowercase letters
                    </li>
                    <li class="req-item" id="req-num">
                        <i class="fa fa-circle req-icon" id="icon-num"></i>
                        At least one number
                    </li>
                    <li class="req-item" id="req-special">
                        <i class="fa fa-circle req-icon" id="icon-special"></i>
                        At least one special character
                    </li>
                </ul>
            </div>

            <div class="btn-row" style="margin-top:24px;">
                <button type="button" class="btn-cancel" id="btnCancel" onclick="resetForm()">
                    Cancel
                </button>
                <asp:Button ID="btnChangePassword" runat="server"
                    Text="Change Password"
                    CssClass="btn-submit"
                    OnClick="btnChangePassword_Click"
                    OnClientClick="return validateForm();" />
            </div>
        </div>
    </asp:Panel>
</div>

<script>
    function toggleEye(inputId, btn) {
        var input = document.getElementById(inputId);
        var icon  = btn.querySelector('i');
        if (input.type === 'password') {
            input.type  = 'text';
            icon.className = 'fa fa-eye-slash';
        } else {
            input.type  = 'password';
            icon.className = 'fa fa-eye';
        }
    }

    function checkStrength(val) {
        var wrap = document.getElementById('strengthWrap');
        if (!val) { wrap.style.display = 'none'; return; }
        wrap.style.display = 'block';

        var score = 0;
        var hasLen     = val.length >= 8;
        var hasUpper   = /[A-Z]/.test(val);
        var hasLower   = /[a-z]/.test(val);
        var hasNum     = /\d/.test(val);
        var hasSpecial = /[^a-zA-Z0-9]/.test(val);

        if (hasLen)                  score++;
        if (hasUpper && hasLower)    score++;
        if (hasNum)                  score++;
        if (hasSpecial)              score++;

        var labels = ['', 'Weak', 'Fair', 'Good', 'Strong'];
        var cls    = ['', 's1',   's2',   's3',   's4'   ];

        for (var i = 1; i <= 4; i++) {
            var bar = document.getElementById('bar' + i);
            bar.className = 'strength-bar' + (i <= score ? ' ' + cls[score] : '');
        }
        document.getElementById('strengthLabel').innerText =
            'Password strength: ' + (labels[score] || 'Too short');

        setReq('icon-len',     hasLen);
        setReq('icon-case',    hasUpper && hasLower);
        setReq('icon-num',     hasNum);
        setReq('icon-special', hasSpecial);
    }

    function setReq(id, met) {
        var el = document.getElementById(id);
        el.className = met ? 'fa fa-check-circle req-icon met' : 'fa fa-circle req-icon';
    }

    function checkMatch() {
        var newPwd  = document.getElementById('<%= txtNewPassword.ClientID %>').value;
        var confirm = document.getElementById('<%= txtConfirmPassword.ClientID %>').value;
        var hint    = document.getElementById('mismatchHint');
        if (confirm && newPwd !== confirm)
            hint.classList.add('show');
        else
            hint.classList.remove('show');
    }

    function validateForm() {
        var cur     = document.getElementById('<%= txtCurrentPassword.ClientID %>').value;
        var newPwd  = document.getElementById('<%= txtNewPassword.ClientID %>').value;
        var confirm = document.getElementById('<%= txtConfirmPassword.ClientID %>').value;

        if (!cur || !newPwd || !confirm) return true;
        if (newPwd !== confirm) {
            document.getElementById('mismatchHint').classList.add('show');
            return false;
        }
        return true;
    }

    function resetForm() {
        document.getElementById('<%= txtCurrentPassword.ClientID %>').value = '';
        document.getElementById('<%= txtNewPassword.ClientID %>').value     = '';
        document.getElementById('<%= txtConfirmPassword.ClientID %>').value = '';
        document.getElementById('strengthWrap').style.display = 'none';
        document.getElementById('mismatchHint').classList.remove('show');
        ['icon-len','icon-case','icon-num','icon-special'].forEach(function(id) {
            document.getElementById(id).className = 'fa fa-circle req-icon';
        });
    }

    window.onload = function () {
        var lbl = document.getElementById('<%= lblMessage.ClientID %>');
        if (!lbl || !lbl.innerText.trim()) return;
        var text    = lbl.innerText.trim();
        var isError = lbl.style.color === 'red' || lbl.style.color === 'rgb(255, 0, 0)' ||
                      lbl.style.color.indexOf('255, 0, 0') > -1;
        lbl.className = isError ? 'msg-error' : 'msg-success';
        lbl.innerHTML = '<i class="fa ' + (isError ? 'fa-exclamation-circle' : 'fa-check-circle') +
                        '"></i> ' + text;
    };
</script>
</asp:Content>

