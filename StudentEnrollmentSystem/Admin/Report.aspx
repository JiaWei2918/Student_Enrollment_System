<%@ Page Title="Reports" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="Report.aspx.cs" Inherits="StudentEnrollmentSystem.Admin.Report" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<style>
    .report-container {
        display: flex;
        flex-direction: column;
        gap: 30px;
    }

    .report-card {
        background: white;
        border-radius: 20px;
        padding: 20px;
        border: 1px solid #e5e7eb;
        box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    }

    .report-title {
        font-size: 1.3rem;
        font-weight: 600;
        margin-bottom: 20px;
        padding-bottom: 8px;
        border-bottom: 2px solid #2563eb;
        display: inline-block;
    }

    .filter-bar {
        margin-bottom: 20px;
        display: flex;
        align-items: center;
        gap: 15px;
        flex-wrap: wrap;
    }

    .filter-bar label {
        font-weight: 500;
        color: #374151;
    }

    .form-control-custom {
        padding: 8px 14px;
        border: 1px solid #d1d5db;
        border-radius: 10px;
        font-size: 0.9rem;
        min-width: 250px;
    }

    .btn-primary-custom {
        background-color: #2563eb;
        border: none;
        color: white;
        padding: 8px 20px;
        border-radius: 30px;
        font-weight: 500;
        cursor: pointer;
        transition: 0.2s;
    }

    .btn-primary-custom:hover {
        background-color: #1d4ed8;
    }

    .styled-grid {
        width: 100%;
        border-collapse: collapse;
        font-size: 0.85rem;
        margin-top: 15px;
    }

    .styled-grid th {
        background-color: #f9fafb;
        color: #1f2937;
        font-weight: 600;
        padding: 12px 8px;
        border-bottom: 2px solid #e5e7eb;
        text-align: left;
    }

    .styled-grid td {
        padding: 10px 8px;
        border-bottom: 1px solid #f0f0f0;
        vertical-align: middle;
    }

    .styled-grid tr:hover {
        background-color: #f9fafb;
    }

    .badge {
        display: inline-block;
        padding: 4px 12px;
        border-radius: 30px;
        font-size: 0.75rem;
        font-weight: 500;
    }

    .badge-open { background: #d1fae5; color: #065f46; }
    .badge-full { background: #fee2e2; color: #991b1b; }

    .empty-message {
        text-align: center;
        color: #6b7280;
        padding: 30px;
    }

    @media (max-width: 768px) {
        .filter-bar { flex-direction: column; align-items: stretch; }
        .form-control-custom { width: 100%; }
    }
</style>

<div class="report-container">
        <div class="report-card">
            <div class="report-title">
                <i class="fas fa-chart-simple"></i> Course Enrollment Summary
            </div>
            <asp:GridView ID="gvSummary" runat="server" AutoGenerateColumns="False" CssClass="styled-grid" GridLines="None" EmptyDataText="No course offerings found.">
                <Columns>
                    <asp:BoundField DataField="CourseCode" HeaderText="Course Code" />
                    <asp:BoundField DataField="CourseName" HeaderText="Course Name" />
                    <asp:BoundField DataField="SemesterName" HeaderText="Semester" />
                    <asp:BoundField DataField="AcademicYear" HeaderText="Year" />
                    <asp:BoundField DataField="Lecturer" HeaderText="Lecturer" />
                    <asp:BoundField DataField="Capacity" HeaderText="Capacity" />
                    <asp:BoundField DataField="EnrolledStudents" HeaderText="Enrolled" />
                    <asp:BoundField DataField="SeatsLeft" HeaderText="Seats Left" />
                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate>
                            <span class='badge <%# Convert.ToInt32(Eval("SeatsLeft")) > 0 ? "badge-open" : "badge-full" %>'>
                                <%# Convert.ToInt32(Eval("SeatsLeft")) > 0 ? "Open" : "Full" %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>

        <div class="report-card">
            <div class="report-title">
                <i class="fas fa-users"></i> Student Enrollment List
            </div>
            <div class="filter-bar">
                <label>Select Course Offering:</label>
                <asp:DropDownList ID="ddlOffering" runat="server" CssClass="form-control-custom" AutoPostBack="True" OnSelectedIndexChanged="ddlOffering_SelectedIndexChanged" />
                <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="btn-primary-custom" OnClick="btnRefresh_Click" />
            </div>
            <asp:GridView ID="gvStudents" runat="server" AutoGenerateColumns="False" CssClass="styled-grid" GridLines="None" EmptyDataText="No students enrolled in this offering.">
                <Columns>
                    <asp:BoundField DataField="MatricNo" HeaderText="Matric No" />
                    <asp:BoundField DataField="FullName" HeaderText="Student Name" />
                    <asp:BoundField DataField="Email" HeaderText="Email" />
                    <asp:BoundField DataField="Program" HeaderText="Program" />
                    <asp:BoundField DataField="EnrollmentDate" HeaderText="Enrollment Date" DataFormatString="{0:yyyy-MM-dd}" />
                </Columns>
            </asp:GridView>
        </div>
    </div>
</asp:Content>