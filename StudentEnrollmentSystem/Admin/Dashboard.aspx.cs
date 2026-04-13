using System;
using System.Configuration;
using System.Data.SqlClient;
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

            if (Session["AdminID"] == null || Session["Role"]?.ToString() != "Admin")
            {
                Response.Redirect("~/Account/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (Session["Role"].ToString() != "Admin")
            {
                Response.Redirect("~/Account/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                LoadAdminInfo();
                LoadStatistics();
            }
        }

        private void LoadAdminInfo()
        {
            if (Session["FullName"] != null)
            {
                lblWelcome.Text = "Welcome, " + Session["FullName"].ToString();
            }
            else
            {
                lblWelcome.Text = "Welcome, " + Session["Username"].ToString();
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
            Session.Clear();
            Session.Abandon();

            Response.Redirect("~/Account/Login.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}