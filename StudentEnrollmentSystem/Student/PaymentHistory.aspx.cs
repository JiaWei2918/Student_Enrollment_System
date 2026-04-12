using iTextSharp.text;
using iTextSharp.text.pdf;
using iTextSharp.text.pdf.draw;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;

namespace StudentEnrollmentSystem.Student
{
    public partial class PaymentHistory : System.Web.UI.Page
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
                LoadHistory();
            }
        }

        private void LoadHistory()
        {
            int studentID = Convert.ToInt32(Session["StudentID"]);

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetStudentPaymentHistory", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@StudentID", studentID);
                conn.Open();

                DataTable dt = new DataTable();
                dt.Load(cmd.ExecuteReader());

                if (dt.Rows.Count == 0)
                {
                    gvHistory.Visible = false;
                    pnlEmpty.Visible = true;

                    lblTotalPayments.Text = "0";
                    lblTotalPaid.Text = "0.00";
                    lblYearPayments.Text = "0";
                    return;
                }

                lblTotalPayments.Text = dt.Rows[0]["TotalPayments"].ToString();
                lblTotalPaid.Text = Convert.ToDecimal(dt.Rows[0]["TotalPaid"]).ToString("N2");
                lblYearPayments.Text = dt.Rows[0]["YearPayments"].ToString();

                gvHistory.Visible = true;
                pnlEmpty.Visible = false;
                gvHistory.DataSource = dt;
                gvHistory.DataBind();
            }
        }

        protected void gvHistory_SelectedIndexChanged(object sender, EventArgs e)
        {
            int paymentID = Convert.ToInt32(gvHistory.SelectedDataKey.Value);

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetReceiptDetails", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@PaymentID", paymentID);
                conn.Open();

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (!dr.Read()) return;

                    lblReceiptNo.Text = dr["ReceiptNumber"].ToString();
                    lblInvoice.Text = dr["InvoiceNumber"].ToString();
                    lblAmount.Text = "RM " + Convert.ToDecimal(dr["Amount"]).ToString("N2");
                    lblMethod.Text = dr["PaymentMethod"].ToString();
                    lblDate.Text = Convert.ToDateTime(dr["PaymentDate"]).ToString("dd MMM yyyy");
                    lblTransaction.Text = dr["TransactionID"].ToString();

                    hfSelectedPaymentID.Value = paymentID.ToString();

                    ScriptManager.RegisterStartupScript(
                        this, GetType(), "showReceipt",
                        $"document.getElementById('{pnlReceipt.ClientID}').style.display='block';",
                        true
                    );
                }
            }
        }

        protected void btnDownloadReceipt_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(hfSelectedPaymentID.Value, out int paymentID) || paymentID == 0)
                return;

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetReceiptDetails", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@PaymentID", paymentID);
                conn.Open();

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (!dr.Read()) return;

                    string receiptNo = dr["ReceiptNumber"].ToString();
                    string invoiceNo = dr["InvoiceNumber"].ToString();
                    decimal amount = Convert.ToDecimal(dr["Amount"]);
                    string method = dr["PaymentMethod"].ToString();
                    string date = Convert.ToDateTime(dr["PaymentDate"]).ToString("dd MMM yyyy");
                    string transID = dr["TransactionID"].ToString();
                    string studentName = Session["FullName"]?.ToString() ?? "—";
                    string studentID = Session["Username"]?.ToString() ?? "—";

                    using (var ms = new MemoryStream())
                    {
                        var doc = new Document(PageSize.A5, 40f, 40f, 40f, 40f);
                        PdfWriter.GetInstance(doc, ms);
                        doc.Open();

                        var titleFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 16);
                        var subFont = FontFactory.GetFont(FontFactory.HELVETICA, 10);
                        var boldFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 10);
                        var amtFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 20);
                        var grayFont = FontFactory.GetFont(FontFactory.HELVETICA, 9,
                            new BaseColor(148, 163, 184));

                        var title = new Paragraph("Student Enrollment System", titleFont)
                        {
                            Alignment = Element.ALIGN_CENTER,
                            SpacingAfter = 4f
                        };
                        doc.Add(title);

                        var sub = new Paragraph("Official Payment Receipt", grayFont)
                        {
                            Alignment = Element.ALIGN_CENTER,
                            SpacingAfter = 14f
                        };
                        doc.Add(sub);

                        doc.Add(new Chunk(new LineSeparator(
                            0.5f, 100f, new BaseColor(226, 232, 240),
                            Element.ALIGN_CENTER, -2)));
                        doc.Add(new Paragraph(" ") { SpacingAfter = 6f });

                        var table = new PdfPTable(2);
                        table.WidthPercentage = 100;
                        table.SetWidths(new float[] { 38f, 62f });
                        table.SpacingAfter = 14f;

                        void AddRow(string label, string value, bool mono = false)
                        {
                            var lFont = subFont;
                            var vFont = mono
                                ? FontFactory.GetFont(FontFactory.COURIER_BOLD, 9)
                                : boldFont;

                            var lCell = new PdfPCell(new Phrase(label, lFont))
                            {
                                Border = Rectangle.NO_BORDER,
                                PaddingBottom = 7f
                            };
                            var vCell = new PdfPCell(new Phrase(value, vFont))
                            {
                                Border = Rectangle.NO_BORDER,
                                PaddingBottom = 7f
                            };
                            table.AddCell(lCell);
                            table.AddCell(vCell);
                        }

                        AddRow("Receipt Number:", receiptNo);
                        AddRow("Invoice Number:", invoiceNo);
                        AddRow("Student Name:", studentName);
                        AddRow("Student ID:", studentID);
                        AddRow("Payment Method:", method);
                        AddRow("Payment Date:", date);
                        AddRow("Transaction ID:", transID, mono: true);

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
                            Padding = 14f
                        };

                        amtCell.AddElement(new Paragraph("Amount Paid", grayFont)
                        {
                            Alignment = Element.ALIGN_CENTER
                        });

                        amtCell.AddElement(new Paragraph("RM " + amount.ToString("N2"), amtFont)
                        {
                            Alignment = Element.ALIGN_CENTER
                        });

                        amtTable.AddCell(amtCell);
                        doc.Add(amtTable);

                        doc.Add(new Paragraph(
                            "This is an official receipt issued by the Student Enrollment System.\n" +
                            "Generated on " + DateTime.Now.ToString("dd MMM yyyy, h:mm tt"),
                            grayFont)
                        {
                            Alignment = Element.ALIGN_CENTER
                        });

                        doc.Close();

                        Response.ContentType = "application/pdf";
                        Response.AddHeader("content-disposition",
                            $"attachment;filename=Receipt_{receiptNo}.pdf");
                        Response.BinaryWrite(ms.ToArray());
                        Response.End();
                    }
                }
            }
        }

        protected string GetStatusBadge(string status)
        {
            switch (status)
            {
                case "Completed": return "<span class=\"badge badge-green\">Completed</span>";
                case "Pending": return "<span class=\"badge badge-amber\">Pending</span>";
                case "Failed": return "<span class=\"badge badge-red\">Failed</span>";
                default: return $"<span class=\"badge badge-gray\">{status}</span>";
            }
        }

        protected string FormatDate(object dateObj)
        {
            if (dateObj == null || dateObj == DBNull.Value) return "—";
            return Convert.ToDateTime(dateObj).ToString("dd MMM yyyy");
        }
    }
}