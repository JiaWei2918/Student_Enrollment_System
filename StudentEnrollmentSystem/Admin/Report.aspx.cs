using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentEnrollmentSystem.Admin
{
    public partial class Report : System.Web.UI.Page
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

            if (!IsPostBack)
            {
                LoadSummaryReport();
                LoadOfferingsDropdown();
            }
        }

        private void LoadSummaryReport()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetAllCourseOfferings", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                conn.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    DataTable dt = new DataTable();
                    dt.Load(reader);
                    gvSummary.DataSource = dt;
                    gvSummary.DataBind();
                }
            }
        }

        private void LoadOfferingsDropdown()
        {
            string query = @"
                SELECT 
                    co.OfferingID,
                    c.CourseCode + ' - ' + c.CourseName + ' (' + s.SemesterName + ' ' + CAST(s.AcademicYear AS VARCHAR) + ')' AS DisplayText
                FROM CourseOffering co
                INNER JOIN Course c ON co.CourseID = c.CourseID
                INNER JOIN Semester s ON co.SemesterID = s.SemesterID
                ORDER BY s.AcademicYear DESC, s.SemesterName, c.CourseCode";

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                conn.Open();
                ddlOffering.DataSource = cmd.ExecuteReader();
                ddlOffering.DataTextField = "DisplayText";
                ddlOffering.DataValueField = "OfferingID";
                ddlOffering.DataBind();
            }

            ddlOffering.Items.Insert(0, new ListItem("-- Select a course offering --", ""));
        }

        protected void ddlOffering_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadStudentList();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadStudentList();
        }

        private void LoadStudentList()
        {
            if (string.IsNullOrEmpty(ddlOffering.SelectedValue))
            {
                gvStudents.DataSource = null;
                gvStudents.DataBind();
                return;
            }

            int offeringId = Convert.ToInt32(ddlOffering.SelectedValue);

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetStudentsByOffering", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@OfferingID", offeringId);
                conn.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    DataTable dt = new DataTable();
                    dt.Load(reader);
                    gvStudents.DataSource = dt;
                    gvStudents.DataBind();
                }
            }
        }
    }
}