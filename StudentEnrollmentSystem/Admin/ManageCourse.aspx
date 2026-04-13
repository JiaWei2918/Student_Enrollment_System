<%@ Page Title="Manage Courses" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="ManageCourse.aspx.cs" Inherits="StudentEnrollmentSystem.Admin.ManageCourse" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<style>
    .form-container {
        background: white;
        border-radius: 16px;
        padding: 25px;
        margin-bottom: 30px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        border: 1px solid #e5e7eb;
    }

    .form-title {
        font-size: 1.5rem;
        font-weight: 600;
        color: #1f2937;
        margin-bottom: 20px;
        padding-bottom: 12px;
        border-bottom: 2px solid #2563eb;
        display: inline-block;
    }

    .form-group {
        margin-bottom: 1.2rem;
    }

    .form-group label {
        font-weight: 500;
        color: #374151;
        margin-bottom: 6px;
        display: block;
    }

    .form-control-custom {
        width: 100%;
        padding: 10px 14px;
        border: 1px solid #d1d5db;
        border-radius: 10px;
        font-size: 0.95rem;
        transition: 0.2s;
    }

    .form-control-custom:focus {
        outline: none;
        border-color: #2563eb;
        box-shadow: 0 0 0 3px rgba(37,99,235,0.1);
    }

    .row-2cols {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
    }

    .btn-primary-custom {
        background-color: #2563eb;
        border: none;
        color: white;
        padding: 10px 24px;
        border-radius: 30px;
        font-weight: 500;
        cursor: pointer;
        transition: 0.2s;
        margin-right: 10px;
    }

    .btn-primary-custom:hover {
        background-color: #1d4ed8;
    }

    .btn-secondary-custom {
        background-color: #f3f4f6;
        border: 1px solid #d1d5db;
        color: #374151;
        padding: 10px 24px;
        border-radius: 30px;
        font-weight: 500;
        cursor: pointer;
        transition: 0.2s;
    }

    .btn-secondary-custom:hover {
        background-color: #e5e7eb;
    }

    .message-label {
        margin-top: 15px;
        padding: 10px;
        border-radius: 10px;
        font-weight: 500;
    }

    .grid-container {
        background: white;
        border-radius: 16px;
        padding: 20px;
        border: 1px solid #e5e7eb;
        overflow-x: auto;
    }

    .grid-title {
        font-size: 1.3rem;
        font-weight: 600;
        margin-bottom: 15px;
        color: #1f2937;
    }

    .styled-grid {
        width: 100%;
        border-collapse: collapse;
        font-size: 0.9rem;
    }

    .styled-grid th {
        background-color: #f9fafb;
        color: #1f2937;
        font-weight: 600;
        padding: 12px 10px;
        border-bottom: 2px solid #e5e7eb;
        text-align: left;
    }

    .styled-grid td {
        padding: 10px;
        border-bottom: 1px solid #f0f0f0;
        vertical-align: middle;
    }

    .styled-grid tr:hover {
        background-color: #f9fafb;
    }

    .action-btn {
        background: none;
        border: none;
        cursor: pointer;
        font-size: 1rem;
        margin: 0 5px;
        padding: 5px 10px;
        border-radius: 20px;
        transition: 0.2s;
    }

    .edit-btn {
        color: #2563eb;
    }
    .edit-btn:hover {
        background-color: #eff6ff;
    }

    .delete-btn {
        color: #dc2626;
    }
    .delete-btn:hover {
        background-color: #fef2f2;
    }

    @media (max-width: 768px) {
        .row-2cols {
            grid-template-columns: 1fr;
        }
    }
</style>

<div class="form-container">
        <h3 class="form-title"><i class="fas fa-book-open"></i> Course Management</h3>

        <asp:HiddenField ID="hfCourseID" runat="server" />

        <div class="row-2cols">
            <div class="form-group">
                <label>Course Code <span style="color:#ef4444;">*</span></label>
                <asp:TextBox ID="txtCourseCode" runat="server" CssClass="form-control-custom" placeholder="e.g., CS101" />
                <asp:RequiredFieldValidator ControlToValidate="txtCourseCode" ErrorMessage="Required" ForeColor="#dc2626" Display="Dynamic" runat="server" />
            </div>

            <div class="form-group">
                <label>Course Name <span style="color:#ef4444;">*</span></label>
                <asp:TextBox ID="txtCourseName" runat="server" CssClass="form-control-custom" placeholder="e.g., Web Development" />
                <asp:RequiredFieldValidator ControlToValidate="txtCourseName" ErrorMessage="Required" ForeColor="#dc2626" Display="Dynamic" runat="server" />
            </div>

            <div class="form-group" style="grid-column: span 2;">
                <label>Description</label>
                <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control-custom" placeholder="Brief description of the course..." />
            </div>

            <div class="form-group">
                <label>Credit Hours <span style="color:#ef4444;">*</span></label>
                <asp:TextBox ID="txtCreditHours" runat="server" CssClass="form-control-custom" placeholder="e.g., 3" />
                <asp:RequiredFieldValidator ControlToValidate="txtCreditHours" ErrorMessage="Required" ForeColor="#dc2626" Display="Dynamic" runat="server" />
                <asp:RegularExpressionValidator ControlToValidate="txtCreditHours" ValidationExpression="^\d+$" ErrorMessage="Only numbers" ForeColor="#dc2626" Display="Dynamic" runat="server" />
            </div>

            <div class="form-group">
                <label>Prerequisite Course</label>
                <asp:DropDownList ID="ddlPrerequisite" runat="server" CssClass="form-control-custom">
                </asp:DropDownList>
            </div>
        </div>

        <div style="margin-top: 15px;">
            <asp:Button ID="btnAdd" runat="server" Text="Add Course" CssClass="btn-primary-custom" OnClick="btnAdd_Click" />
            <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn-secondary-custom" CausesValidation="false" OnClick="btnCancel_Click" Visible="false" />
        </div>

        <asp:Label ID="lblMessage" runat="server" CssClass="message-label" EnableViewState="false" />
    </div>

    <div class="grid-container">
        <div class="grid-title">
            <i class="fas fa-list"></i> Course List
        </div>
        <asp:GridView ID="gvCourse" runat="server" AutoGenerateColumns="False" DataKeyNames="CourseID"
            OnRowCommand="gvCourse_RowCommand" CssClass="styled-grid" GridLines="None" 
            EmptyDataText="No courses found.">
            <Columns>
                <asp:BoundField DataField="CourseID" HeaderText="ID" />
                <asp:BoundField DataField="CourseCode" HeaderText="Code" />
                <asp:BoundField DataField="CourseName" HeaderText="Course Name" />
                <asp:BoundField DataField="CreditHours" HeaderText="Credits" />
                <asp:BoundField DataField="PrerequisiteName" HeaderText="Prerequisite" HeaderStyle-CssClass="text-center" />
                <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>
                        <asp:Button ID="btnEdit" runat="server" Text="Edit" CommandName="EditCourse"
                            CommandArgument='<%# Eval("CourseID") %>' CausesValidation="false"
                            CssClass="action-btn edit-btn" />
                        <asp:Button ID="btnDelete" runat="server" Text="Delete" CommandName="DeleteCourse"
                            CommandArgument='<%# Eval("CourseID") %>' CausesValidation="false"
                            OnClientClick="return confirm('Permanently delete this course?');"
                            CssClass="action-btn delete-btn" />
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>
</asp:Content>