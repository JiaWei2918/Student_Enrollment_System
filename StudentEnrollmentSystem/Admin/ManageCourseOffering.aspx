<%@ Page Title="Manage Course Offering" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="ManageCourseOffering.aspx.cs" Inherits="StudentEnrollmentSystem.Admin.ManageCourseOffering" %>

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
        max-width: 400px;
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

    .btn-primary-custom {
        background-color: #2563eb;
        border: none;
        color: white;
        padding: 10px 24px;
        border-radius: 30px;
        font-weight: 500;
        cursor: pointer;
        transition: 0.2s;
    }

    .btn-primary-custom:hover {
        background-color: #1d4ed8;
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

    .action-link {
        color: #2563eb;
        text-decoration: none;
        margin-right: 8px;
    }

    .action-link:hover {
        text-decoration: underline;
    }

    .delete-link {
        color: #dc2626;
    }

    .delete-link:hover {
        color: #b91c1c;
    }
</style>

<div class="form-container">
        <h3 class="form-title"><i class="fas fa-calendar-plus"></i> Add Course Offering</h3>

        <div class="form-group">
            <label>Course <span style="color:#ef4444;">*</span></label>
            <asp:DropDownList ID="ddlCourse" runat="server" CssClass="form-control-custom" />
        </div>

        <div class="form-group">
            <label>Semester <span style="color:#ef4444;">*</span></label>
            <asp:DropDownList ID="ddlSemester" runat="server" CssClass="form-control-custom" />
        </div>

        <div class="form-group">
            <label>Lecturer <span style="color:#ef4444;">*</span></label>
            <asp:TextBox ID="txtLecturer" runat="server" CssClass="form-control-custom" placeholder="e.g., Prof. John Doe" />
        </div>

        <div class="form-group">
            <label>Capacity <span style="color:#ef4444;">*</span></label>
            <asp:TextBox ID="txtCapacity" runat="server" CssClass="form-control-custom" placeholder="e.g., 40" />
        </div>

        <div>
            <asp:Button ID="btnAdd" runat="server" Text="Add Offering" CssClass="btn-primary-custom" OnClick="btnAdd_Click" />
        </div>

        <asp:Label ID="lblMessage" runat="server" CssClass="message-label" EnableViewState="false" />
    </div>

    <div class="grid-container">
        <div class="grid-title">
            <i class="fas fa-list"></i> Course Offering List
        </div>
        <asp:GridView ID="gvOffering" runat="server" AutoGenerateColumns="False"
            DataKeyNames="OfferingID" CssClass="styled-grid" GridLines="None"
            OnRowEditing="gvOffering_RowEditing"
            OnRowCancelingEdit="gvOffering_RowCancelingEdit"
            OnRowUpdating="gvOffering_RowUpdating"
            OnRowDeleting="gvOffering_RowDeleting"
            EmptyDataText="No course offerings found.">
            <Columns>
                <asp:BoundField DataField="CourseCode" HeaderText="Course Code" ReadOnly="True" />
                <asp:BoundField DataField="CourseName" HeaderText="Course Name" ReadOnly="True" />
                <asp:BoundField DataField="SemesterName" HeaderText="Semester" ReadOnly="True" />
                <asp:BoundField DataField="AcademicYear" HeaderText="Year" ReadOnly="True" />

                <asp:TemplateField HeaderText="Lecturer">
                    <ItemTemplate><%# Eval("Lecturer") %></ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditLecturer" runat="server" Text='<%# Bind("Lecturer") %>' CssClass="form-control-custom" style="width:150px;" />
                    </EditItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Capacity">
                    <ItemTemplate><%# Eval("Capacity") %></ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditCapacity" runat="server" Text='<%# Bind("Capacity") %>' CssClass="form-control-custom" style="width:100px;" />
                    </EditItemTemplate>
                </asp:TemplateField>

                <asp:BoundField DataField="EnrolledStudents" HeaderText="Enrolled" ReadOnly="True" />
                <asp:BoundField DataField="SeatsLeft" HeaderText="Seats Left" ReadOnly="True" />
                <asp:BoundField DataField="Status" HeaderText="Status" ReadOnly="True" />

                <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>
                        <asp:LinkButton ID="btnEdit" runat="server" CommandName="Edit" CssClass="action-link">
                            <i class="fas fa-edit"></i> Edit
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnDelete" runat="server" CommandName="Delete" CssClass="action-link delete-link"
                            OnClientClick="return confirm('Delete this offering?');">
                            <i class="fas fa-trash-alt"></i> Delete
                        </asp:LinkButton>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:LinkButton ID="btnUpdate" runat="server" CommandName="Update" CssClass="action-link">
                            <i class="fas fa-save"></i> Update
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnCancel" runat="server" CommandName="Cancel" CssClass="action-link">
                            <i class="fas fa-times"></i> Cancel
                        </asp:LinkButton>
                    </EditItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>
</asp:Content>