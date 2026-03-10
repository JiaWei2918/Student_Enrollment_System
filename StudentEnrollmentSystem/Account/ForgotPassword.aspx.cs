using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using System.Web.UI;

namespace StudentEnrollmentSystem.Account
{
    public partial class ForgotPassword : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["DBConnection"].ConnectionString;

        private string HashPassword(string password)
        {
            using (var sha = System.Security.Cryptography.SHA256.Create())
            {
                var bytes = sha.ComputeHash(System.Text.Encoding.UTF8.GetBytes(password));

                var builder = new System.Text.StringBuilder();
                foreach (var b in bytes)
                    builder.Append(b.ToString("x2"));

                return builder.ToString();
            }
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            lblMessage.Text = "";
            lblMessage.ForeColor = System.Drawing.Color.Red;

            string username = txtUsername.Text.Trim();
            string email = txtEmail.Text.Trim();
            string newPassword = txtNewPassword.Text;
            string confirmPassword = txtConfirmPassword.Text;

            if(newPassword != confirmPassword)
            {
                lblMessage.Text = "Passwords do not match.";
                return;
            }

            if(!Regex.IsMatch(email, @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
            {
                lblMessage.Text = "Invalid email format.";
                return;
            }

            try
            {
                string hashedPassword = HashPassword(newPassword);

                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("sp_ResetPassword", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.Add("@Username", SqlDbType.VarChar, 50).Value = username;
                    cmd.Parameters.Add("@Email", SqlDbType.VarChar, 100).Value = email;
                    cmd.Parameters.Add("@NewPasswordHash", SqlDbType.VarChar, 255).Value = hashedPassword;

                    conn.Open();

                    object resultObj = cmd.ExecuteScalar();
                    
                    if(resultObj == null)
                    {
                        lblMessage.Text = "Unable to process request. Please try again.";
                        return;
                    }

                    string result = resultObj != null ? resultObj.ToString() : "";

                    if (result == "SUCCESS")
                    {
                        lblMessage.ForeColor = System.Drawing.Color.Green;
                        lblMessage.Text = "Password reset successfully. Redirecting to login...";

                        txtNewPassword.Text = "";
                        txtConfirmPassword.Text = "";

                        Response.AddHeader("REFRESH", "2;URL=Login.aspx");
                    }
                    else if (result == "INVALID_INFO")
                    {
                        lblMessage.Text = "Invalid username or email.";
                    }
                    else
                    {
                        lblMessage.Text = "Password reset failred. Please try again.";
                    }
                }
            } 
            catch (SqlException ex)
            {
                lblMessage.Text = "Database error occured. Please try again later.";
            }
            catch (Exception ex)
            {
                lblMessage.Text = "System error occurred. Please contact administrator.";
            }
        }
    }
}