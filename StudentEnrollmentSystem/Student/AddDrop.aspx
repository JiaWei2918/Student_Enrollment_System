<%@ Page Title="Course Add/Drop" Language="C#" MasterPageFile="~/Student.Master" AutoEventWireup="true" CodeBehind="AddDrop.aspx.cs" Inherits="StudentEnrollmentSystem.Student.AddDrop" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<style>
    .adddrop-wrap { display: flex; flex-direction: column; gap: 28px; }

    .page-header h2 { font-size: 28px; font-weight: 700; color: #0f172a; margin: 0 0 4px; }
    .page-header p  { font-size: 14px; color: #64748b; margin: 0; }

    .notice-box {
        display: flex; align-items: flex-start; gap: 14px;
        padding: 16px 20px; border-radius: 14px;
        border: 1px solid; 
    }

    .notice-amber { background: #fffbeb; border-color: #fde68a; }
    .notice-red   { background: #fef2f2; border-color: #fecaca; }

    .notice-icon  {
        width: 36px; height: 36px; border-radius: 10px;
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }

    .notice-icon-amber { background: linear-gradient(135deg,#f59e0b,#f97316); box-shadow: 0 4px 10px rgba(245,158,11,0.3); }
    .notice-icon-red   { background: linear-gradient(135deg,#ef4444,#dc2626); box-shadow: 0 4px 10px rgba(239,68,68,0.3); }
    .notice-icon i { font-size: 16px; color: #fff; }
    .notice-title { font-size: 14px; font-weight: 700; color: #92400e; margin-bottom: 3px; }
    .notice-title-red { color: #991b1b; }
    .notice-text  { font-size: 13px; color: #b45309; line-height: 1.5; }
    .notice-text-red { color: #b91c1c; }

    .stats-row {
        display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px;
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
    .icon-blue { background: linear-gradient(135deg,#3b82f6,#06b6d4); box-shadow: 0 4px 10px rgba(59,130,246,0.3); }
    .icon-red  { background: linear-gradient(135deg,#ef4444,#dc2626); box-shadow: 0 4px 10px rgba(239,68,68,0.3); }

    .period-bar {
        display: flex; gap: 24px; flex-wrap: wrap;
        background: #fff; border-radius: 14px; padding: 18px 24px;
        border: 1px solid rgba(0,0,0,0.06);
        box-shadow: 0 4px 12px rgba(0,0,0,0.04);
    }

    .period-item .p-label { font-size: 11px; font-weight: 700; color: #94a3b8; text-transform: uppercase; letter-spacing: 0.06em; margin-bottom: 4px; }
    .period-item .p-value { font-size: 14px; font-weight: 600; color: #0f172a; }
    .period-divider { width: 1px; background: #e2e8f0; }

    .card {
        background: #fff; border-radius: 16px; padding: 28px;
        border: 1px solid rgba(0,0,0,0.06);
        box-shadow: 0 4px 12px rgba(0,0,0,0.04);
    }

    .card-header {
        display: flex; align-items: center; justify-content: space-between;
        margin-bottom: 20px; flex-wrap: wrap; gap: 12px;
    }

    .card-title { font-size: 18px; font-weight: 700; color: #0f172a; margin: 0; }

    .gv-table { width: 100%; border-collapse: collapse; }

    .gv-table th {
        padding: 11px 14px; text-align: left;
        font-size: 11px; font-weight: 700; color: #64748b;
        text-transform: uppercase; letter-spacing: 0.06em;
        background: #f8fafc; border-bottom: 1px solid #e2e8f0;
        white-space: nowrap;
    }

    .gv-table td {
        padding: 14px; font-size: 14px; color: #334155;
        border-bottom: 1px solid #f1f5f9; vertical-align: middle;
    }

    .gv-table tr:hover td { background: #fafbff; }

    .gv-table .empty-row td {
        text-align: center; padding: 48px 14px;
        color: #94a3b8; font-size: 14px;
    }

    .course-code { font-weight: 700; color: #0f172a; font-size: 14px; }
    .course-name { font-size: 12px; color: #64748b; margin-top: 2px; }

    .badge {
        display: inline-block; padding: 3px 10px;
        border-radius: 99px; font-size: 11px; font-weight: 600; white-space: nowrap;
    }

    .badge-blue    { background: #dbeafe; color: #1d4ed8; }
    .badge-green   { background: #dcfce7; color: #15803d; }
    .badge-amber   { background: #fef3c7; color: #b45309; }
    .badge-red     { background: #fee2e2; color: #b91c1c; }
    .badge-gray    { background: #f1f5f9; color: #475569; }

    .seat-wrap  { min-width: 130px; }
    .seat-text  { font-size: 12px; color: #64748b; }
    .seat-bar   { width: 100%; height: 6px; background: #f1f5f9; border-radius: 99px; overflow: hidden; margin-top: 5px; }
    .seat-fill  { height: 100%; border-radius: 99px; }

    .row-check { width: 18px; height: 18px; accent-color: #6366f1; cursor: pointer; }
    .row-check-red { accent-color: #ef4444; }
    .row-full td { opacity: 0.5; }

    .btn-add {
        display: inline-flex; align-items: center; gap: 8px;
        padding: 11px 24px;
        background: linear-gradient(90deg,#10b981,#14b8a6);
        color: #fff; border: none; border-radius: 12px;
        font-size: 14px; font-weight: 600; cursor: pointer;
        box-shadow: 0 4px 14px rgba(16,185,129,0.3);
        transition: opacity 0.2s, box-shadow 0.2s;
    }

    .btn-add:hover { opacity: 0.9; box-shadow: 0 8px 22px rgba(16,185,129,0.4); }

    .btn-drop {
        display: inline-flex; align-items: center; gap: 8px;
        padding: 11px 24px;
        background: linear-gradient(90deg,#ef4444,#dc2626);
        color: #fff; border: none; border-radius: 12px;
        font-size: 14px; font-weight: 600; cursor: pointer;
        box-shadow: 0 4px 14px rgba(239,68,68,0.3);
        transition: opacity 0.2s, box-shadow 0.2s;
    }

    .btn-drop:hover { opacity: 0.9; box-shadow: 0 8px 22px rgba(239,68,68,0.4); }

    .btn-wrap { margin-top: 20px; }

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

    .enrolled-badge { background: linear-gradient(90deg,#6366f1,#9333ea); color:#fff; }

    @media (max-width: 700px) {
        .stats-row { grid-template-columns: 1fr; }
        .period-divider { display: none; }
    }
</style>

<div class="adddrop-wrap">
    <div class="page-header">
        <h2>Course Add / Drop</h2>
        <p>Manage your enrolled courses for the current semester</p>
    </div>

    <div class="notice-box notice-amber">
        <div class="notice-icon notice-icon-amber">
            <i class="fa fa-calendar"></i>
        </div>
        <div>
            <div class="notice-title">Add / Drop Period</div>
            <div class="notice-text">
                Current Semester: <strong><asp:Label ID="lblSemester" runat="server" Text="—" /></strong>
                &nbsp;&nbsp;|&nbsp;&nbsp;
                Add Period: <strong><asp:Label ID="lblAddPeriod" runat="server" Text="—" /></strong>
                &nbsp;&nbsp;|&nbsp;&nbsp;
                Drop Period: <strong><asp:Label ID="lblDropPeriod" runat="server" Text="—" /></strong>
            </div>
        </div>
    </div>

    <div class="stats-row">
        <div class="stat-card">
            <div>
                <div class="stat-label">Currently Enrolled</div>
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
            <div class="stat-icon icon-red"><i class="fa fa-plus-circle"></i></div>
        </div>
    </div>

    <div class="card">
        <div class="card-header">
            <div class="card-title">
                <i class="fa fa-plus-circle" style="color:#10b981;margin-right:8px;"></i>
                Add Courses
            </div>
        </div>

        <div style="overflow-x:auto;">
            <asp:GridView ID="gvAvailable" runat="server"
                AutoGenerateColumns="False"
                CssClass="gv-table"
                GridLines="None"
                EmptyDataText="No available courses to add for this semester."
                OnRowDataBound="gvAvailable_RowDataBound">
                <EmptyDataRowStyle CssClass="empty-row" />
                <Columns>
                    <asp:TemplateField HeaderText="Select">
                        <ItemTemplate>
                            <asp:CheckBox ID="chkAdd" runat="server" CssClass="row-check" />
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

                    <asp:TemplateField HeaderText="Availability">
                        <ItemTemplate>
                            <div class="seat-wrap">
                                <div class="seat-text">
                                    <%# Eval("SeatsLeft") %> of <%# Eval("Capacity") %> seats left
                                </div>
                                <div class="seat-bar">
                                    <div class="seat-fill"
                                        style='<%# GetSeatBarStyle(Eval("SeatPct")) %>'></div>
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

        <div class="btn-wrap">
            <asp:Button ID="btnAddSelected" runat="server"
                Text="Add Selected Courses"
                CssClass="btn-add"
                OnClick="btnAddSelected_Click"
                OnClientClick="return confirmAdd();" />
        </div>
    </div>

    <div class="card">
        <div class="card-header">
            <div class="card-title">
                <i class="fa fa-trash" style="color:#ef4444;margin-right:8px;"></i>
                Drop Courses
            </div>
        </div>

        <div class="notice-box notice-red" style="margin-bottom:20px;">
            <div class="notice-icon notice-icon-red">
                <i class="fa fa-exclamation-triangle"></i>
            </div>
            <div>
                <div class="notice-title notice-title-red">Warning</div>
                <div class="notice-text notice-text-red">
                    Dropping a course cannot be undone. You will need to re-enroll if you change your mind before the add period ends.
                </div>
            </div>
        </div>

        <div style="overflow-x:auto;">
            <asp:GridView ID="gvMyCourses" runat="server"
                AutoGenerateColumns="False"
                CssClass="gv-table"
                GridLines="None"
                EmptyDataText="You are not enrolled in any courses this semester.">
                <EmptyDataRowStyle CssClass="empty-row" />
                <Columns>
                    <asp:TemplateField HeaderText="Select">
                        <ItemTemplate>
                            <asp:CheckBox ID="chkDrop" runat="server" CssClass="row-check row-check-red" />
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

                    <asp:TemplateField HeaderText="Enrolled On">
                        <ItemTemplate>
                            <%# FormatDate(Eval("EnrolledDate")) %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate>
                            <%# GetStatusBadge(Eval("Status")) %>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>

        <div class="btn-wrap">
            <asp:Button ID="btnDropSelected" runat="server"
                Text="Drop Selected Courses"
                CssClass="btn-drop"
                OnClick="btnDropSelected_Click"
                OnClientClick="return confirmDrop();" />
        </div>
    </div>

    <asp:Label ID="lblMessage" runat="server" />
</div>

<script>
    function confirmAdd() {
        var checked = document.querySelectorAll('#<%= gvAvailable.ClientID %> input[type=checkbox]:checked');
        if (checked.length === 0) return true;
        return confirm('Add the selected course(s) to your enrollment?');
    }

    function confirmDrop() {
        var checked = document.querySelectorAll('#<%= gvMyCourses.ClientID %> input[type=checkbox]:checked');
        if (checked.length === 0) return true;
        return confirm('Are you sure you want to drop the selected course(s)?\nThis action cannot be undone.');
    }

    window.onload = function () {
        var lbl = document.getElementById('<%= lblMessage.ClientID %>');
        if (!lbl || !lbl.innerText.trim()) return;
        var isError = lbl.style.color === 'red' || lbl.style.color === 'rgb(255, 0, 0)';
        lbl.className = isError ? 'msg-error' : 'msg-success';
        lbl.innerHTML = '<i class="fa ' + (isError ? 'fa-exclamation-circle' : 'fa-check-circle') + '"></i> ' + lbl.innerText;
    };
</script>
</asp:Content>