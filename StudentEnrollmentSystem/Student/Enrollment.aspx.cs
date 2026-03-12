using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentEnrollmentSystem.Student
{
    public partial class Enrollment : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["DBConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StudentID"] == null || Session["Role"]?.ToString() != "Student")
            {
                Response.Redirect("~/Account/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                try
                {
                    lblStudentName.Text = Session["FullName"]?.ToString() ?? "Student";

                    LoadActiveSemester();
                    LoadCourses();
                    LoadMyCourses();
                    LoadTotalCredits();
                }
                catch (SqlException sqlEx)
                {
                    ShowError("Database error while loading page.");

                    System.Diagnostics.Debug.WriteLine(sqlEx.Message);
                }
                catch (Exception ex)
                {
                    ShowError("Unexpected system error occured.");

                    System.Diagnostics.Debug.WriteLine(ex.Message);
                }
            }
        }

        private void ShowError(string msg)
        {
            lblMessage.ForeColor = System.Drawing.Color.Red;
            lblMessage.Text = msg;
        }

        private void LoadActiveSemester()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("sp_GetActiveSemester", conn))
                {
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            lblSemester.Text = reader["SemesterName"] + " " + reader["AcademicYear"];

                            DateTime start = Convert.ToDateTime(reader["AddPeriodStart"]);
                            DateTime end = Convert.ToDateTime(reader["AddPeriodEnd"]);

                            lblAddPeriod.Text = start.ToShortDateString() + " - " + end.ToShortDateString();
                        }
                        else
                        {
                            lblSemester.Text = "No active semester";
                            lblAddPeriod.Text = "-";
                        }
                    }
                }
            }
            catch
            {
                ShowError("Failred to load semester inforamtion.");
            }
        }

        private void LoadCourses()
        {
            try
            {
                int studentID = Convert.ToInt32(Session["StudentID"]);

                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("sp_GetAvailableCourses", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvCourses.DataSource = dt;
                    gvCourses.DataBind();
                }
            }
            catch (Exception ex)
            {
                ShowError("Unable to load available courses.");

                System.Diagnostics.Debug.WriteLine(ex.Message);
            }
        }

        void LoadMyCourses()
        {
            int studentID = Convert.ToInt32(Session["StudentID"]);

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetStudentEnrollments", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvMyCourses.DataSource = dt;
                gvMyCourses.DataBind();
            }
        }

        private void LoadTotalCredits()
        {
            int studentID = Convert.ToInt32(Session["StudentID"]);

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetStudentCredits", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;

                conn.Open();

                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    int credits = reader["TotalCredits"] == DBNull.Value
                        ? 0
                        : Convert.ToInt32(reader["TotalCredits"]);

                    int maxCredit = reader["MaxCredits"] == DBNull.Value
                        ? 0
                        : Convert.ToInt32(reader["MaxCredits"]);

                    lblTotalCredits.Text = credits + " / " + maxCredit;

                    if (maxCredit > 0 && credits >= maxCredit)
                    {
                        lblTotalCredits.ForeColor = System.Drawing.Color.Red;
                    }
                }
            }
        }

        private int? GetActiveSemesterID()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetActiveSemester", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                conn.Open();

                object result = cmd.ExecuteScalar();

                if (result == null || result == DBNull.Value)
                    return null;

                return Convert.ToInt32(result);
            }
        }

        protected void gvCourses_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "Enroll") return;

            try
            {
                int offeringID = Convert.ToInt32(e.CommandArgument);
                int studentID = Convert.ToInt32(Session["StudentID"]);

                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("sp_EnrollCourse", conn))
                {
                    conn.Open();

                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                    cmd.Parameters.Add("@OfferingID", SqlDbType.Int).Value = offeringID;

                    object resultobj = cmd.ExecuteScalar();
                    string result = resultobj?.ToString() ?? "ERROR";

                    switch (result)
                    {
                        case "SUCCESS":
                            lblMessage.ForeColor = System.Drawing.Color.Green;
                            lblMessage.Text = "Course enrolled successfully.";
                            break;

                        case "FULL":
                            ShowError("Course is already full.");
                            break;

                        case "ALREADY_ENROLLED":
                            ShowError("You already enrolled in this course.");
                            break;

                        case "CREDIT_LIMIT":
                            ShowError("Credit limit exceeded.");
                            break;

                        case "ADD_CLOSED":
                            ShowError("Enrollment period is closed.");
                            break;

                        default:
                            ShowError("Enrollment failed.");
                            break;
                    }
                }

                LoadCourses();
                LoadMyCourses();
                LoadTotalCredits();
            }
            catch
            {
                ShowError("System error during enrollment.");
            }
        }

        protected void gvCourses_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                int seatsLeft = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "SeatsLeft"));
                Button btn = (Button)e.Row.FindControl("btnEnroll");

                if (seatsLeft <= 0)
                {
                    btn.Enabled = false;
                    btn.Text = "Full";
                }
            }
        }
    }
}