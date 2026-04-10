using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Threading;
using System.Web.UI;
using System.Web.UI.WebControls;

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

                if (dt.Rows.Count > 0)
                    lblOutstanding.Text = Convert.ToDecimal(dt.Rows[0]["TotalOutstanding"]).ToString("N2");
                else
                    lblOutstanding.Text = "0.00";

                LoadSemesterLabel();

                gvInvoice.DataSource = dt;
                gvInvoice.DataBind();
            }
        }

        private void LoadSemesterLabel()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT TOP 1 RTRIM(SemesterName) + ' ' + RTRIM(AcademicYear) " +
                    "FROM Semester WHERE Status = 'Active'", conn))
                {
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    lblSemesterBanner.Text = result?.ToString() ?? "Current Semester";
                }
            }
            catch { lblSemesterBanner.Text = "Current Semester"; }
        }

        protected void gvInvoice_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow) return;

            string status = DataBinder.Eval(e.Row.DataItem, "Status")?.ToString() ?? "";

            if (status == "Overdue")
                e.Row.Style["background"] = "#fff5f5";
        }


        protected void gvInvoice_SelectedIndexChanged(object sender, EventArgs e)
        {
            GridViewRow row = gvInvoice.SelectedRow;
            string invoiceNo = gvInvoice.SelectedDataKey != null
                ? gvInvoice.DataKeys[gvInvoice.SelectedIndex].Value.ToString() : "";

            decimal balance = GetInvoiceBalance(Convert.ToInt32(gvInvoice.SelectedDataKey.Value));

            lblMaxAmount.Text = balance.ToString("N2");
            lblSummaryBalance.Text = balance.ToString("N2");
            lblSummaryInvoice.Text = row.Cells[0].Text;

            string script = $"showPaymentForm('{balance:F2}', '{row.Cells[0].Text}');";
            ScriptManager.RegisterStartupScript(this, GetType(), "showForm", script, true);
        }

        private decimal GetInvoiceBalance(int invoiceID)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT TotalAmount FROM Invoice WHERE InvoiceID = @InvoiceID", conn))
                {
                    cmd.Parameters.AddWithValue("@InvoiceID", invoiceID);
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    return result == null || result == DBNull.Value
                        ? 0 : Convert.ToDecimal(result);
                }
            }
            catch { return 0; }
        }

        protected void btnPay_Click(object sender, EventArgs e)
        {
            ShowMessage("Processing payment...", isError: false, isProcessing: true);

            int studentID = Convert.ToInt32(Session["StudentID"]);

            if (gvInvoice.SelectedDataKey == null)
            {
                ShowMessage("Please select an invoice first.", isError: true);
                return;
            }

            int invoiceID = Convert.ToInt32(gvInvoice.SelectedDataKey.Value);

            if (!decimal.TryParse(txtAmount.Text, out decimal amount) || amount <= 0)
            {
                ShowMessage("Please enter a valid payment amount.", isError: true);
                return;
            }

            try
            {
                Thread.Sleep(1500);

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

                    switch (result)
                    {
                        case "SUCCESS":
                            Response.Redirect("PaymentHistory.aspx");
                            return;
                        case "OVERPAY":
                            ShowMessage("Amount exceeds the outstanding balance.", isError: true);
                            break;
                        case "FAILED":
                            ShowMessage("Payment failed. Please try again.", isError: true);
                            break;
                        default:
                            ShowMessage("An unexpected error occurred.", isError: true);
                            break;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex.Message);
                ShowMessage("System error during payment.", isError: true);
            }

            txtAmount.Text = "";
            LoadInvoices();
        }

        private void ShowMessage(string text, bool isError, bool isProcessing = false)
        {
            if (isProcessing)
            {
                lblMsg.CssClass = "processing";
                lblMsg.Text = text;
            }
            else
            {
                lblMsg.CssClass = isError ? "error" : "success";
                lblMsg.Text = text;
            }
        }

        protected string GetStatusBadge(string status)
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

        protected bool IsPayable(string status)
        {
            return status == "Issued" || status == "Partial" || status == "Overdue";
        }

        protected string FormatDate(object dateObj)
        {
            if (dateObj == null || dateObj == DBNull.Value) return "—";
            return Convert.ToDateTime(dateObj).ToString("dd MMM yyyy");
        }
    }
}