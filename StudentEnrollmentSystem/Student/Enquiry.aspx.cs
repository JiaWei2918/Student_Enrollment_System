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
                lblMsg.Text = "Please select a subject.";
                return;
            }

            if (string.IsNullOrWhiteSpace(txtMessage.Text))
            {
                lblMsg.Text = "Message cannot be empty.";
                return;
            }

            if (txtMessage.Text.Length < 10)
            {
                lblMsg.Text = "Message too short.";
                return;
            }

            if (txtMessage.Text.Length > 500)
            {
                lblMsg.Text = "Message too long (max 500).";
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
                        lblMsg.Text = "You already submitted this enquiry recently.";
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

            lblMsg.ForeColor = System.Drawing.Color.Green;
            lblMsg.Text = "Enquiry submitted successfully.";

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

                gvEnquiry.DataSource = dt;
                gvEnquiry.DataBind();

                if (dt.Rows.Count == 0)
                {
                    lblMsg.Text = "No enquiries yet.";
                }
            }
        }

        public string GetStatusColor (string status)
        {
            switch (status)
            {
                case "Pending": return "orange";
                case "In Progress": return "blue";
                case "Resolved": return "green";
                case "Closed": return "gray";
                default: return "black";
            }
        }
    }
}