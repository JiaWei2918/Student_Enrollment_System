using iTextSharp.text;
using iTextSharp.text.pdf;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;

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

                decimal balance = 0;

                dt.Columns.Add("Balance", typeof(decimal));

                DataRow opening = dt.NewRow();
                opening["TransDate"] = DBNull.Value;
                opening["TransType"] = "Opening Balance";
                opening["Reference"] = "";
                opening["Debit"] = 0;
                opening["Credit"] = 0;
                dt.Rows.InsertAt(opening, 0);

                foreach (DataRow row in dt.Rows)
                {
                    decimal debit = row["Debit"] == DBNull.Value ? 0 : Convert.ToDecimal(row["Debit"]);
                    decimal credit = row["Credit"] == DBNull.Value ? 0 : Convert.ToDecimal(row["Credit"]);

                    balance += debit;
                    balance -= credit;

                    row["Balance"] = balance;
                }

                lblClosing.Text = "RM " + balance.ToString("N2");
                return dt;
            }
        }
        private void LoadStatement()
        {
            gvStatement.DataSource = GetStatementData();
            gvStatement.DataBind();
        }

        protected void btnExportPDF_Click(object sender, EventArgs e)
        {
            DataTable dt = GetStatementData();

            using (MemoryStream ms = new MemoryStream())
            {
                Document pdfDoc = new Document(PageSize.A4, 20f, 20f, 20f, 20f);
                PdfWriter.GetInstance(pdfDoc, ms);
                pdfDoc.Open();

                Paragraph title = new Paragraph("Student Financial Statement", 
                    FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 14));
                title.Alignment = Element.ALIGN_CENTER;
                pdfDoc.Add(title);
                pdfDoc.Add(new Paragraph(" "));

                PdfPTable table = new PdfPTable(6);
                table.WidthPercentage = 100;

                table.AddCell("Date");
                table.AddCell("Type");
                table.AddCell("Reference");
                table.AddCell("Charge");
                table.AddCell("Payment");
                table.AddCell("Balance");

                foreach (DataRow row in dt.Rows)
                {
                    string date = row["TransDate"] == DBNull.Value
                        ? ""
                        : Convert.ToDateTime(row["TransDate"]).ToString("dd MMM yyyy");

                    table.AddCell(date);
                    table.AddCell(row["TransType"].ToString());
                    table.AddCell(row["Reference"].ToString());
                    table.AddCell("RM " + Convert.ToDecimal(row["Debit"]).ToString("N2"));
                    table.AddCell("RM " + Convert.ToDecimal(row["Credit"]).ToString("N2"));
                    table.AddCell("RM " + Convert.ToDecimal(row["Balance"]).ToString("N2"));
                }

                pdfDoc.Add(table);
                pdfDoc.Add(new Paragraph(" "));
                pdfDoc.Add(new Paragraph("Closing Balance: " + lblClosing.Text));

                pdfDoc.Close();

                Response.ContentType = "application/pdf";
                Response.AddHeader("content-disposition", "attachment;filename=StudentStatment.pdf");
                Response.BinaryWrite(ms.ToArray());
                Response.End();
            }
        }
    }
}