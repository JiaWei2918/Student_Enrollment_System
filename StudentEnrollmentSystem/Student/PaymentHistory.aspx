<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PaymentHistory.aspx.cs" Inherits="StudentEnrollmentSystem.Student.PaymentHistory" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Payment History</title>

    <style>
        body {font-family: Arial; margin: 30px;}
        .receipt-box {
            border: 1px solid #ccc;
            padding: 20px;
            width: 400px;
            background: #fafafa;
        }

        .header {
            text-align: center;
            font-weight: bold;
            font-size: 18px;
        }

        .subheader {
            text-align: center;
            margin-bottom: 15px;
        }
    </style>
</head>
<body>
    <form runat="server">
        <h2>💳 Online Payment History</h2>

        <asp:GridView ID="gvHistory" runat="server" AutoGenerateColumns="False"
            DataKeyNames="PaymentID"
            OnSelectedIndexChanged="gvHistory_SelectedIndexChanged">

            <Columns>
                <asp:BoundField DataField="InvoiceNumber" HeaderText="Invoice" />
                <asp:BoundField DataField="Amount" HeaderText="Amount" DataFormatString="RM {0:N2}" />
                <asp:BoundField DataField="PaymentMethod" HeaderText="Method" />
                <asp:BoundField DataField="Status" HeaderText="Status" />
                <asp:BoundField DataField="PaymentDate" HeaderText="Date" DataFormatString="{0:dd MMM yyyy}" />
                <asp:CommandField ShowSelectButton="True" SelectText="View Receipt" />
            </Columns>
        </asp:GridView>

        <br />

        <asp:Panel ID="pnlReceipt" runat="server" Visible="false" CssClass="receipt-box">

            <div class="header">Student Enrollment System</div>
            <div class="subheader">Official Payment Receipt</div>

            <hr />

            Receipt No:
            <asp:Label ID="lblReceiptNo" runat="server"></asp:Label>
            <br /><br />

            Invoice No:
            <asp:Label ID="lblInvoice" runat="server"></asp:Label>
            <br /><br />

            Amount Paid:
            <asp:Label ID="lblAmount" runat="server"></asp:Label>
            <br /><br />

            Payment Method:
            <asp:Label ID="lblMethod" runat="server"></asp:Label>
            <br /><br />

            Payment Date:
            <asp:Label ID="lblDate" runat="server"></asp:Label>
            <br /><br />

            Transaction ID:
            <asp:Label ID="lblTransaction" runat="server"></asp:Label>
            <br /><br />

            <asp:Button ID="btnPrint" runat="server" Text="Print Receipt"
                OnClientClick="window.print(); return false;" />
        </asp:Panel>
    </form>
</body>
</html>
