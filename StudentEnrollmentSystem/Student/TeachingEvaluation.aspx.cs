using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
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
            using (SqlCommand cmd = new SqlCommand("" +
                "SELECT SemesterID, RTRIM(SemesterName) + ' ' + RTRIM(AcademicYear) AS SemesterLabel " +
                "FROM Semester ORDER BY SemesterID DESC", conn))
            {
                conn.Open();
                DataTable dt = new DataTable();
                dt.Load(cmd.ExecuteReader());

                ddlSemester.DataSource = dt;
                ddlSemester.DataTextField = "SemesterLabel";
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
            if (!int.TryParse(ddlSemester.SelectedValue, out int semesterID)) return;

            int studentID = Convert.ToInt32(Session["StudentID"]);

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetEnrolledCourses", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@StudentID", studentID);
                cmd.Parameters.AddWithValue("@semesterID", semesterID);
                conn.Open();

                DataTable dt = new DataTable();
                dt.Load(cmd.ExecuteReader());

                ddlCourse.Items.Clear();
                ddlCourse.Items.Add(new ListItem("-- Select --", ""));

                phCourses.Controls.Clear();

                if (dt.Rows.Count == 0)
                {
                    pnlNoCourses.Visible = true;
                    pnlCourseList.Visible = false;
                    lblPending.Text = "0";
                    return;
                }

                pnlNoCourses.Visible = false;
                pnlCourseList.Visible = true;
                lblPending.Text = dt.Rows.Count.ToString();

                var sb = new StringBuilder();

                foreach (DataRow row in dt.Rows)
                {
                    string offeringID = row["OfferingID"].ToString();
                    string courseCode = row["CourseCode"].ToString();

                    // Add to hidden ddlCourse
                    ddlCourse.Items.Add(new ListItem(courseCode, offeringID));

                    // Render styled course button
                    sb.AppendFormat(
                        @"<button type='button' class='course-btn' 
                                onclick='selectCourse(""{0}"",""{1}"",""{1}"")'>
                                <div class='cb-top'>
                                    <div>
                                        <div class='cb-code'>{1}</div>
                                    </div>
                                    <i class='fa fa-chevron-right' style='color:#94a3b8;font-size:12px;margin-top:2px;'></i>
                                </div>
                            </button>",
                        offeringID, courseCode
                    );
                }

                phCourses.Controls.Add(new LiteralControl(sb.ToString()));
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            lblMsg.Text = "";

            int studentID = Convert.ToInt32(Session["StudentID"]);

            if (!int.TryParse(ddlCourse.SelectedValue, out int offeringID))
            {
                ShowMessage("Please select a course.", isError: true);
                return;
            }

            if (string.IsNullOrEmpty(ddlRating.SelectedValue))
            {
                ShowMessage("Please select an overall rating.", isError: true);
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
                    string.IsNullOrEmpty(ddlLecturerRating.SelectedValue) 
                    ? (object)DBNull.Value : Convert.ToInt32(ddlLecturerRating.SelectedValue));

                cmd.Parameters.AddWithValue("@CourseRating",
                    string.IsNullOrEmpty(ddlCourseRating.SelectedValue) 
                    ? (object)DBNull.Value : Convert.ToInt32(ddlCourseRating.SelectedValue));

                cmd.Parameters.AddWithValue("@Comment", txtComment.Text.Trim());
                cmd.Parameters.AddWithValue("@IsAnonymous", chkAnonymous.Checked);

                conn.Open();
                string result = cmd.ExecuteScalar()?.ToString();

                switch (result)
                {
                    case "SUCCESS":
                        ShowMessage("Evaluation submitted successfully!", isError: false);
                        ClearForm();

                        LoadCourses();
                        break;
                    case "EXISTS":
                        ShowMessage("You have already submitted an evaluation for this course.", isError: true);
                        break;
                    case "NOT_ENROLLED":
                        ShowMessage("You are not enrolled in this course.", isError: true);
                        break;
                    default:
                        ShowMessage("Submission failed. Please try again.", isError: true);
                        break;
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

                lblCompleted.Text = dt.Rows.Count > 0
                ? dt.Rows[0]["TotalCompleted"].ToString()
                : "0";

                if (dt.Rows.Count == 0)
                {
                    gvEvaluation.Visible = false;
                    pnlEvalEmpty.Visible = true;
                }
                else
                {
                    gvEvaluation.Visible = true;
                    pnlEvalEmpty.Visible = false;
                    gvEvaluation.DataSource = dt;
                    gvEvaluation.DataBind();
                }
            }
        }

        private void ShowMessage(string text, bool isError)
        {
            lblMsg.ForeColor = isError
                ? System.Drawing.Color.Red
                : System.Drawing.Color.Green;
            lblMsg.Text = text;
        }

        protected string RenderStars(object ratingObj)
        {
            if (ratingObj == null || ratingObj == DBNull.Value)
                return "<span style='color:#94a3b8;'>—</span>";

            int rating = Convert.ToInt32(ratingObj);
            var sb = new StringBuilder("<span class='stars-display'>");

            for (int i = 1; i <= 5; i++)
            {
                if (i <= rating)
                    sb.Append("&#9733;");
                else
                    sb.Append("<span class='empty-star'>&#9733;</span>");
            }

            sb.Append("</span>");
            return sb.ToString();
        }

        protected string FormatDate(object dateObj)
        {
            if (dateObj == null || dateObj == DBNull.Value) return "—";
            return Convert.ToDateTime(dateObj).ToString("dd MMM yyyy");
        }
    }
}