using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentEnrollmentSystem.Admin
{
    public partial class ManageCourse : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["DBConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Role"] == null || Session["Role"].ToString() != "Admin")
            {
                Response.Redirect("~/Account/Login.aspx");
            }

            if (!IsPostBack)
            {
                btnCancel.Visible = false;
                LoadCourses();
                LoadPrerequisiteCourses();
            }
        }

        private void LoadCourses()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                using (SqlCommand cmd = new SqlCommand("sp_GetAllCourses", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    conn.Open();
                    gvCourse.DataSource = cmd.ExecuteReader();
                    gvCourse.DataBind();
                }
            }
        }

        private void LoadPrerequisiteCourses()
        {
            ddlPrerequisite.Items.Clear();
            ddlPrerequisite.Items.Add(new ListItem("-- None --", ""));

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand("SELECT CourseID, CourseName FROM Course ORDER BY CourseName", conn);
                conn.Open();

                SqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    ddlPrerequisite.Items.Add(new ListItem(
                        reader["CourseName"].ToString(),
                        reader["CourseID"].ToString()
                    ));
                }
            }
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            Debug.WriteLine("=== ADD COURSE START ===");

            try
            {
               if (string.IsNullOrWhiteSpace(txtCourseCode.Text) || string.IsNullOrWhiteSpace(txtCourseName.Text) ||
                   string.IsNullOrWhiteSpace(txtCreditHours.Text))
                {
                    lblMessage.Text = "All required fields must be filled.";
                    return;
                }

                if (!int.TryParse(txtCreditHours.Text, out int credit))
                {
                    lblMessage.Text = "Credit hours must be numeric.";
                    return;
                }

                if (!string.IsNullOrEmpty(hfCourseID.Value) && hfCourseID.Value == ddlPrerequisite.SelectedValue)
                {
                    lblMessage.Text = "Course cannot be its own prerequisite.";
                    return;
                }

                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    SqlCommand cmd;

                    if (string.IsNullOrEmpty(hfCourseID.Value))
                    {
                        cmd = new SqlCommand("sp_AddCourse", conn);
                    }
                    else
                    {
                        cmd = new SqlCommand("sp_UpdateCourse", conn);
                        cmd.Parameters.AddWithValue("@CourseID", hfCourseID.Value);
                    }

                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@CourseCode", txtCourseCode.Text.Trim());
                    cmd.Parameters.AddWithValue("@CourseName", txtCourseName.Text.Trim());
                    cmd.Parameters.AddWithValue("@Description", txtDescription.Text.Trim());
                    cmd.Parameters.AddWithValue("@CreditHours", credit);
                    if (string.IsNullOrEmpty(ddlPrerequisite.SelectedValue))
                        cmd.Parameters.AddWithValue("@PrerequisiteCourseID", DBNull.Value);
                    else
                        cmd.Parameters.AddWithValue("@PrerequisiteCourseID", ddlPrerequisite.SelectedValue);

                    conn.Open();
                    string result = cmd.ExecuteScalar().ToString();

                    if (result == "DUPLICATE")
                    {
                        lblMessage.Text = "Course Code already exists.";
                    }
                    else
                    {
                        lblMessage.ForeColor = System.Drawing.Color.Green;
                        lblMessage.Text = "Course Added successfully.";

                        ClearForm();
                        LoadCourses();
                        LoadPrerequisiteCourses();

                        btnAdd.Text = "Add";
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine(ex.Message);
                lblMessage.Text = "Error adding course.";
            }

            Debug.WriteLine("=== ADD COURSE END ===");
        }

        protected void gvCourse_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int courseID = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "DeleteCourse")
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    SqlCommand cmd = new SqlCommand("sp_DeleteCourse", conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@CourseID", courseID);

                    conn.Open();
                    string result = cmd.ExecuteScalar().ToString();

                    if (result == "USED_AS_PREREQUISITE")
                    {
                        lblMessage.ForeColor = System.Drawing.Color.Red;
                        lblMessage.Text = "Cannot delete. This course is used as a prerequisite.";
                        return;
                    }
                    /*else if (result == "HAS_OFFERING")
                    {
                        lblMessage.ForeColor = System.Drawing.Color.Red;
                        lblMessage.Text = "Cannot delete. Course has active offerings.";
                        return;
                    }*/
                }
                lblMessage.ForeColor = System.Drawing.Color.Green;
                lblMessage.Text = "Deleted successfully.";

                LoadCourses();
                LoadPrerequisiteCourses();
                ClearForm();
            }

            if (e.CommandName == "EditCourse")
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    SqlCommand cmd = new SqlCommand("SELECT * FROM Course WHERE CourseID=@ID", conn);
                    cmd.Parameters.AddWithValue("@ID", courseID);

                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();

                    if (reader.Read())
                    {
                        hfCourseID.Value = courseID.ToString();
                        txtCourseCode.Text = reader["CourseCode"].ToString();
                        txtCourseName.Text = reader["CourseName"].ToString();
                        txtDescription.Text = reader["Description"].ToString();
                        txtCreditHours.Text = reader["CreditHours"].ToString();

                        if (reader["PrerequisiteCourseID"] != DBNull.Value)
                            ddlPrerequisite.SelectedValue = reader["PrerequisiteCourseID"].ToString();
                        else
                            ddlPrerequisite.SelectedIndex = 0;

                        btnAdd.Text = "Update Course";
                        btnCancel.Visible = true;
                    }
                }
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            ClearForm();
            lblMessage.Text = "";
        }

        private void ClearForm()
        {
            hfCourseID.Value = "";
            txtCourseCode.Text = "";
            txtCourseName.Text = "";
            txtDescription.Text = "";
            txtCreditHours.Text = "";
            ddlPrerequisite.SelectedIndex = 0;

            btnAdd.Text = "Add Course";
            btnCancel.Visible = false;
        }
    }
}