using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentEnrollmentSystem.Student
{
    public partial class AddDrop : System.Web.UI.Page
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
                LoadActiveSemester();
                LoadAvailableCourses();
                LoadMyCourses();
            }
        }

        private void ShowError(string message, Exception ex = null)
        {
            lblMessage.ForeColor = System.Drawing.Color.Red;
            lblMessage.Text = message;

            // Log error for debugging
            if (ex != null)
            {
                System.Diagnostics.Debug.WriteLine("ERROR: " + ex.Message);
            }
        }

        private void LoadActiveSemester()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("sp_GetActiveSemester", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    conn.Open();

                    SqlDataReader reader = cmd.ExecuteReader();

                    if (reader.Read())
                    {
                        lblSemester.Text = reader["SemesterName"].ToString() + " " +
                                           reader["AcademicYear"].ToString();

                        DateTime addStart = Convert.ToDateTime(reader["AddPeriodStart"]);
                        DateTime addEnd = Convert.ToDateTime(reader["AddPeriodEnd"]);
                        DateTime dropStart = Convert.ToDateTime(reader["DropPeriodStart"]);
                        DateTime dropEnd = Convert.ToDateTime(reader["DropPeriodEnd"]);

                        lblAddPeriod.Text = addStart.ToString("dd MMM yyyy") + " - " +
                                            addEnd.ToString("dd MMM yyyy");
                        lblDropPeriod.Text = dropStart.ToString("dd MMM yyyy") + " - " +
                                             dropEnd.ToString("dd MMM yyyy");
                    }
                    else
                    {
                        lblSemester.Text = "No active Semester available";
                        lblAddPeriod.Text = "";
                        lblDropPeriod.Text = "";
                    }
                }
            }
            catch (SqlException)
            {
                lblSemester.Text = "Unable to load semester.";
                lblAddPeriod.Text = "";
                lblDropPeriod.Text = "";
            }
            catch (Exception)
            {
                lblSemester.Text = "Unexpected system error.";
                lblAddPeriod.Text = "";
                lblDropPeriod.Text = "";
            }
        }

        private void LoadAvailableCourses()
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

                    gvAvailable.DataSource = dt;
                    gvAvailable.DataBind();
                }
            }
            catch (SqlException ex)
            {
                ShowError("Database error while loading courses.", ex);
            }
            catch (Exception ex)
            {
                ShowError("Unexpected system error while loading courses.", ex);
            }
        }

        private void LoadMyCourses()
        {
            try
            {
                int studentID = Convert.ToInt32(Session["StudentID"]);

                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("sp_GetMyCourses", conn))
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
            catch (SqlException ex)
            {
                ShowError("Database error while loading enrolled courses.", ex);
            }
            catch (Exception ex)
            {
                ShowError("Unexpected syste error while loading enrolled courses.", ex);
            }
        }

        protected void gvAvailable_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
        {
            if (e.CommandName != "AddCourse") return;

            try
            {
                int offeringID = Convert.ToInt32(e.CommandArgument);
                int studentID = Convert.ToInt32(Session["StudentID"]);

                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("sp_EnrollCourse", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                    cmd.Parameters.Add("@OfferingID", SqlDbType.Int).Value = offeringID;

                    conn.Open();

                    object resultObj = cmd.ExecuteScalar();
                    string result = resultObj?.ToString() ?? "ERROR";

                    switch (result)
                    {
                        case "SUCCESS":
                            lblMessage.ForeColor = System.Drawing.Color.Green;
                            lblMessage.Text = "Course added successfully.";
                            break;

                        case "FULL":
                            lblMessage.Text = "Course is full.";
                            break;

                        case "ALREADY_ENROLLED":
                            lblMessage.Text = "You already enrolled this course.";
                            break;

                        case "CREDIT_LIMIT":
                            lblMessage.Text = "Credit limit exceeded.";
                            break;

                        case "ADD_CLOSED":
                            lblMessage.Text = "Add period is closed.";
                            break;

                        default:
                            lblMessage.Text = "Enrollment failed.";
                            break;
                    }
                }

                LoadAvailableCourses();
                LoadMyCourses();
            }
            catch (SqlException ex)
            {
                ShowError("Database error while loading enrolled courses.", ex);
            }
            catch (Exception ex)
            {
                ShowError("Unexpected syste error while loading enrolled courses.", ex);
            }
        }

        protected void gvAvailable_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                object seatObj = DataBinder.Eval(e.Row.DataItem, "SeatsLeft");
                int seatsLeft = seatObj == DBNull.Value ? 0 : Convert.ToInt32(seatObj);

                Button btn = (Button)e.Row.FindControl("btnAdd");

                if (seatsLeft <= 0 && btn != null)
                {
                    btn.Enabled = false;
                    btn.Text = "Full";
                }
            }
        }

        protected void gvMyCourses_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "DropCourse") return;

            try
            {
                int offeringID = Convert.ToInt32(e.CommandArgument);
                int studentID = Convert.ToInt32(Session["StudentID"]);

                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("sp_DropCourse", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                    cmd.Parameters.Add("@OfferingID", SqlDbType.Int).Value = offeringID;

                    conn.Open();

                    object resultObj = cmd.ExecuteScalar();
                    string result = resultObj?.ToString();

                    if (result == "SUCCESS")
                    {
                        lblMessage.ForeColor = System.Drawing.Color.Green;
                        lblMessage.Text = "Course dropped successfully.";
                    }
                    else if (result == "DROP_CLOSED")
                    {
                        lblMessage.Text = "Drop period has ended.";
                    }
                    else
                    {
                        lblMessage.Text = "Unable to drop this course.";
                    }
                }

                LoadAvailableCourses();
                LoadMyCourses();
            }
            catch (SqlException ex)
            {
                ShowError("Database error while loading enrolled courses.", ex);
            }
            catch (Exception ex)
            {
                ShowError("Unexpected syste error while loading enrolled courses.", ex);
            }
        }
    }
}