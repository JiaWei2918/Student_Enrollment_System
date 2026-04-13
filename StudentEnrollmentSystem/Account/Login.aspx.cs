using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Security.Cryptography;
using System.Text;

namespace StudentEnrollmentSystem.Account
{
    public partial class Login : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["DBConnection"].ConnectionString;

        private string HashPassword(string password)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));

                StringBuilder builder = new StringBuilder();
                foreach (byte b in bytes)
                {
                    builder.Append(b.ToString("x2"));
                }

                return builder.ToString();
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            txtUsername.Enabled = true;
            txtPassword.Enabled = true;
            btnLogin.Enabled = true;

            lblMessage.Text = "";

            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text;

            if (string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(password))
            {
                lblMessage.Text = "Please enter username and password.";
                return;
            }

            string hashedPassword = HashPassword(password);
            Debug.WriteLine("Hashed Password: " + hashedPassword);

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("sp_LoginUser", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@Username", SqlDbType.VarChar, 50).Value = username;
                    cmd.Parameters.Add("@PasswordHash", SqlDbType.VarChar, 255).Value = hashedPassword;

                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string result = reader["Result"].ToString();

                            if (result == "SUCCESS")
                            {
                                string role = reader["Role"].ToString();
                                int userID = Convert.ToInt32(reader["UserID"]);
                                string fullName = reader["FullName"].ToString();
                                object studentID = reader["StudentID"];
                                object adminID = reader["AdminID"];

                                Session["UserID"] = userID;
                                Session["Username"] = username;
                                Session["FullName"] = fullName;
                                Session["Role"] = role;

                                if (studentID != DBNull.Value)
                                    Session["StudentID"] = studentID;

                                if (adminID != DBNull.Value)
                                    Session["AdminID"] = adminID;

                                Session.Timeout = 30;

                                if (role == "Admin")
                                    Response.Redirect("~/Admin/Dashboard.aspx", false);
                                else
                                    Response.Redirect("~/Student/Dashboard.aspx", false);

                                Context.ApplicationInstance.CompleteRequest();
                            }
                            else if (result == "LOCKED")
                            {
                                DateTime lockUntil = Convert.ToDateTime(reader["LockUntil"]);
                                txtUsername.Enabled = false;
                                txtPassword.Enabled = false;
                                btnLogin.Enabled = false;

                                lblMessage.Text = "Account locked.";

                                string script = $"startLockTimer('{lockUntil:yyyy-MM-dd HH:mm:ss}');";
                                ClientScript.RegisterStartupScript(this.GetType(), "lockTimer", script, true);
                            }
                            else
                            {
                                lblMessage.Text = "Invalid username or password.";
                            }
                        }
                        else
                        {
                            lblMessage.Text = "Invalid username or password.";
                        }
                    }
                }
            } 
            catch (Exception ex)
            {
                lblMessage.Text = "System error occurred. Check try again.";
            }
        }

        protected void txtUsername_TextChanged(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_CheckUserLock", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@Username", SqlDbType.VarChar, 50).Value = username;

                conn.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        string result = reader["Result"].ToString();

                        if (result == "LOCKED")
                        {
                            DateTime lockUntil = Convert.ToDateTime(reader["LockUntil"]);

                            txtUsername.Enabled = false;
                            txtPassword.Enabled = false;
                            btnLogin.Enabled = false;

                            lblMessage.Text = "Account locked until " + lockUntil.ToString("HH:mm:ss");
                        }
                    }
                }
            }
        }
    }
}