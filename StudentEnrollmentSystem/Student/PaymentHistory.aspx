<%@ Page Title="Payment History" Language="C#" MasterPageFile="~/Student.Master" AutoEventWireup="true" CodeBehind="PaymentHistory.aspx.cs" Inherits="StudentEnrollmentSystem.Student.PaymentHistory" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<style>
    .ph-wrap { display: flex; flex-direction: column; gap: 28px; }

    .page-header h2 { font-size: 28px; font-weight: 700; color: #0f172a; margin: 0 0 4px; }
    .page-header p  { font-size: 14px; color: #64748b; margin: 0; }

    .stats-row { display: grid; grid-template-columns: repeat(3,1fr); gap: 20px; }

    .stat-card {
        background: #fff; border-radius: 16px; padding: 22px 24px;
        border: 1px solid rgba(0,0,0,0.06);
        box-shadow: 0 4px 12px rgba(0,0,0,0.04);
        display: flex; align-items: center; justify-content: space-between;
        transition: box-shadow 0.2s, transform 0.2s;
    }

    .stat-card:hover { box-shadow: 0 10px 24px rgba(0,0,0,0.08); transform: translateY(-2px); }
    .stat-label { font-size: 13px; font-weight: 500; color: #64748b; }
    .stat-value { font-size: 28px; font-weight: 700; color: #0f172a; margin: 6px 0 0; line-height: 1; }

    .stat-icon {
        width: 48px; height: 48px; border-radius: 12px;
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0; transition: transform 0.2s;
    }

    .stat-card:hover .stat-icon { transform: scale(1.1); }
    .stat-icon i { font-size: 20px; color: #fff; }
    .icon-slate { background: linear-gradient(135deg,#64748b,#475569); box-shadow: 0 4px 10px rgba(100,116,139,0.3); }
    .icon-green { background: linear-gradient(135deg,#10b981,#14b8a6); box-shadow: 0 4px 10px rgba(16,185,129,0.3); }
    .icon-blue  { background: linear-gradient(135deg,#3b82f6,#06b6d4); box-shadow: 0 4px 10px rgba(59,130,246,0.3); }

    .card {
        background: #fff; border-radius: 16px; padding: 28px;
        border: 1px solid rgba(0,0,0,0.06);
        box-shadow: 0 4px 12px rgba(0,0,0,0.04);
    }

    .card-title { font-size: 17px; font-weight: 700; color: #0f172a; margin: 0 0 20px; }

    .gv-history { width: 100%; border-collapse: collapse; }
    .gv-history thead tr { background: #f8fafc; border-bottom: 1px solid #e2e8f0; }

    .gv-history th {
        padding: 11px 14px; text-align: left;
        font-size: 11px; font-weight: 700; color: #64748b;
        text-transform: uppercase; letter-spacing: 0.06em; white-space: nowrap;
    }

    .gv-history td {
        padding: 16px 14px; font-size: 14px; color: #334155;
        border-bottom: 1px solid #f1f5f9; vertical-align: middle;
    }

    .gv-history tr:hover td { background: #fafbff; }
    .gv-history tr.selected-row td { background: #eef2ff; }

    .gv-history .empty-row td {
        text-align: center; padding: 56px; color: #94a3b8; font-size: 14px;
    }

    .date-cell { display:flex; align-items:center; gap:7px; font-size:13px; color:#64748b; }
    .date-cell i { font-size:12px; color:#94a3b8; }
    .method-cell { display:flex; align-items:center; gap:7px; font-size:13px; }
    .method-cell i { color:#94a3b8; }
    .amount-val { font-weight:700; color:#0f172a; }
    .ref-mono { font-family:monospace; font-size:12px; color:#475569; }

    .badge {
        display:inline-block; padding:3px 10px;
        border-radius:99px; font-size:11px; font-weight:600; white-space:nowrap;
    }

    .badge-green { background:#dcfce7; color:#15803d; }
    .badge-amber { background:#fef3c7; color:#b45309; }
    .badge-red   { background:#fee2e2; color:#b91c1c; }
    .badge-gray  { background:#f1f5f9; color:#475569; }

    .btn-view {
        display:inline-flex; align-items:center; gap:6px;
        padding:6px 14px; background:none;
        border:1px solid #e2e8f0; border-radius:10px; color:#6366f1;
        font-size:13px; font-weight:600; cursor:pointer;
        transition:all 0.2s; text-decoration:none;
    }

    .btn-view:hover { background:#eef2ff; border-color:#c7d2fe; color:#4338ca; }

    .modal-backdrop {
        position:fixed; inset:0; background:rgba(0,0,0,0.5);
        backdrop-filter:blur(4px); z-index:100;
        display:flex; align-items:center; justify-content:center; padding:20px;
    }

    .modal-box {
        background:#fff; border-radius:20px;
        width:100%; max-width:560px; max-height:90vh; overflow-y:auto;
        box-shadow:0 24px 48px rgba(0,0,0,0.15);
        animation:modalIn 0.2s ease;
    }

    @keyframes modalIn {
        from { opacity:0; transform:scale(0.95) translateY(8px); }
        to   { opacity:1; transform:scale(1)    translateY(0); }
    }

    .modal-header {
        display:flex; align-items:center; justify-content:space-between;
        padding:20px 24px; border-bottom:1px solid #f1f5f9;
    }

    .modal-title { font-size:17px; font-weight:700; color:#0f172a; }

    .modal-close {
        background:none; border:none; cursor:pointer;
        font-size:20px; color:#94a3b8; padding:4px; line-height:1; transition:color 0.2s;
    }

    .modal-close:hover { color:#374151; }
    .modal-body { padding:24px; }

    .receipt-header {
        text-align:center; padding-bottom:20px;
        border-bottom:1px solid #f1f5f9; margin-bottom:20px;
    }

    .receipt-uni { font-size:18px; font-weight:700; color:#0f172a; }
    .receipt-sub { font-size:13px; color:#64748b; margin-top:4px; }

    .receipt-grid { display:grid; grid-template-columns:1fr 1fr; gap:16px; margin-bottom:20px; }
    .rg-item .rg-label { font-size:12px; color:#94a3b8; margin-bottom:4px; }
    .rg-item .rg-value { font-size:14px; font-weight:600; color:#0f172a; word-break:break-all; }

    .receipt-amount-box {
        background:#f8fafc; border-radius:12px; padding:16px 20px;
        display:flex; justify-content:space-between; align-items:center;
        margin-bottom:20px; border:1px solid #e2e8f0;
    }

    .ra-label { font-size:14px; font-weight:700; color:#0f172a; }
    .ra-value  { font-size:24px; font-weight:700; color:#0f172a; }

    .modal-footer { display:flex; gap:12px; padding:0 24px 24px; }

    .btn-modal-close {
        flex:1; padding:11px; border:2px solid #e2e8f0; border-radius:12px;
        background:#fff; color:#374151; font-size:14px; font-weight:600; cursor:pointer;
        transition:all 0.2s;
    }

    .btn-modal-close:hover { border-color:#94a3b8; background:#f8fafc; }

    .btn-modal-download {
        flex:1; padding:11px;
        background:linear-gradient(90deg,#6366f1,#9333ea);
        color:#fff; border:none; border-radius:12px;
        font-size:14px; font-weight:600; cursor:pointer;
        box-shadow:0 4px 14px rgba(99,102,241,0.3);
        display:flex; align-items:center; justify-content:center; gap:8px;
        transition:opacity 0.2s, box-shadow 0.2s;
    }

    .btn-modal-download:hover { opacity:0.9; box-shadow:0 8px 22px rgba(99,102,241,0.4); }

    .empty-state { text-align:center; padding:56px 24px; }

    .empty-icon {
        width:64px; height:64px; border-radius:50%; background:#f1f5f9;
        display:flex; align-items:center; justify-content:center; margin:0 auto 16px;
    }

    .empty-icon i { font-size:28px; color:#94a3b8; }
    .empty-title  { font-size:16px; font-weight:600; color:#475569; margin-bottom:6px; }
    .empty-sub    { font-size:13px; color:#94a3b8; }

    @media (max-width:768px) {
        .stats-row    { grid-template-columns:1fr; }
        .receipt-grid { grid-template-columns:1fr; }
    }
</style>

<asp:HiddenField ID="hfSelectedPaymentID" runat="server" Value="0" />

<div class="ph-wrap">
    <div class="page-header">
        <h2>Payment History &amp; Receipts</h2>
        <p>View and download your payment receipts</p>
    </div>

    <div class="stats-row">
        <div class="stat-card">
            <div>
                <div class="stat-label">Total Payments</div>
                <div class="stat-value">
                    <asp:Label ID="lblTotalPayments" runat="server" Text="0" />
                </div>
            </div>
            <div class="stat-icon icon-slate"><i class="fa fa-history"></i></div>
        </div>
        <div class="stat-card">
            <div>
                <div class="stat-label">Total Amount Paid</div>
                <div class="stat-value" style="font-size:22px;">
                    RM <asp:Label ID="lblTotalPaid" runat="server" Text="0.00" />
                </div>
            </div>
            <div class="stat-icon icon-green"><i class="fa fa-check-circle"></i></div>
        </div>
        <div class="stat-card">
            <div>
                <div class="stat-label">Current Year Payments</div>
                <div class="stat-value">
                    <asp:Label ID="lblYearPayments" runat="server" Text="0" />
                </div>
            </div>
            <div class="stat-icon icon-blue"><i class="fa fa-calendar"></i></div>
        </div>
    </div>

    <div class="card">
        <div class="card-title">Payment History</div>

        <div style="overflow-x:auto;">
            <asp:GridView ID="gvHistory" runat="server"
                AutoGenerateColumns="False"
                CssClass="gv-history"
                GridLines="None"
                DataKeyNames="PaymentID"
                OnSelectedIndexChanged="gvHistory_SelectedIndexChanged"
                EmptyDataText="">
                <EmptyDataRowStyle CssClass="empty-row" />
                <SelectedRowStyle CssClass="selected-row" />
                <Columns>
                    <asp:TemplateField HeaderText="Date">
                        <ItemTemplate>
                            <div class="date-cell">
                                <i class="fa fa-calendar"></i>
                                <%# FormatDate(Eval("PaymentDate")) %>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="InvoiceNumber" HeaderText="Description" />

                    <asp:TemplateField HeaderText="Reference">
                        <ItemTemplate>
                            <span class="ref-mono"><%# Eval("PaymentID") %></span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Method">
                        <ItemTemplate>
                            <div class="method-cell">
                                <i class="fa fa-credit-card"></i>
                                <%# Eval("PaymentMethod") %>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Amount">
                        <ItemTemplate>
                            <span class="amount-val">
                                RM <%# string.Format("{0:N2}", Eval("Amount")) %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate>
                            <%# GetStatusBadge(Eval("Status")?.ToString()) %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <asp:LinkButton CommandName="Select" runat="server" CssClass="btn-view">
                                <i class="fa fa-eye"></i> View Receipt
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>

        <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
            <div class="empty-state">
                <div class="empty-icon"><i class="fa fa-credit-card"></i></div>
                <div class="empty-title">No payments yet</div>
                <div class="empty-sub">Your completed payments will appear here.</div>
            </div>
        </asp:Panel>
    </div>
</div>

<asp:Panel ID="pnlReceipt" runat="server" style="display:none;">
    <div class="modal-backdrop" onclick="closeReceipt(event)">
        <div class="modal-box" onclick="event.stopPropagation()">
            <div class="modal-header">
                <span class="modal-title">Payment Receipt</span>
                <button type="button" class="modal-close" onclick="closeReceiptModal()">&#10005;</button>
            </div>

            <div class="modal-body">
                <div class="receipt-header">
                    <div class="receipt-uni">Student Enrollment System</div>
                    <div class="receipt-sub">Official Payment Receipt</div>
                </div>

                <div class="receipt-grid">
                    <div class="rg-item">
                        <div class="rg-label">Receipt Number</div>
                        <div class="rg-value"><asp:Label ID="lblReceiptNo"    runat="server" /></div>
                    </div>
                    <div class="rg-item">
                        <div class="rg-label">Date</div>
                        <div class="rg-value"><asp:Label ID="lblDate"         runat="server" /></div>
                    </div>
                    <div class="rg-item">
                        <div class="rg-label">Invoice Number</div>
                        <div class="rg-value"><asp:Label ID="lblInvoice"      runat="server" /></div>
                    </div>
                    <div class="rg-item">
                        <div class="rg-label">Payment Method</div>
                        <div class="rg-value"><asp:Label ID="lblMethod"       runat="server" /></div>
                    </div>
                    <div class="rg-item" style="grid-column:1/-1;">
                        <div class="rg-label">Transaction ID</div>
                        <div class="rg-value" style="font-family:monospace;font-size:12px;">
                            <asp:Label ID="lblTransaction" runat="server" />
                        </div>
                    </div>
                </div>

                <div class="receipt-amount-box">
                    <span class="ra-label">Amount Paid</span>
                    <span class="ra-value"><asp:Label ID="lblAmount" runat="server" /></span>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn-modal-close" onclick="closeReceiptModal()">
                    Close
                </button>
                <asp:Button ID="btnDownloadReceipt" runat="server"
                    Text="Download PDF"
                    CssClass="btn-modal-download"
                    OnClick="btnDownloadReceipt_Click" />
            </div>
        </div>
    </div>
</asp:Panel>

<script>
    function closeReceiptModal() {
        document.getElementById('<%= pnlReceipt.ClientID %>').style.display = 'none';
    }
    function closeReceipt(e) {
        if (e.target === e.currentTarget) closeReceiptModal();
    }
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') closeReceiptModal();
    });
</script>
</asp:Content>

