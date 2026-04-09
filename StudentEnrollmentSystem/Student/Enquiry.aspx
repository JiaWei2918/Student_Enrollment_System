<%@ Page Title="Contact Us" Language="C#" MasterPageFile="~/Student.Master" AutoEventWireup="true" CodeBehind="Enquiry.aspx.cs" Inherits="StudentEnrollmentSystem.Student.Enquiry" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<style>
    .enquiry-wrap { display: flex; flex-direction: column; gap: 28px; }

    /* ── PAGE HEADER ── */
    .page-header h2 { font-size: 28px; font-weight: 700; color: #0f172a; margin: 0 0 4px; }
    .page-header p  { font-size: 14px; color: #64748b; margin: 0; }

    /* ── TWO COLUMN LAYOUT ── */
    .two-col {
        display: grid;
        grid-template-columns: 1fr 320px;
        gap: 28px;
        align-items: start;
    }

    /* ── CARD ── */
    .card {
        background: #fff; border-radius: 16px; padding: 28px;
        border: 1px solid rgba(0,0,0,0.06);
        box-shadow: 0 4px 12px rgba(0,0,0,0.04);
    }
    .card-title {
        font-size: 17px; font-weight: 700; color: #0f172a; margin: 0 0 20px;
    }

    /* ── FORM ── */
    .form-group { margin-bottom: 20px; }
    .form-label {
        display: block; font-size: 13px; font-weight: 600;
        color: #374151; margin-bottom: 6px;
    }
    .form-select, .form-textarea {
        width: 100%; padding: 11px 14px;
        border: 1px solid #e2e8f0; border-radius: 12px;
        font-size: 14px; color: #0f172a; background: #f8fafc;
        outline: none; transition: border-color 0.2s, box-shadow 0.2s;
        box-sizing: border-box; font-family: inherit;
    }
    .form-select:focus, .form-textarea:focus {
        border-color: #6366f1;
        box-shadow: 0 0 0 3px rgba(99,102,241,0.12);
        background: #fff;
    }
    .form-textarea { resize: none; line-height: 1.6; }
    .char-count {
        text-align: right; font-size: 12px; color: #94a3b8;
        margin-top: 6px;
    }
    .char-count.warn { color: #d97706; }
    .char-count.over { color: #dc2626; }

    /* ── SUBMIT BUTTON ── */
    .btn-submit {
        display: inline-flex; align-items: center; gap: 8px;
        padding: 12px 28px; width: 100%;
        background: linear-gradient(90deg,#6366f1,#9333ea);
        color: #fff; border: none; border-radius: 12px;
        font-size: 14px; font-weight: 600; cursor: pointer;
        box-shadow: 0 4px 14px rgba(99,102,241,0.3);
        justify-content: center;
        transition: opacity 0.2s, box-shadow 0.2s;
    }
    .btn-submit:hover { opacity: 0.9; box-shadow: 0 8px 22px rgba(99,102,241,0.4); }

    /* ── MESSAGE BOX ── */
    .msg-success {
        display: flex; align-items: center; gap: 10px;
        padding: 14px 18px; border-radius: 12px;
        background: #f0fdf4; border: 1px solid #bbf7d0;
        color: #15803d; font-size: 14px; font-weight: 600;
        margin-bottom: 20px;
    }
    .msg-error {
        display: flex; align-items: center; gap: 10px;
        padding: 14px 18px; border-radius: 12px;
        background: #fef2f2; border: 1px solid #fecaca;
        color: #b91c1c; font-size: 14px; font-weight: 600;
        margin-bottom: 20px;
    }

    /* ── CONTACT INFO CARD ── */
    .contact-item {
        display: flex; align-items: flex-start; gap: 14px;
        padding: 14px 0;
        border-bottom: 1px solid #f1f5f9;
    }
    .contact-item:last-child { border-bottom: none; padding-bottom: 0; }
    .contact-item:first-child { padding-top: 0; }
    .contact-icon {
        width: 40px; height: 40px; border-radius: 10px;
        background: linear-gradient(135deg,#6366f1,#9333ea);
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
        box-shadow: 0 4px 10px rgba(99,102,241,0.25);
    }
    .contact-icon i { font-size: 15px; color: #fff; }
    .contact-label { font-size: 12px; font-weight: 600; color: #0f172a; }
    .contact-value { font-size: 13px; color: #64748b; margin-top: 2px; }

    /* ── OFFICE HOURS CARD ── */
    .hours-row {
        display: flex; justify-content: space-between; align-items: center;
        padding: 8px 0; font-size: 13px;
        border-bottom: 1px solid #f8fafc;
    }
    .hours-row:last-child { border-bottom: none; }
    .hours-day  { color: #64748b; }
    .hours-time { font-weight: 600; color: #0f172a; }
    .hours-closed { color: #94a3b8; font-weight: 500; }

    /* ── QUICK RESPONSE BANNER ── */
    .quick-banner {
        background: linear-gradient(135deg,rgba(99,102,241,0.08),rgba(147,51,234,0.05));
        border: 1px solid rgba(99,102,241,0.15);
        border-radius: 12px; padding: 14px 16px;
        font-size: 13px; color: #4338ca; line-height: 1.5;
    }
    .quick-banner strong { font-weight: 700; }

    /* ── MY ENQUIRIES TABLE ── */
    .section-title {
        font-size: 22px; font-weight: 700; color: #0f172a; margin: 0 0 20px;
    }
    .gv-enquiry { width: 100%; border-collapse: collapse; }
    .gv-enquiry thead tr {
        background: #f8fafc; border-bottom: 1px solid #e2e8f0;
    }
    .gv-enquiry th {
        padding: 11px 14px; text-align: left;
        font-size: 11px; font-weight: 700; color: #64748b;
        text-transform: uppercase; letter-spacing: 0.06em; white-space: nowrap;
    }
    .gv-enquiry td {
        padding: 16px 14px; font-size: 14px; color: #334155;
        border-bottom: 1px solid #f1f5f9; vertical-align: top;
    }
    .gv-enquiry tr:hover td { background: #fafbff; }
    .gv-enquiry .empty-row td {
        text-align: center; padding: 48px 14px;
        color: #94a3b8; font-size: 14px;
    }

    /* Message cell — truncate long text */
    .msg-cell {
        max-width: 260px;
        overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
    }
    /* Reply cell */
    .reply-cell { color: #64748b; font-style: italic; }

    /* ── STATUS BADGES ── */
    .badge {
        display: inline-block; padding: 3px 10px;
        border-radius: 99px; font-size: 11px; font-weight: 600; white-space: nowrap;
    }
    .badge-pending     { background: #fef3c7; color: #b45309; }
    .badge-inprogress  { background: #dbeafe; color: #1d4ed8; }
    .badge-resolved    { background: #dcfce7; color: #15803d; }
    .badge-closed      { background: #f1f5f9; color: #475569; }
    .badge-default     { background: #f1f5f9; color: #334155; }

    /* ── EMPTY STATE ── */
    .empty-state {
        text-align: center; padding: 48px 24px;
    }
    .empty-icon {
        width: 56px; height: 56px; border-radius: 50%;
        background: #f1f5f9;
        display: flex; align-items: center; justify-content: center;
        margin: 0 auto 14px;
    }
    .empty-icon i { font-size: 24px; color: #94a3b8; }
    .empty-title { font-size: 15px; font-weight: 600; color: #475569; margin-bottom: 4px; }
    .empty-sub   { font-size: 13px; color: #94a3b8; }

    /* ── RESPONSIVE ── */
    @media (max-width: 900px) {
        .two-col { grid-template-columns: 1fr; }
    }
</style>

<div class="enquiry-wrap">

    <!-- PAGE HEADER -->
    <div class="page-header">
        <h2>Contact Us</h2>
        <p>Get in touch with our support team</p>
    </div>

    <!-- TWO COLUMN: FORM + CONTACT INFO -->
    <div class="two-col">

        <!-- LEFT: Message Form -->
        <div class="card">
            <div class="card-title">Send us a message</div>

            <!-- Message label (success / error) -->
            <asp:Label ID="lblMsg" runat="server" />

            <!-- Category -->
            <div class="form-group">
                <label class="form-label" for="<%= ddlSubject.ClientID %>">Category</label>
                <asp:DropDownList ID="ddlSubject" runat="server" CssClass="form-select">
                    <asp:ListItem Value="">-- Select a category --</asp:ListItem>
                    <asp:ListItem Value="Registration">General Inquiry</asp:ListItem>
                    <asp:ListItem Value="Registration">Enrollment Question</asp:ListItem>
                    <asp:ListItem Value="Payment">Payment Issue</asp:ListItem>
                    <asp:ListItem Value="Technical">Technical Support</asp:ListItem>
                    <asp:ListItem Value="Timetable">Academic Advising</asp:ListItem>
                </asp:DropDownList>
            </div>

            <!-- Message -->
            <div class="form-group">
                <label class="form-label" for="<%= txtMessage.ClientID %>">Message</label>
                <asp:TextBox ID="txtMessage" runat="server"
                    TextMode="MultiLine" Rows="6"
                    CssClass="form-textarea"
                    placeholder="Please provide details about your inquiry..." />
                <div class="char-count" id="charCount">0 / 500</div>
            </div>

            <!-- Submit -->
            <asp:Button ID="btnSubmit" runat="server"
                Text="Send Message"
                CssClass="btn-submit"
                OnClick="btnSubmit_Click"
                OnClientClick="return confirmSubmit();" />
        </div>

        <!-- RIGHT: Contact Info + Hours -->
        <div style="display:flex;flex-direction:column;gap:20px;">

            <!-- Contact Information -->
            <div class="card">
                <div class="card-title">Contact Information</div>

                <div class="contact-item">
                    <div class="contact-icon"><i class="fa fa-envelope"></i></div>
                    <div>
                        <div class="contact-label">Email</div>
                        <div class="contact-value">support@university.edu</div>
                    </div>
                </div>

                <div class="contact-item">
                    <div class="contact-icon"><i class="fa fa-phone"></i></div>
                    <div>
                        <div class="contact-label">Phone</div>
                        <div class="contact-value">067982000</div>
                    </div>
                </div>

                <div class="contact-item">
                    <div class="contact-icon"><i class="fa fa-map-marker"></i></div>
                    <div>
                        <div class="contact-label">Office</div>
                        <div class="contact-value">
                            Student Services Building<br />
                            D2, Main Campus
                        </div>
                    </div>
                </div>
            </div>

            <!-- Office Hours -->
            <div class="card">
                <div class="card-title">
                    <i class="fa fa-clock-o" style="color:#6366f1;margin-right:8px;"></i>
                    Office Hours
                </div>

                <div class="hours-row">
                    <span class="hours-day">Monday – Friday</span>
                    <span class="hours-time">8:00 AM – 6:00 PM</span>
                </div>
                <div class="hours-row">
                    <span class="hours-day">Saturday</span>
                    <span class="hours-closed">Closed</span>
                </div>
                <div class="hours-row">
                    <span class="hours-day">Sunday</span>
                    <span class="hours-closed">Closed</span>
                </div>
            </div>

            <!-- Quick Response Banner -->
            <div class="quick-banner">
                <strong>Quick Response:</strong> For urgent matters, please call us directly during office hours.
            </div>

        </div>
    </div>

    <!-- MY ENQUIRIES -->
    <div class="card">
        <div class="card-title">My Enquiries</div>

        <div style="overflow-x:auto;">
            <asp:GridView ID="gvEnquiry" runat="server"
                AutoGenerateColumns="false"
                CssClass="gv-enquiry"
                GridLines="None"
                EmptyDataText="">
                <EmptyDataRowStyle CssClass="empty-row" />
                <Columns>

                    <asp:TemplateField HeaderText="#">
                        <ItemTemplate>
                            <%# Container.DataItemIndex + 1 %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="Subject" HeaderText="Subject" />

                    <asp:TemplateField HeaderText="Message">
                        <ItemTemplate>
                            <div class="msg-cell" title="<%# Eval("Message") %>">
                                <%# Eval("Message") %>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate>
                            <%# GetStatusBadge(Eval("Status").ToString()) %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Admin Reply">
                        <ItemTemplate>
                            <span class="reply-cell"><%# Eval("Response") %></span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="CreatedAt" HeaderText="Date Submitted" />

                </Columns>
            </asp:GridView>
        </div>

        <!-- Empty state (shown when no data) -->
        <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
            <div class="empty-state">
                <div class="empty-icon"><i class="fa fa-envelope-o"></i></div>
                <div class="empty-title">No enquiries yet</div>
                <div class="empty-sub">Your submitted enquiries will appear here.</div>
            </div>
        </asp:Panel>
    </div>

</div>

<script>
    // Character counter
    document.addEventListener("DOMContentLoaded", function () {
        var txt     = document.getElementById('<%= txtMessage.ClientID %>');
        var counter = document.getElementById('charCount');
        if (!txt) return;

        txt.addEventListener('input', function () {
            var len = txt.value.length;
            counter.innerText = len + ' / 500';
            counter.className = 'char-count' +
                (len > 500 ? ' over' : len > 400 ? ' warn' : '');
        });
    });

    // Confirm before submit
    function confirmSubmit() {
        var ddl = document.getElementById('<%= ddlSubject.ClientID %>');
        var txt = document.getElementById('<%= txtMessage.ClientID %>');
        if (!ddl.value || !txt.value.trim()) return true; // let server-side validate
        return confirm('Submit this enquiry?');
    }

    // Style the message label after postback
    window.onload = function () {
        var lbl = document.getElementById('<%= lblMsg.ClientID %>');
        if (!lbl || !lbl.innerText.trim()) return;
        var isError = lbl.style.color === 'red' ||
            lbl.style.color === 'rgb(255, 0, 0)' ||
            lbl.innerText.indexOf('successfully') === -1;
        lbl.className = isError ? 'msg-error' : 'msg-success';
        lbl.innerHTML = '<i class="fa ' + (isError ? 'fa-exclamation-circle' : 'fa-check-circle') + '"></i> ' + lbl.innerText;
    };
</script>

</asp:Content>