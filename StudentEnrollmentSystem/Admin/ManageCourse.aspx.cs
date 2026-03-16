using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

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
                return;
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
            using (SqlCommand cmd = new SqlCommand("sp_GetAllCourses", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                conn.Open();
                gvCourse.DataSource = cmd.ExecuteReader();
                gvCourse.DataBind();
            }
        }

        private void LoadPrerequisiteCourses(int? editingCourseID = null)
        {
            ddlPrerequisite.Items.Clear();
            ddlPrerequisite.Items.Add(new System.Web.UI.WebControls.ListItem("-- None --", ""));

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetCoursesForPrerequisite", conn))
            {
                cmd.CommandType= CommandType.StoredProcedure;

                if (editingCourseID == null)
                    cmd.Parameters.AddWithValue("@CourseID", DBNull.Value);
                else
                    cmd.Parameters.AddWithValue("@CourseID", editingCourseID);

                conn.Open();

                SqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    ddlPrerequisite.Items.Add(
                        new System.Web.UI.WebControls.ListItem(
                            reader["CourseName"].ToString(),
                            reader["CourseID"].ToString()
                        ));
                }
            }
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            lblMessage.Text = "";
            lblMessage.ForeColor = System.Drawing.Color.Red;

            if (!int.TryParse(txtCreditHours.Text, out int credit))
            {
                lblMessage.Text = "Credit hours must be numeric.";
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    SqlCommand cmd;

                    if (string.IsNullOrEmpty(hfCourseID.Value))
                        cmd = new SqlCommand("sp_AddCourse", conn);
                    else
                    {
                        cmd = new SqlCommand("sp_UpdateCourse", conn);
                        cmd.Parameters.Add("@CourseID", SqlDbType.Int).Value = hfCourseID.Value;
                    }

                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.Add("@CourseCode", SqlDbType.VarChar).Value = txtCourseCode.Text.Trim();
                    cmd.Parameters.Add("@CourseName", SqlDbType.VarChar).Value = txtCourseName.Text.Trim();
                    cmd.Parameters.Add("@Description", SqlDbType.VarChar).Value = txtDescription.Text.Trim();
                    cmd.Parameters.Add("@CreditHours", SqlDbType.Int).Value = credit;

                    if (string.IsNullOrEmpty(ddlPrerequisite.SelectedValue))
                        cmd.Parameters.Add("@PrerequisiteCourseID", SqlDbType.Int).Value = DBNull.Value;
                    else
                        cmd.Parameters.Add("@PrerequisiteCourseID", SqlDbType.Int).Value = ddlPrerequisite.SelectedValue;

                    conn.Open();
                    string result = cmd.ExecuteScalar().ToString();

                    if (result == "DUPLICATE")
                    {
                        lblMessage.Text = "Course Code already exists.";
                        return;
                    }

                    lblMessage.ForeColor = System.Drawing.Color.Green;
                    if (string.IsNullOrEmpty(hfCourseID.Value))
                        lblMessage.Text = "Course added successfully.";
                    else
                        lblMessage.Text = "Course updated successfully.";

                    ClearForm();
                    LoadCourses();
                    LoadPrerequisiteCourses();

                    //btnAdd.Text = "Add";
                }
            }
            catch
            {
                lblMessage.Text = "System error occurred.";
            }
        }

        protected void gvCourse_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
        {
            int courseID = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "DeleteCourse")
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("sp_DeleteCourse", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@CourseID", SqlDbType.Int).Value = courseID;

                    conn.Open();
                    string result = cmd.ExecuteScalar().ToString();

                    if (result == "USED_AS_PREREQUISITE")
                    {
                        lblMessage.ForeColor = System.Drawing.Color.Red;
                        lblMessage.Text = "Cannot delete. Course is used as prerequisite.";
                        return;
                    }
                    
                    if (result == "HAS_OFFERING")
                    {
                        lblMessage.ForeColor = System.Drawing.Color.Red;
                        lblMessage.Text = "Cannot delete. Course has offerings.";
                        return;
                    }

                    lblMessage.ForeColor = System.Drawing.Color.Green;
                    lblMessage.Text = "Deleted successfully.";
                }
                
                LoadCourses();
                LoadPrerequisiteCourses();
                ClearForm();
            }

            if (e.CommandName == "EditCourse")
            {
                LoadCourseForEdit(courseID);
            }
        }

        private void LoadCourseForEdit(int courseID)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("SELECT * FROM Course WHERE CourseID=@ID", conn))
            {
                cmd.Parameters.Add("@ID", SqlDbType.Int).Value = courseID;

                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    hfCourseID.Value = courseID.ToString();
                    txtCourseCode.Text = reader["CourseCode"].ToString();
                    txtCourseName.Text = reader["CourseName"].ToString();
                    txtDescription.Text = reader["Description"].ToString();
                    txtCreditHours.Text = reader["CreditHours"].ToString();

                    LoadPrerequisiteCourses(courseID);

                    if (reader["PrerequisiteCourseID"] != DBNull.Value)
                        ddlPrerequisite.SelectedValue = reader["PrerequisiteCourseID"].ToString();

                    btnAdd.Text = "Update Course";
                    btnCancel.Visible = true;
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