using System;
using System.Collections.Generic;
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

        protected void btnAddSelected_Click(object sender, EventArgs e)
        {
            ProcessAction("ADD");
        }

        protected void btnDropSelected_Click(object sender, EventArgs e)
        {
            ProcessAction("DROP");
        }

        private void ProcessAction(string action)
        {
            int studentID = Convert.ToInt32(Session["StudentID"]);
            List<int> list = new List<int>();

            GridView gv = action == "ADD" ? gvAvailable : gvMyCourses;
            string chkName = action == "ADD" ? "chkAdd" : "chkDrop";

            foreach (GridViewRow row in gv.Rows)
            {
                CheckBox chk = (CheckBox)row.FindControl(chkName);
                HiddenField hf = (HiddenField)row.FindControl("hfOfferingID");

                if (chk != null && chk.Checked)
                    list.Add(Convert.ToInt32(hf.Value));
            }

            if (list.Count == 0)
            {
                ShowError("Please select at least one course.");
                return;
            }

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_AddDropBatch", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@StudentID", studentID);
                cmd.Parameters.AddWithValue("@OfferingIDs", string.Join(",", list));
                cmd.Parameters.AddWithValue("@Action", action);

                conn.Open();

                string result = cmd.ExecuteScalar()?.ToString();

                if (result == "SUCCESS")
                {
                    lblMessage.ForeColor = System.Drawing.Color.Green;
                    lblMessage.Text = action + " successful.";
                }
                else
                {
                    ShowError(result);
                }
            }

            LoadAvailableCourses();
            LoadMyCourses();
        }
    }
}