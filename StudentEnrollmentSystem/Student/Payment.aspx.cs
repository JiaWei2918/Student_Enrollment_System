using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Threading;
using System.Web.UI;

namespace StudentEnrollmentSystem.Student
{
    public partial class Payment : System.Web.UI.Page
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
                LoadPayments();
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

                gvInvoice.DataSource = dt;
                gvInvoice.DataBind();
            }
        }

        private void LoadPayments()
        {
            int studentID = Convert.ToInt32(Session["StudentID"]);

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetPaymentHistory", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@StudentID", studentID);

                conn.Open();

                DataTable dt = new DataTable();
                dt.Load(cmd.ExecuteReader());

                gvPayment.DataSource = dt;
                gvPayment.DataBind();
            }
        }

        protected void gvInvoice_SelectedIndexChanged(object sender, EventArgs e)
        {
            pnlPayment.Visible = true;
        }

        protected void btnPay_Click(object sender, EventArgs e)
        {
            lblMsg.CssClass = "processing";
            lblMsg.Text = "Processing payment...";
            Response.Flush();

            Thread.Sleep(1500);

            int studentID = Convert.ToInt32(Session["StudentID"]);
            int invoiceID = Convert.ToInt32(gvInvoice.SelectedDataKey.Value);

            decimal amount;
            if (!decimal.TryParse(txtAmount.Text, out amount))
            {
                lblMsg.CssClass = "error";
                lblMsg.Text = "Invalid amount.";
                return;
            }

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_MakePayment", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@InvoiceID", invoiceID);
                cmd.Parameters.AddWithValue("@StudentID", studentID);
                cmd.Parameters.AddWithValue("@Amount", amount);
                cmd.Parameters.AddWithValue("@PaymentMethod", ddlMethod.SelectedValue);

                conn.Open();

                string result = cmd.ExecuteScalar()?.ToString();

                if (result == "SUCCESS")
                {
                    lblMsg.CssClass = "success";
                    lblMsg.Text = "Payment successful!";
                }
                else if (result == "FAILED")
                {
                    lblMsg.CssClass = "error";
                    lblMsg.Text = "Payment failed. Try again.";
                }
                else if (result == "OVERPAY")
                {
                    lblMsg.CssClass = "error";
                    lblMsg.Text = "Amount exceeds balance.";
                }
                else
                {
                    lblMsg.CssClass = "error";
                    lblMsg.Text = "Error occurred.";
                }
            }

            pnlPayment.Visible = false;
            txtAmount.Text = "";

            LoadInvoices();
            LoadPayments();
        }
    }
}