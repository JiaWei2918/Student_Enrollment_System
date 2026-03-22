using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

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

                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    lblReceiptNo.Text = dr["ReceiptNumber"].ToString();
                    lblInvoice.Text = dr["InvoiceNumber"].ToString();
                    lblAmount.Text = "RM " + Convert.ToDecimal(dr["Amount"]).ToString("N2");
                    lblMethod.Text = dr["PaymentMethod"].ToString();
                    lblDate.Text = Convert.ToDateTime(dr["PaymentDate"]).ToString("dd MM yyyy");
                    lblTransaction.Text = dr["TransactionID"].ToString();

                    pnlReceipt.Visible = true;
                }
            }
        }
    }
}