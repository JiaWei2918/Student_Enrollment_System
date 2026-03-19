<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Enquiry.aspx.cs" Inherits="StudentEnrollmentSystem.Student.Enquiry" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Contact Us</title>

    <style>
        body { font-family: Arial; }
        .badge {
            padding: 5px 10px;
            color: white;
            border-radius: 5px;
        }
    </style>

    <script>
        document.addEventListener("DOMContentLoaded", function () {
            var txt = document.getElementById('<%= txtMessage.ClientID %>');
            var counter = document.getElementById('charCount');

            if (txt) {
                txt.addEventListener('input', function () {
                    counter.innerText = txt.value.length + " / 500";
                });
            }
        });
    </script>
</head>
<body>
    <form runat="server">
        <h2>📩 Contact Us</h2>

        <asp:Label ID="lblMsg" runat="server"></asp:Label>

        <br /><br />

        <b>Subject:</b><br />
        <asp:DropDownList ID="ddlSubject" runat="server" Width="300">
            <asp:ListItem Value="">-- Select Subject --</asp:ListItem>
            <asp:ListItem>Registration</asp:ListItem>
            <asp:ListItem>Payment</asp:ListItem>
            <asp:ListItem>Timetable</asp:ListItem>
            <asp:ListItem>Technical</asp:ListItem>
        </asp:DropDownList>

        <br /><br />

        <b>Message:</b><br />
        <asp:TextBox ID="txtMessage" runat="server"
            TextMode="MultiLine" Rows="5" Width="400"></asp:TextBox>

        <br />
        <span id="charCount">0 / 500</span>

        <br /><br />

        <asp:Button ID="btnSubmit" runat="server" Text="Submit Enquiry"
            OnClick="btnSubmit_Click" 
            OnClientClick="return confirm('Submit this enquiry?');" />

        <hr />

        <h3>📋 My Enquiries</h3>

        <asp:GridView ID="gvEnquiry" runat="server" AutoGenerateColumns="false" BorderWidth="1">
            <Columns>
                <asp:TemplateField HeaderText="#">
                    <ItemTemplate>
                        <%# Container.DataItemIndex + 1 %>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:BoundField DataField="Subject" HeaderText="Subject" />
                <asp:BoundField DataField="Message" HeaderText="Message" />

                <asp:TemplateField HeaderText="Status">
                    <ItemTemplate>
                        <span class="badge" 
                            style='background-color:<%# GetStatusColor(Eval("Status").ToString()) %>'>
                            <%# Eval("Status") %>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:BoundField DataField="Response" HeaderText="Admin Reply" />
                <asp:BoundField DataField="CreatedAt" HeaderText="Date" />
            </Columns>
        </asp:GridView>
    </form>
</body>
</html>
