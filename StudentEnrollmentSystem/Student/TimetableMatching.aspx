<%@ Page Title="Timetable Matching" Language="C#" MasterPageFile="~/Student.Master" AutoEventWireup="true" CodeBehind="TimetableMatching.aspx.cs" Inherits="StudentEnrollmentSystem.Student.TimetableMatching" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<style>
    .tt-wrap { display: flex; flex-direction: column; gap: 28px; }

    .page-header h2 { font-size: 28px; font-weight: 700; color: #0f172a; margin: 0 0 4px; }
    .page-header p  { font-size: 14px; color: #64748b; margin: 0; }

    .card {
        background: #fff; border-radius: 16px; padding: 28px;
        border: 1px solid rgba(0,0,0,0.06);
        box-shadow: 0 4px 12px rgba(0,0,0,0.04);
    }

    .card-title { font-size: 17px; font-weight: 700; color: #0f172a; margin: 0 0 20px; }

    .compat-grid {
        display: grid; grid-template-columns: 1fr 1fr; gap: 20px;
        align-items: end;
    }

    .form-group { display: flex; flex-direction: column; gap: 6px; }
    .form-label { font-size: 13px; font-weight: 600; color: #374151; }

    .form-select {
        width: 100%; padding: 11px 14px;
        border: 1px solid #e2e8f0; border-radius: 12px;
        font-size: 14px; color: #0f172a; background: #f8fafc;
        outline: none; transition: border-color 0.2s, box-shadow 0.2s;
        box-sizing: border-box;
    }

    .form-select:focus {
        border-color: #6366f1;
        box-shadow: 0 0 0 3px rgba(99,102,241,0.12);
        background: #fff;
    }

    .btn-search {
        display: inline-flex; align-items: center; gap: 8px;
        padding: 11px 24px; width: 100%;
        background: linear-gradient(90deg,#6366f1,#9333ea);
        color: #fff; border: none; border-radius: 12px;
        font-size: 14px; font-weight: 600; cursor: pointer;
        box-shadow: 0 4px 14px rgba(99,102,241,0.3);
        justify-content: center;
        transition: opacity 0.2s, box-shadow 0.2s;
    }

    .btn-search:hover { opacity: 0.9; box-shadow: 0 8px 22px rgba(99,102,241,0.4); }

    .notice-box {
        display: flex; align-items: flex-start; gap: 14px;
        padding: 16px 20px; border-radius: 14px; border: 1px solid;
    }

    .notice-green  { background: #f0fdf4; border-color: #bbf7d0; }
    .notice-amber  { background: #fffbeb; border-color: #fde68a; }
    .notice-red    { background: #fef2f2; border-color: #fecaca; }

    .notice-icon {
        width: 36px; height: 36px; border-radius: 10px;
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }

    .ni-green  { background: linear-gradient(135deg,#10b981,#14b8a6); box-shadow: 0 4px 10px rgba(16,185,129,0.3); }
    .ni-amber  { background: linear-gradient(135deg,#f59e0b,#f97316); box-shadow: 0 4px 10px rgba(245,158,11,0.3); }
    .ni-red    { background: linear-gradient(135deg,#ef4444,#dc2626); box-shadow: 0 4px 10px rgba(239,68,68,0.3); }
    .notice-icon i { font-size: 15px; color: #fff; }
    .notice-title  { font-size: 14px; font-weight: 700; }
    .notice-text   { font-size: 13px; margin-top: 2px; line-height: 1.5; }
    .nt-green { color: #15803d; }
    .nt-amber { color: #92400e; }
    .nt-red   { color: #991b1b; }

    .gv-courses { width: 100%; border-collapse: collapse; }

    .gv-courses thead tr {
        background: #f8fafc; border-bottom: 1px solid #e2e8f0;
    }

    .gv-courses th {
        padding: 11px 14px; text-align: left;
        font-size: 11px; font-weight: 700; color: #64748b;
        text-transform: uppercase; letter-spacing: 0.06em; white-space: nowrap;
    }

    .gv-courses td {
        padding: 16px 14px; font-size: 14px; color: #334155;
        border-bottom: 1px solid #f1f5f9; vertical-align: middle;
    }

    .gv-courses tr:hover td { background: #fafbff; }

    .gv-courses .empty-row td {
        text-align: center; padding: 48px 14px;
        color: #94a3b8; font-size: 14px;
    }

    .course-code { font-weight: 700; color: #0f172a; font-size: 14px; }
    .course-name { font-size: 12px; color: #64748b; margin-top: 2px; }

    .schedule-slot {
        display: inline-flex; align-items: center; gap: 5px;
        font-size: 12px; color: #475569;
        background: #f1f5f9; border-radius: 6px;
        padding: 3px 8px; margin: 2px 2px 2px 0;
        white-space: nowrap;
    }

    .schedule-slot i { color: #94a3b8; font-size: 11px; }

    .lecturer-cell {
        display: flex; align-items: center; gap: 8px; font-size: 13px;
    }

    .lecturer-cell i { color: #94a3b8; font-size: 13px; }

    .btn-enroll {
        display: inline-flex; align-items: center; gap: 6px;
        padding: 8px 16px;
        background: linear-gradient(90deg,#6366f1,#9333ea);
        color: #fff; border: none; border-radius: 10px;
        font-size: 13px; font-weight: 600; cursor: pointer;
        box-shadow: 0 3px 10px rgba(99,102,241,0.3);
        transition: opacity 0.2s, box-shadow 0.2s;
        white-space: nowrap;
    }

    .btn-enroll:hover { opacity: 0.9; box-shadow: 0 6px 16px rgba(99,102,241,0.4); }

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

    .tip-banner {
        background: #f8fafc; border: 1px solid #e2e8f0;
        border-radius: 12px; padding: 14px 16px;
        font-size: 13px; color: #64748b; line-height: 1.5;
    }

    .tip-banner strong { color: #475569; }

    .empty-state {
        text-align: center; padding: 56px 24px;
    }

    .empty-icon {
        width: 64px; height: 64px; border-radius: 50%;
        background: #f1f5f9;
        display: flex; align-items: center; justify-content: center;
        margin: 0 auto 16px;
    }

    .empty-icon i   { font-size: 28px; color: #94a3b8; }
    .empty-title    { font-size: 16px; font-weight: 600; color: #475569; margin-bottom: 6px; }
    .empty-sub      { font-size: 13px; color: #94a3b8; }

    @media (max-width: 700px) {
        .compat-grid { grid-template-columns: 1fr; }
    }
</style>

<div class="tt-wrap">
    <div class="page-header">
        <h2>Timetable Matching</h2>
        <p>Check for schedule conflicts and find available courses that fit your timetable</p>
    </div>

    <asp:Label ID="lblMsg" runat="server" />

    <div class="card">
        <div class="card-title">Check Course Compatibility</div>

        <div class="compat-grid">
            <div class="form-group">
                <label class="form-label" for="<%= ddlSemester.ClientID %>">
                    Select a semester to check
                </label>
                <asp:DropDownList ID="ddlSemester" runat="server" CssClass="form-select" />
            </div>

            <div class="form-group">
                <asp:Button ID="btnSearch" runat="server"
                    Text="Find Available Courses"
                    CssClass="btn-search"
                    OnClick="btnSearch_Click" />
            </div>
        </div>

        <asp:Panel ID="pnlNoClash" runat="server" Visible="false" style="margin-top:20px;">
            <div class="notice-box notice-green">
                <div class="notice-icon ni-green"><i class="fa fa-check"></i></div>
                <div>
                    <div class="notice-title nt-green">No Conflicts Found</div>
                    <div class="notice-text nt-green">
                        The courses below fit perfectly with your current schedule.
                    </div>
                </div>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlNoResult" runat="server" Visible="false" style="margin-top:20px;">
            <div class="notice-box notice-amber">
                <div class="notice-icon ni-amber"><i class="fa fa-exclamation-triangle"></i></div>
                <div>
                    <div class="notice-title nt-amber">No Available Courses</div>
                    <div class="notice-text nt-amber">
                        All remaining courses clash with your current schedule, or no courses are available for this semester.
                    </div>
                </div>
            </div>
        </asp:Panel>
    </div>

    <asp:Panel ID="pnlResults" runat="server" Visible="false">
        <div class="card">
            <div class="card-title">
                Available Courses — No Clash &nbsp;
                <asp:Label ID="lblResultCount" runat="server"
                    style="font-size:13px;font-weight:500;color:#64748b;" />
            </div>

            <div style="overflow-x:auto;">
                <asp:GridView ID="gvCourses" runat="server"
                    AutoGenerateColumns="False"
                    CssClass="gv-courses"
                    GridLines="None"
                    DataKeyNames="OfferingID"
                    OnRowCommand="gvCourses_RowCommand"
                    EmptyDataText="">
                    <EmptyDataRowStyle CssClass="empty-row" />
                    <Columns>

                        <asp:TemplateField HeaderText="Course">
                            <ItemTemplate>
                                <div class="course-code"><%# Eval("CourseCode") %></div>
                                <div class="course-name"><%# Eval("CourseName") %></div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Schedule">
                            <ItemTemplate>
                                <%# FormatSchedule(Eval("Schedule")?.ToString()) %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Lecturer">
                            <ItemTemplate>
                                <div class="lecturer-cell">
                                    <i class="fa fa-user"></i>
                                    <span><%# Eval("Lecturer") %></span>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Action">
                            <ItemTemplate>
                                <asp:LinkButton
                                    CommandName="Enroll"
                                    CommandArgument='<%# Container.DataItemIndex %>'
                                    CssClass="btn-enroll"
                                    OnClientClick="return confirm('Enroll in this course?');"
                                    runat="server">
                                    <i class="fa fa-plus"></i> Enroll
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlDefault" runat="server" Visible="true">
        <div class="card">
            <div class="empty-state">
                <div class="empty-icon"><i class="fa fa-calendar"></i></div>
                <div class="empty-title">Select a semester to get started</div>
                <div class="empty-sub">
                    Choose a semester above and click "Find Available Courses" to see courses that don't clash with your current schedule.
                </div>
            </div>
        </div>
    </asp:Panel>

    <div class="tip-banner">
        <strong><i class="fa fa-lightbulb-o"></i> Tip:</strong>
        Only courses with no timetable clash against your currently enrolled courses are shown.
        Courses that are full are also excluded automatically.
    </div>
</div>

<script>
    window.onload = function () {
        var lbl = document.getElementById('<%= lblMsg.ClientID %>');
        if (!lbl || !lbl.innerText.trim()) return;

        var text    = lbl.innerText.trim();
        var isError = lbl.style.color === 'red' || lbl.style.color === 'rgb(255, 0, 0)';
        var isSuccess = text.toLowerCase().indexOf('success') > -1 ||
                        text.toLowerCase().indexOf('enrolled') > -1;

        if (isSuccess) {
            lbl.className = 'msg-success';
            lbl.innerHTML = '<i class="fa fa-check-circle"></i> ' + text;
        } else if (isError || (!isSuccess && text.length > 0)) {
            lbl.className = 'msg-error';
            lbl.innerHTML = '<i class="fa fa-exclamation-circle"></i> ' + text;
        }
    };
</script>
</asp:Content>
