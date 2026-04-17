<%@ Page Title="Update Bank Details" Language="C#" MasterPageFile="~/Student.Master" AutoEventWireup="true" CodeBehind="UpdateBankDetail.aspx.cs" Inherits="StudentEnrollmentSystem.Account.UpdateBank" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<style>
    .bank-wrap { display: flex; flex-direction: column; gap: 28px; max-width: 900px; }

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

    .notice-amber {
        display: flex; align-items: flex-start; gap: 14px;
        padding: 16px 20px; border-radius: 14px;
        background: #fffbeb; border: 1px solid #fde68a;
    }

    .notice-icon {
        width: 36px; height: 36px; border-radius: 10px;
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
        background: linear-gradient(135deg,#f59e0b,#f97316);
        box-shadow: 0 4px 10px rgba(245,158,11,0.3);
    }

    .notice-icon i { font-size: 15px; color: #fff; }
    .notice-title { font-size: 14px; font-weight: 700; color: #92400e; margin-bottom: 3px; }
    .notice-text  { font-size: 13px; color: #b45309; line-height: 1.5; }

    .card {
        background: #fff; border-radius: 16px; padding: 28px 32px;
        border: 1px solid rgba(0,0,0,0.06);
        box-shadow: 0 4px 12px rgba(0,0,0,0.04);
    }

    .card-header {
        display: flex; align-items: center; justify-content: space-between;
        margin-bottom: 24px; padding-bottom: 16px;
        border-bottom: 1px solid #f1f5f9; flex-wrap: wrap; gap: 12px;
    }

    .card-header-left { display: flex; align-items: center; gap: 14px; }

    .card-icon {
        width: 48px; height: 48px; border-radius: 12px;
        background: linear-gradient(135deg,#6366f1,#9333ea);
        display: flex; align-items: center; justify-content: center;
        box-shadow: 0 4px 12px rgba(99,102,241,0.3);
    }

    .card-icon i { font-size: 20px; color: #fff; }
    .card-title { font-size: 17px; font-weight: 700; color: #0f172a; }
    .card-sub   { font-size: 13px; color: #64748b; margin-top: 2px; }

    .btn-edit {
        display: inline-flex; align-items: center; gap: 8px;
        padding: 9px 20px;
        background: linear-gradient(90deg,#6366f1,#9333ea);
        color: #fff; border: none; border-radius: 12px;
        font-size: 13px; font-weight: 600; cursor: pointer;
        box-shadow: 0 4px 12px rgba(99,102,241,0.3);
        transition: opacity 0.2s;
    }

    .btn-edit:hover { opacity: 0.9; }

    .form-grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
    .col-full    { grid-column: 1 / -1; }
    .form-group  { display: flex; flex-direction: column; gap: 6px; }
    .form-label  { font-size: 13px; font-weight: 600; color: #374151; }
    .input-wrap  { position: relative; }

    .input-icon  {
        position: absolute; left: 13px; top: 50%;
        transform: translateY(-50%);
        color: #94a3b8; font-size: 14px; pointer-events: none;
    }

    .form-input, .form-select {
        width: 100%; padding: 11px 14px 11px 38px;
        border: 1px solid #e2e8f0; border-radius: 12px;
        font-size: 14px; color: #0f172a; background: #f8fafc;
        outline: none; transition: border-color 0.2s, box-shadow 0.2s;
        box-sizing: border-box; font-family: inherit;
    }

    .form-input.no-icon, .form-select.no-icon { padding-left: 14px; }

    .form-input:focus, .form-select:focus {
        border-color: #6366f1;
        box-shadow: 0 0 0 3px rgba(99,102,241,0.12);
        background: #fff;
    }

    .form-input[disabled], .form-select[disabled],
    .form-input.disabled, .form-select.disabled {
        background: #f1f5f9; color: #94a3b8; cursor: not-allowed;
    }

    .field-hint { font-size: 12px; color: #94a3b8; margin-top: 2px; }

    .validator-msg { display: block; font-size: 12px; color: #b91c1c; margin-top: 3px; }

    .primary-row {
        display: flex; align-items: center; gap: 10px;
        padding: 13px 16px; border-radius: 12px;
        border: 1px solid #e2e8f0; background: #f8fafc;
        cursor: pointer;
    }

    .primary-row input  { width: 18px; height: 18px; accent-color: #6366f1; cursor: pointer; }
    .primary-row label  { font-size: 14px; font-weight: 500; color: #374151; cursor: pointer; }

    .btn-row { display: flex; gap: 12px; margin-top: 24px; }

    .btn-cancel {
        padding: 11px 24px; border: 2px solid #e2e8f0; border-radius: 12px;
        background: #fff; color: #374151; font-size: 14px; font-weight: 600;
        cursor: pointer; transition: all 0.2s;
    }

    .btn-cancel:hover { border-color: #94a3b8; background: #f8fafc; }

    .btn-save {
        padding: 11px 28px;
        background: linear-gradient(90deg,#6366f1,#9333ea);
        color: #fff; border: none; border-radius: 12px;
        font-size: 14px; font-weight: 600; cursor: pointer;
        box-shadow: 0 4px 14px rgba(99,102,241,0.3);
        transition: opacity 0.2s, box-shadow 0.2s;
    }

    .btn-save:hover { opacity: 0.9; box-shadow: 0 8px 22px rgba(99,102,241,0.4); }

    .gv-bank { width: 100%; border-collapse: collapse; }
    .gv-bank thead tr { background: #f8fafc; border-bottom: 1px solid #e2e8f0; }

    .gv-bank th {
        padding: 11px 14px; text-align: left;
        font-size: 11px; font-weight: 700; color: #64748b;
        text-transform: uppercase; letter-spacing: 0.06em; white-space: nowrap;
    }

    .gv-bank td {
        padding: 16px 14px; font-size: 14px; color: #334155;
        border-bottom: 1px solid #f1f5f9; vertical-align: middle;
    }

    .gv-bank tr:hover td { background: #fafbff; }

    .gv-bank .empty-row td {
        text-align: center; padding: 48px; color: #94a3b8; font-size: 14px;
    }

    .bank-cell { display: flex; align-items: center; gap: 12px; }

    .bank-avatar {
        width: 40px; height: 40px; border-radius: 10px;
        background: linear-gradient(135deg,#6366f1,#9333ea);
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
        box-shadow: 0 3px 8px rgba(99,102,241,0.25);
    }

    .bank-avatar i { font-size: 16px; color: #fff; }
    .bank-name  { font-size: 14px; font-weight: 700; color: #0f172a; }
    .bank-acct  { font-size: 12px; color: #64748b; font-family: monospace; margin-top: 1px; }

    .badge-primary { background: linear-gradient(90deg,#6366f1,#9333ea); color: #fff; }

    .badge {
        display: inline-block; padding: 3px 10px;
        border-radius: 99px; font-size: 11px; font-weight: 600; white-space: nowrap;
    }

    .badge-gray { background: #f1f5f9; color: #475569; }

    .btn-row-action {
        display: inline-flex; align-items: center; gap: 5px;
        padding: 6px 12px; border-radius: 9px;
        font-size: 12px; font-weight: 600; cursor: pointer;
        border: 1px solid; transition: all 0.2s; background: none;
        text-decoration: none;
    }

    .btn-row-edit   { color: #6366f1; border-color: #c7d2fe; }
    .btn-row-edit:hover   { background: #eef2ff; }
    .btn-row-delete { color: #dc2626; border-color: #fecaca; }
    .btn-row-delete:hover { background: #fef2f2; }

    .security-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }

    .security-card {
        border-radius: 14px; padding: 20px;
        display: flex; align-items: flex-start; gap: 14px;
    }

    .sc-blue   { background: linear-gradient(135deg,#eff6ff,#ecfeff); border: 1px solid #bfdbfe; }
    .sc-purple { background: linear-gradient(135deg,#faf5ff,#fdf2f8); border: 1px solid #e9d5ff; }

    .sc-icon {
        width: 44px; height: 44px; border-radius: 10px;
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }

    .sc-icon-blue   { background: linear-gradient(135deg,#3b82f6,#06b6d4); box-shadow: 0 4px 10px rgba(59,130,246,0.3); }
    .sc-icon-purple { background: linear-gradient(135deg,#a855f7,#ec4899); box-shadow: 0 4px 10px rgba(168,85,247,0.3); }
    .sc-icon i { font-size: 18px; color: #fff; }
    .sc-title { font-size: 14px; font-weight: 700; margin-bottom: 4px; }
    .sc-blue   .sc-title   { color: #1e40af; }
    .sc-purple .sc-title   { color: #6d28d9; }
    .sc-text { font-size: 13px; line-height: 1.5; }
    .sc-blue   .sc-text    { color: #1d4ed8; }
    .sc-purple .sc-text    { color: #7c3aed; }

    .usage-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-top: 20px; }
    .usage-item { display: flex; align-items: flex-start; gap: 10px; }

    .usage-check {
        width: 22px; height: 22px; border-radius: 6px;
        background: #dcfce7;
        display: flex; align-items: center; justify-content: center; flex-shrink: 0; margin-top: 2px;
    }

    .usage-check i { font-size: 11px; color: #15803d; }
    .usage-title { font-size: 13px; font-weight: 700; color: #0f172a; }
    .usage-sub   { font-size: 12px; color: #64748b; margin-top: 1px; }

    @media (max-width: 720px) {
        .form-grid-2  { grid-template-columns: 1fr; }
        .security-grid{ grid-template-columns: 1fr; }
        .usage-grid   { grid-template-columns: 1fr; }
    }
</style>

<asp:HiddenField ID="hfBankDetailID" runat="server" />

<div class="bank-wrap">
    <div class="page-header">
        <h2>Update Bank Details</h2>
        <p>Manage your banking information for refunds and payments</p>
    </div>

    <asp:Label ID="lblMessage" runat="server" />

    <div class="notice-amber">
        <div class="notice-icon"><i class="fa fa-exclamation-triangle"></i></div>
        <div>
            <div class="notice-title">Important Information</div>
            <div class="notice-text">
                Bank details are used for refunds and scholarship disbursements.
                Please ensure all information is accurate.
                Changes may take 3–5 business days to process.
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-header">
            <div class="card-header-left">
                <div class="card-icon"><i class="fa fa-university"></i></div>
                <div>
                    <div class="card-title">Bank Account Information</div>
                    <div class="card-sub">Secure and encrypted</div>
                </div>
            </div>
        </div>

        <div class="form-grid-2">
            <div class="form-group col-full">
                <label class="form-label" for="<%= txtHolderName.ClientID %>">
                    Account Holder Name
                </label>
                <div class="input-wrap">
                    <i class="fa fa-user input-icon"></i>
                    <asp:TextBox ID="txtHolderName" runat="server"
                        CssClass="form-input" MaxLength="100"
                        placeholder="Must match the name on your bank account" />
                </div>
                <asp:RequiredFieldValidator
                    ControlToValidate="txtHolderName"
                    ErrorMessage="Account holder name is required."
                    CssClass="validator-msg" Display="Dynamic" runat="server" />
                <span class="field-hint">Must match the name on your bank account</span>
            </div>

            <div class="form-group">
                <label class="form-label" for="<%= txtBankName.ClientID %>">
                    Bank Name
                </label>
                <div class="input-wrap">
                    <i class="fa fa-building input-icon"></i>
                    <asp:TextBox ID="txtBankName" runat="server"
                        CssClass="form-input" MaxLength="100"
                        placeholder="e.g. Maybank, CIMB, Public Bank" />
                </div>
                <asp:RequiredFieldValidator
                    ControlToValidate="txtBankName"
                    ErrorMessage="Bank name is required."
                    CssClass="validator-msg" Display="Dynamic" runat="server" />
            </div>

            <div class="form-group">
                <label class="form-label" for="<%= ddlType.ClientID %>">
                    Account Type
                </label>
                <div class="input-wrap">
                    <asp:DropDownList ID="ddlType" runat="server" CssClass="form-select no-icon">
                        <asp:ListItem Text="Savings Account"  Value="Savings" />
                        <asp:ListItem Text="Current Account"  Value="Current" />
                    </asp:DropDownList>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label" for="<%= txtAccountNumber.ClientID %>">
                    Account Number
                </label>
                <div class="input-wrap">
                    <i class="fa fa-credit-card input-icon"></i>
                    <asp:TextBox ID="txtAccountNumber" runat="server"
                        CssClass="form-input" MaxLength="20"
                        placeholder="Enter account number" />
                </div>
                <asp:RequiredFieldValidator
                    ControlToValidate="txtAccountNumber"
                    ErrorMessage="Account number is required."
                    CssClass="validator-msg" Display="Dynamic" runat="server" />
                <asp:RegularExpressionValidator
                    ControlToValidate="txtAccountNumber"
                    ValidationExpression="^\d{8,20}$"
                    ErrorMessage="Account number must be 8–20 digits."
                    CssClass="validator-msg" Display="Dynamic" runat="server" />
            </div>

            <div class="form-group" style="justify-content:flex-end;">
                <label class="form-label">&nbsp;</label>
                <div class="primary-row">
                    <asp:CheckBox ID="chkPrimary" runat="server" />
                    <label for="<%= chkPrimary.ClientID %>">Set as primary account</label>
                </div>
            </div>
        </div>

        <div class="btn-row">
            <button type="button" class="btn-cancel" onclick="cancelEdit()">Cancel</button>
            <asp:Button ID="btnSave" runat="server"
                Text="Save Changes"
                CssClass="btn-save"
                OnClick="btnSave_Click"
                OnClientClick="return Page_ClientValidate();" />
        </div>
    </div>

    <div class="card">
        <div class="card-header">
            <div class="card-title" style="font-size:17px;">My Bank Accounts</div>
        </div>

        <div style="overflow-x:auto;">
            <asp:GridView ID="gvBank" runat="server"
                AutoGenerateColumns="False"
                CssClass="gv-bank"
                GridLines="None"
                DataKeyNames="BankDetailID"
                OnRowEditing="gvBank_RowEditing"
                OnRowDeleting="gvBank_RowDeleting"
                EmptyDataText="">
                <EmptyDataRowStyle CssClass="empty-row" />
                <Columns>

                    <asp:TemplateField HeaderText="Bank">
                        <ItemTemplate>
                            <div class="bank-cell">
                                <div class="bank-avatar"><i class="fa fa-university"></i></div>
                                <div>
                                    <div class="bank-name"><%# Eval("BankName") %></div>
                                    <div class="bank-acct"><%# Eval("AccountNumber") %></div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="AccountHolderName" HeaderText="Account Holder" />

                    <asp:TemplateField HeaderText="Type">
                        <ItemTemplate>
                            <span class="badge badge-gray"><%# Eval("AccountType") %></span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Primary">
                        <ItemTemplate>
                            <%# Convert.ToBoolean(Eval("IsPrimary"))
                                ? "<span class='badge badge-primary'>Primary</span>"
                                : "<span class='badge badge-gray'>—</span>" %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <asp:LinkButton CommandName="Edit" runat="server"
                                CssClass="btn-row-action btn-row-edit"
                                CausesValidation="false">
                                <i class="fa fa-pencil"></i> Edit
                            </asp:LinkButton>
                            &nbsp;
                            <asp:LinkButton CommandName="Delete" runat="server"
                                CssClass="btn-row-action btn-row-delete"
                                CausesValidation="false"
                                OnClientClick="return confirm('Delete this bank account?');">
                                <i class="fa fa-trash"></i> Delete
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>

        <asp:Panel ID="pnlBankEmpty" runat="server" Visible="false">
            <div style="text-align:center;padding:48px 24px;">
                <div style="width:56px;height:56px;border-radius:50%;background:#f1f5f9;
                            display:flex;align-items:center;justify-content:center;margin:0 auto 14px;">
                    <i class="fa fa-university" style="font-size:24px;color:#94a3b8;"></i>
                </div>
                <div style="font-size:15px;font-weight:600;color:#475569;margin-bottom:4px;">
                    No bank accounts added
                </div>
                <div style="font-size:13px;color:#94a3b8;">
                    Add a bank account using the form above.
                </div>
            </div>
        </asp:Panel>
    </div>

    <div class="security-grid">
        <div class="security-card sc-blue">
            <div class="sc-icon sc-icon-blue"><i class="fa fa-shield"></i></div>
            <div>
                <div class="sc-title">Bank-Level Security</div>
                <div class="sc-text">
                    Your bank details are encrypted using 256-bit SSL encryption and stored securely.
                </div>
            </div>
        </div>
        <div class="security-card sc-purple">
            <div class="sc-icon sc-icon-purple"><i class="fa fa-lock"></i></div>
            <div>
                <div class="sc-title">Privacy Protected</div>
                <div class="sc-text">
                    We will never share your banking information with third parties without your consent.
                </div>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-header" style="margin-bottom:0;border-bottom:none;">
            <div class="card-header-left">
                <div class="card-icon" style="background:linear-gradient(135deg,#10b981,#14b8a6);box-shadow:0 4px 12px rgba(16,185,129,0.3);">
                    <i class="fa fa-credit-card"></i>
                </div>
                <div>
                    <div class="card-title">How We Use Your Bank Details</div>
                    <div class="card-sub">Your banking information helps us process transactions efficiently</div>
                </div>
            </div>
        </div>
        <div class="usage-grid">
            <div class="usage-item">
                <div class="usage-check"><i class="fa fa-check"></i></div>
                <div>
                    <div class="usage-title">Tuition Refunds</div>
                    <div class="usage-sub">Direct deposit of overpayments</div>
                </div>
            </div>
            <div class="usage-item">
                <div class="usage-check"><i class="fa fa-check"></i></div>
                <div>
                    <div class="usage-title">Scholarship Payments</div>
                    <div class="usage-sub">Automatic disbursement processing</div>
                </div>
            </div>
            <div class="usage-item">
                <div class="usage-check"><i class="fa fa-check"></i></div>
                <div>
                    <div class="usage-title">Financial Aid</div>
                    <div class="usage-sub">Quick transfer of aid funds</div>
                </div>
            </div>
            <div class="usage-item">
                <div class="usage-check"><i class="fa fa-check"></i></div>
                <div>
                    <div class="usage-title">Other Credits</div>
                    <div class="usage-sub">Various account credit disbursements</div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    function cancelEdit() {
        document.getElementById('<%= hfBankDetailID.ClientID %>').value = '';
        document.getElementById('<%= txtBankName.ClientID %>').value    = '';
        document.getElementById('<%= txtAccountNumber.ClientID %>').value = '';
        document.getElementById('<%= txtHolderName.ClientID %>').value  = '';
        document.getElementById('<%= chkPrimary.ClientID %>').checked   = false;
        var ddl = document.getElementById('<%= ddlType.ClientID %>');
        if (ddl) ddl.selectedIndex = 0;
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
