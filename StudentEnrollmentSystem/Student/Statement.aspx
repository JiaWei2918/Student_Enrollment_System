<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Statement.aspx.cs" Inherits="StudentEnrollmentSystem.Student.Statement" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Student Statement</title>

    <style>
      body { font-family: Arial; margin: 30px;}
      .balance { font-weight: bold; color:blue;}
      .header { font-size: 18px; font-weight:bold; margin-bottom:10px;}
    </style>
</head>
<body>
    <form runat="server">
        <div class="header">📊 Student Financial Statement</div>

        <asp:Button ID="btnPrint" runat="server" Text="Print" OnClientClick="window.print(); return false;" />

        <asp:Button ID="btnExportPDF" runat="server" Text="Export PDF" OnClick="btnExportPDF_Click" />

        <br /><br />

        <asp:GridView ID="gvStatement" runat="server" AutoGenerateColumns="False" GridLines="Horizontal">
            <Columns>
                <asp:BoundField DataField="TransDate" HeaderText="Date" DataFormatString="{0:dd MMM yyyy}" HtmlEncode="false" />
                <asp:BoundField DataField="TransType" HeaderText="Type" />
                <asp:BoundField DataField="Reference" HeaderText="Reference" />
                <asp:BoundField DataField="Debit" HeaderText="Charge" DataFormatString="RM {0:N2}" />
                <asp:BoundField DataField="Credit" HeaderText="Payment" DataFormatString="RM {0:N2}" />
                <asp:BoundField DataField="Balance" HeaderText="Balance" DataFormatString="RM {0:N2}" />
            </Columns>
        </asp:GridView>

        <br />

        <b>Closing Balance:</b>
        <asp:Label ID="lblClosing" runat="server" CssClass="balance"></asp:Label>
    </form>
</body>
</html>
