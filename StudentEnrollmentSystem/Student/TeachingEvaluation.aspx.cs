using Microsoft.SqlServer.Server;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace StudentEnrollmentSystem.Student
{
    public partial class TeachingEvaluation : System.Web.UI.Page
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
                LoadMyEvaluation();
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
        }

        protected void ddlSemester_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadCourses();
        }

        private void LoadCourses()
        {
            int studentID = Convert.ToInt32(Session["StudentID"]);
            int semesterID = Convert.ToInt32(ddlSemester.SelectedValue);

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetEnrolledCourses", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@StudentID", studentID);
                cmd.Parameters.AddWithValue("@semesterID", semesterID);

                conn.Open();
                ddlCourse.DataSource = cmd.ExecuteReader();
                ddlCourse.DataTextField = "CourseCode";
                ddlCourse.DataValueField = "OfferingID";
                ddlCourse.DataBind();

                ddlCourse.Items.Insert(0, new ListItem("-- Select Course --", ""));
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            int studentID = Convert.ToInt32(Session["StudentID"]);
            int offeringID;

            if (!int.TryParse(ddlCourse.SelectedValue, out offeringID))
            {
                lblMsg.Text = "Please select a course.";
                lblMsg.ForeColor = System.Drawing.Color.Red;
                return;
            }

            if (string.IsNullOrEmpty(ddlRating.SelectedValue))
            {
                lblMsg.Text = "Please select overall rating.";
                lblMsg.ForeColor = System.Drawing.Color.Red;
                return;
            }

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_SubmitEvaluation", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@StudentID", studentID);
                cmd.Parameters.AddWithValue("@OfferingID", offeringID);
                cmd.Parameters.AddWithValue("@Rating", Convert.ToInt32(ddlRating.SelectedValue));

                cmd.Parameters.AddWithValue("@LecturerRating",
                    string.IsNullOrEmpty(ddlLecturerRating.SelectedValue) ? (object)DBNull.Value : Convert.ToInt32(ddlLecturerRating.SelectedValue));

                cmd.Parameters.AddWithValue("@CourseRating",
                    string.IsNullOrEmpty(ddlCourseRating.SelectedValue) ? (object)DBNull.Value : Convert.ToInt32(ddlCourseRating.SelectedValue));

                cmd.Parameters.AddWithValue("@Comment", txtComment.Text.Trim());
                cmd.Parameters.AddWithValue("@IsAnonymous", chkAnonymous.Checked);

                conn.Open();
                string result = cmd.ExecuteScalar()?.ToString();

                if (result == "EXISTS")
                {
                    lblMsg.Text = "You already submitted evaluation.";
                    lblMsg.ForeColor = System.Drawing.Color.Red;
                }
                else if (result == "NOT_ENROLLED")
                {
                    lblMsg.Text = "Invalid course.";
                    lblMsg.ForeColor = System.Drawing.Color.Red;
                }
                else
                {
                    lblMsg.Text = "Evaluation submitted successfully!";
                    lblMsg.ForeColor = System.Drawing.Color.Green;

                    ClearForm();
                }
            }

            LoadMyEvaluation();
        }

        private void ClearForm()
        {
            ddlCourse.SelectedIndex = 0;
            ddlRating.SelectedIndex = 0;
            ddlLecturerRating.SelectedIndex = 0;
            ddlCourseRating.SelectedIndex = 0;
            txtComment.Text = "";
            chkAnonymous.Checked = false;
        }

        private void LoadMyEvaluation()
        {
            int studentID = Convert.ToInt32(Session["StudentID"]);

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetMyEvaluations", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@StudentID", studentID);

                conn.Open();
               
                DataTable dt = new DataTable();
                dt.Load(cmd.ExecuteReader());

                gvEvaluation.DataSource = dt;
                gvEvaluation.DataBind();
            }
        }
    }
}