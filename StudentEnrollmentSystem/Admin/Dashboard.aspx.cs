using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentEnrollmentSystem.Admin
{
    public partial class Dashboard : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["DBConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            Debug.WriteLine("=== ADMIN DASHBOARD LOAD ===");

            if (Session["Role"] == null || Session["Role"].ToString() != "Admin")
            {
                Debug.WriteLine("Unauthorized access attempt.");
                Response.Redirect("~/Account/Login.aspx");
            }

            if (!IsPostBack)
            {
                lblWelcome.Text = "Welcome, " + Session["Username"];
                LoadStatistics();
            }
        }

        private void LoadStatistics()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                lblTotalStudents.Text =
                    ExecuteCount(conn, "SELECT COUNT(*) FROM Student");

                lblTotalCourses.Text =
                    ExecuteCount(conn, "SELECT COUNT(*) FROM Course");

                lblTotalSemesters.Text =
                    ExecuteCount(conn, "SELECT COUNT(*) FROM Semester");

                lblTotalOfferings.Text =
                    ExecuteCount(conn, "SELECT COUNT(*) FROM CourseOffering");
            }
        }

        private string ExecuteCount(SqlConnection conn, string query)
        {
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                return cmd.ExecuteScalar().ToString();
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Debug.WriteLine("Admin logged out.");

            Session.Clear();
            Session.Abandon();

            Response.Redirect("~/Account/Login.aspx");
        }
    }
}