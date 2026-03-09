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
    public partial class AddDrop : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["DBConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StudentID"] == null || Session["Role"] == null)
            {
                Response.Redirect("~/Account/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadAvailableCourses();
                LoadMyCourses();
            }
        }

        private void LoadAvailableCourses()
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

                gvAvailable.DataSource = dt;
                gvAvailable.DataBind();
            }
        }

        private void LoadMyCourses()
        {
            int studentID = Convert.ToInt32(Session["StudentID"]);

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand("sp_GetMyCourses", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@StudentID", studentID);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();

                da.Fill(dt);

                gvMyCourses.DataSource = dt;
                gvMyCourses.DataBind();
            }
        }

        protected void gvAvailable_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
        {
            if (e.CommandName == "AddCourse")
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
                                lblMessage.Text = "Course added successfully.";
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
                                lblMessage.Text = "Credit limit exceeded (Maximum 18 credits).";
                                break;

                            default:
                                lblMessage.ForeColor = System.Drawing.Color.Red;
                                lblMessage.Text = "Operation failed.";
                                break;
                        }
                    }
                }

                LoadAvailableCourses();
                LoadMyCourses();
            }
        }

        protected void gvAvailable_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                int seatsLeft = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "SeatsLeft"));

                Button btn = (Button)e.Row.FindControl("btnAdd");

                if (seatsLeft <= 0)
                {
                    btn.Enabled = false;
                    btn.Text = "Full";
                }
            }
        }

        protected void gvMyCourses_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DropCourse")
            {
                int offeringID = Convert.ToInt32(e.CommandArgument);
                int studentID = Convert.ToInt32(Session["StudentID"]);

                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    SqlCommand cmd = new SqlCommand("sp_DropCourse", conn);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@StudentID", studentID);
                    cmd.Parameters.AddWithValue("@OfferingID", offeringID);

                    cmd.ExecuteNonQuery();
                }

                lblMessage.Text = "Course dropped successfully.";

                LoadAvailableCourses();
                LoadMyCourses();
            }
        }
    }
}