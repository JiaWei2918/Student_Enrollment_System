<%@ Page Title="Course Enrollment" Language="C#" MasterPageFile="~/Student.Master" AutoEventWireup="true" CodeBehind="Enrollment.aspx.cs" Inherits="StudentEnrollmentSystem.Student.Enrollment" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<style>
    .enroll-wrap { display: flex; flex-direction: column; gap: 28px; }

    /* ── PAGE HEADER ── */
    .page-header h2 {
        font-size: 28px; font-weight: 700; color: #0f172a; margin: 0 0 4px;
    }
    .page-header p { font-size: 14px; color: #64748b; margin: 0; }

    /* ── INFO BANNER ── */
    .info-banner {
        background: linear-gradient(135deg, #6366f1, #9333ea);
        border-radius: 16px; padding: 20px 28px; color: #fff;
        display: flex; align-items: center; gap: 32px; flex-wrap: wrap;
        box-shadow: 0 8px 24px rgba(99,102,241,0.25);
    }
    .info-banner-item .ib-label {
        font-size: 11px; color: #c7d2fe; text-transform: uppercase;
        letter-spacing: 0.06em; margin-bottom: 3px;
    }
    .info-banner-item .ib-value {
        font-size: 15px; font-weight: 700;
    }
    .ib-divider { width: 1px; height: 36px; background: rgba(255,255,255,0.25); }

    /* ── STATS ROW ── */
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
    .icon-blue   { background: linear-gradient(135deg,#3b82f6,#06b6d4); box-shadow: 0 4px 10px rgba(59,130,246,0.3); }
    .icon-purple { background: linear-gradient(135deg,#a855f7,#ec4899); box-shadow: 0 4px 10px rgba(168,85,247,0.3); }
    .icon-emerald{ background: linear-gradient(135deg,#10b981,#14b8a6); box-shadow: 0 4px 10px rgba(16,185,129,0.3); }

    /* ── CARD ── */
    .card {
        background: #fff; border-radius: 16px; padding: 28px;
        border: 1px solid rgba(0,0,0,0.06);
        box-shadow: 0 4px 12px rgba(0,0,0,0.04);
    }
    .card-title {
        font-size: 18px; font-weight: 700; color: #0f172a; margin: 0 0 20px;
    }

    /* ── FILTER BAR ── */
    .filter-bar {
        display: grid; grid-template-columns: 1fr auto; gap: 12px;
        align-items: center; margin-bottom: 20px;
    }
    .search-wrap { position: relative; }
    .search-wrap i {
        position: absolute; left: 14px; top: 50%; transform: translateY(-50%);
        color: #94a3b8; font-size: 14px; pointer-events: none;
    }
    .search-input {
        width: 100%; padding: 11px 14px 11px 40px;
        border: 1px solid #e2e8f0; border-radius: 12px;
        font-size: 14px; background: #f8fafc; color: #0f172a;
        outline: none; transition: border-color 0.2s, box-shadow 0.2s;
        box-sizing: border-box;
    }
    .search-input:focus {
        border-color: #6366f1;
        box-shadow: 0 0 0 3px rgba(99,102,241,0.12);
        background: #fff;
    }

    /* ── SELECT ALL ROW ── */
    .select-all-row {
        display: flex; align-items: center; gap: 10px;
        padding: 10px 14px;
        background: #f8fafc; border-radius: 10px;
        margin-bottom: 16px; border: 1px solid #e2e8f0;
    }
    .select-all-row label { font-size: 13px; font-weight: 600; color: #475569; cursor: pointer; }

    /* ── AVAILABLE COURSES TABLE ── */
    .courses-table { width: 100%; border-collapse: collapse; }
    .courses-table thead tr {
        background: #f8fafc; border-bottom: 1px solid #e2e8f0;
    }
    .courses-table thead th {
        padding: 11px 14px; text-align: left;
        font-size: 11px; font-weight: 700; color: #64748b;
        text-transform: uppercase; letter-spacing: 0.06em;
        white-space: nowrap;
    }
    .courses-table tbody tr {
        border-bottom: 1px solid #f1f5f9;
        transition: background 0.15s;
    }
    .courses-table tbody tr:hover { background: #fafbff; }
    .courses-table tbody td {
        padding: 14px; font-size: 14px; color: #334155; vertical-align: middle;
    }

    /* Course code + name cell */
    .course-code  { font-weight: 700; color: #0f172a; font-size: 14px; }
    .course-name  { font-size: 12px; color: #64748b; margin-top: 2px; }

    /* Badges */
    .badge {
        display: inline-block; padding: 3px 10px;
        border-radius: 99px; font-size: 11px; font-weight: 600;
        white-space: nowrap;
    }
    .badge-blue    { background: #dbeafe; color: #1d4ed8; }
    .badge-green   { background: #dcfce7; color: #15803d; }
    .badge-amber   { background: #fef3c7; color: #b45309; }
    .badge-red     { background: #fee2e2; color: #b91c1c; }
    .badge-gray    { background: #f1f5f9; color: #475569; }

    /* Seat progress bar */
    .seat-wrap { min-width: 120px; }
    .seat-bar  {
        width: 100%; height: 6px; background: #f1f5f9;
        border-radius: 99px; overflow: hidden; margin-top: 5px;
    }
    .seat-fill { height: 100%; border-radius: 99px; }
    .seat-text { font-size: 12px; color: #64748b; }

    /* Row checkbox */
    .row-check { width: 18px; height: 18px; accent-color: #6366f1; cursor: pointer; }

    /* Disabled row */
    .row-full td { opacity: 0.55; }

    /* ── ENROLL BUTTON ── */
    .enroll-btn-wrap { margin-top: 20px; display: flex; align-items: center; gap: 16px; }
    .btn-enroll {
        display: inline-flex; align-items: center; gap: 8px;
        padding: 12px 28px;
        background: linear-gradient(90deg, #6366f1, #9333ea);
        color: #fff; border: none; border-radius: 12px;
        font-size: 14px; font-weight: 600; cursor: pointer;
        box-shadow: 0 4px 14px rgba(99,102,241,0.35);
        transition: opacity 0.2s, box-shadow 0.2s;
    }
    .btn-enroll:hover { opacity: 0.9; box-shadow: 0 8px 22px rgba(99,102,241,0.45); }

    /* ── MESSAGE BOX ── */
    .msg-box {
        padding: 14px 18px; border-radius: 12px;
        font-size: 14px; font-weight: 600;
        display: flex; align-items: center; gap: 10px;
    }
    .msg-box i { font-size: 16px; }
    .msg-success { background: #f0fdf4; border: 1px solid #bbf7d0; color: #15803d; }
    .msg-error   { background: #fef2f2; border: 1px solid #fecaca; color: #b91c1c; }

    /* ── MY COURSES TABLE ── */
    .my-courses-table { width: 100%; border-collapse: collapse; }
    .my-courses-table thead tr {
        background: #f8fafc; border-bottom: 1px solid #e2e8f0;
    }
    .my-courses-table thead th {
        padding: 11px 14px; text-align: left;
        font-size: 11px; font-weight: 700; color: #64748b;
        text-transform: uppercase; letter-spacing: 0.06em;
    }
    .my-courses-table tbody tr {
        border-bottom: 1px solid #f1f5f9;
        transition: background 0.15s;
    }
    .my-courses-table tbody tr:hover { background: #fafbff; }
    .my-courses-table tbody td {
        padding: 14px; font-size: 14px; color: #334155; vertical-align: middle;
    }
    .my-courses-table .empty-row td {
        text-align: center; padding: 48px; color: #94a3b8;
        font-size: 14px;
    }

    /* Overrides for ASP.NET GridView */
    .gv-available, .gv-mycourses { width: 100%; border-collapse: collapse; }
    .gv-available th, .gv-mycourses th {
        padding: 11px 14px; text-align: left;
        font-size: 11px; font-weight: 700; color: #64748b;
        text-transform: uppercase; letter-spacing: 0.06em;
        background: #f8fafc; border-bottom: 1px solid #e2e8f0;
        white-space: nowrap;
    }
    .gv-available td, .gv-mycourses td {
        padding: 14px; font-size: 14px; color: #334155;
        border-bottom: 1px solid #f1f5f9; vertical-align: middle;
    }
    .gv-available tr:hover td, .gv-mycourses tr:hover td { background: #fafbff; }

    /* ── RESPONSIVE ── */
    @media (max-width: 900px) {
        .stats-row { grid-template-columns: 1fr 1fr; }
        .filter-bar { grid-template-columns: 1fr; }
        .info-banner { gap: 16px; }
    }
    @media (max-width: 600px) {
        .stats-row { grid-template-columns: 1fr; }
        .ib-divider { display: none; }
    }
</style>

<div class="enroll-wrap">

    <!-- PAGE HEADER -->
    <div class="page-header">
        <h2>Course Enrollment</h2>
        <p>Browse and enroll in available courses for the current semester</p>
    </div>

    <!-- SEMESTER INFO BANNER -->
    <div class="info-banner">
        <div class="info-banner-item">
            <div class="ib-label">Welcome</div>
            <div class="ib-value">
                <asp:Label ID="lblStudentName" runat="server" />
            </div>
        </div>
        <div class="ib-divider"></div>
        <div class="info-banner-item">
            <div class="ib-label">Current Semester</div>
            <div class="ib-value">
                <asp:Label ID="lblSemester" runat="server" Text="—" />
            </div>
        </div>
        <div class="ib-divider"></div>
        <div class="info-banner-item">
            <div class="ib-label">Enrollment Period</div>
            <div class="ib-value">
                <asp:Label ID="lblAddPeriod" runat="server" Text="—" />
            </div>
        </div>
    </div>

    <!-- STATS ROW -->
    <div class="stats-row">
        <div class="stat-card">
            <div>
                <div class="stat-label">Enrolled Courses</div>
                <div class="stat-value">
                    <asp:Label ID="lblEnrolledCount" runat="server" Text="0" />
                </div>
            </div>
            <div class="stat-icon icon-blue"><i class="fa fa-book"></i></div>
        </div>
        <div class="stat-card">
            <div>
                <div class="stat-label">Total Credits</div>
                <div class="stat-value">
                    <asp:Label ID="lblTotalCredits" runat="server" Text="0" />
                </div>
            </div>
            <div class="stat-icon icon-purple"><i class="fa fa-plus"></i></div>
        </div>
        <div class="stat-card">
            <div>
                <div class="stat-label">Max Credits Allowed</div>
                <div class="stat-value">
                    <asp:Label ID="lblMaxCredits" runat="server" Text="18" />
                </div>
            </div>
            <div class="stat-icon icon-emerald"><i class="fa fa-info-circle"></i></div>
        </div>
    </div>

    <!-- AVAILABLE COURSES -->
    <div class="card">
        <div class="card-title">Available Courses</div>

        <!-- Select All -->
        <div class="select-all-row">
            <asp:CheckBox ID="chkSelectAll" runat="server"
                AutoPostBack="true"
                OnCheckedChanged="chkSelectAll_CheckedChanged" />
            <label for="<%= chkSelectAll.ClientID %>">Select / Deselect All</label>
        </div>

        <!-- Courses GridView -->
        <div style="overflow-x:auto;">
            <asp:GridView ID="gvCourses" runat="server"
                AutoGenerateColumns="False"
                CssClass="gv-available"
                GridLines="None"
                EmptyDataText="No available courses for this semester."
                OnRowDataBound="gvCourses_RowDataBound">
                <EmptyDataRowStyle CssClass="empty-row" />
                <Columns>
                    <asp:TemplateField HeaderText="Select">
                        <ItemTemplate>
                            <asp:CheckBox ID="chkSelect" runat="server" CssClass="row-check" />
                            <asp:HiddenField ID="hfOfferingID" runat="server"
                                Value='<%# Eval("OfferingID") %>' />
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Course">
                        <ItemTemplate>
                            <div class="course-code"><%# Eval("CourseCode") %></div>
                            <div class="course-name"><%# Eval("CourseName") %></div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Credits">
                        <ItemTemplate>
                            <span class="badge badge-blue"><%# Eval("CreditHours") %> Credits</span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="SemesterName" HeaderText="Semester" />

                    <asp:TemplateField HeaderText="Availability">
                        <ItemTemplate>
                            <div class="seat-wrap">
                                <div class="seat-text">
                                    <%# Eval("SeatsLeft") %> of <%# Eval("Capacity") %> seats left
                                </div>
                                <div class="seat-bar">
                                    <div class="seat-fill" style='<%# GetSeatBarStyle(Eval("SeatPct")) %>'></div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate>
                            <%# GetSeatBadge(Eval("SeatStatus")) %>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>

        <!-- Enroll Button + Message -->
        <div class="enroll-btn-wrap">
            <asp:Button ID="btnEnrollSelected" runat="server"
                Text="Enroll Selected Courses"
                OnClick="btnEnrollSelected_Click"
                CssClass="btn-enroll"
                OnClientClick="return confirmEnroll();" />
        </div>

        <asp:Label ID="lblMessage" runat="server" />
    </div>

    <!-- MY ENROLLED COURSES -->
    <div class="card">
        <div class="card-title">My Enrolled Courses</div>
        <div style="overflow-x:auto;">
            <asp:GridView ID="gvMyCourses" runat="server"
                AutoGenerateColumns="False"
                CssClass="gv-mycourses"
                GridLines="None"
                EmptyDataText="You have not enrolled in any courses yet.">
                <EmptyDataRowStyle CssClass="empty-row" />
                <Columns>
                    <asp:TemplateField HeaderText="Course">
                        <ItemTemplate>
                            <div class="course-code"><%# Eval("CourseCode") %></div>
                            <div class="course-name"><%# Eval("CourseName") %></div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Credits">
                        <ItemTemplate>
                            <span class="badge badge-blue"><%# Eval("CreditHours") %> Credits</span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="SemesterName" HeaderText="Semester" />

                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate>
                            <%# GetStatusBadge(Eval("Status")) %>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>

</div>

<script>
    function confirmEnroll() {
        var checked = document.querySelectorAll('.gv-available input[type=checkbox]:checked');
        // subtract 1 for the select-all checkbox if checked
        if (checked.length === 0) return true;
        return confirm('Enroll in the selected course(s)?');
    }

    // Style message label based on content color set by server
    window.onload = function () {
        var lbl = document.getElementById('<%= lblMessage.ClientID %>');
        if (!lbl || !lbl.innerText.trim()) return;
        var isError = lbl.style.color === 'red' || lbl.style.color === 'rgb(255, 0, 0)';
        lbl.className = 'msg-box ' + (isError ? 'msg-error' : 'msg-success');
        lbl.innerHTML = '<i class="fa ' + (isError ? 'fa-exclamation-circle' : 'fa-check-circle') + '"></i> ' + lbl.innerText;
    };
</script>

</asp:Content>