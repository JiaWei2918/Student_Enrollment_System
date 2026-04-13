<%@ Page Title="Manage Students" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="ManageStudent.aspx.cs" Inherits="StudentEnrollmentSystem.Admin.ManageStudent" %>

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

    .form-row {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
    }

    .form-group {
        margin-bottom: 1rem;
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

    .btn-primary-custom {
        background-color: #2563eb;
        border: none;
        color: white;
        padding: 10px 24px;
        border-radius: 30px;
        font-weight: 500;
        cursor: pointer;
        transition: 0.2s;
        margin-top: 10px;
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
        font-size: 0.85rem;
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

    .styled-grid input, .styled-grid select {
        padding: 6px 8px;
        border: 1px solid #d1d5db;
        border-radius: 8px;
        width: 100%;
        font-size: 0.85rem;
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

    .validation-error {
        color: #dc2626;
        font-size: 0.75rem;
        margin-top: 4px;
        display: block;
    }

    @media (max-width: 768px) {
        .form-row {
            grid-template-columns: 1fr;
        }
    }
</style>

<div class="form-container">
        <h3 class="form-title"><i class="fas fa-user-plus"></i> Add New Student</h3>

        <asp:Label ID="lblMessage" runat="server" CssClass="message-label" EnableViewState="false" />

        <div class="form-row">
            <div class="form-group">
                <label>Matric No <span style="color:#ef4444;">*</span></label>
                <asp:TextBox ID="txtMatricNo" runat="server" CssClass="form-control-custom" placeholder="e.g., I23024002" />
                <asp:RequiredFieldValidator ControlToValidate="txtMatricNo" ErrorMessage="Required" CssClass="validation-error" Display="Dynamic" ValidationGroup="AddStudent" runat="server" />
            </div>
            <div class="form-group">
                <label>Full Name <span style="color:#ef4444;">*</span></label>
                <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control-custom" placeholder="e.g., John Doe" />
                <asp:RequiredFieldValidator ControlToValidate="txtFullName" ErrorMessage="Required" CssClass="validation-error" Display="Dynamic" ValidationGroup="AddStudent" runat="server" />
            </div>
            <div class="form-group">
                <label>Email <span style="color:#ef4444;">*</span></label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control-custom" placeholder="student@example.com" />
                <asp:RequiredFieldValidator ControlToValidate="txtEmail" ErrorMessage="Required" CssClass="validation-error" Display="Dynamic" ValidationGroup="AddStudent" runat="server" />
                <asp:RegularExpressionValidator ControlToValidate="txtEmail" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" ErrorMessage="Invalid email format" CssClass="validation-error" Display="Dynamic" ValidationGroup="AddStudent" runat="server" />
            </div>
            <div class="form-group">
                <label>Phone</label>
                <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control-custom" placeholder="e.g., 012-3456789" />
            </div>
            <div class="form-group">
                <label>Program</label>
                <asp:TextBox ID="txtProgram" runat="server" CssClass="form-control-custom" placeholder="e.g., BCSI" />
            </div>
            <div class="form-group">
                <label>Section</label>
                <asp:TextBox ID="txtSection" runat="server" CssClass="form-control-custom" placeholder="e.g., 1G1" />
            </div>
            <div class="form-group">
                <label>Enrollment Date <span style="color:#ef4444;">*</span></label>
                <asp:TextBox ID="txtEnrollmentDate" runat="server" TextMode="Date" CssClass="form-control-custom" />
                <asp:RequiredFieldValidator ControlToValidate="txtEnrollmentDate" ErrorMessage="Required" CssClass="validation-error" Display="Dynamic" ValidationGroup="AddStudent" runat="server" />
            </div>
            <div class="form-group">
                <label>Status</label>
                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control-custom">
                    <asp:ListItem Text="Active" Value="Active" />
                    <asp:ListItem Text="Inactive" Value="Inactive" />
                    <asp:ListItem Text="Graduated" Value="Graduated" />
                </asp:DropDownList>
            </div>
        </div>

        <asp:Button ID="btnAdd" runat="server" Text="Add Student" CssClass="btn-primary-custom" ValidationGroup="AddStudent" OnClick="btnAdd_Click" />
    </div>

    <div class="grid-container">
        <div class="grid-title">
            <i class="fas fa-users"></i> Student List
        </div>
        <asp:GridView ID="gvStudent" runat="server" AutoGenerateColumns="False" DataKeyNames="StudentID"
            CssClass="styled-grid" GridLines="None"
            OnRowEditing="gvStudent_RowEditing"
            OnRowCancelingEdit="gvStudent_RowCancelingEdit"
            OnRowUpdating="gvStudent_RowUpdating"
            OnRowDeleting="gvStudent_RowDeleting"
            EmptyDataText="No students found.">
            <Columns>
                <asp:BoundField DataField="MatricNo" HeaderText="Matric No" ReadOnly="True" />
                <asp:TemplateField HeaderText="Full Name">
                    <ItemTemplate><%# Eval("FullName") %></ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditFullName" runat="server" Text='<%# Bind("FullName") %>' />
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Email">
                    <ItemTemplate><%# Eval("Email") %></ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditEmail" runat="server" Text='<%# Bind("Email") %>' />
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Phone">
                    <ItemTemplate><%# Eval("Phone") %></ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditPhone" runat="server" Text='<%# Bind("Phone") %>' />
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Program">
                    <ItemTemplate><%# Eval("Program") %></ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditProgram" runat="server" Text='<%# Bind("Program") %>' />
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Section">
                    <ItemTemplate><%# Eval("Section") %></ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditSection" runat="server" Text='<%# Bind("Section") %>' />
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="EnrollmentDate" HeaderText="Enrollment Date" DataFormatString="{0:yyyy-MM-dd}" ReadOnly="True" />
                <asp:TemplateField HeaderText="Status">
                    <ItemTemplate><%# Eval("Status") %></ItemTemplate>
                    <EditItemTemplate>
                        <asp:DropDownList ID="ddlEditStatus" runat="server" SelectedValue='<%# Bind("Status") %>'>
                            <asp:ListItem Text="Active" Value="Active" />
                            <asp:ListItem Text="Inactive" Value="Inactive" />
                            <asp:ListItem Text="Graduated" Value="Graduated" />
                        </asp:DropDownList>
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>
                        <asp:LinkButton ID="btnEdit" runat="server" CommandName="Edit" CssClass="action-link">
                            <i class="fas fa-edit"></i> Edit
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnDelete" runat="server" CommandName="Delete" CssClass="action-link delete-link"
                            OnClientClick="return confirm('Delete this student? This action cannot be undone.');">
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