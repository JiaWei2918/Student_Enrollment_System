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
    public partial class Login : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["DBConnection"].ConnectionString;

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            Debug.WriteLine("===== LOGIN ATTEMPT START =====");

            try
            {
                string username = txtUsername.Text.Trim();
                string password = txtPassword.Text.Trim();

                Debug.WriteLine("Username Entered: " + username);

                //string hashedPassword = PasswordHelper.HashPassword(password);
                //Debug.WriteLine("Hashed Password: " + hashedPassword);

                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    Debug.WriteLine("Opening SQL Connection...");
                    conn.Open();
                    Debug.WriteLine("Opening SQL Connection...");

                    using (SqlCommand cmd = new SqlCommand("sp_LoginUser", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@Username", username);
                        cmd.Parameters.AddWithValue("@PasswordHash", password);

                        Debug.WriteLine("Executing Stored Procedure...");

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string result = reader["Result"].ToString();
                                Debug.WriteLine("Stored Procedure Result: " + result);

                                switch (result)
                                {
                                    case "SUCCESS":
                                        string role = reader["Role"].ToString();
                                        Debug.WriteLine("Login SUCCESS. Role: " + role);

                                        Session["Username"] = username;
                                        Session["Role"] = role;

                                        Debug.WriteLine("Session Created.");

                                        if (role == "Admin")
                                        {
                                            Debug.WriteLine("Redirecting to Admin Dashboard");
                                            Response.Redirect("~/Admin/Dashboard.aspx");
                                        }
                                        else
                                        {
                                            Debug.WriteLine("Redirecting to Student Dashboard");
                                            Response.Redirect("~/Student/Dashboard.aspx");
                                        }
                                        break;

                                    case "LOCKED":
                                        Debug.WriteLine("Account LOCKED.");
                                        lblMessage.Text = "Account locked. Try again after 5 minutes.";
                                        break;

                                    case "WRONG_PASSWORD":
                                        Debug.WriteLine("Wrong password entered.");
                                        lblMessage.Text = "Wrong password.";
                                        break;

                                    case "INVALID_USER":
                                        Debug.WriteLine("User not found.");
                                        lblMessage.Text = "User not found.";
                                        break;

                                    default:
                                        lblMessage.Text = "Unknown login error.";
                                        break;
                                }
                            }
                            else
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
            Debug.WriteLine("===== LOGIN ATTEMPT END =====");
        }
    }
}