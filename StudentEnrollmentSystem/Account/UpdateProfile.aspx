<%@ Page Title="Update Profile" Language="C#" MasterPageFile="~/Student.Master" AutoEventWireup="true" CodeBehind="UpdateProfile.aspx.cs" Inherits="StudentEnrollmentSystem.Account.UpdateProfile" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<style>
    .up-wrap { display: flex; flex-direction: column; gap: 28px; max-width: 860px; }

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

    .card {
        background: #fff; border-radius: 16px; padding: 28px 32px;
        border: 1px solid rgba(0,0,0,0.06);
        box-shadow: 0 4px 12px rgba(0,0,0,0.04);
    }

    .card-title {
        display: flex; align-items: center; gap: 10px;
        font-size: 15px; font-weight: 700; color: #0f172a;
        margin: 0 0 22px; padding-bottom: 16px;
        border-bottom: 1px solid #f1f5f9;
    }

    .card-title i { font-size: 16px; color: #6366f1; }

    .form-grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
    .form-grid-1 { display: grid; grid-template-columns: 1fr; gap: 20px; }
    .col-full    { grid-column: 1 / -1; }

    .form-group { display: flex; flex-direction: column; gap: 6px; }

    .form-label {
        font-size: 13px; font-weight: 600; color: #374151;
    }

    .form-label .optional {
        font-weight: 400; color: #94a3b8; margin-left: 4px; font-size: 12px;
    }

    .input-wrap { position: relative; }

    .input-icon {
        position: absolute; left: 13px; top: 50%;
        transform: translateY(-50%);
        color: #94a3b8; font-size: 14px; pointer-events: none;
    }

    .form-input, .form-textarea {
        width: 100%; padding: 11px 14px 11px 38px;
        border: 1px solid #e2e8f0; border-radius: 12px;
        font-size: 14px; color: #0f172a; background: #f8fafc;
        outline: none; transition: border-color 0.2s, box-shadow 0.2s;
        box-sizing: border-box; font-family: inherit;
    }

    .form-input.no-icon { padding-left: 14px; }

    .form-input:focus, .form-textarea:focus {
        border-color: #6366f1;
        box-shadow: 0 0 0 3px rgba(99,102,241,0.12);
        background: #fff;
    }

    .form-input[readonly] {
        background: #f1f5f9; color: #94a3b8; cursor: not-allowed;
    }

    .form-textarea { resize: none; padding-left: 14px; line-height: 1.6; }
    .field-hint { font-size: 12px; color: #94a3b8; margin-top: 2px; }

    .validator-msg {
        display: block; font-size: 12px; color: #b91c1c; margin-top: 3px;
    }

    .btn-row { display: flex; gap: 12px; margin-top: 4px; }

    .btn-cancel {
        padding: 11px 28px;
        border: 2px solid #e2e8f0; border-radius: 12px;
        background: #fff; color: #374151;
        font-size: 14px; font-weight: 600; cursor: pointer;
        transition: all 0.2s;
    }

    .btn-cancel:hover { border-color: #94a3b8; background: #f8fafc; }

    .btn-save {
        padding: 11px 32px;
        background: linear-gradient(90deg,#6366f1,#9333ea);
        color: #fff; border: none; border-radius: 12px;
        font-size: 14px; font-weight: 600; cursor: pointer;
        box-shadow: 0 4px 14px rgba(99,102,241,0.3);
        transition: opacity 0.2s, box-shadow 0.2s;
    }

    .btn-save:hover { opacity: 0.9; box-shadow: 0 8px 22px rgba(99,102,241,0.4); }

    @media (max-width: 640px) {
        .form-grid-2 { grid-template-columns: 1fr; }
        .btn-row { flex-direction: column; }
        .btn-cancel, .btn-save { width: 100%; text-align: center; }
    }
</style>

<div class="up-wrap">
    <div class="page-header">
        <h2>Update Profile</h2>
        <p>Manage your personal information</p>
    </div>

    <asp:Label ID="lblMessage" runat="server" />

    <div class="card">
        <div class="card-title">
            <i class="fa fa-user"></i> Personal Information
        </div>
        <div class="form-grid-2">

            <div class="form-group">
                <label class="form-label" for="<%= txtFullName.ClientID %>">
                    First Name
                </label>
                <div class="input-wrap">
                    <i class="fa fa-user input-icon"></i>
                    <asp:TextBox ID="txtFullName" runat="server"
                        CssClass="form-input" MaxLength="100"
                        placeholder="Full name" />
                </div>
                <asp:RequiredFieldValidator
                    ControlToValidate="txtFullName"
                    ErrorMessage="Full name is required."
                    CssClass="validator-msg" Display="Dynamic" runat="server" />
            </div>

            <div class="form-group">
                <label class="form-label" for="<%= txtDOB.ClientID %>">
                    Date of Birth
                </label>
                <div class="input-wrap">
                    <i class="fa fa-calendar input-icon"></i>
                    <asp:TextBox ID="txtDOB" runat="server"
                        CssClass="form-input" TextMode="Date" />
                </div>
            </div>

            <div class="form-group">
                <label class="form-label" for="<%= txtPhone.ClientID %>">
                    Phone Number <span class="optional">(optional)</span>
                </label>
                <div class="input-wrap">
                    <i class="fa fa-phone input-icon"></i>
                    <asp:TextBox ID="txtPhone" runat="server"
                        CssClass="form-input" MaxLength="20"
                        placeholder="+60 12-345 6789" />
                </div>
            </div>

            <div class="form-group">
                <label class="form-label" for="<%= txtNationality.ClientID %>">
                    Nationality <span class="optional">(optional)</span>
                </label>
                <div class="input-wrap">
                    <i class="fa fa-globe input-icon"></i>
                    <asp:TextBox ID="txtNationality" runat="server"
                        CssClass="form-input" MaxLength="50"
                        placeholder="e.g. Malaysian" />
                </div>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-title">
            <i class="fa fa-envelope"></i> Contact Information
        </div>
        <div class="form-grid-1">

            <div class="form-group">
                <label class="form-label" for="<%= txtEmail.ClientID %>">
                    Email Address
                </label>
                <div class="input-wrap">
                    <i class="fa fa-envelope input-icon"></i>
                    <asp:TextBox ID="txtEmail" runat="server"
                        CssClass="form-input" MaxLength="100"
                        placeholder="your@email.com" ReadOnly="true" />
                </div>
                <asp:RequiredFieldValidator
                    ControlToValidate="txtEmail"
                    ErrorMessage="Email address is required."
                    CssClass="validator-msg" Display="Dynamic" runat="server" />
                <asp:RegularExpressionValidator
                    ControlToValidate="txtEmail"
                    ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                    ErrorMessage="Please enter a valid email address."
                    CssClass="validator-msg" Display="Dynamic" runat="server" />
                <span class="field-hint">
                    This is your university email and cannot be changed once set.
                </span>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-title">
            <i class="fa fa-map-marker"></i> Address
        </div>
        <div class="form-grid-2">

            <div class="form-group col-full">
                <label class="form-label" for="<%= txtAddress.ClientID %>">
                    Street Address <span class="optional">(optional)</span>
                </label>
                <div class="input-wrap">
                    <asp:TextBox ID="txtAddress" runat="server"
                        CssClass="form-input no-icon" MaxLength="255"
                        placeholder="e.g. 123 Jalan Utama, Taman Maju" />
                </div>
            </div>

            <div class="form-group">
                <label class="form-label" for="<%= txtProgram.ClientID %>">
                    Program <span class="optional">(optional)</span>
                </label>
                <div class="input-wrap">
                    <i class="fa fa-graduation-cap input-icon"></i>
                    <asp:TextBox ID="txtProgram" runat="server"
                        CssClass="form-input" MaxLength="50"
                        placeholder="e.g. Computer Science" />
                </div>
            </div>

            <div class="form-group">
                <label class="form-label" for="<%= txtSection.ClientID %>">
                    Section <span class="optional">(optional)</span>
                </label>
                <div class="input-wrap">
                    <i class="fa fa-users input-icon"></i>
                    <asp:TextBox ID="txtSection" runat="server"
                        CssClass="form-input" MaxLength="10"
                        placeholder="e.g. A" />
                </div>
            </div>
        </div>
    </div>

    <div class="btn-row">
        <button type="button" class="btn-cancel" onclick="resetForm()">Cancel</button>
        <asp:Button ID="btnUpdate" runat="server"
            Text="Save Changes"
            CssClass="btn-save"
            OnClick="btnUpdate_Click"
            OnClientClick="return confirmSave();" />
    </div>
</div>

<script>
    function confirmSave() {
        if (!Page_ClientValidate()) return false;
        return true;
    }

    function resetForm() {
        document.getElementById('<%= txtFullName.ClientID %>').value    = '';
        document.getElementById('<%= txtEmail.ClientID %>').value       = '';
        document.getElementById('<%= txtPhone.ClientID %>').value       = '';
        document.getElementById('<%= txtDOB.ClientID %>').value         = '';
        document.getElementById('<%= txtAddress.ClientID %>').value     = '';
        document.getElementById('<%= txtProgram.ClientID %>').value     = '';
        document.getElementById('<%= txtSection.ClientID %>').value     = '';
        document.getElementById('<%= txtNationality.ClientID %>').value = '';
    }

    window.onload = function () {
        var lbl = document.getElementById('<%= lblMessage.ClientID %>');
        if (!lbl || !lbl.innerText.trim()) return;
        var isError = lbl.style.color === 'red' ||
                      lbl.style.color === 'rgb(255, 0, 0)' ||
                      lbl.style.color.indexOf('255, 0, 0') > -1;
        lbl.className = isError ? 'msg-error' : 'msg-success';
        lbl.innerHTML = '<i class="fa ' + (isError ? 'fa-exclamation-circle' : 'fa-check-circle') +
                        '"></i> ' + lbl.innerText;
    };
</script>
</asp:Content>
