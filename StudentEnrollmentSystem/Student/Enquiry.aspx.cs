using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace StudentEnrollmentSystem.Student
{
    public partial class Enquiry : System.Web.UI.Page
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
                LoadEnquiries();
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            lblMsg.Text = "";

            if (ddlSubject.SelectedValue == "")
            {
                ShowMessage("Please select a category.", isError: true);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtMessage.Text))
            {
                ShowMessage("Message cannot be empty.", isError: true);
                return;
            }

            if (txtMessage.Text.Trim().Length < 10)
            {
                ShowMessage("Message is too short (minimum 10 characters).", isError: true);
                return;
            }

            if (txtMessage.Text.Trim().Length > 500)
            {
                ShowMessage("Message is too long (maximum 500 characters).", isError: true);
                return;
            }

            int studentID = Convert.ToInt32(Session["StudentID"]);

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                using (SqlCommand checkCmd = new SqlCommand("sp_CheckDuplicateEnquiry", conn))
                {
                    checkCmd.CommandType = CommandType.StoredProcedure;
                    checkCmd.Parameters.AddWithValue("@StudentID", studentID);
                    checkCmd.Parameters.AddWithValue("@Message", txtMessage.Text.Trim());

                    int count = (int)checkCmd.ExecuteScalar();

                    if (count > 0)
                    {
                        ShowMessage("You already submitted this enquiry recently. Please wait a few minutes before resubmitting.", isError: true);
                        return;
                    }
                }

                using (SqlCommand cmd = new SqlCommand("sp_InsertEnquiry", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@StudentID", studentID);
                    cmd.Parameters.AddWithValue("@Subject", ddlSubject.SelectedValue);
                    cmd.Parameters.AddWithValue("@Message", txtMessage.Text.Trim());

                    cmd.ExecuteNonQuery();
                }
            }

            ShowMessage("Your message has been sent! We'll get back to you within 24–48 hours.", isError: false);

            txtMessage.Text = "";
            ddlSubject.SelectedIndex = 0;

            LoadEnquiries();
        }

        private void LoadEnquiries()
        {
            int studentID = Convert.ToInt32(Session["StudentID"]);

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetStudentEnquiries", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@StudentID", studentID);

                conn.Open();
                
                DataTable dt = new DataTable();
                dt.Load(cmd.ExecuteReader());

                if (dt.Rows.Count == 0)
                {
                    gvEnquiry.Visible = false;
                    pnlEmpty.Visible = true;
                }
                else
                {
                    gvEnquiry.Visible = true;
                    pnlEmpty.Visible = false;
                    gvEnquiry.DataSource = dt;
                    gvEnquiry.DataBind();
                }
            }
        }

        private void ShowMessage(string text, bool isError)
        {
            lblMsg.ForeColor = isError
                ? System.Drawing.Color.Red
                : System.Drawing.Color.Green;
            lblMsg.Text = text;
        }

        public string GetStatusBadge(string status)
        {
            switch (status)
            {
                case "Pending": return "<span class=\"badge badge-pending\">Pending</span>";
                case "In Progress": return "<span class=\"badge badge-inprogress\">In Progress</span>";
                case "Resolved": return "<span class=\"badge badge-resolved\">Resolved</span>";
                case "Closed": return "<span class=\"badge badge-closed\">Closed</span>";
                default: return $"<span class=\"badge badge-default\">{status}</span>";
            }
        }
    }
}