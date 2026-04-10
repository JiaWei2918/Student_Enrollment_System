<%@ Page Title="Title & Registration Summary" Language="C#" MasterPageFile="~/Student.Master" AutoEventWireup="true" CodeBehind="TimeTable.aspx.cs" Inherits="StudentEnrollmentSystem.Student.TimeTable" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<style>
    .tt-wrap { display: flex; flex-direction: column; gap: 28px; }

    .page-header { display: flex; align-items: flex-start; justify-content: space-between; flex-wrap: wrap; gap: 16px; }
    .page-header-left h2 { font-size: 28px; font-weight: 700; color: #0f172a; margin: 0 0 4px; }
    .page-header-left p  { font-size: 14px; color: #64748b; margin: 0; }

    .btn-primary {
        display: inline-flex; align-items: center; gap: 8px;
        padding: 10px 22px;
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

    .semester-row { display: flex; align-items: center; gap: 12px; }
    .form-label   { font-size: 13px; font-weight: 600; color: #374151; white-space: nowrap; }

    .form-select  {
        padding: 11px 14px; border: 1px solid #e2e8f0; border-radius: 12px;
        font-size: 14px; color: #0f172a; background: #f8fafc;
        outline: none; transition: border-color 0.2s, box-shadow 0.2s;
        min-width: 220px;
    }

    .form-select:focus {
        border-color: #6366f1;
        box-shadow: 0 0 0 3px rgba(99,102,241,0.12);
        background: #fff;
    }

    .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 28px; }
    .info-section h3 { font-size: 14px; font-weight: 700; color: #0f172a; margin: 0 0 12px; }

    .info-row {
        display: flex; justify-content: space-between;
        font-size: 13px; padding: 6px 0;
        border-bottom: 1px solid #f8fafc;
    }

    .info-row:last-child { border-bottom: none; }
    .info-label { color: #64748b; }
    .info-value { font-weight: 600; color: #0f172a; }

    .course-card {
        border: 1px solid #e2e8f0; border-radius: 12px; padding: 16px 18px;
        margin-bottom: 12px; transition: border-color 0.2s, box-shadow 0.2s;
    }

    .course-card:last-child { margin-bottom: 0; }
    .course-card:hover { border-color: #c7d2fe; box-shadow: 0 4px 14px rgba(0,0,0,0.06); }
    .course-card-top { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 12px; }
    .cc-code  { font-size: 16px; font-weight: 700; color: #0f172a; }
    .cc-name  { font-size: 13px; color: #334155; margin-top: 2px; }
    .cc-meta  { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-top: 4px; }

    .cc-meta-item {
        display: flex; align-items: center; gap: 7px;
        font-size: 12px; color: #64748b;
    }

    .cc-meta-item i { font-size: 12px; color: #94a3b8; }

    .badge {
        display: inline-block; padding: 3px 10px;
        border-radius: 99px; font-size: 11px; font-weight: 600; white-space: nowrap;
    }

    .badge-blue   { background: #dbeafe; color: #1d4ed8; }
    .badge-purple { background: #ede9fe; color: #6d28d9; }
    .badge-green  { background: #dcfce7; color: #15803d; }

    .tt-scroll { overflow-x: auto; }
    .gv-grid   { width: 100%; border-collapse: collapse; min-width: 700px; }

    .gv-grid th {
        padding: 11px 12px; text-align: center;
        font-size: 12px; font-weight: 700; color: #64748b;
        text-transform: uppercase; letter-spacing: 0.05em;
        background: #f8fafc; border-bottom: 1px solid #e2e8f0;
    }

    .gv-grid th.time-col { text-align: left; min-width: 110px; }
    .gv-grid th.today-col { background: #eef2ff; color: #4338ca; }

    .gv-grid td {
        padding: 8px 10px; font-size: 13px; color: #334155;
        border-bottom: 1px solid #f1f5f9; vertical-align: top;
        min-height: 64px; min-width: 100px;
    }

    .gv-grid tr:hover td { background: #fafbff; }

    .time-slot { font-size: 12px; color: #64748b; font-weight: 600; white-space: nowrap; }

    .grid-cell {
        background: linear-gradient(135deg,#eef2ff,#f5f3ff);
        border: 1px solid #c7d2fe; border-radius: 8px;
        padding: 6px 10px; font-size: 12px; color: #3730a3;
        margin-bottom: 4px;
    }

    .grid-cell b { display: block; font-size: 12px; font-weight: 700; margin-bottom: 2px; }

    .grid-cell-today {
        background: linear-gradient(135deg,#fef9c3,#fef3c7);
        border-color: #fbbf24; color: #92400e;
    }

    .grid-clash {
        background: #fef2f2; border-color: #fecaca;
        color: #991b1b; font-size: 11px; font-weight: 700;
        padding: 3px 8px; border-radius: 6px; margin: 3px 0;
        display: inline-block;
    }

    .msg-error {
        display: flex; align-items: center; gap: 10px;
        padding: 14px 18px; border-radius: 12px;
        background: #fef2f2; border: 1px solid #fecaca;
        color: #b91c1c; font-size: 14px; font-weight: 600;
    }
    .msg-warning {
        display: flex; align-items: center; gap: 10px;
        padding: 14px 18px; border-radius: 12px;
        background: #fffbeb; border: 1px solid #fde68a;
        color: #92400e; font-size: 14px; font-weight: 600;
    }

    .empty-state {
        text-align: center; padding: 56px 24px;
    }

    .empty-icon {
        width: 64px; height: 64px; border-radius: 50%;
        background: #f1f5f9;
        display: flex; align-items: center; justify-content: center;
        margin: 0 auto 16px;
    }

    .empty-icon i { font-size: 28px; color: #94a3b8; }
    .empty-title  { font-size: 16px; font-weight: 600; color: #475569; margin-bottom: 6px; }
    .empty-sub    { font-size: 13px; color: #94a3b8; }

    @media (max-width: 768px) {
        .info-grid  { grid-template-columns: 1fr; }
        .cc-meta    { grid-template-columns: 1fr; }
        .page-header { flex-direction: column; }
    }

    @media print {
        .page-header .btn-primary,
        .semester-row { display: none !important; }
        .card { box-shadow: none !important; }
    }
</style>

<div class="tt-wrap">
    <div class="page-header">
        <div class="page-header-left">
            <h2>Registration Summary</h2>
            <p>Your class schedule and timetable</p>
        </div>
        <asp:Button ID="btnExport" runat="server"
            Text="Download Schedule"
            CssClass="btn-primary"
            OnClick="btnExport_Click" />
    </div>

    <asp:Label ID="lblMessage" runat="server" />

    <div class="card" style="padding:20px 28px;">
        <div class="semester-row">
            <label class="form-label">Semester:</label>
            <asp:DropDownList ID="ddlSemester" runat="server"
                CssClass="form-select"
                AutoPostBack="true"
                OnSelectedIndexChanged="ddlSemester_SelectedIndexChanged" />
        </div>
    </div>

    <asp:Panel ID="pnlSummary" runat="server" Visible="false">
        <div class="card">
            <div class="info-grid">
                <div class="info-section">
                    <h3>Student Information</h3>
                    <div class="info-row">
                        <span class="info-label">Name</span>
                        <span class="info-value"><asp:Label ID="lblStudentName" runat="server" /></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Student ID</span>
                        <span class="info-value"><asp:Label ID="lblStudentID" runat="server" /></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Program</span>
                        <span class="info-value"><asp:Label ID="lblProgram" runat="server" /></span>
                    </div>
                </div>
                <div class="info-section">
                    <h3>Registration Details</h3>
                    <div class="info-row">
                        <span class="info-label">Semester</span>
                        <span class="info-value"><asp:Label ID="lblSemesterName" runat="server" /></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Total Courses</span>
                        <span class="info-value"><asp:Label ID="lblTotalSubjects" runat="server" /></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Total Credits</span>
                        <span class="info-value"><asp:Label ID="lblTotalCredits" runat="server" /></span>
                    </div>
                </div>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlTimetable" runat="server" Visible="false">
        <div class="card">
            <div class="card-title">Enrolled Courses</div>
            <asp:GridView ID="gvTimetable" runat="server"
                AutoGenerateColumns="False"
                CssClass="gv-hidden"
                Visible="false">
                <Columns>
                    <asp:BoundField DataField="CourseCode" />
                    <asp:BoundField DataField="CourseName" />
                    <asp:BoundField DataField="DayOfWeek" />
                    <asp:BoundField DataField="StartTime" />
                    <asp:BoundField DataField="EndTime" />
                    <asp:BoundField DataField="Venue" />
                    <asp:BoundField DataField="Lecturer" />
                </Columns>
            </asp:GridView>
            <asp:PlaceHolder ID="phCourses" runat="server" />
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlGrid" runat="server" Visible="false">
        <div class="card">
            <div class="card-title">
                <i class="fa fa-calendar" style="color:#6366f1;margin-right:8px;"></i>
                Weekly Class Timetable
            </div>
            <div class="tt-scroll">
                <asp:GridView ID="gvGrid" runat="server"
                    AutoGenerateColumns="False"
                    CssClass="gv-grid"
                    GridLines="None">
                    <Columns>
                        <asp:TemplateField HeaderText="Time" HeaderStyle-CssClass="time-col">
                            <ItemTemplate>
                                <div class="time-slot"><%# Eval("TimeSlot") %></div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="Monday"    HeaderText="Monday"    HtmlEncode="false" />
                        <asp:BoundField DataField="Tuesday"   HeaderText="Tuesday"   HtmlEncode="false" />
                        <asp:BoundField DataField="Wednesday" HeaderText="Wednesday" HtmlEncode="false" />
                        <asp:BoundField DataField="Thursday"  HeaderText="Thursday"  HtmlEncode="false" />
                        <asp:BoundField DataField="Friday"    HeaderText="Friday"    HtmlEncode="false" />
                        <asp:BoundField DataField="Saturday"  HeaderText="Saturday"  HtmlEncode="false" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlEmpty" runat="server" Visible="true">
        <div class="card">
            <div class="empty-state">
                <div class="empty-icon"><i class="fa fa-calendar"></i></div>
                <div class="empty-title">No courses registered</div>
                <div class="empty-sub">Select a semester above to view your registration summary and timetable.</div>
            </div>
        </div>
    </asp:Panel>
</div>

<script>
    window.onload = function () {
        var days = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
        var today = days[new Date().getDay()];

        var table = document.querySelector('.gv-grid');
        if (!table) return;

        var headers = table.querySelectorAll('th');
        var todayIndex = -1;

        headers.forEach(function (th, i) {
            if (th.innerText.trim() === today) {
                th.classList.add('today-col');
                todayIndex = i;
            }
        });

        if (todayIndex > -1) {
            table.querySelectorAll('tr').forEach(function (tr) {
                var cells = tr.querySelectorAll('td');
                if (cells[todayIndex])
                    cells[todayIndex].style.background = '#f5f3ff';
            });
        }

        var lbl = document.getElementById('<%= lblMessage.ClientID %>');
        if (!lbl || !lbl.innerText.trim()) return;
        var text = lbl.innerText.trim();
        var isWarning = text.indexOf('⚠') > -1 || text.toLowerCase().indexOf('limit') > -1;
        lbl.className = isWarning ? 'msg-warning' : 'msg-error';
        lbl.innerHTML = '<i class="fa ' + (isWarning ? 'fa-exclamation-triangle' : 'fa-exclamation-circle') + '"></i> ' + text;
    };
</script>
</asp:Content>

