using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentEnrollmentSystem.Account
{
    public partial class ForgotPassword : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["DBConnection"].ConnectionString;

        protected void btnReset_Click(object sender, EventArgs e)
        {
            Debug.WriteLine("===== RESET PASSWORD ATTEMPT START =====");

            try
            {
                lblMessage.Text = "";
                lblMessage.ForeColor = System.Drawing.Color.Red;

                string username = txtUsername.Text.Trim();
                string email = txtEmail.Text.Trim();
                string newPassword = txtNewPassword.Text.Trim();

                Debug.WriteLine("Username Entered: " + username);
                Debug.WriteLine("Email Entered: " + email);

                if (string.IsNullOrEmpty(username) ||
                    string.IsNullOrEmpty(email) ||
                    string.IsNullOrEmpty(newPassword))
                {
                    Debug.WriteLine("Validation Failed: One or more fields empty.");
                    lblMessage.Text = "All fields are required.";
                    return;
                }

                //string hashedPassword = PasswordHelper.HashPassword(newPassword);
                //Debug.WriteLine("Password hashed successfully.");

                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    Debug.WriteLine("Opening SQL Connection...");
                    conn.Open();
                    Debug.WriteLine("SQL Connection Opened.");

                    using (SqlCommand cmd = new SqlCommand("sp_ResetPassword", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        cmd.Parameters.AddWithValue("@Username", username);
                        cmd.Parameters.AddWithValue("@Email", email);
                        cmd.Parameters.AddWithValue("@NewPasswordHash", newPassword);

                        Debug.WriteLine("Executing Stored Procedure sp_ResetPassword...");

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string result = reader["Result"].ToString();
                                Debug.WriteLine("Stored Procedure Result: " + result);

                                if (result == "SUCCESS")
                                {
                                    lblMessage.ForeColor = System.Drawing.Color.Green;
                                    lblMessage.Text = "Password reset successful. You may login now.";

                                    Debug.WriteLine("Password reset SUCCESS.");
                                }
                                else
                                {
                                    lblMessage.Text = "Invalid username or email.";
                                    Debug.WriteLine("Reset FAILED: Invalid info."); 
                                }
                            } else
                            {
                                Debug.WriteLine("No result returned from stored procedure.");
                                lblMessage.Text = "Unexpected error occurred.";
                            }
                        }
                    }
                }
            } catch (Exception ex)
            {
                Debug.WriteLine("EXCEPTION OCCURRED:");
                Debug.WriteLine(ex.Message);
                Debug.WriteLine(ex.StackTrace);

                lblMessage.Text = "System error occurred. Check debug output.";
            }
            Debug.WriteLine("===== RESET PASSWORD ATTEMPT END =====");
        }
    }
}