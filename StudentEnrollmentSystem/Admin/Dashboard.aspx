<%@ Page Title="Dashbaord" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="StudentEnrollmentSystem.Admin.Dashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<style>
    .welcome-section {
        margin-bottom: 30px;
    }

    .welcome-title {
        font-size: 1.8rem;
        font-weight: 600;
        color: #1f2937;
        margin-bottom: 8px;
    }

    .welcome-sub {
        color: #6b7280;
        border-left: 3px solid #2563eb;
        padding-left: 12px;
    }

    .stats-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
        gap: 20px;
        margin-bottom: 40px;
    }

    .stat-card {
        background: white;
        border-radius: 20px;
        padding: 20px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        border: 1px solid #e5e7eb;
        transition: transform 0.2s, box-shadow 0.2s;
    }

    .stat-card:hover {
        transform: translateY(-3px);
        box-shadow: 0 8px 20px rgba(0,0,0,0.08);
    }

    .stat-icon {
        font-size: 2.2rem;
        color: #2563eb;
        margin-bottom: 12px;
    }

    .stat-number {
        font-size: 2rem;
        font-weight: 700;
        color: #1f2937;
        line-height: 1.2;
    }

    .stat-label {
        color: #6b7280;
        font-size: 0.9rem;
        margin-top: 5px;
    }

    .quick-actions {
        background: white;
        border-radius: 20px;
        padding: 20px;
        border: 1px solid #e5e7eb;
    }

    .section-title {
        font-size: 1.3rem;
        font-weight: 600;
        margin-bottom: 20px;
        padding-bottom: 8px;
        border-bottom: 2px solid #2563eb;
        display: inline-block;
    }

    .action-buttons {
        display: flex;
        flex-wrap: wrap;
        gap: 15px;
        margin-top: 15px;
    }

    .action-btn {
        display: inline-flex;
        align-items: center;
        gap: 10px;
        background: #f3f4f6;
        color: #1f2937;
        padding: 12px 24px;
        border-radius: 40px;
        text-decoration: none;
        font-weight: 500;
        transition: all 0.2s;
        border: 1px solid #e5e7eb;
    }

    .action-btn i {
        color: #2563eb;
        font-size: 1.1rem;
    }

    .action-btn:hover {
        background: #2563eb;
        color: white;
    }

    .action-btn:hover i {
        color: white;
    }

    @media (max-width: 640px) {
        .stats-grid {
            grid-template-columns: 1fr;
        }

        .action-buttons {
            flex-direction: column;
        }

        .action-btn {
            justify-content: center;
        }
    }
</style>

<div class="welcome-section">
        <div class="welcome-title">
            <i class="fas fa-chalkboard-user" style="color: #2563eb;"></i>
            <asp:Label ID="lblWelcome" runat="server" />
        </div>
        <div class="welcome-sub">
            Manage students, courses, semesters, and offerings from one central dashboard.
        </div>
    </div>

    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon"><i class="fas fa-users"></i></div>
            <div class="stat-number"><asp:Label ID="lblTotalStudents" runat="server" Text="0" /></div>
            <div class="stat-label">Total Students</div>
        </div>
        <div class="stat-card">
            <div class="stat-icon"><i class="fas fa-book"></i></div>
            <div class="stat-number"><asp:Label ID="lblTotalCourses" runat="server" Text="0" /></div>
            <div class="stat-label">Total Courses</div>
        </div>
        <div class="stat-card">
            <div class="stat-icon"><i class="fas fa-calendar-alt"></i></div>
            <div class="stat-number"><asp:Label ID="lblTotalSemesters" runat="server" Text="0" /></div>
            <div class="stat-label">Semesters</div>
        </div>
        <div class="stat-card">
            <div class="stat-icon"><i class="fas fa-chalkboard"></i></div>
            <div class="stat-number"><asp:Label ID="lblTotalOfferings" runat="server" Text="0" /></div>
            <div class="stat-label">Course Offerings</div>
        </div>
    </div>

    <div class="quick-actions">
        <div class="section-title"><i class="fas fa-bolt"></i> Quick Management</div>
        <div class="action-buttons">
            <asp:HyperLink ID="lnkSemester" runat="server" NavigateUrl="~/Admin/ManageSemester.aspx" CssClass="action-btn">
                <i class="fas fa-calendar-week"></i> Manage Semesters
            </asp:HyperLink>
            <asp:HyperLink ID="lnkCourse" runat="server" NavigateUrl="~/Admin/ManageCourse.aspx" CssClass="action-btn">
                <i class="fas fa-book-open"></i> Manage Courses
            </asp:HyperLink>
            <asp:HyperLink ID="lnkOffering" runat="server" NavigateUrl="~/Admin/ManageCourseOffering.aspx" CssClass="action-btn">
                <i class="fas fa-clock"></i> Manage Offerings
            </asp:HyperLink>
            <asp:HyperLink ID="lnkStudent" runat="server" NavigateUrl="~/Admin/ManageStudent.aspx" CssClass="action-btn">
                <i class="fas fa-user-graduate"></i> Manage Students
            </asp:HyperLink>
        </div>
    </div>
</asp:Content>