<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="InvoiceHistory.aspx.cs" Inherits="StudentEnrollmentSystem.Student.InvoiceHistory" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Invoice & Adjustment</title>

    <style>
        body {font-family: Arial; margin: 30px;}
        .section {margin-bottom: 40px;}
        .refund {color:red; font-weight:bold;}
        .charge {color:green; font-weight:bold;}
    </style>
</head>
<body>
    <form runat="server">
        <h2>📄 Invoice & Adjustment History</h2>

        <div class="section">
            <h3>Invoice History</h3>
            <asp:GridView ID="gvInvoice" runat="server" AutoGenerateColumns="False">
                <Columns>
                    <asp:BoundField DataField="InvoiceNumber" HeaderText="Invoice No" />
                    <asp:BoundField DataField="IssueDate" HeaderText="Issue Date" DataFormatString="{0:dd MMM yyyy}" />
                    <asp:BoundField DataField="DueDate" HeaderText="Due Date" DataFormatString="{0:dd MMM yyyy}" />
                    <asp:BoundField DataField="TotalAmount" HeaderText="Total" DataFormatString="RM {0:N2}" />
                    <asp:BoundField DataField="PaidAmount" HeaderText="Paid" DataFormatString="RM {0:N2}" />
                    <asp:BoundField DataField="Balance" HeaderText="Balance" DataFormatString="RM {0:N2}" />
                    <asp:BoundField DataField="Status" HeaderText="Status" />
                </Columns>
            </asp:GridView>
        </div>

        <div class="section">
            <h3>Adjustment Notes</h3>

            <asp:GridView ID="gvAdjustment" runat="server" AutoGenerateColumns="False">
                <Columns>
                    <asp:BoundField DataField="ReceiptNumber" HeaderText="Receipt" />
                    <asp:BoundField DataField="AdjustmentType" HeaderText="Type" />
                    <asp:BoundField DataField="Amount" HeaderText="Amount" DataFormatString="RM {0:N2}" />
                    <asp:BoundField DataField="Reason" HeaderText="Reason" />
                    <asp:BoundField DataField="AdjustmentDate" HeaderText="Date" DataFormatString="{0:dd MMM yyyy}" />
                    <asp:BoundField DataField="ApprovedByName" HeaderText="Approved By" />
                </Columns>
            </asp:GridView>
        </div>
    </form>
</body>
</html>
