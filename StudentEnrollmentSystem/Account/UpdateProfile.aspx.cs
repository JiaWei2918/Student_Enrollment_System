using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace StudentEnrollmentSystem.Account
{
    public partial class UpdateProfile : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["DBConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StudentID"] == null || Session["Role"]?.ToString() != "Student")
            {
                Response.Redirect("~/Account/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadProfile();
            }
        }

        private void LoadProfile()
        {
            int studentID = Convert.ToInt32(Session["StudentID"]);

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("sp_GetStudentProfile", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@StudentID", studentID);

                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            txtFullName.Text = reader["FullName"].ToString();
                            txtEmail.Text = reader["Email"].ToString();
                            txtPhone.Text = reader["Phone"].ToString();
                            txtProgram.Text = reader["Program"].ToString();
                            txtSection.Text = reader["Section"].ToString();
                            txtAddress.Text = reader["Address"].ToString();
                            txtNationality.Text = reader["Nationality"].ToString();

                            if (reader["DateOfBirth"] != DBNull.Value)
                                txtDOB.Text = Convert.ToDateTime(reader["DateOfBirth"])
                                    .ToString("yyyy-MM-dd");
                        }
                    }
                }
            }
            catch
            {
                ShowMessage("Error loading profile.", isError: true);
            }
        }

        protected void btnUpdate_Click(object sender, EventArgs e) 
        { 
            int studentID = Convert.ToInt32(Session["StudentID"]);

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("sp_UpdateStudentProfile", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@StudentID", studentID);
                    cmd.Parameters.AddWithValue("@FullName", txtFullName.Text.Trim());

                    cmd.Parameters.AddWithValue("@Phone",
                        string.IsNullOrEmpty(txtPhone.Text) ? (object)DBNull.Value : txtPhone.Text.Trim());
                    cmd.Parameters.AddWithValue("@Program",
                        string.IsNullOrEmpty(txtProgram.Text) ? (object)DBNull.Value : txtProgram.Text.Trim());
                    cmd.Parameters.AddWithValue("@Section",
                        string.IsNullOrEmpty(txtSection.Text) ? (object)DBNull.Value : txtSection.Text.Trim());
                    cmd.Parameters.AddWithValue("@Address",
                        string.IsNullOrEmpty(txtAddress.Text) ? (object)DBNull.Value : txtAddress.Text.Trim());
                    cmd.Parameters.AddWithValue("@Nationality",
                        string.IsNullOrEmpty(txtNationality.Text) ? (object)DBNull.Value : txtNationality.Text.Trim());

                    cmd.Parameters.AddWithValue("@DateOfBirth",
                       string.IsNullOrWhiteSpace(txtDOB.Text) ? (object)DBNull.Value : (object)Convert.ToDateTime(txtDOB.Text));

                    conn.Open();
                    string result = cmd.ExecuteScalar()?.ToString();

                    switch (result)
                    {
                        case "SUCCESS":
                            Session["FullName"] = txtFullName.Text.Trim();
                            ShowMessage("Profile updated successfully!", isError: false);
                            break;

                        case "DUPLICATE_EMAIL":
                            ShowMessage("This email address is already in use by another account.", isError: true);
                            break;

                        case "ERROR":
                            ShowMessage("A database error occurred. Please try again.", isError: true);
                            break;

                        default:
                            ShowMessage("An unexpected error occurred.", isError: true);
                            break;
                    }
                }
            }
            catch
            {
                ShowMessage("A system error occurred. Please try again.", isError: true);
            }
        }

        private void ShowMessage(string text, bool isError)
        {
            lblMessage.ForeColor = isError
                ? System.Drawing.Color.Red
                : System.Drawing.Color.Green;
            lblMessage.Text = text;
        }
    }
}