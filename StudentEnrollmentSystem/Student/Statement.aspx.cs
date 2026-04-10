using iTextSharp.text;
using iTextSharp.text.pdf;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;

namespace StudentEnrollmentSystem.Student
{
    public partial class Statement : System.Web.UI.Page
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
                LoadStatement();
            }
        }

        private DataTable GetStatementData()
        {
            int studentID = Convert.ToInt32(Session["StudentID"]);

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetStudentStatement", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@StudentID", studentID);

                conn.Open();

                DataTable dt = new DataTable();
                dt.Load(cmd.ExecuteReader());

                if (dt.Rows.Count > 0)
                {
                    DataRow last = dt.Rows[dt.Rows.Count - 1];

                    decimal totalDebits = Convert.ToDecimal(last["TotalDebits"]);
                    decimal totalCredits = Convert.ToDecimal(last["TotalCredits"]);
                    decimal balance = Convert.ToDecimal(last["Balance"]);

                    lblTotalDebits.Text = totalDebits.ToString("N2");
                    lblTotalCredits.Text = totalCredits.ToString("N2");

                    string closingText = "RM " + balance.ToString("N2");
                    lblClosing.Text = closingText;
                    lblClosingFooter.Text = closingText;

                    if (balance <= 0)
                    {
                        lblClosing.CssClass = "sc-green";
                        lblClosingFooter.CssClass = "closing-zero";
                    }
                    else
                    {
                        lblClosing.CssClass = "sc-amber";
                        lblClosingFooter.CssClass = "closing-positive";
                    }
                }

                return dt;
            }
        }
        private void LoadStatement()
        {
            lblStudentName.Text = Session["FullName"]?.ToString() ?? "—";
            lblStudentID.Text = Session["Username"]?.ToString() ?? "—";
            lblProgram.Text = Session["Program"]?.ToString() ?? "Computer Science";

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT TOP 1 RTRIM(SemesterName) + ' ' + RTRIM(AcademicYear) " +
                    "FROM Semester WHERE Status = 'Active'", conn))
                {
                    conn.Open();
                    object sem = cmd.ExecuteScalar();
                    lblSemester.Text = sem?.ToString() ?? "—";
                }
            }
            catch { lblSemester.Text = "—"; }

            gvStatement.DataSource = GetStatementData();
            gvStatement.DataBind();
        }

        protected void btnExportPDF_Click(object sender, EventArgs e)
        {
            DataTable dt = GetStatementData();

            using (MemoryStream ms = new MemoryStream())
            {
                Document pdfDoc = new Document(PageSize.A4, 20f, 20f, 30f, 20f);
                PdfWriter.GetInstance(pdfDoc, ms);
                pdfDoc.Open();

                var titleFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 14);
                var subFont = FontFactory.GetFont(FontFactory.HELVETICA, 10);
                var boldFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 10);

                Paragraph title = new Paragraph("Student Financial Statement", titleFont);
                title.Alignment = Element.ALIGN_CENTER;
                pdfDoc.Add(title);
                pdfDoc.Add(new Paragraph(" "));

                pdfDoc.Add(new Paragraph("Student: " + lblStudentName.Text, subFont));
                pdfDoc.Add(new Paragraph("Student ID: " + lblStudentID.Text, subFont));
                pdfDoc.Add(new Paragraph("Generated: " + DateTime.Now.ToString("dd MMM yyyy"), subFont));
                pdfDoc.Add(new Paragraph(" "));

                PdfPTable table = new PdfPTable(6);
                table.WidthPercentage = 100;
                table.SetWidths(new float[] { 15f, 25f, 20f, 13f, 13f, 14f });

                string[] headers = { "Date", "Type", "Reference", "Charge", "Payment", "Balance" };
                foreach (string h in headers)
                {
                    PdfPCell cell = new PdfPCell(new Phrase(h, boldFont));
                    cell.BackgroundColor = new BaseColor(248, 250, 252);
                    cell.Padding = 6;
                    table.AddCell(cell);
                }

                foreach (DataRow row in dt.Rows)
                {
                    string date = row["TransDate"] == DBNull.Value
                        ? ""
                        : Convert.ToDateTime(row["TransDate"]).ToString("dd MMM yyyy");

                    table.AddCell(new Phrase(date, subFont));
                    table.AddCell(new Phrase(row["TransType"].ToString(), subFont));
                    table.AddCell(new Phrase(row["Reference"].ToString(), subFont));
                    table.AddCell(new Phrase("RM " + Convert.ToDecimal(row["Debit"]).ToString("N2"), subFont));
                    table.AddCell(new Phrase("RM " + Convert.ToDecimal(row["Credit"]).ToString("N2"), subFont));
                    table.AddCell(new Phrase("RM " + Convert.ToDecimal(row["Balance"]).ToString("N2"), subFont));
                }

                pdfDoc.Add(table);
                pdfDoc.Add(new Paragraph(" "));
                pdfDoc.Add(new Paragraph("Closing Balance: " + lblClosing.Text, boldFont));

                pdfDoc.Close();

                Response.ContentType = "application/pdf";
                Response.AddHeader("content-disposition", "attachment;filename=StudentStatment.pdf");
                Response.BinaryWrite(ms.ToArray());
                Response.End();
            }
        }

        protected string FormatTransDate(object dateObj)
        {
            if (dateObj == null || dateObj == DBNull.Value) return "—";
            return Convert.ToDateTime(dateObj).ToString("dd MMM yyyy");
        }

        protected string FormatAmount(object amountObj, string type)
        {
            decimal amount = amountObj == null || amountObj == DBNull.Value
                ? 0 : Convert.ToDecimal(amountObj);

            if (amount == 0)
                return "<span class='zero-val'>—</span>";

            string css = type == "debit" ? "debit-val" : "credit-val";
            return $"<span class='{css}'>RM {amount:N2}</span>";
        }

        protected string FormatDecimal(object val)
        {
            if (val == null || val == DBNull.Value) return "0.00";
            return Convert.ToDecimal(val).ToString("N2");
        }
    }
}