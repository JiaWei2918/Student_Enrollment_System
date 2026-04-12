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

            if (txtCurrentPassword.Text == txtNewPassword.Text)
            {
                ShowMessage("New password cannot be the same as your current password.", isError: true);
                return;
            }

            try
            {
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

                    switch (result)
                    {
                        case "SUCCESS":
                            txtCurrentPassword.Text = "";
                            txtNewPassword.Text = "";
                            txtConfirmPassword.Text = "";

                            ScriptManager.RegisterStartupScript(
                                this, GetType(), "showSuccess",
                                "document.getElementById('" + pnlSuccess.ClientID + "').style.display='block';" +
                                "document.getElementById('" + pnlForm.ClientID + "').style.display='none';",
                                true);

                            ShowMessage("Password changed successfully!", isError: false);
                            break;

                        case "INVALID_PASSWORD":
                            ShowMessage("Current password is incorrect. Please try again.", isError: true);
                            break;

                        default:
                            ShowMessage("A system error occurred. Please try again.", isError: true);
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