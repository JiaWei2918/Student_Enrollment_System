using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;

namespace StudentEnrollmentSystem.Account
{
    public partial class ChangePassword : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["DBConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null)
            {
                Response.Redirect("~/Account/Login.aspx");
                return;
            }
        }

        private string HashPassword(string password)
        {
            using (SHA256 sha = SHA256.Create())
            {
                byte[] bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(password));

                StringBuilder builder = new StringBuilder();

                foreach (byte b in bytes)
                {
                    builder.Append(b.ToString("x2"));
                }

                return builder.ToString();
            }
        }

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            int userID = Convert.ToInt32(Session["UserID"]);

            if (txtConfirmPassword.Text == txtNewPassword.Text)
            {
                lblMessage.ForeColor = System.Drawing.Color.Red;
                lblMessage.Text = "New Password cannot be the same as current password.";
                return;
            }

            string currentHash = HashPassword(txtCurrentPassword.Text);
            string newHash = HashPassword(txtNewPassword.Text);

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_ChangePassword", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@UserID", userID);
                cmd.Parameters.AddWithValue("@CurrentPasswordHash", currentHash);
                cmd.Parameters.AddWithValue("@NewPasswordHash", newHash);

                conn.Open();

                string result = cmd.ExecuteScalar()?.ToString();

                if (result == "INVALID_PASSWORD")
                {
                    lblMessage.ForeColor = System.Drawing.Color.Red;
                    lblMessage.Text = "Current password is incorrect.";
                }
                else if (result == "SUCCESS")
                {
                    lblMessage.ForeColor = System.Drawing.Color.Green;
                    lblMessage.Text = "Password changed successfully.";

                    txtCurrentPassword.Text = "";
                    txtNewPassword.Text = "";
                    txtConfirmPassword.Text = "";
                }
                else
                {
                    lblMessage.ForeColor = System.Drawing.Color.Red;
                    lblMessage.Text = "System error occurred.";
                }
            }
        }
    }
}