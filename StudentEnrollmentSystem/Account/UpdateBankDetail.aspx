<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UpdateBankDetail.aspx.cs" Inherits="StudentEnrollmentSystem.Account.UpdateBank" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Update Bank Details</title>
</head>
<body>
    <form runat="server">
        <asp:Label ID="lblMessage" runat="server" Font-Bold="true"></asp:Label>

        <h3>Add / Update Bank</h3>

        <asp:HiddenField ID="hfBankDetailID" runat="server" />

        <table>
            <tr>
                <td>Bank Name</td>
                <td>
                    <asp:TextBox ID="txtBankName" runat="server" />
                    <asp:RequiredFieldValidator
                        ControlToValidate="txtBankName"
                        ErrorMessage="Required"
                        ForeColor="Red"
                        runat="server" />
                </td>
            </tr>

            <tr>
                <td>Account Number</td>
                <td>
                    <asp:TextBox ID="txtAccountNumber" runat="server" />
                    <asp:RequiredFieldValidator
                        ControlToValidate="txtAccountNumber"
                        ErrorMessage="Required"
                        ForeColor="Red"
                        runat="server" />

                    <asp:RegularExpressionValidator
                        ControlToValidate="txtAccountNumber"
                        ValidationExpression="^\d{8,20}$"
                        ErrorMessage="8-20 digits only"
                        ForeColor="Red"
                        runat="server" />
                </td>
            </tr>

            <tr>
                <td>Account Holder</td>
                <td>
                    <asp:TextBox ID="txtHolderName" runat="server" />
                    <asp:RequiredFieldValidator
                        ControlToValidate="txtHolderName"
                        ErrorMessage="Required"
                        ForeColor="Red"
                        runat="server" />
                </td>
            </tr>

            <tr>
                <td>Account Type</td>
                <td>
                    <asp:DropDownList ID="ddlType" runat="server">
                        <asp:ListItem Text="Savings" />
                        <asp:ListItem Text="Current" />
                    </asp:DropDownList>
                </td>
            </tr>

            <tr>
                <td>Primary</td>
                <td>
                    <asp:CheckBox ID="chkPrimary" runat="server" />
                </td>
            </tr>

            <tr>
                <td></td>
                <td>
                    <asp:Button ID="btnSave" runat="server" Text="Save" OnClick="btnSave_Click" />
                </td>
            </tr>
        </table>

        <hr />

        <h3>My Bank Accounts</h3>
        <asp:GridView ID="gvBank" runat="server" AutoGenerateColumns="False"
            DataKeyNames="BankDetailID"
            OnRowEditing="gvBank_RowEditing"
            OnRowDeleting="gvBank_RowDeleting">

            <Columns>
                <asp:BoundField DataField="BankName" HeaderText="Bank" />
                <asp:BoundField DataField="AccountNumber" HeaderText="Account No" />
                <asp:BoundField DataField="AccountHolderName" HeaderText="Holder" />
                <asp:BoundField DataField="AccountType" HeaderText="Type" />
                <asp:CheckBoxField DataField="IsPrimary" HeaderText="Primary" />

                <asp:CommandField ShowEditButton="True" ShowDeleteButton="True" CausesValidation="false" />
            </Columns>
        </asp:GridView>
    </form>
</body>
</html>
