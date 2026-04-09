<%@ Page Title="Add/Drop History" Language="C#" MasterPageFile="~/Student.Master" AutoEventWireup="true" CodeBehind="AddDropHistory.aspx.cs" Inherits="StudentEnrollmentSystem.Student.AddDropHistory" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<style>
    .history-wrap { display: flex; flex-direction: column; gap: 28px; }

    .page-header h2 { font-size: 28px; font-weight: 700; color: #0f172a; margin: 0 0 4px; }
    .page-header p  { font-size: 14px; color: #64748b; margin: 0; }

    .stats-row {
        display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px;
    }

    .stat-card {
        background: #fff; border-radius: 16px; padding: 22px 24px;
        border: 1px solid rgba(0,0,0,0.06);
        box-shadow: 0 4px 12px rgba(0,0,0,0.04);
        display: flex; align-items: center; justify-content: space-between;
        transition: box-shadow 0.2s, transform 0.2s;
    }

    .stat-card:hover { box-shadow: 0 10px 24px rgba(0,0,0,0.08); transform: translateY(-2px); }
    .stat-label { font-size: 13px; font-weight: 500; color: #64748b; }
    .stat-value { font-size: 32px; font-weight: 700; color: #0f172a; margin: 6px 0 0; line-height: 1; }

    .stat-icon {
        width: 48px; height: 48px; border-radius: 12px;
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0; transition: transform 0.2s;
    }

    .stat-card:hover .stat-icon { transform: scale(1.1); }
    .stat-icon i { font-size: 20px; color: #fff; }
    .icon-slate   { background: linear-gradient(135deg,#64748b,#475569); box-shadow: 0 4px 10px rgba(100,116,139,0.3); }
    .icon-green   { background: linear-gradient(135deg,#10b981,#14b8a6); box-shadow: 0 4px 10px rgba(16,185,129,0.3); }
    .icon-red     { background: linear-gradient(135deg,#ef4444,#dc2626); box-shadow: 0 4px 10px rgba(239,68,68,0.3); }

    .semester-group { display: flex; flex-direction: column; gap: 12px; }

    .semester-heading {
        display: flex; align-items: center; gap: 10px;
        margin-bottom: 4px;
    }
    .semester-heading i { font-size: 16px; color: #6366f1; }
    .semester-heading span { font-size: 16px; font-weight: 700; color: #0f172a; }

    .history-card {
        background: #fff; border-radius: 14px; padding: 18px 20px;
        border: 1px solid rgba(0,0,0,0.06);
        box-shadow: 0 4px 12px rgba(0,0,0,0.04);
        display: flex; align-items: flex-start; gap: 16px;
        transition: box-shadow 0.2s, border-color 0.2s;
    }

    .history-card:hover { box-shadow: 0 8px 20px rgba(0,0,0,0.08); }

    .action-icon {
        width: 44px; height: 44px; border-radius: 50%;
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
    }

    .action-add  { background: #dcfce7; }
    .action-add  i { color: #15803d; font-size: 18px; }
    .action-drop { background: #fee2e2; }
    .action-drop i { color: #b91c1c; font-size: 18px; }

    .hc-body { flex: 1; min-width: 0; }

    .hc-top {
        display: flex; align-items: flex-start;
        justify-content: space-between; gap: 12px;
        margin-bottom: 10px;
    }

    .hc-action-label {
        font-size: 14px; font-weight: 700; color: #0f172a;
    }

    .hc-course-name { font-size: 13px; color: #64748b; margin-top: 2px; }
    .hc-date { font-size: 12px; color: #94a3b8; white-space: nowrap; }

    .hc-meta {
        display: flex; flex-wrap: wrap; gap: 16px; align-items: center;
    }

    .hc-meta-item {
        display: flex; align-items: center; gap: 6px;
        font-size: 12px; color: #64748b;
    }

    .hc-meta-item i { font-size: 12px; color: #94a3b8; }

    .hc-approved {
        margin-top: 10px; padding-top: 10px;
        border-top: 1px solid #f1f5f9;
        font-size: 12px; color: #64748b;
        display: flex; align-items: center; gap: 6px;
    }

    .hc-approved i { color: #94a3b8; font-size: 12px; }

    .badge {
        display: inline-block; padding: 3px 10px;
        border-radius: 99px; font-size: 11px; font-weight: 600; white-space: nowrap;
    }

    .badge-green   { background: #dcfce7; color: #15803d; }
    .badge-amber   { background: #fef3c7; color: #b45309; }
    .badge-red     { background: #fee2e2; color: #b91c1c; }
    .badge-blue    { background: #dbeafe; color: #1d4ed8; }
    .badge-gray    { background: #f1f5f9; color: #475569; }
    .badge-add     { background: #dcfce7; color: #15803d; }
    .badge-drop    { background: #fee2e2; color: #b91c1c; }

    .empty-state {
        background: #fff; border-radius: 16px; padding: 64px 24px;
        border: 1px solid rgba(0,0,0,0.06);
        box-shadow: 0 4px 12px rgba(0,0,0,0.04);
        text-align: center;
    }

    .empty-icon {
        width: 64px; height: 64px; border-radius: 50%;
        background: #f1f5f9;
        display: flex; align-items: center; justify-content: center;
        margin: 0 auto 16px;
    }

    .empty-icon i { font-size: 28px; color: #94a3b8; }
    .empty-title { font-size: 16px; font-weight: 600; color: #475569; margin-bottom: 6px; }
    .empty-sub   { font-size: 13px; color: #94a3b8; }

    .msg-error {
        display: flex; align-items: center; gap: 10px;
        padding: 14px 18px; border-radius: 12px;
        background: #fef2f2; border: 1px solid #fecaca;
        color: #b91c1c; font-size: 14px; font-weight: 600;
    }

    @media (max-width: 768px) {
        .stats-row { grid-template-columns: 1fr; }
        .hc-top    { flex-direction: column; gap: 6px; }
    }
</style>

<div class="history-wrap">
    <div class="page-header">
        <h2>Add / Drop History</h2>
        <p>View your course enrollment change history</p>
    </div>

    <asp:Label ID="lblMessage" runat="server" />

    <div class="stats-row">
        <div class="stat-card">
            <div>
                <div class="stat-label">Total Actions</div>
                <div class="stat-value">
                    <asp:Label ID="lblTotalActions" runat="server" Text="0" />
                </div>
            </div>
            <div class="stat-icon icon-slate"><i class="fa fa-history"></i></div>
        </div>
        <div class="stat-card">
            <div>
                <div class="stat-label">Courses Added</div>
                <div class="stat-value">
                    <asp:Label ID="lblTotalAdded" runat="server" Text="0" />
                </div>
            </div>
            <div class="stat-icon icon-green"><i class="fa fa-plus-circle"></i></div>
        </div>
        <div class="stat-card">
            <div>
                <div class="stat-label">Courses Dropped</div>
                <div class="stat-value">
                    <asp:Label ID="lblTotalDropped" runat="server" Text="0" />
                </div>
            </div>
            <div class="stat-icon icon-red"><i class="fa fa-minus-circle"></i></div>
        </div>
    </div>

    <asp:PlaceHolder ID="phHistory" runat="server" />
</div>
</asp:Content>