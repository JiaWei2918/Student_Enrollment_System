using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
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
            using (SqlCommand cmd = new SqlCommand(
                @"SELECT SemesterID, 
                  RTRIM(SemesterName) + ' ' + RTRIM(AcademicYear) AS SemesterLabel
                  FROM Semester
                  ORDER BY SemesterID DESC", conn))
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

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("SELECT TOP 1 SemesterID FROM Semester WHERE Status='Active'", conn))
            {
                conn.Open();
                object id = cmd.ExecuteScalar();

                if (id != null)
                    ddlSemester.SelectedValue = id.ToString();
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            lblMsg.Text = "";

            if (!int.TryParse(Session["StudentID"]?.ToString(), out int studentID))
            {
                ShowMessage("Session expired. Please log in again.", isError: true);
                return;
            }

            if (!int.TryParse(ddlSemester.SelectedValue, out int semesterID))
            {
                ShowMessage("Please select a valid semester.", isError: true);
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
                pnlDefault.Visible = false;

                if (dt.Rows.Count == 0)
                {
                    pnlNoClash.Visible = false;
                    pnlNoResult.Visible = true;
                    pnlResults.Visible = false;
                }
                else
                {
                    int total = Convert.ToInt32(dt.Rows[0]["TotalAvailable"]);

                    pnlNoClash.Visible = true;
                    pnlNoResult.Visible = false;
                    pnlResults.Visible = true;

                    lblResultCount.Text = $"({total} course{(total == 1 ? "" : "s")} found)";

                    gvCourses.DataSource = dt;
                    gvCourses.DataBind();
                }
            }
        }

        protected void gvCourses_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "Enroll") return;

            int index = Convert.ToInt32(e.CommandArgument);
            int offeringID = Convert.ToInt32(gvCourses.DataKeys[index].Value);
            int studentID = Convert.ToInt32(Session["StudentID"]);

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("sp_EnrollCourse", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@StudentID", studentID);
                    cmd.Parameters.AddWithValue("@OfferingID", offeringID);

                    conn.Open();
                    string result = cmd.ExecuteScalar()?.ToString();

                    switch (result)
                    {
                        case "SUCCESS":
                            ShowMessage("Enrolled successfully! The course has been added to your schedule.", isError: false);
                            break;
                        case "FULL":
                            ShowMessage("This course is now full. Please choose another.", isError: true);
                            break;
                        case "CLASH":
                            ShowMessage("A schedule clash was detected. Please refresh and try again.", isError: true);
                            break;
                        case "CREDIT_LIMIT":
                            ShowMessage("Credit limit exceeded. You cannot enroll in more courses.", isError: true);
                            break;
                        default:
                            ShowMessage("Enrollment failed. Please try again.", isError: true);
                            break;
                    }
                }

                btnSearch_Click(null, null);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex.Message);
                ShowMessage("System error during enrollment.", isError: true);
            }
        }

        private void ShowMessage(string text, bool isError)
        {
            lblMsg.ForeColor = isError
                ? System.Drawing.Color.Red
                : System.Drawing.Color.Green;
            lblMsg.Text = text;
        }

        protected string FormatSchedule(string schedule)
        {
            if (string.IsNullOrWhiteSpace(schedule)) return "—";

            var sb = new StringBuilder();

            string[] slots = schedule.Split(new[] { ", " }, StringSplitOptions.RemoveEmptyEntries);

            foreach (string slot in slots)
            {
                sb.AppendFormat(
                    "<span class='schedule-slot'><i class='fa fa-clock-o'></i>{0}</span>",
                    slot.Trim()
                );
            }

            return sb.ToString();
        }
    }
}