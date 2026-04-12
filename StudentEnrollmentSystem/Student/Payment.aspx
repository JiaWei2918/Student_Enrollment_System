<%@ Page Title="Payment" Language="C#" MasterPageFile="~/Student.Master" AutoEventWireup="true" CodeBehind="Payment.aspx.cs" Inherits="StudentEnrollmentSystem.Student.Payment" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<style>
    .pay-wrap { display: flex; flex-direction: column; gap: 28px; }

    .page-header h2 { font-size: 28px; font-weight: 700; color: #0f172a; margin: 0 0 4px; }
    .page-header p  { font-size: 14px; color: #64748b; margin: 0; }

    .balance-banner {
        background: linear-gradient(135deg,#2563eb,#1d4ed8);
        border-radius: 16px; padding: 28px 32px; color: #fff;
        box-shadow: 0 8px 24px rgba(37,99,235,0.3);
    }

    .balance-label { font-size: 13px; color: #bfdbfe; margin-bottom: 6px; }
    .balance-amount { font-size: 40px; font-weight: 700; line-height: 1; margin-bottom: 8px; }
    .balance-sub { font-size: 13px; color: #bfdbfe; }

    .card {
        background: #fff; border-radius: 16px; padding: 28px;
        border: 1px solid rgba(0,0,0,0.06);
        box-shadow: 0 4px 12px rgba(0,0,0,0.04);
    }

    .card-title { font-size: 17px; font-weight: 700; color: #0f172a; margin: 0 0 20px; }

    .gv-invoice { width: 100%; border-collapse: collapse; }
    .gv-invoice thead tr { background: #f8fafc; border-bottom: 1px solid #e2e8f0; }

    .gv-invoice th {
        padding: 11px 14px; text-align: left;
        font-size: 11px; font-weight: 700; color: #64748b;
        text-transform: uppercase; letter-spacing: 0.06em; white-space: nowrap;
    }

    .gv-invoice td {
        padding: 16px 14px; font-size: 14px; color: #334155;
        border-bottom: 1px solid #f1f5f9; vertical-align: middle;
    }

    .gv-invoice tr:hover td { background: #fafbff; }
    .gv-invoice tr.selected-row td { background: #eef2ff; }

    .gv-invoice .empty-row td {
        text-align: center; padding: 48px; color: #94a3b8; font-size: 14px;
    }

    .badge {
        display: inline-block; padding: 3px 10px;
        border-radius: 99px; font-size: 11px; font-weight: 600; white-space: nowrap;
    }

    .badge-green  { background: #dcfce7; color: #15803d; }
    .badge-amber  { background: #fef3c7; color: #b45309; }
    .badge-red    { background: #fee2e2; color: #b91c1c; }
    .badge-blue   { background: #dbeafe; color: #1d4ed8; }
    .badge-gray   { background: #f1f5f9; color: #475569; }

    .amount-val { font-weight: 700; color: #0f172a; }

    .btn-pay-row {
        display: inline-flex; align-items: center; gap: 6px;
        padding: 7px 16px;
        background: linear-gradient(90deg,#6366f1,#9333ea);
        color: #fff; border: none; border-radius: 10px;
        font-size: 13px; font-weight: 600; cursor: pointer;
        box-shadow: 0 3px 10px rgba(99,102,241,0.3);
        transition: opacity 0.2s;
        text-decoration: none;
    }

    .btn-pay-row:hover { opacity: 0.9; color: #fff; }
    .btn-pay-row:disabled,
    .btn-paid { background: #e2e8f0; color: #94a3b8; box-shadow: none; cursor: default; }

    .pay-form-grid {
        display: grid; grid-template-columns: 1fr 320px; gap: 28px; align-items: start;
    }

    .form-group { margin-bottom: 22px; }
    .form-label { display: block; font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 6px; }

    .form-input, .form-select {
        width: 100%; padding: 11px 14px;
        border: 1px solid #e2e8f0; border-radius: 12px;
        font-size: 14px; color: #0f172a; background: #f8fafc;
        outline: none; transition: border-color 0.2s, box-shadow 0.2s;
        box-sizing: border-box; font-family: inherit;
    }

    .form-input:focus, .form-select:focus {
        border-color: #6366f1;
        box-shadow: 0 0 0 3px rgba(99,102,241,0.12);
        background: #fff;
    }

    .input-prefix {
        position: relative;
    }

    .input-prefix span {
        position: absolute; left: 14px; top: 50%;
        transform: translateY(-50%);
        font-size: 14px; color: #94a3b8; pointer-events: none;
    }

    .input-prefix .form-input { padding-left: 36px; }
    .input-hint { font-size: 12px; color: #94a3b8; margin-top: 5px; }
    .input-hint.over { color: #dc2626; }

    .method-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }

    .method-card {
        padding: 14px; border: 2px solid #e2e8f0;
        border-radius: 12px; cursor: pointer;
        display: flex; align-items: center; gap: 10px;
        transition: all 0.2s; background: #fff;
    }

    .method-card:hover { border-color: #a5b4fc; background: #fafbff; }
    .method-card.selected { border-color: #6366f1; background: #eef2ff; }
    .method-card i { font-size: 18px; color: #6366f1; }
    .method-label { font-size: 13px; font-weight: 600; color: #334155; }

    .btn-submit {
        display: flex; align-items: center; justify-content: center; gap: 8px;
        width: 100%; padding: 13px;
        background: linear-gradient(90deg,#6366f1,#9333ea);
        color: #fff; border: none; border-radius: 12px;
        font-size: 15px; font-weight: 600; cursor: pointer;
        box-shadow: 0 4px 14px rgba(99,102,241,0.3);
        margin-top: 8px;
        transition: opacity 0.2s, box-shadow 0.2s;
    }

    .btn-submit:hover { opacity: 0.9; box-shadow: 0 8px 22px rgba(99,102,241,0.4); }

    .summary-row {
        display: flex; justify-content: space-between; align-items: center;
        font-size: 13px; padding: 8px 0;
        border-bottom: 1px solid #f1f5f9;
    }

    .summary-row:last-child { border-bottom: none; }

    .summary-row-total {
        display: flex; justify-content: space-between; align-items: center;
        font-size: 15px; font-weight: 700; padding-top: 12px;
        border-top: 2px solid #e2e8f0; margin-top: 4px;
    }

    .sum-label { color: #64748b; }
    .sum-val   { font-weight: 600; color: #0f172a; }

    .note-box {
        background: #fffbeb; border: 1px solid #fde68a;
        border-radius: 12px; padding: 14px 16px;
        font-size: 13px; color: #92400e; line-height: 1.5; margin-top: 16px;
    }

    .note-box strong { font-weight: 700; }

    .success-state {
        text-align: center; padding: 48px 24px;
    }

    .success-icon {
        width: 64px; height: 64px; border-radius: 50%;
        background: linear-gradient(135deg,#10b981,#14b8a6);
        display: flex; align-items: center; justify-content: center;
        margin: 0 auto 16px;
        box-shadow: 0 8px 20px rgba(16,185,129,0.3);
    }

    .success-icon i { font-size: 28px; color: #fff; }
    .success-title  { font-size: 20px; font-weight: 700; color: #0f172a; margin-bottom: 8px; }
    .success-sub    { font-size: 14px; color: #64748b; }

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

    .msg-processing {
        display: flex; align-items: center; gap: 10px;
        padding: 14px 18px; border-radius: 12px;
        background: #fffbeb; border: 1px solid #fde68a;
        color: #92400e; font-size: 14px; font-weight: 600;
    }

    @media (max-width: 900px) {
        .pay-form-grid { grid-template-columns: 1fr; }
        .method-grid   { grid-template-columns: 1fr; }
    }
</style>

<div class="pay-wrap">
    <div class="page-header">
        <h2>Make a Payment</h2>
        <p>Pay your tuition and fees online</p>
    </div>

    <asp:Label ID="lblMsg" runat="server" />

    <div class="balance-banner">
        <div class="balance-label">Outstanding Balance</div>
        <div class="balance-amount">
            RM <asp:Label ID="lblOutstanding" runat="server" Text="0.00" />
        </div>
        <div class="balance-sub">
            <asp:Label ID="lblSemesterBanner" runat="server" Text="Current Semester" />
        </div>
    </div>

    <div class="card">
        <div class="card-title">My Invoices</div>
        <div style="overflow-x:auto;">
            <asp:GridView ID="gvInvoice" runat="server"
                AutoGenerateColumns="False"
                CssClass="gv-invoice"
                GridLines="None"
                DataKeyNames="InvoiceID"
                OnSelectedIndexChanged="gvInvoice_SelectedIndexChanged"
                OnRowDataBound="gvInvoice_RowDataBound"
                EmptyDataText="No invoices found.">
                <EmptyDataRowStyle CssClass="empty-row" />
                <SelectedRowStyle CssClass="selected-row" />
                <Columns>
                    <asp:BoundField DataField="InvoiceNumber" HeaderText="Invoice No" />

                    <asp:TemplateField HeaderText="Amount">
                        <ItemTemplate>
                            <span class="amount-val">
                                RM <%# string.Format("{0:N2}", Eval("TotalAmount")) %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Due Date">
                        <ItemTemplate>
                            <div style="display:flex;align-items:center;gap:6px;font-size:13px;color:#64748b;">
                                <i class="fa fa-calendar" style="color:#94a3b8;"></i>
                                <%# FormatDate(Eval("DueDate")) %>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate>
                            <%# GetStatusBadge(Eval("Status")?.ToString()) %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Action">
                        <ItemTemplate>
                            <asp:LinkButton
                                CommandName="Select"
                                runat="server"
                                CssClass='<%# IsPayable(Eval("Status")?.ToString()) ? "btn-pay-row" : "btn-pay-row btn-paid" %>'
                                Enabled='<%# IsPayable(Eval("Status")?.ToString()) %>'>
                                <i class="fa fa-credit-card"></i> Pay
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <asp:Panel ID="pnlPayment" runat="server" style="display:none;">
        <div class="pay-form-grid">
            <div class="card">
                <div class="card-title">Payment Details</div>

                <div class="form-group">
                    <label class="form-label">Payment Amount</label>
                    <div class="input-prefix">
                        <span>RM</span>
                        <asp:TextBox ID="txtAmount" runat="server"
                            CssClass="form-input"
                            placeholder="0.00"
                            onkeyup="updateSummary()" />
                    </div>
                    <div class="input-hint" id="hintAmount">
                        Maximum: RM <asp:Label ID="lblMaxAmount" runat="server" Text="0.00" />
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Payment Method</label>
                    <div class="method-grid">
                        <div class="method-card selected" id="mc-card" onclick="selectMethod('Credit Card', this)">
                            <i class="fa fa-credit-card"></i>
                            <span class="method-label">Credit Card</span>
                        </div>
                        <div class="method-card" id="mc-banking" onclick="selectMethod('Online Banking', this)">
                            <i class="fa fa-university"></i>
                            <span class="method-label">Online Banking</span>
                        </div>
                        <div class="method-card" id="mc-transfer" onclick="selectMethod('Bank Transfer', this)">
                            <i class="fa fa-exchange"></i>
                            <span class="method-label">Bank Transfer</span>
                        </div>
                    </div>
                    <asp:DropDownList ID="ddlMethod" runat="server" style="display:none;">
                        <asp:ListItem>Credit Card</asp:ListItem>
                        <asp:ListItem>Online Banking</asp:ListItem>
                        <asp:ListItem>Bank Transfer</asp:ListItem>
                    </asp:DropDownList>
                </div>

                <asp:Button ID="btnPay" runat="server"
                    Text="Process Payment"
                    CssClass="btn-submit"
                    OnClick="btnPay_Click"
                    OnClientClick="return confirmPayment();" />
            </div>

            <div class="card">
                <div class="card-title">Payment Summary</div>

                <div class="summary-row">
                    <span class="sum-label">Invoice</span>
                    <span class="sum-val"><asp:Label ID="lblSummaryInvoice" runat="server" Text="—" /></span>
                </div>
                <div class="summary-row">
                    <span class="sum-label">Outstanding Balance</span>
                    <span class="sum-val">RM <asp:Label ID="lblSummaryBalance" runat="server" Text="0.00" /></span>
                </div>
                <div class="summary-row">
                    <span class="sum-label">Payment Amount</span>
                    <span class="sum-val" id="spanPayAmount">RM 0.00</span>
                </div>
                <div class="summary-row-total">
                    <span>Remaining Balance</span>
                    <span id="spanRemaining">RM 0.00</span>
                </div>

                <div class="note-box">
                    <strong>Note:</strong> Payments may take 1–2 business days to process and reflect in your account.
                </div>
            </div>
        </div>
    </asp:Panel>
</div>

<script>
    var outstandingBalance = 0;

    function showPaymentForm(balance, invoiceNo) {
        outstandingBalance = parseFloat(balance) || 0;
        document.getElementById('<%= pnlPayment.ClientID %>').style.display = 'block';
        document.getElementById('<%= lblSummaryBalance.ClientID %>').innerText = outstandingBalance.toFixed(2);
        document.getElementById('<%= lblMaxAmount.ClientID %>').innerText = outstandingBalance.toFixed(2);
        updateSummary();
        document.getElementById('<%= txtAmount.ClientID %>').focus();
        window.scrollTo({ top: document.getElementById('<%= pnlPayment.ClientID %>').offsetTop - 80, behavior: 'smooth' });
    }

    function updateSummary() {
        var txt = document.getElementById('<%= txtAmount.ClientID %>');
        var amount = parseFloat(txt.value) || 0;
        var remaining = outstandingBalance - amount;

        document.getElementById('spanPayAmount').innerText = 'RM ' + amount.toFixed(2);
        document.getElementById('spanRemaining').innerText = 'RM ' + Math.max(0, remaining).toFixed(2);

        var hint = document.getElementById('hintAmount');
        if (amount > outstandingBalance) {
            hint.className = 'input-hint over';
            hint.innerText = 'Amount exceeds outstanding balance of RM ' + outstandingBalance.toFixed(2);
        } else {
            hint.className = 'input-hint';
            hint.innerText = 'Maximum: RM ' + outstandingBalance.toFixed(2);
        }
    }

    function selectMethod(value, el) {
        document.querySelectorAll('.method-card').forEach(function(c) { c.classList.remove('selected'); });
        el.classList.add('selected');
        var ddl = document.getElementById('<%= ddlMethod.ClientID %>');
        for (var i = 0; i < ddl.options.length; i++) {
            if (ddl.options[i].value === value) { ddl.selectedIndex = i; break; }
        }
    }

    function confirmPayment() {
        var amount = parseFloat(document.getElementById('<%= txtAmount.ClientID %>').value);
        if (!amount || amount <= 0) { alert('Please enter a valid amount.'); return false; }
        if (amount > outstandingBalance) { alert('Amount exceeds outstanding balance.'); return false; }
        return confirm('Process payment of RM ' + amount.toFixed(2) + '?');
    }

    window.onload = function () {
        var lbl = document.getElementById('<%= lblMsg.ClientID %>');
        if (!lbl || !lbl.innerText.trim()) return;
        var cls = lbl.className;
        var text = lbl.innerText.trim();
        if (cls === 'success' || text.toLowerCase().indexOf('success') > -1)
            lbl.className = 'msg-success', lbl.innerHTML = '<i class="fa fa-check-circle"></i> ' + text;
        else if (cls === 'processing' || text.toLowerCase().indexOf('processing') > -1)
            lbl.className = 'msg-processing', lbl.innerHTML = '<i class="fa fa-spinner fa-spin"></i> ' + text;
        else
            lbl.className = 'msg-error', lbl.innerHTML = '<i class="fa fa-exclamation-circle"></i> ' + text;
    };
</script>
</asp:Content>