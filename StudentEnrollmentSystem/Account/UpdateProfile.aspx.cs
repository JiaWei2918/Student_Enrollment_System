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
            if (Session["StudentID"] == null || Session["Role"] == null || Session["Role"].ToString() != "Student")
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
                        {
                            txtDOB.Text = Convert.ToDateTime(reader["DateOfBirth"]).ToString("yyyy-MM-dd");
                        }
                    }
                }
            }
        }

        protected void btnUpdate_Click(object sender, EventArgs e) 
        { 
            int studentID = Convert.ToInt32(Session["StudentID"]); 
            
            using (SqlConnection conn = new SqlConnection(connStr)) 
            using (SqlCommand cmd = new SqlCommand("sp_UpdateStudentProfile", conn)) 
            { 
                cmd.CommandType = CommandType.StoredProcedure; 

                cmd.Parameters.AddWithValue("@StudentID", studentID); 
                cmd.Parameters.AddWithValue("@FullName", txtFullName.Text.Trim()); 
                cmd.Parameters.AddWithValue("@Email", txtEmail.Text.Trim()); 

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

                if (string.IsNullOrEmpty(txtDOB.Text))
                    cmd.Parameters.AddWithValue("@DateOfBirth", DBNull.Value);
                else
                    cmd.Parameters.AddWithValue("@DateOfBirth", Convert.ToDateTime(txtDOB.Text));

                try
                {
                    conn.Open();

                    string result = cmd.ExecuteScalar()?.ToString();

                    if (result == "DUPLICATE_EMAIL")
                    {
                        lblMessage.ForeColor = System.Drawing.Color.Red;
                        lblMessage.Text = "Email already exists.";
                    }
                    else if (result == "SUCCESS")
                    {
                        lblMessage.ForeColor = System.Drawing.Color.Green;
                        lblMessage.Text = "Profile updated successfully.";
                    }
                    else
                    {
                        lblMessage.ForeColor = System.Drawing.Color.Red;
                        lblMessage.Text = "System error occurred.";
                    }
                }
                catch
                {
                    lblMessage.ForeColor= System.Drawing.Color.Red;
                    lblMessage.Text = "Database error occurred.";
                }
            } 
        }
    }
}