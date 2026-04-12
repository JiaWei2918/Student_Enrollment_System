<%@ Page Title="Student Statement" Language="C#" MasterPageFile="~/Student.Master" AutoEventWireup="true" CodeBehind="Statement.aspx.cs" Inherits="StudentEnrollmentSystem.Student.Statement" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<style>
    .stmt-wrap { display: flex; flex-direction: column; gap: 28px; }

    .page-header { display: flex; align-items: flex-start; justify-content: space-between; flex-wrap: wrap; gap: 16px; }
    .page-header-left h2 { font-size: 28px; font-weight: 700; color: #0f172a; margin: 0 0 4px; }
    .page-header-left p  { font-size: 14px; color: #64748b; margin: 0; }

    .btn-group { display: flex; gap: 10px; flex-wrap: wrap; align-items: center; }

    .btn-outline {
        display: inline-flex; align-items: center; gap: 8px;
        padding: 10px 20px;
        background: #fff; color: #374151;
        border: 2px solid #e2e8f0; border-radius: 12px;
        font-size: 14px; font-weight: 600; cursor: pointer;
        transition: all 0.2s;
    }

    .btn-outline:hover { border-color: #94a3b8; background: #f8fafc; }

    .btn-primary {
        display: inline-flex; align-items: center; gap: 8px;
        padding: 10px 20px;
        background: linear-gradient(90deg,#6366f1,#9333ea);
        color: #fff; border: none; border-radius: 12px;
        font-size: 14px; font-weight: 600; cursor: pointer;
        box-shadow: 0 4px 14px rgba(99,102,241,0.3);
        transition: opacity 0.2s, box-shadow 0.2s;
    }

    .btn-primary:hover { opacity: 0.9; box-shadow: 0 8px 22px rgba(99,102,241,0.4); }

    .card {
        background: #fff; border-radius: 16px; padding: 28px;
        border: 1px solid rgba(0,0,0,0.06);
        box-shadow: 0 4px 12px rgba(0,0,0,0.04);
    }

    .card-title { font-size: 17px; font-weight: 700; color: #0f172a; margin: 0 0 20px; }

    .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 28px; }
    .info-section h3 { font-size: 14px; font-weight: 700; color: #0f172a; margin: 0 0 12px; }

    .info-row {
        display: flex; justify-content: space-between;
        font-size: 13px; padding: 5px 0;
        border-bottom: 1px solid #f8fafc;
    }

    .info-row:last-child { border-bottom: none; }
    .info-label { color: #64748b; }
    .info-value { font-weight: 600; color: #0f172a; }

    .summary-grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 20px; }

    .summary-card {
        border-radius: 12px; padding: 18px 20px;
    }

    .summary-card-red    { background: #fef2f2; }
    .summary-card-green  { background: #f0fdf4; }
    .summary-card-amber  { background: #fffbeb; }
    .summary-card-blue   { background: #eff6ff; }
    .sc-label { font-size: 12px; color: #64748b; margin-bottom: 6px; }
    .sc-value { font-size: 22px; font-weight: 700; }
    .sc-red   { color: #dc2626; }
    .sc-green { color: #15803d; }
    .sc-amber { color: #d97706; }
    .sc-blue  { color: #2563eb; }

    .gv-stmt { width: 100%; border-collapse: collapse; }
    .gv-stmt thead tr { background: #f8fafc; border-bottom: 1px solid #e2e8f0; }

    .gv-stmt th {
        padding: 11px 16px; text-align: left;
        font-size: 11px; font-weight: 700; color: #64748b;
        text-transform: uppercase; letter-spacing: 0.06em; white-space: nowrap;
    }

    .gv-stmt th.text-right { text-align: right; }

    .gv-stmt td {
        padding: 14px 16px; font-size: 14px; color: #334155;
        border-bottom: 1px solid #f1f5f9; vertical-align: middle;
    }

    .gv-stmt tr:hover td { background: #fafbff; }

    .gv-stmt .empty-row td {
        text-align: center; padding: 48px; color: #94a3b8; font-size: 14px;
    }

    .date-cell { display: flex; align-items: center; gap: 8px; font-size: 13px; color: #64748b; }
    .date-cell i { font-size: 13px; color: #94a3b8; }

    .type-opening { font-style: italic; color: #94a3b8; }

    .amount-right { text-align: right; font-size: 14px; }
    .debit-val    { color: #dc2626; font-weight: 600; }
    .credit-val   { color: #15803d; font-weight: 600; }
    .balance-val  { font-weight: 700; color: #0f172a; }
    .zero-val     { color: #d1d5db; }

    .stmt-footer {
        display: flex; justify-content: flex-end;
        padding-top: 20px; border-top: 2px solid #e2e8f0;
        margin-top: 4px;
    }

    .closing-box {
        display: flex; align-items: center; justify-content: space-between;
        gap: 48px; background: #f8fafc; border-radius: 12px;
        padding: 16px 24px; min-width: 320px;
        border: 1px solid #e2e8f0;
    }

    .closing-label { font-size: 15px; font-weight: 700; color: #0f172a; }
    .closing-value { font-size: 22px; font-weight: 700; }
    .closing-positive { color: #d97706; }
    .closing-zero     { color: #15803d; }

    .footer-note {
        background: #f8fafc; border-radius: 12px; padding: 14px 18px;
        font-size: 13px; color: #64748b; line-height: 1.6;
        border: 1px solid #e2e8f0;
    }

    .footer-note strong { color: #475569; }

    @media print {
        .btn-group, .page-header .btn-group { display: none !important; }
        .card { box-shadow: none !important; border: 1px solid #e2e8f0 !important; }
    }

    @media (max-width: 900px) {
        .info-grid    { grid-template-columns: 1fr; }
        .summary-grid { grid-template-columns: 1fr 1fr; }
        .page-header  { flex-direction: column; }
    }
    @media (max-width: 600px) {
        .summary-grid { grid-template-columns: 1fr; }
        .closing-box  { min-width: unset; width: 100%; }
        .stmt-footer  { justify-content: stretch; }
    }
</style>

<div class="stmt-wrap">
    <div class="page-header">
        <div class="page-header-left">
            <h2>Student Statement</h2>
            <p>View your financial transactions and balance</p>
        </div>
        <div class="btn-group">
            <button type="button" class="btn-outline" onclick="window.print();">
                <i class="fa fa-print"></i> Print
            </button>
            <asp:Button ID="btnExportPDF" runat="server"
                Text="Download PDF"
                CssClass="btn-primary"
                OnClick="btnExportPDF_Click" />
        </div>
    </div>

    <div class="card">
        <div class="info-grid">
            <div class="info-section">
                <h3>Student Information</h3>
                <div class="info-row">
                    <span class="info-label">Student ID</span>
                    <span class="info-value"><asp:Label ID="lblStudentID" runat="server" /></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Name</span>
                    <span class="info-value"><asp:Label ID="lblStudentName" runat="server" /></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Program</span>
                    <span class="info-value"><asp:Label ID="lblProgram" runat="server" /></span>
                </div>
            </div>

            <div class="info-section">
                <h3>Statement Period</h3>
                <div class="info-row">
                    <span class="info-label">Generated</span>
                    <span class="info-value"><%= DateTime.Now.ToString("dd MMM yyyy") %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Semester</span>
                    <span class="info-value"><asp:Label ID="lblSemester" runat="server" Text="—" /></span>
                </div>
            </div>
        </div>
    </div>

    <div class="summary-grid">
        <div class="summary-card summary-card-red">
            <div class="sc-label">Total Charges</div>
            <div class="sc-value sc-red">
                RM <asp:Label ID="lblTotalDebits" runat="server" Text="0.00" />
            </div>
        </div>
        <div class="summary-card summary-card-green">
            <div class="sc-label">Total Payments</div>
            <div class="sc-value sc-green">
                RM <asp:Label ID="lblTotalCredits" runat="server" Text="0.00" />
            </div>
        </div>
        <div class="summary-card summary-card-amber">
            <div class="sc-label">Current Balance</div>
            <div class="sc-value">
                <asp:Label ID="lblClosing" runat="server" CssClass="sc-amber" Text="0.00" />
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-title">Transaction History</div>

        <div style="overflow-x:auto;">
            <asp:GridView ID="gvStatement" runat="server"
                AutoGenerateColumns="False"
                CssClass="gv-stmt"
                GridLines="None"
                EmptyDataText="No transactions found.">
                <EmptyDataRowStyle CssClass="empty-row" />
                <Columns>
                    <asp:TemplateField HeaderText="Date">
                        <ItemTemplate>
                            <div class="date-cell">
                                <i class="fa fa-calendar"></i>
                                <%# FormatTransDate(Eval("TransDate")) %>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="TransType"  HeaderText="Description" />
                    <asp:BoundField DataField="Reference"  HeaderText="Reference" />

                    <asp:TemplateField HeaderText="Charges" ItemStyle-CssClass="amount-right"
                        HeaderStyle-CssClass="text-right">
                        <ItemTemplate>
                            <%# FormatAmount(Eval("Debit"), "debit") %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Payments" ItemStyle-CssClass="amount-right"
                        HeaderStyle-CssClass="text-right">
                        <ItemTemplate>
                            <%# FormatAmount(Eval("Credit"), "credit") %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Balance" ItemStyle-CssClass="amount-right"
                        HeaderStyle-CssClass="text-right">
                        <ItemTemplate>
                            <span class="balance-val">RM <%# FormatDecimal(Eval("Balance")) %></span>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>

        <div class="stmt-footer">
            <div class="closing-box">
                <span class="closing-label">Closing Balance</span>
                <span class="closing-value">
                    <asp:Label ID="lblClosingFooter" runat="server" CssClass="closing-positive" />
                </span>
            </div>
        </div>
    </div>

    <div class="footer-note">
        <strong>Note:</strong> This statement reflects all financial transactions on your account.
        For questions or discrepancies, please contact the Student Finance Office.
    </div>
</div>
</asp:Content>
