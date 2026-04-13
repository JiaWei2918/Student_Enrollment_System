using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentEnrollmentSystem.Admin
{
    public partial class ManageStudent : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["DBConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["AdminID"] == null || Session["Role"]?.ToString() != "Admin")
                Response.Redirect("~/Account/Login.aspx");

            if (!IsPostBack)
                LoadStudents();
        }

        private void LoadStudents()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetAllStudents", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                conn.Open();
                gvStudent.DataSource = cmd.ExecuteReader();
                gvStudent.DataBind();
            }
        }

        private string HashPassword(string password)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));

                StringBuilder builder = new StringBuilder();
                foreach (byte b in bytes)
                    builder.Append(b.ToString("x2"));

                return builder.ToString();
            }
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            lblMessage.Text = "";
            lblMessage.ForeColor = System.Drawing.Color.Red;

            string matricNo = txtMatricNo.Text.Trim();
            string hashedPassword = HashPassword(matricNo);

            if (!DateTime.TryParse(txtEnrollmentDate.Text, out DateTime enrollDate))
            {
                lblMessage.Text = "Invalid enrollment date.";
                return;
            }

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_AddStudent", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@MatricNo", matricNo);
                cmd.Parameters.AddWithValue("@FullName", txtFullName.Text.Trim());
                cmd.Parameters.AddWithValue("@Email", txtEmail.Text.Trim());
                cmd.Parameters.AddWithValue("@Phone", txtPhone.Text.Trim());
                cmd.Parameters.AddWithValue("@Program", txtProgram.Text.Trim());
                cmd.Parameters.AddWithValue("@Section", txtSection.Text.Trim());
                cmd.Parameters.AddWithValue("@EnrollmentDate", enrollDate);
                cmd.Parameters.AddWithValue("@PasswordHash", hashedPassword);

                conn.Open();
                string result = cmd.ExecuteScalar()?.ToString();

                HandleResult(result);
            }

            LoadStudents();
        }

        protected void gvStudent_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvStudent.EditIndex = e.NewEditIndex;
            LoadStudents();
        }

        protected void gvStudent_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvStudent.EditIndex = -1;
            LoadStudents();
        }

        protected void gvStudent_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            int id = Convert.ToInt32(gvStudent.DataKeys[e.RowIndex].Value);
            GridViewRow row = gvStudent.Rows[e.RowIndex];

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_UpdateStudent", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@StudentID", id);
                cmd.Parameters.AddWithValue("@FullName",
                    ((TextBox)row.FindControl("txtEditFullName")).Text);
                cmd.Parameters.AddWithValue("@Email",
                    ((TextBox)row.FindControl("txtEditEmail")).Text);
                cmd.Parameters.AddWithValue("@Phone",
                    ((TextBox)row.FindControl("txtEditPhone")).Text);
                cmd.Parameters.AddWithValue("@Program",
                    ((TextBox)row.FindControl("txtEditProgram")).Text);
                cmd.Parameters.AddWithValue("@Section",
                    ((TextBox)row.FindControl("txtEditSection")).Text);
                cmd.Parameters.AddWithValue("@Status",
                    ((DropDownList)row.FindControl("ddlEditStatus")).SelectedValue);

                conn.Open();
                string result = cmd.ExecuteScalar()?.ToString();

                if (result != "SUCCESS")
                {
                    HandleResult(result);
                    return;
                }
            }

            gvStudent.EditIndex = -1;
            lblMessage.ForeColor = System.Drawing.Color.Green;
            lblMessage.Text = "Student updated successfully.";

            LoadStudents();
        }

        protected void gvStudent_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int id = Convert.ToInt32(gvStudent.DataKeys[e.RowIndex].Value);

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_DeleteStudent", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@StudentID", id);

                conn.Open();
                string result = cmd.ExecuteScalar()?.ToString();

                if (result == "HAS_ENROLLMENTS")
                {
                    lblMessage.ForeColor = System.Drawing.Color.Red;
                    lblMessage.Text = "Cannot delete student. Student has enrollments.";
                    return;
                }
            }

            lblMessage.ForeColor = System.Drawing.Color.Green;
            lblMessage.Text = "Student deleted successfully.";

            LoadStudents();
        }

        private void HandleResult(string result)
        {
            switch (result)
            {
                case "SUCCESS":
                    lblMessage.ForeColor = System.Drawing.Color.Green;
                    lblMessage.Text = "Student added successfully.";
                    ClearForm();
                    break;

                case "DUPLICATE_MATRIC":
                    lblMessage.Text = "Matric number already exists.";
                    break;

                case "DUPLICATE_EMAIL":
                    lblMessage.Text = "Email already exists.";
                    break;

                case "DUPLICATE_USERNAME":
                    lblMessage.Text = "Username already exists.";
                    break;

                default:
                    lblMessage.Text = "Unexpected system error.";
                    break;
            }
        }

        private void ClearForm()
        {
            txtMatricNo.Text = "";
            txtFullName.Text = "";
            txtEmail.Text = "";
            txtPhone.Text = "";
            txtProgram.Text = "";
            txtSection.Text = "";
            txtEnrollmentDate.Text = "";
        }
    }
}