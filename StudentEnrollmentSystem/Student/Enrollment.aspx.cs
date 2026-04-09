using Microsoft.Ajax.Utilities;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentEnrollmentSystem.Student
{
    public partial class Enrollment : System.Web.UI.Page
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
                try
                {
                    lblStudentName.Text = Session["FullName"]?.ToString() ?? "Student";

                    LoadActiveSemester();
                    LoadCourses();
                    LoadMyCourses();
                    LoadTotalCredits();
                }
                catch (SqlException sqlEx)
                {
                    ShowMessage("Database error while loading page.", isError: true);

                    System.Diagnostics.Debug.WriteLine(sqlEx.Message);
                }
                catch (Exception ex)
                {
                    ShowMessage("Unexpected system error occurred.", isError: true);

                    System.Diagnostics.Debug.WriteLine(ex.Message);
                }
            }
        }

        private void ShowMessage(string msg, bool isError)
        {
            lblMessage.Text = msg;
            lblMessage.ForeColor = isError
               ? System.Drawing.Color.Red
               : System.Drawing.Color.Green;
        }

        private void LoadActiveSemester()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("sp_GetActiveSemester", conn))
                {
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            lblSemester.Text = reader["SemesterName"] + " " + reader["AcademicYear"];
                            DateTime start = Convert.ToDateTime(reader["AddPeriodStart"]);
                            DateTime end = Convert.ToDateTime(reader["AddPeriodEnd"]);
                            lblAddPeriod.Text = start.ToShortDateString() + " - " + end.ToShortDateString();
                        }
                        else
                        {
                            lblSemester.Text = "No active semester";
                            lblAddPeriod.Text = "-";
                        }
                    }
                }
            }
            catch
            {
                ShowMessage("Failred to load semester inforamtion.", isError: true);
            }
        }

        private void LoadCourses()
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

                    gvCourses.DataSource = dt;
                    gvCourses.DataBind();
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Unable to load available courses.", isError: true);

                System.Diagnostics.Debug.WriteLine(ex.Message);
            }
        }

        void LoadMyCourses()
        {
            int studentID = Convert.ToInt32(Session["StudentID"]);

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetStudentEnrollments", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                lblEnrolledCount.Text = dt.Rows.Count.ToString();

                gvMyCourses.DataSource = dt;
                gvMyCourses.DataBind();
            }
        }

        private void LoadTotalCredits()
        {
            int studentID = Convert.ToInt32(Session["StudentID"]);

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetStudentCredits", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;

                conn.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        int credits = reader["TotalCredits"] == DBNull.Value
                            ? 0
                            : Convert.ToInt32(reader["TotalCredits"]);

                        int maxCredit = reader["MaxCredits"] == DBNull.Value
                            ? 0
                            : Convert.ToInt32(reader["MaxCredits"]);

                        lblTotalCredits.Text = credits.ToString();
                        lblMaxCredits.Text = maxCredit.ToString();

                        if (maxCredit > 0 && credits >= maxCredit)
                        {
                            lblTotalCredits.ForeColor = System.Drawing.Color.FromArgb(185, 28, 28);
                        }
                    }
                }
            }
        }

        private int? GetActiveSemesterID()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetActiveSemester", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                conn.Open();

                object result = cmd.ExecuteScalar();

                if (result == null || result == DBNull.Value)
                    return null;

                return Convert.ToInt32(result);
            }
        }

        protected void chkSelectAll_CheckedChanged(object sender, EventArgs e)
        {
            foreach (GridViewRow row in gvCourses.Rows)
            {
                CheckBox chk = (CheckBox)row.FindControl("chkSelect");
                if(chk != null && chk.Enabled)
                    chk.Checked = ((CheckBox)sender).Checked;
            }
        }

        protected void btnEnrollSelected_Click(object sender, EventArgs e)
        {
            try
            {
                int studentID = Convert.ToInt32(Session["StudentID"]);
                List<int> selectedOfferings = new List<int>();

                foreach (GridViewRow row in gvCourses.Rows)
                {
                    CheckBox chk = (CheckBox)row.FindControl("chkSelect");
                    HiddenField hf = (HiddenField)row.FindControl("hfOfferingID");

                    if (chk != null && chk.Checked && hf != null)
                        selectedOfferings.Add(Convert.ToInt32(hf.Value));
                }

                if (selectedOfferings.Count == 0)
                {
                    ShowMessage("Please select at least one courses.", isError: true);
                    return;
                }

                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("sp_EnrollCoursesBatch", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                    cmd.Parameters.Add("@OfferingIDs", SqlDbType.VarChar).Value = string.Join(",", selectedOfferings);

                    conn.Open();

                    string result = cmd.ExecuteScalar()?.ToString();

                    switch (result)
                    {
                        case "SUCCESS":
                            ShowMessage("Enrollment successful! Your courses have been added.", isError: false);
                            break;

                        case "FULL":
                            ShowMessage("One or more courses are full.", isError: true);
                            break;

                        case "CREDIT_LIMIT":
                            ShowMessage("Credit limit exceeded.", isError: true);
                            break;

                        case "CLASH":
                            ShowMessage("Timetable clash detected.", isError: true);
                            break;

                        case "NO_NEW_COURSE":
                            ShowMessage("No new course enrolled.", isError: true);
                            break;

                        default:
                            ShowMessage("Enrollment failed.", isError: true);
                            break;
                    }
                }

                LoadCourses();
                LoadMyCourses();
                LoadTotalCredits();
            }
            catch
            {
                ShowMessage("System error during enrollment.", isError: true);
            }
        }

        protected void gvCourses_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                int seatsLeft = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "SeatsLeft"));
                CheckBox chk = (CheckBox)e.Row.FindControl("chkSelect");

                if (seatsLeft <= 0 && chk != null)
                {
                    chk.Enabled = false;
                    e.Row.CssClass += " row-full";
                }
            }
        }

        protected string GetSeatBarStyle(object pctObj)
        {
            double pct = pctObj == DBNull.Value ? 0 : Convert.ToDouble(pctObj);
            pct = Math.Max(0, Math.Min(100, pct));
            string color = pct > 40 ? "#10b981"   // green  — plenty
                         : pct > 15 ? "#f59e0b"   // amber  — limited
                         : "#ef4444";   // red    — almost full / full
            return $"width:{pct:0.#}%; background:{color};";
        }

        protected string GetSeatBadge(object statusObj)
        {
            switch (statusObj?.ToString())
            {
                case "full": return "<span class=\"badge badge-red\">Full</span>";
                case "limited": return "<span class=\"badge badge-amber\">Limited</span>";
                default: return "<span class=\"badge badge-green\">Available</span>";
            }
        }

        protected string GetStatusBadge(object statusObj)
        {
            string status = statusObj?.ToString() ?? "";
            switch (status.ToLower())
            {
                case "enrolled": return "<span class=\"badge badge-green\">Enrolled</span>";
                case "pending": return "<span class=\"badge badge-amber\">Pending</span>";
                case "dropped": return "<span class=\"badge badge-red\">Dropped</span>";
                case "completed": return "<span class=\"badge badge-blue\">Completed</span>";
                default: return $"<span class=\"badge badge-gray\">{status}</span>";
            }
        }
    }
}