<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Student.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="StudentEnrollmentSystem.Student.Dashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<style>
    .db-wrap { display: flex; flex-direction: column; gap: 32px; }

    .welcome-banner {
        background: linear-gradient(135deg, #6366f1 0%, #9333ea 50%, #ec4899 100%);
        border-radius: 24px;
        padding: 48px;
        color: #fff;
        position: relative;
        overflow: hidden;
        box-shadow: 0 20px 40px rgba(99,102,241,0.3);
    }

    .welcome-blob1 {
        position: absolute; top: -96px; right: -96px;
        width: 384px; height: 384px;
        background: rgba(255,255,255,0.1);
        border-radius: 50%;
    }

    .welcome-blob2 {
        position: absolute; bottom: -72px; left: -72px;
        width: 288px; height: 288px;
        background: rgba(255,255,255,0.05);
        border-radius: 50%;
    }

    .welcome-inner {
        position: relative; z-index: 1;
        display: flex; align-items: flex-start;
        justify-content: space-between; flex-wrap: wrap; gap: 24px;
    }

    .welcome-title { font-size: 40px; font-weight: 700; margin-bottom: 12px; }
    .welcome-sub { font-size: 16px; color: #c7d2fe; max-width: 560px; line-height: 1.6; }

    .welcome-meta {
        display: flex; align-items: center; gap: 24px;
        margin-top: 24px; flex-wrap: wrap;
    }

    .welcome-meta-item .meta-label { font-size: 12px; color: #a5b4fc; margin-bottom: 2px; }
    .welcome-meta-item .meta-value { font-size: 16px; font-weight: 700; }
    .meta-divider { width: 1px; height: 32px; background: rgba(255,255,255,0.3); }

    .welcome-icon-box {
        width: 120px; height: 120px;
        border-radius: 24px;
        background: rgba(255,255,255,0.2);
        border: 1px solid rgba(255,255,255,0.3);
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
    }

    .welcome-icon-box i { font-size: 52px; color: #fff; }

    .stats-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 24px;
    }

    .stat-card {
        background: #fff;
        border-radius: 16px;
        padding: 24px;
        border: 1px solid rgba(0,0,0,0.06);
        box-shadow: 0 4px 12px rgba(0,0,0,0.04);
        display: flex; align-items: center; justify-content: space-between;
        transition: box-shadow 0.2s, transform 0.2s;
    }

    .stat-card:hover { box-shadow: 0 12px 28px rgba(0,0,0,0.08); transform: translateY(-2px); }
    .stat-label { font-size: 13px; font-weight: 500; color: #64748b; }
    .stat-value { font-size: 36px; font-weight: 700; color: #0f172a; margin: 6px 0; line-height: 1; }
    .stat-sub   { font-size: 12px; font-weight: 600; }
    .stat-sub.green  { color: #059669; }
    .stat-sub.slate  { color: #94a3b8; }
    .stat-sub.amber  { color: #d97706; }

    .stat-icon {
        width: 52px; height: 52px; border-radius: 14px;
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        transition: transform 0.2s;
    }

    .stat-card:hover .stat-icon { transform: scale(1.1); }
    .stat-icon i { font-size: 22px; color: #fff; }
    .icon-green  { background: linear-gradient(135deg, #10b981, #14b8a6); box-shadow: 0 4px 12px rgba(16,185,129,0.3); }
    .icon-blue   { background: linear-gradient(135deg, #3b82f6, #06b6d4); box-shadow: 0 4px 12px rgba(59,130,246,0.3); }
    .icon-purple { background: linear-gradient(135deg, #a855f7, #ec4899); box-shadow: 0 4px 12px rgba(168,85,247,0.3); }
    .icon-amber  { background: linear-gradient(135deg, #f59e0b, #f97316); box-shadow: 0 4px 12px rgba(245,158,11,0.3); }

    .content-grid {
        display: grid;
        grid-template-columns: 1fr 340px;
        gap: 32px;
        align-items: start;
    }

    .main-col { display: flex; flex-direction: column; gap: 24px; }
    .side-col  { display: flex; flex-direction: column; gap: 24px; }

    .card {
        background: #fff;
        border-radius: 16px;
        padding: 24px;
        border: 1px solid rgba(0,0,0,0.06);
        box-shadow: 0 4px 12px rgba(0,0,0,0.04);
    }

    .card-title {
        font-size: 18px; font-weight: 700; color: #0f172a; margin-bottom: 16px;
    }

    .schedule-header {
        display: flex; align-items: center;
        justify-content: space-between; margin-bottom: 20px;
    }
    .schedule-header h2 { font-size: 22px; font-weight: 700; color: #0f172a; }
    .schedule-header p  { font-size: 14px; color: #64748b; margin-top: 4px; }

    .btn-calendar {
        display: inline-flex; align-items: center; gap: 8px;
        padding: 10px 18px;
        background: linear-gradient(90deg, #6366f1, #9333ea);
        color: #fff; border: none; border-radius: 12px;
        font-size: 14px; font-weight: 600; cursor: pointer;
        box-shadow: 0 4px 12px rgba(99,102,241,0.3);
        text-decoration: none; transition: opacity 0.2s, box-shadow 0.2s;
        white-space: nowrap;
    }

    .btn-calendar:hover { opacity: 0.9; box-shadow: 0 8px 20px rgba(99,102,241,0.4); color: #fff; }

    .class-card {
        background: #fff;
        border-radius: 16px; padding: 24px;
        border: 1px solid rgba(0,0,0,0.06);
        box-shadow: 0 4px 12px rgba(0,0,0,0.04);
        display: flex; align-items: flex-start; gap: 16px;
        transition: box-shadow 0.2s, border-color 0.2s;
    }

    .class-card:hover { box-shadow: 0 12px 28px rgba(0,0,0,0.08); border-color: #c7d2fe; }

    .class-icon {
        width: 60px; height: 60px; border-radius: 14px;
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
    }

    .class-icon i { font-size: 24px; color: #fff; }
    .icon-blue-cyan    { background: linear-gradient(135deg, #3b82f6, #06b6d4); box-shadow: 0 4px 12px rgba(59,130,246,0.3); }
    .icon-purple-pink  { background: linear-gradient(135deg, #a855f7, #ec4899); box-shadow: 0 4px 12px rgba(168,85,247,0.3); }
    .icon-emerald-teal { background: linear-gradient(135deg, #10b981, #14b8a6); box-shadow: 0 4px 12px rgba(16,185,129,0.3); }
    .class-body { flex: 1; min-width: 0; }
    .class-code { font-size: 17px; font-weight: 700; color: #0f172a; }
    .class-name { font-size: 14px; font-weight: 500; color: #334155; margin-top: 2px; }

    .class-meta {
        display: grid; grid-template-columns: 1fr 1fr;
        gap: 10px; margin-top: 14px;
    }

    .class-meta-item {
        display: flex; align-items: center; gap: 8px;
        font-size: 13px; color: #64748b;
    }

    .class-meta-item i { font-size: 13px; color: #94a3b8; }

    .quick-actions-grid {
        display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px;
    }

    .qa-btn {
        padding: 16px 8px; border-radius: 12px;
        border: 1px solid; background: none;
        cursor: pointer; text-align: center;
        transition: all 0.2s; text-decoration: none; display: block;
    }

    .qa-btn:hover .qa-icon { transform: scale(1.1); }

    .qa-icon {
        width: 40px; height: 40px; border-radius: 10px;
        display: flex; align-items: center; justify-content: center;
        margin: 0 auto 8px;
        transition: transform 0.2s;
        box-shadow: 0 4px 10px rgba(0,0,0,0.15);
    }

    .qa-icon i { font-size: 16px; color: #fff; }
    .qa-label { font-size: 11px; font-weight: 600; color: #334155; }

    .qa-blue   { background: linear-gradient(135deg,#eff6ff,#ecfeff); border-color: #bfdbfe; }
    .qa-blue:hover { background: linear-gradient(135deg,#dbeafe,#cffafe); }
    .qa-blue .qa-icon { background: linear-gradient(135deg,#3b82f6,#06b6d4); box-shadow: 0 4px 10px rgba(59,130,246,0.3); }

    .qa-purple { background: linear-gradient(135deg,#faf5ff,#fdf2f8); border-color: #e9d5ff; }
    .qa-purple:hover { background: linear-gradient(135deg,#f3e8ff,#fce7f3); }
    .qa-purple .qa-icon { background: linear-gradient(135deg,#a855f7,#ec4899); box-shadow: 0 4px 10px rgba(168,85,247,0.3); }

    .qa-emerald { background: linear-gradient(135deg,#f0fdf4,#f0fdfa); border-color: #a7f3d0; }
    .qa-emerald:hover { background: linear-gradient(135deg,#dcfce7,#ccfbf1); }
    .qa-emerald .qa-icon { background: linear-gradient(135deg,#10b981,#14b8a6); box-shadow: 0 4px 10px rgba(16,185,129,0.3); }

    .qa-amber  { background: linear-gradient(135deg,#fffbeb,#fff7ed); border-color: #fde68a; }
    .qa-amber:hover { background: linear-gradient(135deg,#fef3c7,#ffedd5); }
    .qa-amber .qa-icon { background: linear-gradient(135deg,#f59e0b,#f97316); box-shadow: 0 4px 10px rgba(245,158,11,0.3); }

    .activity-item {
        display: flex; align-items: flex-start; gap: 12px;
        padding: 8px 0; cursor: pointer;
    }

    .activity-item + .activity-item { border-top: 1px solid #f1f5f9; }

    .act-icon {
        width: 40px; height: 40px; border-radius: 12px;
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0; transition: transform 0.2s;
    }

    .activity-item:hover .act-icon { transform: scale(1.1); }
    .act-icon i { font-size: 15px; }
    .act-title { font-size: 13px; font-weight: 600; color: #0f172a; }
    .act-desc  { font-size: 12px; color: #64748b; margin-top: 2px;
                 white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 200px; }
    .act-time  { font-size: 11px; color: #94a3b8; margin-top: 3px; }
    .act-emerald { background: #ecfdf5; } .act-emerald i { color: #059669; }
    .act-blue    { background: #eff6ff; } .act-blue    i { color: #2563eb; }
    .act-amber   { background: #fffbeb; } .act-amber   i { color: #d97706; }
    .act-purple  { background: #faf5ff; } .act-purple  i { color: #9333ea; }

    .btn-view-all {
        display: flex; align-items: center; justify-content: center; gap: 6px;
        width: 100%; margin-top: 16px; padding: 10px;
        background: none; border: none; cursor: pointer;
        font-size: 13px; font-weight: 600; color: #6366f1;
        transition: color 0.2s;
    }

    .btn-view-all:hover { color: #4f46e5; }
    .btn-view-all i { font-size: 12px; transition: transform 0.2s; }
    .btn-view-all:hover i { transform: translateX(3px); }

    .announcement-item {
        padding: 14px; border-radius: 12px;
        border: 1px solid #e2e8f0; cursor: pointer;
        transition: border-color 0.2s, background 0.2s;
    }

    .announcement-item + .announcement-item { margin-top: 10px; }
    .announcement-item:hover { border-color: #c7d2fe; background: rgba(99,102,241,0.03); }
    .ann-header { display: flex; align-items: flex-start; gap: 10px; }

    .ann-dot {
        width: 8px; height: 8px; border-radius: 50%;
        flex-shrink: 0; margin-top: 5px;
    }

    .dot-info    { background: #3b82f6; }
    .dot-warning { background: #f59e0b; }
    .dot-success { background: #10b981; }
    .ann-title { font-size: 13px; font-weight: 600; color: #0f172a; }
    .ann-desc  { font-size: 12px; color: #64748b; margin-top: 4px; line-height: 1.5; }
    .ann-date  { font-size: 11px; color: #94a3b8; margin-top: 6px; }

    .progress-card {
        background: linear-gradient(135deg, #6366f1, #9333ea);
        border-radius: 16px; padding: 24px; color: #fff;
        box-shadow: 0 8px 24px rgba(99,102,241,0.3);
    }

    .progress-card h3 { font-size: 16px; font-weight: 700; margin-bottom: 16px; }

    .progress-meta {
        display: flex; justify-content: space-between;
        align-items: center; margin-bottom: 8px;
    }

    .progress-meta span { font-size: 13px; color: #c7d2fe; }
    .progress-meta strong { font-weight: 700; }

    .progress-bar {
        width: 100%; height: 10px;
        background: rgba(255,255,255,0.2);
        border-radius: 99px; overflow: hidden;
    }

    .progress-fill {
        height: 100%; background: #fff;
        border-radius: 99px;
        box-shadow: 0 2px 6px rgba(255,255,255,0.4);
    }

    .progress-footer { margin-top: 14px; padding-top: 14px; border-top: 1px solid rgba(255,255,255,0.2); }
    .progress-footer p  { font-size: 13px; color: #c7d2fe; margin-bottom: 4px; }
    .progress-footer small { font-size: 11px; color: #a5b4fc; }

    @media (max-width: 1100px) {
        .content-grid { grid-template-columns: 1fr; }
        .stats-grid   { grid-template-columns: repeat(2, 1fr); }
    }

    @media (max-width: 600px) {
        .stats-grid { grid-template-columns: 1fr; }
        .welcome-banner { padding: 28px 20px; }
        .welcome-title  { font-size: 26px; }
        .quick-actions-grid { grid-template-columns: repeat(2, 1fr); }
        .class-meta { grid-template-columns: 1fr; }
        .welcome-icon-box { display: none; }
    }
</style>

<div class="db-wrap">
    <div class="welcome-banner">
        <div class="welcome-blob1"></div>
        <div class="welcome-blob2"></div>
        <div class="welcome-inner">
            <div>
                <div class="welcome-title">
                    Welcome back, <asp:Label ID="lblWelcomeName" runat="server" Text="John" />! 👋
                </div>
                <p class="welcome-sub">
                    You're doing great this semester! Here's an overview of your academic progress and upcoming activities.
                </p>
                <div class="welcome-meta">
                    <div class="welcome-meta-item">
                        <div class="meta-label">Student ID</div>
                        <div class="meta-value"><asp:Label ID="lblWelcomeID" runat="server" Text="2024001234" /></div>
                    </div>
                    <div class="meta-divider"></div>
                    <div class="welcome-meta-item">
                        <div class="meta-label">Program</div>
                        <div class="meta-value"><asp:Label ID="lblWelcomeProgram" runat="server" Text="Computer Science" /></div>
                    </div>
                    <div class="meta-divider"></div>
                    <div class="welcome-meta-item">
                        <div class="meta-label">Semester</div>
                        <div class="meta-value"><asp:Label ID="lblWelcomeSemester" runat="server" Text="Spring 2024" /></div>
                    </div>
                </div>
            </div>
            <div class="welcome-icon-box">
                <i class="fa fa-graduation-cap"></i>
            </div>
        </div>
    </div>

    <div class="stats-grid">
        <div class="stat-card">
            <div>
                <div class="stat-label">Current GPA</div>
                <div class="stat-value"><asp:Label ID="lblGPA" runat="server" Text="3.85" /></div>
                <div class="stat-sub green">
                    <i class="fa fa-trending-up"></i>
                    +0.12 this semester
                </div>
            </div>
            <div class="stat-icon icon-green"><i class="fa fa-line-chart"></i></div>
        </div>

        <div class="stat-card">
            <div>
                <div class="stat-label">Enrolled Courses</div>
                <div class="stat-value"><asp:Label ID="lblEnrolledCount" runat="server" Text="6" /></div>
                <div class="stat-sub slate">
                    <asp:Label ID="lblTotalCredits" runat="server" Text="18" /> credits total
                </div>
            </div>
            <div class="stat-icon icon-blue"><i class="fa fa-book"></i></div>
        </div>

        <div class="stat-card">
            <div>
                <div class="stat-label">Completed Credits</div>
                <div class="stat-value"><asp:Label ID="lblCompletedCredits" runat="server" Text="87" /></div>
                <div class="stat-sub slate">
                    of <asp:Label ID="lblRequiredCredits" runat="server" Text="120" /> required
                </div>
            </div>
            <div class="stat-icon icon-purple"><i class="fa fa-trophy"></i></div>
        </div>

        <div class="stat-card">
            <div>
                <div class="stat-label">Outstanding Balance</div>
                <div class="stat-value">$<asp:Label ID="lblBalance" runat="server" Text="2.5K" /></div>
                <div class="stat-sub amber">
                    Due <asp:Label ID="lblDueDate" runat="server" Text="Apr 20" />
                </div>
            </div>
            <div class="stat-icon icon-amber"><i class="fa fa-credit-card"></i></div>
        </div>
    </div>

    <div class="content-grid">
        <div class="main-col">
            <div class="schedule-header">
                <div>
                    <h2>Today's Schedule</h2>
                    <p><asp:Label ID="lblTodayDate" runat="server" /></p>
                </div>
                <a href="TimeTable.aspx" class="btn-calendar">
                    <i class="fa fa-calendar"></i> View Full Calendar
                </a>
            </div>

            <asp:Repeater ID="rptClasses" runat="server">
                <ItemTemplate>
                    <div class="class-card">
                        <div class="class-icon <%# Eval("IconClass") %>">
                            <i class="fa fa-book-open"></i>
                        </div>
                        <div class="class-body">
                            <div class="class-code"><%# Eval("Code") %></div>
                            <div class="class-name"><%# Eval("Name") %></div>
                            <div class="class-meta">
                                <div class="class-meta-item">
                                    <i class="fa fa-clock-o"></i>
                                    <span><%# Eval("Time") %></span>
                                </div>
                                <div class="class-meta-item">
                                    <i class="fa fa-map-marker"></i>
                                    <span><%# Eval("Room") %></span>
                                </div>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
                <SeparatorTemplate><div style="height:12px;"></div></SeparatorTemplate>
            </asp:Repeater>

            <div class="card">
                <div class="card-title">Quick Actions</div>
                <div class="quick-actions-grid">
                    <a href="Enrollment.aspx" class="qa-btn qa-blue">
                        <div class="qa-icon"><i class="fa fa-book"></i></div>
                        <div class="qa-label">Enroll</div>
                    </a>
                    <a href="Statement.aspx" class="qa-btn qa-purple">
                        <div class="qa-icon"><i class="fa fa-file-text"></i></div>
                        <div class="qa-label">Statement</div>
                    </a>
                    <a href="Payment.aspx" class="qa-btn qa-emerald">
                        <div class="qa-icon"><i class="fa fa-credit-card"></i></div>
                        <div class="qa-label">Pay</div>
                    </a>
                    <a href="TeachingEvaluation.aspx" class="qa-btn qa-amber">
                        <div class="qa-icon"><i class="fa fa-star"></i></div>
                        <div class="qa-label">Evaluate</div>
                    </a>
                </div>
            </div>
        </div>

        <div class="side-col">
            <div class="card">
                <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:16px;">
                    <div class="card-title" style="margin-bottom:0;">Recent Activities</div>
                    <i class="fa fa-bell" style="color:#94a3b8;font-size:16px;"></i>
                </div>

                <asp:Repeater ID="rptActivities" runat="server">
                    <ItemTemplate>
                        <div class="activity-item">
                            <div class="act-icon <%# Eval("BgClass") %>">
                                <i class="<%# Eval("IconClass") %>"></i>
                            </div>
                            <div style="flex:1;min-width:0;">
                                <div class="act-title"><%# Eval("Title") %></div>
                                <div class="act-desc"><%# Eval("Description") %></div>
                                <div class="act-time"><%# Eval("Time") %></div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>

                <button class="btn-view-all">
                    View all activities <i class="fa fa-arrow-right"></i>
                </button>
            </div>

            <div class="card">
                <div class="card-title">Announcements</div>
                <asp:Repeater ID="rptAnnouncements" runat="server">
                    <ItemTemplate>
                        <div class="announcement-item">
                            <div class="ann-header">
                                <div class="ann-dot <%# Eval("DotClass") %>"></div>
                                <div>
                                    <div class="ann-title"><%# Eval("Title") %></div>
                                    <div class="ann-desc"><%# Eval("Description") %></div>
                                    <div class="ann-date"><%# Eval("Date") %></div>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <div class="progress-card">
                <h3>Academic Progress</h3>
                <div class="progress-meta">
                    <span>Credits Earned</span>
                    <strong>
                        <asp:Label ID="lblProgressText" runat="server" Text="87/120" />
                    </strong>
                </div>
                <div class="progress-bar">
                    <div class="progress-fill" style="width: <%# GetProgressWidth() %>%;"></div>
                </div>
                <div class="progress-footer">
                    <p>You're <asp:Label ID="lblProgressPct" runat="server" Text="72.5" />% complete!</p>
                    <small>Expected graduation: <asp:Label ID="lblGradYear" runat="server" Text="May 2027" /></small>
                </div>
            </div>

        </div>
    </div>
</div>
</asp:Content>