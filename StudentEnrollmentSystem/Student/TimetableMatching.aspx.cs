using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace StudentEnrollmentSystem.Student
{
    public partial class TimetableMatching : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["DBConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StudentID"] == null)
            {
                Response.Redirect("~/Account/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadSemester();
            }
        }

        private void LoadSemester()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("SELECT SemesterID, SemesterName FROM Semester", conn))
            {
                conn.Open();
                ddlSemester.DataSource = cmd.ExecuteReader();
                ddlSemester.DataTextField = "SemesterName";
                ddlSemester.DataValueField = "SemesterID";
                ddlSemester.DataBind();

                ddlSemester.Items.Insert(0, new ListItem("-- Select Semester --", ""));
            }

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("SELECT TOP 1 SemesterID FROM Semester WHERE Status='Active'", conn))
            {
                conn.Open();
                var id = cmd.ExecuteScalar();

                if (id != null)
                    ddlSemester.SelectedValue = id.ToString();
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            int studentID;
            int semesterID;

            if (!int.TryParse(Session["StudentID"]?.ToString(), out studentID))
            {
                lblMsg.Text = "Session expired.";
                return;
            }

            if (!int.TryParse(ddlSemester.SelectedValue, out semesterID))
            {
                lblMsg.Text = "Please select a valid semester.";
                return;
            }

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetAvailableCourses_NoClash", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@StudentID", studentID);
                cmd.Parameters.AddWithValue("@SemesterID", semesterID);

                conn.Open();

                DataTable dt = new DataTable();
                dt.Load(cmd.ExecuteReader());

                if (dt.Rows.Count == 0)
                {
                    lblMsg.Text = "No available courses without clash.";
                }
                else
                {
                    lblMsg.Text = "";
                }

                gvCourses.DataSource = dt;
                gvCourses.DataBind();
            }
        }

        protected void gvCourses_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Enroll")
            {
                int index = Convert.ToInt32(e.CommandArgument);
                int offeringID = Convert.ToInt32(gvCourses.DataKeys[index].Value);
                int studentID = Convert.ToInt32(Session["StudentID"]);

                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("sp_EnrollCourse", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@StudentID", studentID);
                    cmd.Parameters.AddWithValue("@OfferingID", offeringID);

                    conn.Open();
                    string result = cmd.ExecuteScalar()?.ToString();

                    if (result == "SUCCESS")
                        lblMsg.Text = "Enrolled successfully";
                    else
                        lblMsg.Text = "Failed to enroll.";
                }

                btnSearch_Click(null, null);
            }
        }
    }
}