using iTextSharp.text;
using iTextSharp.text.pdf;
using iTextSharp.text.pdf.draw;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentEnrollmentSystem.Student
{
    public partial class InvoiceHistory : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["DBConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StudentID"] == null)
            {
                Response.Redirect("~/Account/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadInvoices();
                LoadAdjustment();
            }
        }

        private void LoadInvoices()
        {
            int studentID = Convert.ToInt32(Session["StudentID"]);

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetStudentInvoices", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@StudentID", studentID);
                conn.Open();

                DataTable dt = new DataTable();
                dt.Load(cmd.ExecuteReader());

                if (dt.Rows.Count == 0)
                {
                    gvInvoice.Visible = false;
                    pnlInvoiceEmpty.Visible = true;
                    lblTotalInvoices.Text = "0.00";
                }
                else
                {
                    lblTotalInvoices.Text = Convert.ToDecimal(dt.Rows[0]["TotalInvoices"]).ToString("N2");
                    gvInvoice.Visible = true;
                    pnlInvoiceEmpty.Visible = false;
                    gvInvoice.DataSource = dt;
                    gvInvoice.DataBind();
                }

                UpdateNetAmount();
            }
        }

        private void LoadAdjustment()
        {
            int studentID = Convert.ToInt32(Session["StudentID"]);

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetStudentAdjustmentHistory", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@StudentID", studentID);
                conn.Open();

                DataTable dt = new DataTable();
                dt.Load(cmd.ExecuteReader());

                if (dt.Rows.Count == 0)
                {
                    gvAdjustment.Visible = false;
                    pnlAdjEmpty.Visible = true;
                    lblTotalAdjustments.Text = "0.00";
                }
                else
                {
                    lblTotalAdjustments.Text = Convert.ToDecimal(dt.Rows[0]["TotalAdjustments"]).ToString("N2");
                    gvAdjustment.Visible = true;
                    pnlAdjEmpty.Visible = false;
                    gvAdjustment.DataSource = dt;
                    gvAdjustment.DataBind();
                }

                UpdateNetAmount();
            }
        }

        private void UpdateNetAmount()
        {
            decimal invoices, adjustments;

            decimal.TryParse(lblTotalInvoices.Text.Replace(",", ""), out invoices);
            decimal.TryParse(lblTotalAdjustments.Text.Replace(",", ""), out adjustments);
            lblNetAmount.Text = (invoices - adjustments).ToString("N2");
        }

        protected void gvInvoice_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument.ToString(), out int invoiceID)) return;

            if (e.CommandName == "ViewInvoice")
                ShowInvoiceDetail(invoiceID);
            else if (e.CommandName == "DownloadInvoice")
                DownloadInvoicePdf(invoiceID);
        }

        protected void gvAdjustment_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string receiptNo = e.CommandArgument.ToString();

            if (e.CommandName == "ViewAdj")
                ShowAdjDetail(receiptNo);
            else if (e.CommandName == "DownloadAdj")
                DownloadAdjPdf(receiptNo);
        }

        private void ShowInvoiceDetail(int invoiceID)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT * FROM Invoice WHERE InvoiceID = @ID", conn))
            {
                cmd.Parameters.AddWithValue("@ID", invoiceID);
                conn.Open();

                DataTable dt = new DataTable();
                dt.Load(cmd.ExecuteReader());
                if (dt.Rows.Count == 0) return;

                DataRow r = dt.Rows[0];
                decimal total = Convert.ToDecimal(r["TotalAmount"]);
                string status = r["Status"].ToString();

                decimal paid = GetPaidAmount(invoiceID, conn);
                decimal balance = total - paid;

                lblDetailTitle.Text = "Invoice Details";
                hfInvoiceID.Value = invoiceID.ToString();
                hfModalType.Value = "invoice";

                var sb = new StringBuilder();
                sb.Append(DetailRow("Invoice Number", r["InvoiceNumber"].ToString()));
                sb.Append(DetailRow("Issue Date", FormatDate(r["IssueDate"])));
                sb.Append(DetailRow("Due Date", FormatDate(r["DueDate"])));
                sb.Append(DetailRow("Status", GetInvoiceStatusBadge(status)));

                sb.Append("<div class='modal-amount-box'>");
                sb.Append("<span class='modal-amount-label'>Total Amount</span>");
                sb.AppendFormat("<span class='modal-amount-val'>RM {0}</span>",
                    total.ToString("N2"));
                sb.Append("</div>");

                sb.Append(DetailRow("Amount Paid",
                    $"<span style='color:#15803d;font-weight:700;'>RM {paid:N2}</span>"));
                sb.Append(DetailRow("Balance",
                    balance <= 0
                        ? $"<span style='color:#15803d;font-weight:700;'>RM {balance:N2}</span>"
                        : $"<span style='color:#d97706;font-weight:700;'>RM {balance:N2}</span>"));

                phDetailContent.Controls.Add(new LiteralControl(sb.ToString()));
                ShowModal();
            }
        }

        private decimal GetPaidAmount(int invoiceID, SqlConnection conn)
        {
            using (SqlCommand cmd = new SqlCommand(
                "SELECT ISNULL(SUM(Amount),0) FROM Payment " +
                "WHERE InvoiceID = @ID AND Status = 'Completed'", conn))
            {
                cmd.Parameters.AddWithValue("@ID", invoiceID);
                object result = cmd.ExecuteScalar();
                return result == null || result == DBNull.Value ? 0 : Convert.ToDecimal(result);
            }
        }

        private void ShowAdjDetail(string receiptNo)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT a.AdjustmentType, a.Amount, a.Reason, a.AdjustmentDate, " +
                "       r.ReceiptNumber, ad.FullName AS ApprovedByName " +
                "FROM AdjustmentNote a " +
                "JOIN Payment p       ON a.PaymentID  = p.PaymentID " +
                "JOIN Receipt r       ON p.PaymentID  = r.PaymentID " +
                "JOIN Administrator ad ON a.ApprovedBy = ad.AdminID " +
                "WHERE r.ReceiptNumber = @ReceiptNo", conn))
            {
                cmd.Parameters.AddWithValue("@ReceiptNo", receiptNo);
                conn.Open();

                DataTable dt = new DataTable();
                dt.Load(cmd.ExecuteReader());
                if (dt.Rows.Count == 0) return;

                DataRow r = dt.Rows[0];
                decimal amount = Convert.ToDecimal(r["Amount"]);
                string type = r["AdjustmentType"].ToString();

                lblDetailTitle.Text = "Adjustment Note Details";
                hfReceiptNo.Value = receiptNo;
                hfModalType.Value = "adjustment";

                var sb = new StringBuilder();
                sb.Append(DetailRow("Receipt Number", r["ReceiptNumber"].ToString()));
                sb.Append(DetailRow("Adjustment Type", GetAdjTypeBadge(type)));
                sb.Append(DetailRow("Reason", r["Reason"].ToString()));
                sb.Append(DetailRow("Date", FormatDate(r["AdjustmentDate"])));
                sb.Append(DetailRow("Approved By", r["ApprovedByName"].ToString()));

                sb.Append("<div class='modal-amount-box'>");
                sb.Append("<span class='modal-amount-label'>Adjustment Amount</span>");
                sb.AppendFormat("<span class='modal-amount-val {0}'>RM {1}</span>",
                    amount < 0 ? "amount-credit" : "amount-debit",
                    Math.Abs(amount).ToString("N2"));
                sb.Append("</div>");

                phDetailContent.Controls.Add(new LiteralControl(sb.ToString()));
                ShowModal();
            }
        }

        private void ShowModal()
        {
            ScriptManager.RegisterStartupScript(
                this, GetType(), "showModal",
                $"document.getElementById('{pnlDetail.ClientID}').style.display='block';",
                true);
        }

        protected void btnModalDownload_Click(object sender, EventArgs e)
        {
            if (hfModalType.Value == "invoice" &&
                int.TryParse(hfInvoiceID.Value, out int invoiceID) && invoiceID > 0)
                DownloadInvoicePdf(invoiceID);
            else if (hfModalType.Value == "adjustment" &&
                     !string.IsNullOrEmpty(hfReceiptNo.Value))
                DownloadAdjPdf(hfReceiptNo.Value);
        }

        private void DownloadInvoicePdf(int invoiceID)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                DataTable dt = new DataTable();
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT i.*, s.SemesterName, s.AcademicYear " +
                    "FROM Invoice i " +
                    "LEFT JOIN Semester s ON i.SemesterID = s.SemesterID " +
                    "WHERE i.InvoiceID = @ID", conn))
                {
                    cmd.Parameters.AddWithValue("@ID", invoiceID);
                    dt.Load(cmd.ExecuteReader());
                }
                if (dt.Rows.Count == 0) return;

                DataRow r = dt.Rows[0];
                decimal total = Convert.ToDecimal(r["TotalAmount"]);
                decimal paid = GetPaidAmount(invoiceID, conn);
                decimal balance = total - paid;
                string invNo = r["InvoiceNumber"].ToString();
                string status = r["Status"].ToString();
                string semName = r["SemesterName"] == DBNull.Value ? "—"
                    : r["SemesterName"].ToString() + " " + r["AcademicYear"].ToString();

                using (var ms = new MemoryStream())
                {
                    var doc = new Document(PageSize.A5, 40f, 40f, 40f, 40f);
                    PdfWriter.GetInstance(doc, ms);
                    doc.Open();

                    var titleFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 15);
                    var subFont = FontFactory.GetFont(FontFactory.HELVETICA, 10);
                    var boldFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 10);
                    var amtFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 20);
                    var grayFont = FontFactory.GetFont(FontFactory.HELVETICA, 9,
                        new BaseColor(148, 163, 184));

                    doc.Add(new Paragraph("Student Enrollment System", titleFont)
                    { Alignment = Element.ALIGN_CENTER, SpacingAfter = 4f });
                    doc.Add(new Paragraph("Official Invoice", grayFont)
                    { Alignment = Element.ALIGN_CENTER, SpacingAfter = 14f });
                    doc.Add(new Chunk(new LineSeparator(0.5f, 100f,
                        new BaseColor(226, 232, 240), Element.ALIGN_CENTER, -2)));
                    doc.Add(new Paragraph(" ") { SpacingAfter = 6f });

                    var table = new PdfPTable(2);
                    table.WidthPercentage = 100;
                    table.SetWidths(new float[] { 40f, 60f });
                    table.SpacingAfter = 14f;

                    void AddRow(string label, string value)
                    {
                        var lc = new PdfPCell(new Phrase(label, subFont))
                        { Border = Rectangle.NO_BORDER, PaddingBottom = 7f };
                        var vc = new PdfPCell(new Phrase(value, boldFont))
                        { Border = Rectangle.NO_BORDER, PaddingBottom = 7f };
                        table.AddCell(lc);
                        table.AddCell(vc);
                    }

                    AddRow("Invoice Number:", invNo);
                    AddRow("Student Name:", Session["FullName"]?.ToString() ?? "—");
                    AddRow("Student ID:", Session["Username"]?.ToString() ?? "—");
                    AddRow("Semester:", semName);
                    AddRow("Issue Date:", FormatDate(r["IssueDate"]));
                    AddRow("Due Date:", FormatDate(r["DueDate"]));
                    AddRow("Status:", status);
                    doc.Add(table);

                    var amtTable = new PdfPTable(1);
                    amtTable.WidthPercentage = 100;
                    amtTable.SpacingAfter = 10f;
                    var amtCell = new PdfPCell
                    {
                        BackgroundColor = new BaseColor(248, 250, 252),
                        Border = Rectangle.BOX,
                        BorderColor = new BaseColor(226, 232, 240),
                        BorderWidth = 0.5f,
                        Padding = 12f
                    };
                    amtCell.AddElement(new Paragraph("Total Amount", grayFont)
                    { Alignment = Element.ALIGN_CENTER });
                    amtCell.AddElement(new Paragraph("RM " + total.ToString("N2"), amtFont)
                    { Alignment = Element.ALIGN_CENTER });
                    amtTable.AddCell(amtCell);
                    doc.Add(amtTable);

                    var summTable = new PdfPTable(2);
                    summTable.WidthPercentage = 100;
                    summTable.SetWidths(new float[] { 50f, 50f });
                    summTable.SpacingAfter = 14f;

                    void AddSumm(string label, string value)
                    {
                        var lc = new PdfPCell(new Phrase(label, subFont))
                        { Border = Rectangle.NO_BORDER, PaddingTop = 4f };
                        var vc = new PdfPCell(new Phrase(value, boldFont))
                        {
                            Border = Rectangle.NO_BORDER,
                            PaddingTop = 4f,
                            HorizontalAlignment = Element.ALIGN_RIGHT
                        };
                        summTable.AddCell(lc);
                        summTable.AddCell(vc);
                    }
                    AddSumm("Amount Paid:", "RM " + paid.ToString("N2"));
                    AddSumm("Remaining Balance:", "RM " + balance.ToString("N2"));
                    doc.Add(summTable);

                    doc.Add(new Paragraph(
                        "Generated on " + DateTime.Now.ToString("dd MMM yyyy, h:mm tt"),
                        grayFont)
                    { Alignment = Element.ALIGN_CENTER });

                    doc.Close();
                    Response.ContentType = "application/pdf";
                    Response.AddHeader("content-disposition",
                        $"attachment;filename=Invoice_{invNo}.pdf");
                    Response.BinaryWrite(ms.ToArray());
                    Response.End();
                }
            }
        }

        private void DownloadAdjPdf(string receiptNo)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT a.AdjustmentType, a.Amount, a.Reason, a.AdjustmentDate, " +
                "       r.ReceiptNumber, ad.FullName AS ApprovedByName, " +
                "       a.ApprovedDate " +
                "FROM AdjustmentNote a " +
                "JOIN Payment p        ON a.PaymentID  = p.PaymentID " +
                "JOIN Receipt r        ON p.PaymentID  = r.PaymentID " +
                "JOIN Administrator ad ON a.ApprovedBy = ad.AdminID " +
                "WHERE r.ReceiptNumber = @ReceiptNo", conn))
            {
                cmd.Parameters.AddWithValue("@ReceiptNo", receiptNo);
                conn.Open();

                DataTable dt = new DataTable();
                dt.Load(cmd.ExecuteReader());
                if (dt.Rows.Count == 0) return;

                DataRow r = dt.Rows[0];
                decimal amount = Convert.ToDecimal(r["Amount"]);
                string type = r["AdjustmentType"].ToString();

                using (var ms = new MemoryStream())
                {
                    var doc = new Document(PageSize.A5, 40f, 40f, 40f, 40f);
                    PdfWriter.GetInstance(doc, ms);
                    doc.Open();

                    var titleFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 15);
                    var subFont = FontFactory.GetFont(FontFactory.HELVETICA, 10);
                    var boldFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 10);
                    var amtFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 20);
                    var grayFont = FontFactory.GetFont(FontFactory.HELVETICA, 9,
                        new BaseColor(148, 163, 184));

                    doc.Add(new Paragraph("Student Enrollment System", titleFont)
                    { Alignment = Element.ALIGN_CENTER, SpacingAfter = 4f });
                    doc.Add(new Paragraph("Adjustment Note", grayFont)
                    { Alignment = Element.ALIGN_CENTER, SpacingAfter = 14f });
                    doc.Add(new Chunk(new LineSeparator(0.5f, 100f,
                        new BaseColor(226, 232, 240), Element.ALIGN_CENTER, -2)));
                    doc.Add(new Paragraph(" ") { SpacingAfter = 6f });

                    var table = new PdfPTable(2);
                    table.WidthPercentage = 100;
                    table.SetWidths(new float[] { 42f, 58f });
                    table.SpacingAfter = 14f;

                    void AddRow(string label, string value)
                    {
                        var lc = new PdfPCell(new Phrase(label, subFont))
                        { Border = Rectangle.NO_BORDER, PaddingBottom = 7f };
                        var vc = new PdfPCell(new Phrase(value, boldFont))
                        { Border = Rectangle.NO_BORDER, PaddingBottom = 7f };
                        table.AddCell(lc);
                        table.AddCell(vc);
                    }

                    AddRow("Receipt Number:", receiptNo);
                    AddRow("Student Name:", Session["FullName"]?.ToString() ?? "—");
                    AddRow("Student ID:", Session["Username"]?.ToString() ?? "—");
                    AddRow("Adjustment Type:", type);
                    AddRow("Reason:", r["Reason"].ToString());
                    AddRow("Adjustment Date:", FormatDate(r["AdjustmentDate"]));
                    AddRow("Approved By:", r["ApprovedByName"].ToString());
                    if (r["ApprovedDate"] != DBNull.Value)
                        AddRow("Approved Date:", FormatDate(r["ApprovedDate"]));
                    doc.Add(table);

                    var amtTable = new PdfPTable(1);
                    amtTable.WidthPercentage = 100;
                    amtTable.SpacingAfter = 14f;
                    var amtCell = new PdfPCell
                    {
                        BackgroundColor = new BaseColor(248, 250, 252),
                        Border = Rectangle.BOX,
                        BorderColor = new BaseColor(226, 232, 240),
                        BorderWidth = 0.5f,
                        Padding = 12f
                    };
                    amtCell.AddElement(new Paragraph("Adjustment Amount", grayFont)
                    { Alignment = Element.ALIGN_CENTER });
                    amtCell.AddElement(new Paragraph(
                        (amount < 0 ? "- " : "") + "RM " + Math.Abs(amount).ToString("N2"),
                        amtFont)
                    { Alignment = Element.ALIGN_CENTER });
                    amtTable.AddCell(amtCell);
                    doc.Add(amtTable);

                    doc.Add(new Paragraph(
                        "Generated on " + DateTime.Now.ToString("dd MMM yyyy, h:mm tt"),
                        grayFont)
                    { Alignment = Element.ALIGN_CENTER });

                    doc.Close();
                    Response.ContentType = "application/pdf";
                    Response.AddHeader("content-disposition",
                        $"attachment;filename=Adjustment_{receiptNo}.pdf");
                    Response.BinaryWrite(ms.ToArray());
                    Response.End();
                }
            }
        }

        private string DetailRow(string label, string value)
        {
            return $"<div class='detail-row'>" +
                   $"<span class='detail-label'>{label}</span>" +
                   $"<span class='detail-value'>{value}</span>" +
                   $"</div>";
        }

        protected string GetInvoiceStatusBadge(string status)
        {
            switch (status)
            {
                case "Paid": return "<span class=\"badge badge-green\">Paid</span>";
                case "Issued": return "<span class=\"badge badge-amber\">Issued</span>";
                case "Partial": return "<span class=\"badge badge-blue\">Partial</span>";
                case "Overdue": return "<span class=\"badge badge-red\">Overdue</span>";
                default: return $"<span class=\"badge badge-gray\">{status}</span>";
            }
        }

        protected string GetAdjTypeBadge(string type)
        {
            switch (type)
            {
                case "Refund": return "<span class=\"badge badge-green\">Refund</span>";
                case "Additional Charge": return "<span class=\"badge badge-red\">Additional Charge</span>";
                case "Correction": return "<span class=\"badge badge-blue\">Correction</span>";
                default: return $"<span class=\"badge badge-gray\">{type}</span>";
            }
        }

        protected string GetAdjIconClass(string type)
        {
            if (type == "Additional Charge") return "doc-icon doc-icon-charge";
            return "doc-icon doc-icon-adj";
        }

        protected string GetAdjIconFA(string type)
        {
            switch (type)
            {
                case "Refund": return "fa fa-minus-circle";
                case "Additional Charge": return "fa fa-plus-circle";
                case "Correction": return "fa fa-pencil";
                default: return "fa fa-file-text-o";
            }
        }

        protected string GetBalanceDisplay(object balanceObj, string status)
        {
            decimal balance = balanceObj == null || balanceObj == DBNull.Value
                ? 0 : Convert.ToDecimal(balanceObj);

            if (status == "Paid" || balance <= 0)
                return $"<span class='amount-credit'>RM {balance:N2}</span>";

            return $"<span class='amount-amber'>RM {balance:N2}</span>";
        }

        protected string GetAdjAmountDisplay(object amountObj, string type)
        {
            decimal amount = amountObj == null || amountObj == DBNull.Value
                ? 0 : Convert.ToDecimal(amountObj);

            if (amount < 0)
                return $"<span class='amount-credit'>- RM {Math.Abs(amount):N2}</span>";

            return $"<span class='amount-debit'>RM {amount:N2}</span>";
        }

        protected string FormatDate(object dateObj)
        {
            if (dateObj == null || dateObj == DBNull.Value) return "—";
            return Convert.ToDateTime(dateObj).ToString("dd MMM yyyy");
        }
    }
}