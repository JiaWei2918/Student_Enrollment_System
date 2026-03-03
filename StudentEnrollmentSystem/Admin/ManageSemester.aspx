<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageSemester.aspx.cs" Inherits="StudentEnrollmentSystem.Admin.ManageSemester" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Manage Semester</title>
</head>
<body>
    <form runat="server">
        <h2>Manage Semester</h2>

        <asp:Label ID="lblMessage" runat="server" Font-Bold="true"></asp:Label>
        <br /><br />

        Semester Name:
        <asp:TextBox ID="txtSemesterName" runat="server" /><br />

        Academic Year:
        <asp:TextBox ID="txtAcademicYear" runat="server" /><br />

        Start Date:
        <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" /><br />

        End Date:
        <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" /><br />

        Add Period Start:
        <asp:TextBox ID="txtAddStart" runat="server" TextMode="Date" /><br />

        Add Period End:
        <asp:TextBox ID="txtAddEnd" runat="server" TextMode="Date" /><br />

        Drop Period Start:
        <asp:TextBox ID="txtDropStart" runat="server" TextMode="Date" /><br />

        Drop Period End:
        <asp:TextBox ID="txtDropEnd" runat="server" TextMode="Date" /><br />

        Status:
        <asp:DropDownList ID="ddlStatus" runat="server">
            <asp:ListItem Text="Planning" Value="Planning" />
            <asp:ListItem Text="Active" Value="Active" />
            <asp:ListItem Text="Closed" Value="Closed" />
        </asp:DropDownList><br />

        Max Credits:
        <asp:TextBox ID="txtMaxCredits" runat="server" /><br /><br />

        <asp:Button ID="btnAdd" runat="server" Text="Add Semester"
            OnClick="btnAdd_Click" CssClass="btn btn-primary" />

        <hr />

        <h3>Semester List</h3>

        <asp:GridView ID="gvSemester" runat="server" AutoGenerateColumns="False"
            DataKeyNames="SemesterID"
            OnRowEditing="gvSemester_RowEditing"
            OnRowUpdating="gvSemester_RowUpdating"
            OnRowCancelingEdit="gvSemester_RowCancelingEdit"
            OnRowDeleting="gvSemester_RowDeleting">

            <Columns>
                <asp:TemplateField HeaderText="Semester Name">
                    <ItemTemplate>
                        <%# Eval("SemesterName") %>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditSemesterName" runat="server"
                            Text='<%# Bind("SemesterName") %>' />
                    </EditItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Academic Year">
                    <ItemTemplate>
                        <%# Eval("AcademicYear") %>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditAcademicYear" runat="server"
                            Text='<%# Bind("AcademicYear") %>' />
                    </EditItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Start Date">
                    <ItemTemplate>
                        <%# Eval("StartDate", "{0:yyyy-MM-dd}") %>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditStartDate" runat="server"
                            TextMode="Date"
                            Text='<%# Bind("StartDate", "{0:yyyy-MM-dd}") %>' />
                    </EditItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="End Date">
                    <ItemTemplate>
                        <%# Eval("EndDate", "{0:yyyy-MM-dd}") %>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditEndDate" runat="server"
                            TextMode="Date"
                            Text='<%# Bind("EndDate", "{0:yyyy-MM-dd}") %>' />
                    </EditItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Add Start">
                    <ItemTemplate>
                        <%# Eval("AddPeriodStart", "{0:yyyy-MM-dd}") %>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditAddStart" runat="server"
                            TextMode="Date"
                            Text='<%# Bind("AddPeriodStart", "{0:yyyy-MM-dd}") %>' />
                    </EditItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Add End">
                    <ItemTemplate>
                        <%# Eval("AddPeriodEnd", "{0:yyyy-MM-dd}") %>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditAddEnd" runat="server"
                            TextMode="Date"
                            Text='<%# Bind("AddPeriodEnd", "{0:yyyy-MM-dd}") %>' />
                    </EditItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Drop Start">
                    <ItemTemplate>
                        <%# Eval("DropPeriodStart", "{0:yyyy-MM-dd}") %>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditDropStart" runat="server"
                            TextMode="Date"
                            Text='<%# Bind("DropPeriodStart", "{0:yyyy-MM-dd}") %>' />
                    </EditItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Drop End">
                    <ItemTemplate>
                        <%# Eval("DropPeriodEnd", "{0:yyyy-MM-dd}") %>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditDropEnd" runat="server"
                            TextMode="Date"
                            Text='<%# Bind("DropPeriodEnd", "{0:yyyy-MM-dd}") %>' />
                    </EditItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Status">
                    <ItemTemplate>
                        <%# Eval("Status") %>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:DropDownList ID="ddlEditStatus" runat="server"
                            SelectedValue='<%# Bind("Status") %>'>
                            <asp:ListItem Text="Planning" Value="Planning" />
                            <asp:ListItem Text="Active" Value="Active" />
                            <asp:ListItem Text="Closed" Value="Closed" />
                        </asp:DropDownList>
                    </EditItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Max Credits">
                    <ItemTemplate>
                        <%# Eval("MaxCredits") %>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditMaxCredits" runat="server"
                            Text='<%# Bind("MaxCredits") %>' />
                    </EditItemTemplate>
                </asp:TemplateField>

                <asp:CommandField ShowEditButton="True" ShowDeleteButton="True" />
            </Columns>
        </asp:GridView>
    </form>
</body>
</html>
