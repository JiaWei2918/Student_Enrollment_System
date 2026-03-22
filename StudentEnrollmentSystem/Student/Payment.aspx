<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Payment.aspx.cs" Inherits="StudentEnrollmentSystem.Student.Payment" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Payment</title>
    <style>
        .success { color:green; font-weight:bold;}
        .error { color:red; font-weight:bold;}
        .processing { color:orange; font-weight:bold;}
    </style>
</head>
<body>
    <form runat="server">
        <h2>💳 Payment Portal</h2>

        <asp:Label ID="lblMsg" runat="server"></asp:Label>

        <br />

        <h3>My Invoices</h3>

        <asp:GridView ID="gvInvoice" runat="server" AutoGenerateColumns="False"
            DataKeyNames="InvoiceID"
            OnSelectedIndexChanged="gvInvoice_SelectedIndexChanged">

            <Columns>
                <asp:BoundField DataField="InvoiceNumber" HeaderText="Invoice No" />
                <asp:BoundField DataField="TotalAmount" HeaderText="Amount" />
                <asp:BoundField DataField="Status" HeaderText="Status" />
                <asp:BoundField DataField="DueDate" HeaderText="Due Date" />
                <asp:CommandField ShowSelectButton="True" SelectText="Pay" />
            </Columns>
        </asp:GridView>

        <br />

        <asp:Panel ID="pnlPayment" runat="server" Visible="false">
            <h3>Make Payment</h3>

            Amount:
            <asp:TextBox ID="txtAmount" runat="server"></asp:TextBox>

            <br /><br />

            Method:
            <asp:DropDownList ID="ddlMethod" runat="server">
                <asp:ListItem>Credit Card</asp:ListItem>
                <asp:ListItem>Online Banking</asp:ListItem>
                <asp:ListItem>Bank Transfer</asp:ListItem>
            </asp:DropDownList>

            <br /><br />

            <asp:Button ID="btnPay" runat="server" Text="Pay Now"
                OnClick="btnPay_Click" />
        </asp:Panel>
    </form>
</body>
</html>
