using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
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
                if (Session["StudentID"] == null || Session["Role"] == null || Session["Role"].ToString() != "Student")
                {
                    Response.Redirect("~/Account/Login.aspx");
                    return;
                }

                if (!IsPostBack)
                {
                    if (Session["FullName"] != null)
                    {
                        lblStudentName.Text = Session["FullName"].ToString();
                    }
                    else
                    {
                        lblStudentName.Text = "Student";
                    }
                    LoadCourses();
                    LoadMyCourses();
                }
            }
            catch (Exception ex)
            {
                lblMessage.ForeColor = System.Drawing.Color.Red;
                lblMessage.Text = "Page loading error.";

                System.Diagnostics.Debug.WriteLine(ex.Message);
            }
        }

        private void LoadCourses()
        {
            int studentID = Convert.ToInt32(Session["StudentID"]);

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand("sp_GetAvailableCourses", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@StudentID", studentID);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();

                da.Fill(dt);

                gvCourses.DataSource = dt;
                gvCourses.DataBind();
            }
        }

        void LoadMyCourses()
        {
            try
            {
                int studentID = Convert.ToInt32(Session["StudentID"]);

                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    SqlCommand cmd = new SqlCommand("sp_GetStudentEnrollments", conn);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@StudentID", studentID);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvMyCourses.DataSource = dt;
                    gvMyCourses.DataBind();
                }
            }
            catch (Exception ex)
            {
                lblMessage.ForeColor = System.Drawing.Color.Red;
                lblMessage.Text = "Error loading enrolled courses: " + ex.Message;
            }
        }

        protected void gvCourses_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Enroll")
            {
                try
                {
                    int offeringID = Convert.ToInt32(e.CommandArgument);
                    int studentID = Convert.ToInt32(Session["StudentID"]);

                    using (SqlConnection conn = new SqlConnection(connStr))
                    {
                        conn.Open();

                        SqlCommand cmd = new SqlCommand("sp_EnrollCourse", conn);
                        cmd.CommandType = CommandType.StoredProcedure;

                        cmd.Parameters.AddWithValue("@StudentID", studentID);
                        cmd.Parameters.AddWithValue("@OfferingID", offeringID);

                        SqlDataReader reader = cmd.ExecuteReader();

                        if (reader.Read())
                        {
                            string result = reader["Result"].ToString();

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
                                    lblMessage.Text = "You already enrolled this course.";
                                    break;

                                case "CREDIT_LIMIT":
                                    lblMessage.ForeColor = System.Drawing.Color.Red;
                                    lblMessage.Text = "Credit limit exceeded (Max 18 credits).";
                                    break;

                                case "ERROR":
                                    lblMessage.ForeColor = System.Drawing.Color.Red;
                                    lblMessage.Text = "System error occurred. Please try again.";
                                    break;
                            }
                        }
                    }

                    LoadCourses();
                    LoadMyCourses();
                }
                catch (Exception ex)
                { 
                    lblMessage.ForeColor = System.Drawing.Color.Red;
                    lblMessage.Text = "Unexpected error occurred.";

                    System.Diagnostics.Debug.WriteLine(ex.Message);
                }
            }
        }

        protected void gvCourses_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                object seatsObj = DataBinder.Eval(e.Row.DataItem, "SeatsLeft");

                if (seatsObj != DBNull.Value)
                {
                    int seatsLeft = Convert.ToInt32(seatsObj);

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
}