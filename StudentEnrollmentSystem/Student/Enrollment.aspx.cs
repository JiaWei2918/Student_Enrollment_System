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
            try
            {
                if (Session["StudentID"] == null || Session["Role"]?.ToString() != "Student")
                {
                    Response.Redirect("~/Account/Login.aspx");
                    return;
                }

                if (!IsPostBack)
                {
                    lblStudentName.Text = Session["FullName"]?.ToString() ?? "Student";

                    LoadActiveSemester();
                    LoadCourses();
                    LoadMyCourses();
                    LoadTotalCredits();
                }
            }
            catch (Exception ex)
            {
                lblMessage.ForeColor = System.Drawing.Color.Red;
                lblMessage.Text = "Page loading error.";
            }
        }

        private void LoadActiveSemester()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetActiveSemester", conn))
            {
                conn.Open();

                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    lblSemester.Text = reader["SemesterName"] + " " + reader["AcademicYear"];

                    DateTime start = Convert.ToDateTime(reader["AddPeriodStart"]);
                    DateTime end = Convert.ToDateTime(reader["AddPeriodEnd"]);

                    lblAddPeriod.Text = start.ToShortDateString() + " - " + end.ToShortDateString();
                }
            }
        }

        private void LoadCourses()
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
                    int credits = Convert.ToInt32(reader["TotalCredits"]);
                    int maxCredit = Convert.ToInt32(reader["MaxCredit"]);

                    lblTotalCredits.Text = credits + " / " + maxCredit;

                    if (credits >= maxCredit)
                    {
                        lblTotalCredits.ForeColor = System.Drawing.Color.Red;
                    }
                }
            }
        }

        protected void gvCourses_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "Enroll") return;

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
                        lblMessage.ForeColor = System.Drawing.Color.Red;
                        lblMessage.Text = "Course is already full.";
                        break;

                    case "ALREADY_ENROLLED":
                        lblMessage.ForeColor = System.Drawing.Color.Orange;
                        lblMessage.Text = "You already enrolled in this course.";
                        break;

                    case "CREDIT_LIMIT":
                        lblMessage.ForeColor = System.Drawing.Color.Red;
                        lblMessage.Text = "Credit limit exceeded (Max 18 credits).";
                        break;

                    case "ADD_CLOSED":
                        lblMessage.ForeColor= System.Drawing.Color.Orange;
                        lblMessage.Text = "Enrollment period is closed.";
                        break;

                    default:
                        lblMessage.ForeColor = System.Drawing.Color.Red;
                        lblMessage.Text = "Enrollment failed.";
                        break;
                }
            }

            LoadCourses();
            LoadMyCourses();
            LoadTotalCredits();
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