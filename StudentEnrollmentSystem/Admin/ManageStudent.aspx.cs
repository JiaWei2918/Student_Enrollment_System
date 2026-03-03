using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentEnrollmentSystem.Admin
{
    public partial class ManageStudent : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["DBConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Role"] == null || Session["Role"].ToString() != "Admin")
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
                cmd.Parameters.AddWithValue("@EnrollmentDate", Convert.ToDateTime(txtEnrollmentDate.Text));
                cmd.Parameters.AddWithValue("@PasswordHash", hashedPassword);

                conn.Open();
                object obj = cmd.ExecuteScalar();
                string result = obj == null ? "ERROR" : obj.ToString();

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
                    ((TextBox)row.Cells[1].Controls[0]).Text);
                cmd.Parameters.AddWithValue("@Email",
                    ((TextBox)row.Cells[2].Controls[0]).Text);
                cmd.Parameters.AddWithValue("@Program",
                    ((TextBox)row.Cells[3].Controls[0]).Text);
                cmd.Parameters.AddWithValue("@Section",
                    ((TextBox)row.Cells[4].Controls[0]).Text);
                cmd.Parameters.AddWithValue("@Phone", "");
                cmd.Parameters.AddWithValue("@Status",
                    ((TextBox)row.Cells[5].Controls[0]).Text);

                conn.Open();
                object obj = cmd.ExecuteScalar();
                string result = obj == null ? "ERROR" : obj.ToString();

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
                object obj = cmd.ExecuteScalar();
                string result = obj == null ? "ERROR" : obj.ToString();

                if (result == "HAS_ENROLLMENTS")
                {
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