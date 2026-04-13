<%@ Page Title="Manage Semester" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="ManageSemester.aspx.cs" Inherits="StudentEnrollmentSystem.Admin.ManageSemester" %>

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

    @media (max-width: 768px) {
        .form-row {
            grid-template-columns: 1fr;
        }
    }
</style>

<div class="form-container">
        <h3 class="form-title"><i class="fas fa-calendar-alt"></i> Add/Edit Semester</h3>

        <asp:Label ID="lblMessage" runat="server" CssClass="message-label" EnableViewState="false" />

        <div class="form-row">
            <div class="form-group">
                <label>Semester Name <span style="color:#ef4444;">*</span></label>
                <asp:TextBox ID="txtSemesterName" runat="server" CssClass="form-control-custom" placeholder="e.g., Semester 1" />
            </div>
            <div class="form-group">
                <label>Academic Year <span style="color:#ef4444;">*</span></label>
                <asp:TextBox ID="txtAcademicYear" runat="server" CssClass="form-control-custom" placeholder="e.g., 2025" />
            </div>
            <div class="form-group">
                <label>Start Date <span style="color:#ef4444;">*</span></label>
                <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" CssClass="form-control-custom" />
            </div>
            <div class="form-group">
                <label>End Date <span style="color:#ef4444;">*</span></label>
                <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" CssClass="form-control-custom" />
            </div>
            <div class="form-group">
                <label>Add Period Start</label>
                <asp:TextBox ID="txtAddStart" runat="server" TextMode="Date" CssClass="form-control-custom" />
            </div>
            <div class="form-group">
                <label>Add Period End</label>
                <asp:TextBox ID="txtAddEnd" runat="server" TextMode="Date" CssClass="form-control-custom" />
            </div>
            <div class="form-group">
                <label>Drop Period Start</label>
                <asp:TextBox ID="txtDropStart" runat="server" TextMode="Date" CssClass="form-control-custom" />
            </div>
            <div class="form-group">
                <label>Drop Period End</label>
                <asp:TextBox ID="txtDropEnd" runat="server" TextMode="Date" CssClass="form-control-custom" />
            </div>
            <div class="form-group">
                <label>Status</label>
                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control-custom">
                    <asp:ListItem Text="Planning" Value="Planning" />
                    <asp:ListItem Text="Active" Value="Active" />
                    <asp:ListItem Text="Closed" Value="Closed" />
                </asp:DropDownList>
            </div>
            <div class="form-group">
                <label>Max Credits <span style="color:#ef4444;">*</span></label>
                <asp:TextBox ID="txtMaxCredits" runat="server" CssClass="form-control-custom" placeholder="e.g., 18" />
            </div>
        </div>

        <asp:Button ID="btnAdd" runat="server" Text="Add Semester" CssClass="btn-primary-custom" OnClick="btnAdd_Click" />
    </div>

    <div class="grid-container">
        <div class="grid-title">
            <i class="fas fa-list"></i> Semester List
        </div>
        <asp:GridView ID="gvSemester" runat="server" AutoGenerateColumns="False"
            DataKeyNames="SemesterID" CssClass="styled-grid" GridLines="None"
            OnRowEditing="gvSemester_RowEditing"
            OnRowUpdating="gvSemester_RowUpdating"
            OnRowCancelingEdit="gvSemester_RowCancelingEdit"
            OnRowDeleting="gvSemester_RowDeleting"
            EmptyDataText="No semesters found.">
            <Columns>
                <asp:TemplateField HeaderText="Semester Name">
                    <ItemTemplate><%# Eval("SemesterName") %></ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditSemesterName" runat="server" Text='<%# Bind("SemesterName") %>' />
                    </EditItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Academic Year">
                    <ItemTemplate><%# Eval("AcademicYear") %></ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditAcademicYear" runat="server" Text='<%# Bind("AcademicYear") %>' />
                    </EditItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Start Date">
                    <ItemTemplate><%# Eval("StartDate", "{0:yyyy-MM-dd}") %></ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditStartDate" runat="server" TextMode="Date" Text='<%# Bind("StartDate", "{0:yyyy-MM-dd}") %>' />
                    </EditItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="End Date">
                    <ItemTemplate><%# Eval("EndDate", "{0:yyyy-MM-dd}") %></ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditEndDate" runat="server" TextMode="Date" Text='<%# Bind("EndDate", "{0:yyyy-MM-dd}") %>' />
                    </EditItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Add Start">
                    <ItemTemplate><%# Eval("AddPeriodStart", "{0:yyyy-MM-dd}") %></ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditAddStart" runat="server" TextMode="Date" Text='<%# Bind("AddPeriodStart", "{0:yyyy-MM-dd}") %>' />
                    </EditItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Add End">
                    <ItemTemplate><%# Eval("AddPeriodEnd", "{0:yyyy-MM-dd}") %></ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditAddEnd" runat="server" TextMode="Date" Text='<%# Bind("AddPeriodEnd", "{0:yyyy-MM-dd}") %>' />
                    </EditItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Drop Start">
                    <ItemTemplate><%# Eval("DropPeriodStart", "{0:yyyy-MM-dd}") %></ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditDropStart" runat="server" TextMode="Date" Text='<%# Bind("DropPeriodStart", "{0:yyyy-MM-dd}") %>' />
                    </EditItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Drop End">
                    <ItemTemplate><%# Eval("DropPeriodEnd", "{0:yyyy-MM-dd}") %></ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditDropEnd" runat="server" TextMode="Date" Text='<%# Bind("DropPeriodEnd", "{0:yyyy-MM-dd}") %>' />
                    </EditItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Status">
                    <ItemTemplate><%# Eval("Status") %></ItemTemplate>
                    <EditItemTemplate>
                        <asp:DropDownList ID="ddlEditStatus" runat="server" SelectedValue='<%# Bind("Status") %>'>
                            <asp:ListItem Text="Planning" Value="Planning" />
                            <asp:ListItem Text="Active" Value="Active" />
                            <asp:ListItem Text="Closed" Value="Closed" />
                        </asp:DropDownList>
                    </EditItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Max Credits">
                    <ItemTemplate><%# Eval("MaxCredits") %></ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditMaxCredits" runat="server" Text='<%# Bind("MaxCredits") %>' />
                    </EditItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>
                        <asp:LinkButton ID="btnEdit" runat="server" CommandName="Edit" CssClass="action-link">
                            <i class="fas fa-edit"></i> Edit
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnDelete" runat="server" CommandName="Delete" CssClass="action-link delete-link"
                            OnClientClick="return confirm('Delete this semester? All related offerings will also be deleted.');">
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