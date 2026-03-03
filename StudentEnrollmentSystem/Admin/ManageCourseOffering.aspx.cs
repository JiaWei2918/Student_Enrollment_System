using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentEnrollmentSystem.Admin
{
    public partial class ManageCourseOffering : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["DBConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Role"] == null || Session["Role"].ToString() != "Admin")
                Response.Redirect("~/Account/Login.aspx");

            if (!IsPostBack)
            {
                LoadCourses();
                LoadSemesters();
                LoadOfferings();
            }
        }

        private void LoadCourses()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("SELECT CourseID, CourseCode FROM Course", conn))
            {
                conn.Open();
                ddlCourse.DataSource = cmd.ExecuteReader();
                ddlCourse.DataTextField = "CourseCode";
                ddlCourse.DataValueField = "CourseID";
                ddlCourse.DataBind();
            }
        }

        private void LoadSemesters()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("SELECT SemesterID, SemesterName FROM Semester WHERE Status <> 'Closed'", conn))
            {
                conn.Open();
                ddlSemester.DataSource = cmd.ExecuteReader();
                ddlSemester.DataTextField = "SemesterName";
                ddlSemester.DataValueField = "SemesterID";
                ddlSemester.DataBind();
            }
        }

        private void LoadOfferings()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetAllCourseOfferings", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                conn.Open();
                gvOffering.DataSource = cmd.ExecuteReader();
                gvOffering.DataBind();
            }
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_AddCourseOffering", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@CourseID", ddlCourse.SelectedValue);
                cmd.Parameters.AddWithValue("@SemesterID", ddlSemester.SelectedValue);
                cmd.Parameters.AddWithValue("@Lecturer", txtLecturer.Text.Trim());
                cmd.Parameters.AddWithValue("@Capacity", Convert.ToInt32(txtCapacity.Text));

                conn.Open();
                string result = cmd.ExecuteScalar().ToString();

                if (result == "DUPLICATE")
                    lblMessage.Text = "Offering already exists.";
                else if (result == "SEMESTER_CLOSED")
                    lblMessage.Text = "Cannot add offering. Semester is closed.";
                else
                {
                    lblMessage.ForeColor = System.Drawing.Color.Green;
                    lblMessage.Text = "Offering added successfully.";

                    txtLecturer.Text = "";
                    txtCapacity.Text = "";
                    ddlCourse.SelectedIndex = 0;
                    ddlSemester.SelectedIndex = 0;
                }
            }

            LoadOfferings();
        }

        protected void gvOffering_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvOffering.EditIndex = e.NewEditIndex;
            LoadOfferings();
        }

        protected void gvOffering_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvOffering.EditIndex = -1;
            LoadOfferings();
        }

        protected void gvOffering_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            int id = Convert.ToInt32(gvOffering.DataKeys[e.RowIndex].Value);
            GridViewRow row = gvOffering.Rows[e.RowIndex];

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_UpdateCourseOffering", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@OfferingID", id);
                cmd.Parameters.AddWithValue("@Lecturer", ((TextBox)row.FindControl("txtEditLecturer")).Text);
                cmd.Parameters.AddWithValue("@Capacity", Convert.ToInt32(((TextBox)row.FindControl("txtEditCapacity")).Text));

                conn.Open();
                cmd.ExecuteScalar();
            }

            gvOffering.EditIndex = -1;
            LoadOfferings();
        }

        protected void gvOffering_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int id = Convert.ToInt32(gvOffering.DataKeys[e.RowIndex].Value);

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_DeleteCourseOffering", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@OfferingID", id);

                conn.Open();
                cmd.ExecuteScalar();
            }

            LoadOfferings();
        }
    }
}