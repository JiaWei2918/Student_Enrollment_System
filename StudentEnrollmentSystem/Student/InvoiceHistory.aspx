<%@ Page Title="Invoice & Adjustment" Language="C#" MasterPageFile="~/Student.Master" AutoEventWireup="true" CodeBehind="InvoiceHistory.aspx.cs" Inherits="StudentEnrollmentSystem.Student.InvoiceHistory" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<style>
   .inv-wrap { display: flex; flex-direction: column; gap: 28px; }

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
    .stat-value { font-size: 22px; font-weight: 700; color: #0f172a; margin: 6px 0 0; line-height: 1; }

    .stat-icon {
        width: 48px; height: 48px; border-radius: 12px;
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0; transition: transform 0.2s;
    }

    .stat-card:hover .stat-icon { transform: scale(1.1); }
    .stat-icon i { font-size: 20px; color: #fff; }
    .icon-red   { background: linear-gradient(135deg,#ef4444,#dc2626); box-shadow: 0 4px 10px rgba(239,68,68,0.3); }
    .icon-green { background: linear-gradient(135deg,#10b981,#14b8a6); box-shadow: 0 4px 10px rgba(16,185,129,0.3); }
    .icon-slate { background: linear-gradient(135deg,#64748b,#475569); box-shadow: 0 4px 10px rgba(100,116,139,0.3); }

    .card {
        background: #fff; border-radius: 16px; padding: 28px;
        border: 1px solid rgba(0,0,0,0.06);
        box-shadow: 0 4px 12px rgba(0,0,0,0.04);
    }

    .card-header {
        display: flex; align-items: center; justify-content: space-between;
        margin-bottom: 20px; flex-wrap: wrap; gap: 12px;
    }

    .card-title { font-size: 17px; font-weight: 700; color: #0f172a; margin: 0; }

    .filter-group { display: flex; gap: 6px; flex-wrap: wrap; }

    .filter-btn {
        padding: 5px 14px; border: 1px solid #e2e8f0;
        border-radius: 99px; background: #fff;
        font-size: 12px; font-weight: 600; color: #64748b;
        cursor: pointer; transition: all 0.2s;
    }

    .filter-btn:hover  { border-color: #6366f1; color: #6366f1; background: #eef2ff; }
    .filter-btn.active { border-color: #6366f1; color: #6366f1; background: #eef2ff; }

    .section-divider {
        margin-top: 20px; padding-top: 20px;
        border-top: 1px solid #f1f5f9;
    }

    .section-sub-title {
        font-size: 14px; font-weight: 700; color: #64748b;
        margin-bottom: 16px; text-transform: uppercase;
        letter-spacing: 0.05em; font-size: 11px;
    }

    .gv-table { width: 100%; border-collapse: collapse; }
    .gv-table thead tr { background: #f8fafc; border-bottom: 1px solid #e2e8f0; }

    .gv-table th {
        padding: 11px 14px; text-align: left;
        font-size: 11px; font-weight: 700; color: #64748b;
        text-transform: uppercase; letter-spacing: 0.06em; white-space: nowrap;
    }

    .gv-table td {
        padding: 16px 14px; font-size: 14px; color: #334155;
        border-bottom: 1px solid #f1f5f9; vertical-align: middle;
    }

    .gv-table tr:hover td { background: #fafbff; }

    .gv-table .empty-row td {
        text-align: center; padding: 48px; color: #94a3b8; font-size: 14px;
    }

    .doc-cell { display: flex; align-items: flex-start; gap: 14px; }

    .doc-icon {
        width: 44px; height: 44px; border-radius: 10px;
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }

    .doc-icon-invoice   { background: #fee2e2; }
    .doc-icon-invoice i { color: #dc2626; font-size: 18px; }
    .doc-icon-adj       { background: #dcfce7; }
    .doc-icon-adj i     { color: #15803d; font-size: 18px; }
    .doc-icon-charge    { background: #fef3c7; }
    .doc-icon-charge i  { color: #d97706; font-size: 18px; }
    .doc-id   { font-size: 14px; font-weight: 700; color: #0f172a; }
    .doc-desc { font-size: 12px; color: #64748b; margin-top: 2px; }

    .amount-debit  { font-size: 15px; font-weight: 700; color: #0f172a; }
    .amount-credit { font-size: 15px; font-weight: 700; color: #15803d; }
    .amount-amber  { font-size: 15px; font-weight: 700; color: #d97706; }
    .paid-sub      { font-size: 11px; color: #94a3b8; margin-top: 2px; }
    .text-right    { text-align: right !important; }

    .date-cell { font-size: 13px; color: #64748b; }

    .btn-action {
        display: inline-flex; align-items: center; gap: 5px;
        font-size: 12px; font-weight: 600; color: #6366f1;
        background: none; border: none; cursor: pointer;
        text-decoration: none; padding: 0; transition: color 0.2s;
    }

    .btn-action:hover { color: #4338ca; }
    .action-sep { color: #e2e8f0; margin: 0 6px; font-size: 13px; }

    .badge {
        display: inline-block; padding: 3px 10px;
        border-radius: 99px; font-size: 11px; font-weight: 600; white-space: nowrap;
    }

    .badge-green  { background: #dcfce7; color: #15803d; }
    .badge-amber  { background: #fef3c7; color: #b45309; }
    .badge-red    { background: #fee2e2; color: #b91c1c; }
    .badge-blue   { background: #dbeafe; color: #1d4ed8; }
    .badge-gray   { background: #f1f5f9; color: #475569; }

    .modal-backdrop {
        position: fixed; inset: 0; background: rgba(0,0,0,0.5);
        backdrop-filter: blur(4px); z-index: 100;
        display: flex; align-items: center; justify-content: center; padding: 20px;
    }

    .modal-box {
        background: #fff; border-radius: 20px;
        width: 100%; max-width: 520px; max-height: 90vh; overflow-y: auto;
        box-shadow: 0 24px 48px rgba(0,0,0,0.15);
        animation: modalIn 0.2s ease;
    }

    @keyframes modalIn {
        from { opacity: 0; transform: scale(0.95) translateY(8px); }
        to   { opacity: 1; transform: scale(1) translateY(0); }
    }

    .modal-header {
        display: flex; align-items: center; justify-content: space-between;
        padding: 20px 24px; border-bottom: 1px solid #f1f5f9;
    }

    .modal-title { font-size: 16px; font-weight: 700; color: #0f172a; }

    .modal-close {
        background: none; border: none; cursor: pointer;
        font-size: 18px; color: #94a3b8; padding: 4px; line-height: 1; transition: color 0.2s;
    }

    .modal-close:hover { color: #374151; }
    .modal-body   { padding: 24px; }
    .modal-footer { display: flex; gap: 12px; padding: 0 24px 24px; }

    .detail-row {
        display: flex; justify-content: space-between; align-items: flex-start;
        font-size: 13px; padding: 10px 0; border-bottom: 1px solid #f8fafc;
    }

    .detail-row:last-child { border-bottom: none; }
    .detail-label { color: #64748b; flex-shrink: 0; margin-right: 16px; }
    .detail-value { font-weight: 600; color: #0f172a; text-align: right; word-break: break-all; }

    .modal-amount-box {
        background: #f8fafc; border-radius: 12px; padding: 14px 18px;
        display: flex; justify-content: space-between; align-items: center;
        margin: 16px 0; border: 1px solid #e2e8f0;
    }

    .modal-amount-label { font-size: 13px; font-weight: 700; color: #0f172a; }
    .modal-amount-val   { font-size: 20px; font-weight: 700; color: #0f172a; }

    .btn-modal-close {
        flex: 1; padding: 11px; border: 2px solid #e2e8f0; border-radius: 12px;
        background: #fff; color: #374151; font-size: 14px; font-weight: 600; cursor: pointer;
        transition: all 0.2s;
    }

    .btn-modal-close:hover { border-color: #94a3b8; background: #f8fafc; }

    .btn-modal-download {
        flex: 1; padding: 11px;
        background: linear-gradient(90deg,#6366f1,#9333ea);
        color: #fff; border: none; border-radius: 12px;
        font-size: 14px; font-weight: 600; cursor: pointer;
        box-shadow: 0 4px 14px rgba(99,102,241,0.3);
        display: flex; align-items: center; justify-content: center; gap: 8px;
        transition: opacity 0.2s;
    }

    .btn-modal-download:hover { opacity: 0.9; }

    .info-note {
        background: #eff6ff; border: 1px solid #bfdbfe;
        border-radius: 12px; padding: 14px 18px;
        font-size: 13px; color: #1e40af; line-height: 1.6;
    }

    .info-note strong { font-weight: 700; }

    .empty-state { text-align: center; padding: 48px 24px; }

    .empty-icon {
        width: 56px; height: 56px; border-radius: 50%; background: #f1f5f9;
        display: flex; align-items: center; justify-content: center; margin: 0 auto 14px;
    }

    .empty-icon i { font-size: 24px; color: #94a3b8; }
    .empty-title  { font-size: 15px; font-weight: 600; color: #475569; margin-bottom: 4px; }
    .empty-sub    { font-size: 13px; color: #94a3b8; }

    @media (max-width: 768px) {
        .stats-row { grid-template-columns: 1fr; }
        .card-header { flex-direction: column; align-items: flex-start; }
        .receipt-grid { grid-template-columns: 1fr; }
    }
</style>

<asp:HiddenField ID="hfInvoiceID"  runat="server" Value="0" />
<asp:HiddenField ID="hfReceiptNo"  runat="server" Value="" />
<asp:HiddenField ID="hfModalType"  runat="server" Value="" />

<div class="inv-wrap">
    <div class="page-header">
        <h2>Invoice &amp; Adjustment Notes</h2>
        <p>View all invoices and adjustments to your account</p>
    </div>

    <div class="stats-row">
        <div class="stat-card">
            <div>
                <div class="stat-label">Total Invoices</div>
                <div class="stat-value" style="color:#dc2626;">
                    RM <asp:Label ID="lblTotalInvoices" runat="server" Text="0.00" />
                </div>
            </div>
            <div class="stat-icon icon-red"><i class="fa fa-file-text"></i></div>
        </div>
        <div class="stat-card">
            <div>
                <div class="stat-label">Total Adjustments</div>
                <div class="stat-value" style="color:#15803d;">
                    RM <asp:Label ID="lblTotalAdjustments" runat="server" Text="0.00" />
                </div>
            </div>
            <div class="stat-icon icon-green"><i class="fa fa-plus-circle"></i></div>
        </div>
        <div class="stat-card">
            <div>
                <div class="stat-label">Net Amount</div>
                <div class="stat-value">
                    RM <asp:Label ID="lblNetAmount" runat="server" Text="0.00" />
                </div>
            </div>
            <div class="stat-icon icon-slate"><i class="fa fa-balance-scale"></i></div>
        </div>
    </div>

    <div class="card">
        <div class="card-header">
            <div class="card-title">All Documents</div>
            <div class="filter-group">
                <button type="button" class="filter-btn active" onclick="filterDocs('all',this)">All</button>
                <button type="button" class="filter-btn" onclick="filterDocs('invoice',this)">Invoices</button>
                <button type="button" class="filter-btn" onclick="filterDocs('adjustment',this)">Adjustments</button>
            </div>
        </div>

        <div id="sectionInvoice">
            <div style="overflow-x:auto;">
                <asp:GridView ID="gvInvoice" runat="server"
                    AutoGenerateColumns="False"
                    CssClass="gv-table"
                    GridLines="None"
                    DataKeyNames="InvoiceID"
                    OnRowCommand="gvInvoice_RowCommand"
                    EmptyDataText="">
                    <EmptyDataRowStyle CssClass="empty-row" />
                    <Columns>
                        <asp:TemplateField HeaderText="Document">
                            <ItemTemplate>
                                <div class="doc-cell">
                                    <div class="doc-icon doc-icon-invoice">
                                        <i class="fa fa-file-text-o"></i>
                                    </div>
                                    <div>
                                        <div class="doc-id"><%# Eval("InvoiceNumber") %></div>
                                        <div class="doc-desc">Tuition Invoice</div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <%# GetInvoiceStatusBadge(Eval("Status")?.ToString()) %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Issue Date">
                            <ItemTemplate>
                                <span class="date-cell"><%# FormatDate(Eval("IssueDate")) %></span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Due Date">
                            <ItemTemplate>
                                <span class="date-cell"><%# FormatDate(Eval("DueDate")) %></span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Amount"
                            HeaderStyle-HorizontalAlign="Right">
                            <ItemTemplate>
                                <div style="text-align:right;">
                                    <div class="amount-debit">
                                        RM <%# string.Format("{0:N2}", Eval("TotalAmount")) %>
                                    </div>
                                    <div class="paid-sub">
                                        Paid: RM <%# string.Format("{0:N2}", Eval("PaidAmount")) %>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Balance"
                            HeaderStyle-HorizontalAlign="Right">
                            <ItemTemplate>
                                <div style="text-align:right;">
                                    <%# GetBalanceDisplay(Eval("Balance"), Eval("Status")?.ToString()) %>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:LinkButton
                                    CommandName="DownloadInvoice"
                                    CommandArgument='<%# Eval("InvoiceID") %>'
                                    CssClass="btn-action" runat="server">
                                    <i class="fa fa-download"></i> Download PDF
                                </asp:LinkButton>
                                <span class="action-sep">|</span>
                                <asp:LinkButton
                                    CommandName="ViewInvoice"
                                    CommandArgument='<%# Eval("InvoiceID") %>'
                                    CssClass="btn-action" runat="server">
                                    View Details
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

            <asp:Panel ID="pnlInvoiceEmpty" runat="server" Visible="false">
                <div class="empty-state">
                    <div class="empty-icon"><i class="fa fa-file-text-o"></i></div>
                    <div class="empty-title">No invoices found</div>
                    <div class="empty-sub">Your invoices will appear here once generated.</div>
                </div>
            </asp:Panel>
        </div>

        <div id="sectionAdjustment" style="display:none;">
            <div class="section-divider">
                <div style="overflow-x:auto;">
                    <asp:GridView ID="gvAdjustment" runat="server"
                        AutoGenerateColumns="False"
                        CssClass="gv-table"
                        GridLines="None"
                        OnRowCommand="gvAdjustment_RowCommand"
                        EmptyDataText="">
                        <EmptyDataRowStyle CssClass="empty-row" />
                        <Columns>
                            <asp:TemplateField HeaderText="Document">
                                <ItemTemplate>
                                    <div class="doc-cell">
                                        <div class='<%# GetAdjIconClass(Eval("AdjustmentType")?.ToString()) %>'>
                                            <i class='<%# GetAdjIconFA(Eval("AdjustmentType")?.ToString()) %>'></i>
                                        </div>
                                        <div>
                                            <div class="doc-id"><%# Eval("ReceiptNumber") %></div>
                                            <div class="doc-desc"><%# Eval("Reason") %></div>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Type">
                                <ItemTemplate>
                                    <%# GetAdjTypeBadge(Eval("AdjustmentType")?.ToString()) %>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Date">
                                <ItemTemplate>
                                    <span class="date-cell"><%# FormatDate(Eval("AdjustmentDate")) %></span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Approved By">
                                <ItemTemplate>
                                    <span style="font-size:13px;color:#64748b;">
                                        <%# Eval("ApprovedByName") %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Amount"
                                HeaderStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <div style="text-align:right;">
                                        <%# GetAdjAmountDisplay(Eval("Amount"), Eval("AdjustmentType")?.ToString()) %>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Actions">
                                <ItemTemplate>
                                    <asp:LinkButton
                                        CommandName="DownloadAdj"
                                        CommandArgument='<%# Eval("ReceiptNumber") %>'
                                        CssClass="btn-action" runat="server">
                                        <i class="fa fa-download"></i> Download PDF
                                    </asp:LinkButton>
                                    <span class="action-sep">|</span>
                                    <asp:LinkButton
                                        CommandName="ViewAdj"
                                        CommandArgument='<%# Eval("ReceiptNumber") %>'
                                        CssClass="btn-action" runat="server">
                                        View Details
                                    </asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

            <asp:Panel ID="pnlAdjEmpty" runat="server" Visible="false">
                <div class="empty-state">
                    <div class="empty-icon"><i class="fa fa-plus-circle"></i></div>
                    <div class="empty-title">No adjustments found</div>
                    <div class="empty-sub">Adjustment notes will appear here when applied to your account.</div>
                </div>
            </asp:Panel>
        </div>
    </div>

    <div class="info-note">
        <strong>Note:</strong> Invoices represent charges to your account, while adjustment notes represent
        credits or reductions. All documents are available for download in PDF format.
    </div>

</div>

<asp:Panel ID="pnlDetail" runat="server" style="display:none;">
    <div class="modal-backdrop" onclick="closeDetail(event)">
        <div class="modal-box" onclick="event.stopPropagation()">

            <div class="modal-header">
                <span class="modal-title">
                    <asp:Label ID="lblDetailTitle" runat="server" Text="Document Details" />
                </span>
                <button type="button" class="modal-close" onclick="closeDetailModal()">&#10005;</button>
            </div>

            <div class="modal-body">
                <asp:PlaceHolder ID="phDetailContent" runat="server" />
            </div>

            <div class="modal-footer">
                <button type="button" class="btn-modal-close" onclick="closeDetailModal()">
                    Close
                </button>
                <asp:Button ID="btnModalDownload" runat="server"
                    Text="Download PDF"
                    CssClass="btn-modal-download"
                    OnClick="btnModalDownload_Click" />
            </div>

        </div>
    </div>
</asp:Panel>

<script>
    function filterDocs(type, btn) {
        document.querySelectorAll('.filter-btn').forEach(function (b) {
            b.classList.remove('active');
        });
        btn.classList.add('active');

        var inv = document.getElementById('sectionInvoice');
        var adj = document.getElementById('sectionAdjustment');

        if (type === 'all') {
            inv.style.display = 'block';
            adj.style.display = 'block';
        } else if (type === 'invoice') {
            inv.style.display = 'block';
            adj.style.display = 'none';
        } else {
            inv.style.display = 'none';
            adj.style.display = 'block';
        }
    }

    function closeDetailModal() {
        document.getElementById('<%= pnlDetail.ClientID %>').style.display = 'none';
    }

    function closeDetail(e) {
        if (e.target === e.currentTarget) closeDetailModal();
    }

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') closeDetailModal();
    });
</script>
</asp:Content>

