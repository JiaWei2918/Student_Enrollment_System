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
    public partial class ManageSemester : System.Web.UI.Page
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
                LoadSemesters();
            }
        }

        private void LoadSemesters()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetAllSemesters", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                conn.Open();
                gvSemester.DataSource = cmd.ExecuteReader();
                gvSemester.DataBind();
            }
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            lblMessage.Text = "";
            lblMessage.ForeColor = System.Drawing.Color.Red;

            Debug.WriteLine("=== ADD SEMESTER START ===");

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_AddSemester", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@SemesterName", txtSemesterName.Text);
                cmd.Parameters.AddWithValue("@AcademicYear", Convert.ToInt32(txtAcademicYear.Text));
                cmd.Parameters.AddWithValue("@StartDate", Convert.ToDateTime(txtStartDate.Text));
                cmd.Parameters.AddWithValue("@EndDate", Convert.ToDateTime(txtEndDate.Text));

                cmd.Parameters.AddWithValue("@AddPeriodStart",
                    string.IsNullOrEmpty(txtAddStart.Text) ? (object)DBNull.Value : Convert.ToDateTime(txtAddStart.Text));

                cmd.Parameters.AddWithValue("@AddPeriodEnd",
                    string.IsNullOrEmpty(txtAddEnd.Text) ? (object)DBNull.Value : Convert.ToDateTime(txtAddEnd.Text));

                cmd.Parameters.AddWithValue("@DropPeriodStart",
                    string.IsNullOrEmpty(txtDropStart.Text) ? (object)DBNull.Value : Convert.ToDateTime(txtDropStart.Text));

                cmd.Parameters.AddWithValue("@DropPeriodEnd",
                    string.IsNullOrEmpty(txtDropEnd.Text) ? (object)DBNull.Value : Convert.ToDateTime(txtDropEnd.Text));

                cmd.Parameters.AddWithValue("@Status", ddlStatus.SelectedValue);
                cmd.Parameters.AddWithValue("@MaxCredits", Convert.ToInt32(txtMaxCredits.Text));

                conn.Open();
                object obj = cmd.ExecuteScalar();
                string result = obj == null ? "ERROR" : obj.ToString();

                HandleResult(result);
            }
            LoadSemesters();
        }

        protected void gvSemester_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int id = Convert.ToInt32(gvSemester.DataKeys[e.RowIndex].Value);

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_DeleteSemester", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@SemesterID", id);

                conn.Open();
                object obj = cmd.ExecuteScalar();
                string result = obj == null ? "ERROR" : obj.ToString();

                if (result == "HAS_OFFERINGS")
                {
                    lblMessage.ForeColor = System.Drawing.Color.Red;
                    lblMessage.Text = "Cannot delete. Semester has course offerings.";
                    return;
                }
                else
                {
                    lblMessage.ForeColor = System.Drawing.Color.Green;
                    lblMessage.Text = "Semester deleted successfully.";
                }
            }
            LoadSemesters();
        }

        protected void gvSemester_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvSemester.EditIndex = e.NewEditIndex;
            LoadSemesters();
        }

        protected void gvSemester_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvSemester.EditIndex = -1;
            LoadSemesters();
        }

        protected void gvSemester_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            int id = Convert.ToInt32(gvSemester.DataKeys[e.RowIndex].Value);
            GridViewRow row = gvSemester.Rows[e.RowIndex];

            lblMessage.Text = "";
            lblMessage.ForeColor = System.Drawing.Color.Red;

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_UpdateSemester", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@SemesterID", id);
                cmd.Parameters.AddWithValue("@SemesterName", ((TextBox)row.FindControl("txtEditSemesterName")).Text);
                cmd.Parameters.AddWithValue("@AcademicYear", Convert.ToInt32(((TextBox)row.FindControl("txtEditAcademicYear")).Text));
                cmd.Parameters.AddWithValue("@StartDate", Convert.ToDateTime(((TextBox)row.FindControl("txtEditStartDate")).Text));
                cmd.Parameters.AddWithValue("@EndDate", Convert.ToDateTime(((TextBox)row.FindControl("txtEditEndDate")).Text));

                cmd.Parameters.AddWithValue("@AddPeriodStart",
                    string.IsNullOrEmpty(((TextBox)row.FindControl("txtEditAddStart")).Text)
                    ? (object)DBNull.Value
                    : Convert.ToDateTime(((TextBox)row.FindControl("txtEditAddStart")).Text));

                cmd.Parameters.AddWithValue("@AddPeriodEnd",
                    string.IsNullOrEmpty(((TextBox)row.FindControl("txtEditAddEnd")).Text)
                    ? (object)DBNull.Value
                    : Convert.ToDateTime(((TextBox)row.FindControl("txtEditAddEnd")).Text));

                cmd.Parameters.AddWithValue("@DropPeriodStart",
                    string.IsNullOrEmpty(((TextBox)row.FindControl("txtEditDropStart")).Text)
                    ? (object)DBNull.Value
                    : Convert.ToDateTime(((TextBox)row.FindControl("txtEditDropStart")).Text));

                cmd.Parameters.AddWithValue("@DropPeriodEnd",
                    string.IsNullOrEmpty(((TextBox)row.FindControl("txtEditDropEnd")).Text)
                    ? (object)DBNull.Value
                    : Convert.ToDateTime(((TextBox)row.FindControl("txtEditDropEnd")).Text));

                cmd.Parameters.AddWithValue("@Status", ((DropDownList)row.FindControl("ddlEditStatus")).SelectedValue);
                cmd.Parameters.AddWithValue("@MaxCredits", Convert.ToInt32(((TextBox)row.FindControl("txtEditMaxCredits")).Text));

                conn.Open();
                object obj = cmd.ExecuteScalar();
                string result = obj == null ? "ERROR" : obj.ToString();

                if (result != "SUCCESS")
                {
                    HandleResult(result);
                    return;
                }
            }
            gvSemester.EditIndex = -1;
            lblMessage.ForeColor = System.Drawing.Color.Green;
            lblMessage.Text = "Semester updated successfully.";

            LoadSemesters();
        }

        private void HandleResult(string result)
        {
            switch (result)
            {
                case "SUCCESS":
                    lblMessage.ForeColor = System.Drawing.Color.Green;
                    lblMessage.Text = "Semester saved successfully.";
                    break;

                case "DUPLICATE":
                    lblMessage.Text = "Duplicate semester for that year.";
                    break;

                case "INVALID_YEAR":
                    lblMessage.Text = "Dates must match Academic Year.";
                    break;

                case "INVALID_SEMESTER_RANGE":
                    lblMessage.Text = "End date must be after start date.";
                    break;

                case "ADD_TOO_EARLY":
                    lblMessage.Text = "Add period can only start up to 7 days before semester.";
                    break;

                case "ADD_TOO_LATE":
                    lblMessage.Text = "Add period cannot exceed 2 weeks after semester start.";
                    break;

                case "DROP_BEFORE_SEMESTER":
                    lblMessage.Text = "Drop period cannot start before semester.";
                    break;

                case "DROP_TOO_LATE":
                    lblMessage.Text = "Drop period must be within 2 weeks of semester start.";
                    break;

                case "INVALID_ADD_PERIOD":
                    lblMessage.Text = "Invalid Add period range.";
                    break;

                case "INVALID_DROP_PERIOD":
                    lblMessage.Text = "Invalid Drop period range.";
                    break;

                default:
                    lblMessage.Text = "Unexpected system error.";
                    break;
            }
        }
    }
}