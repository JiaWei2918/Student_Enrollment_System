using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace StudentEnrollmentSystem.Student
{
    public partial class Enrollment : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["DBConnection"].ConnectionString;

        public enum EnrollState { NotYetOpen, Open, Closed, NoSemester }

        private EnrollState CurrentState
        {
            get
            {
                if (ViewState["EnrollState"] == null) return EnrollState.NoSemester;
                return (EnrollState)Enum.Parse(typeof(EnrollState),
                    ViewState["EnrollState"].ToString());
            }
            set { ViewState["EnrollState"] = value.ToString(); }
        }

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
                }
                catch (Exception ex)
                {
                    ShowMessage("Unexpected system error occurred.", isError: true);
                }
            }
        }

        private void ShowMessage(string msg, bool isError)
        {
            lblMessage.Text = msg;
            lblMessage.ForeColor = isError
               ? System.Drawing.Color.FromArgb(185, 28, 28)
               : System.Drawing.Color.FromArgb(21, 128, 61);
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

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            lblSemester.Text = reader["SemesterName"] + " " + reader["AcademicYear"];
                            DateTime start = Convert.ToDateTime(reader["AddPeriodStart"]);
                            DateTime end = Convert.ToDateTime(reader["AddPeriodEnd"]);
                            lblAddPeriod.Text = start.ToString("dd MMM yyyy") + " – " + end.ToString("dd MMM yyyy");

                            DateTime today = DateTime.Today;

                            if (today < start)
                                SetEnrollmentState(EnrollState.NotYetOpen, start, end);
                            else if (today <= end)
                                SetEnrollmentState(EnrollState.Open, start, end);
                            else
                                SetEnrollmentState(EnrollState.Closed, start, end);
                        }
                        else
                        {
                            lblSemester.Text = "No active semester";
                            lblAddPeriod.Text = "-";
                            SetEnrollmentState(EnrollState.NoSemester, DateTime.MinValue, DateTime.MinValue);
                        }
                    }
                }
            }
            catch
            {
                ShowMessage("Failred to load semester inforamtion.", isError: true);
            }
        }

        private void SetEnrollmentState(EnrollState state, DateTime start, DateTime end)
        {
            CurrentState = state;

            switch (state)
            {
                case EnrollState.NotYetOpen:
                    ShowNotice(
                        cssClass: "enroll-notice notice-amber",
                        iconClass: "fa-clock-o",
                        title: "Enrollment Not Yet Open",
                        body: $"The enrollment period opens on <strong>{start:dd MMM yyyy}</strong>. " +
                                    $"You can browse available courses but cannot enroll until the period begins.",
                        disableEnroll: true
                    );
                    break;

                case EnrollState.Open:
                    pnlEnrollNotice.Visible = false;
                    SetEnrollControls(enabled: true);
                    break;

                case EnrollState.Closed:
                    ShowNotice(
                        cssClass: "enroll-notice notice-red",
                        iconClass: "fa-lock",
                        title: "Enrollment Period Closed",
                        body: $"The enrollment period ended on <strong>{end:dd MMM yyyy}</strong>. " +
                                    $"To add or drop courses, please visit the " +
                                    $"<a href='AddDrop.aspx'>Add/Drop page</a> where late requests " +
                                    $"will be submitted for administrator approval.",
                        disableEnroll: true
                    );
                    break;

                case EnrollState.NoSemester:
                    ShowNotice(
                        cssClass: "enroll-notice notice-gray",
                        iconClass: "fa-info-circle",
                        title: "No Active Semester",
                        body: "There is no active semester at this time. " +
                                    "Please contact the administrator for assistance.",
                        disableEnroll: true
                    );
                    break;
            }
        }

        private void ShowNotice(string cssClass, string iconClass, string title, string body, bool disableEnroll)
        {
            pnlEnrollNotice.Visible = true;

            var noticeDiv = (HtmlGenericControl)pnlEnrollNotice.FindControl("enrollNoticeBox");
            if (noticeDiv != null) noticeDiv.Attributes["class"] = cssClass;

            var iconEl = (HtmlGenericControl)pnlEnrollNotice.FindControl("enrollNoticeIcon");
            if (iconEl != null) iconEl.Attributes["class"] = "fa " + iconClass;

            lblNoticeTitle.Text = title;
            lblNoticeBody.Text = body;

            SetEnrollControls(enabled: !disableEnroll);
        }

        private void SetEnrollControls(bool enabled)
        {
            btnEnrollSelected.Enabled = enabled;
            chkSelectAll.Enabled = enabled;

            var row = (HtmlGenericControl)FindControl("selectAllRow");
            if (row != null)
                row.Attributes["class"] = enabled
                    ? "select-all-row"
                    : "select-all-row disabled";
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
                    conn.Open();

                    DataTable dt = new DataTable();
                    dt.Load(cmd.ExecuteReader());

                    gvCourses.DataSource = dt;
                    gvCourses.DataBind();
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Unable to load available courses.", isError: true);
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
                conn.Open();

                DataTable dt = new DataTable();
                dt.Load(cmd.ExecuteReader());

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
                            ? 0 : Convert.ToInt32(reader["TotalCredits"]);

                        int maxCredit = reader["MaxCredits"] == DBNull.Value
                            ? 0 : Convert.ToInt32(reader["MaxCredits"]);

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
            if (CurrentState != EnrollState.Open) return;

            foreach (GridViewRow row in gvCourses.Rows)
            {
                CheckBox chk = (CheckBox)row.FindControl("chkSelect");
                if(chk != null && chk.Enabled)
                    chk.Checked = ((CheckBox)sender).Checked;
            }
        }

        protected void btnEnrollSelected_Click(object sender, EventArgs e)
        {
            if (CurrentState != EnrollState.Open)
            {
                ShowMessage("Enrollment is not currently open.", isError: true);
                return;
            }

            try
            {
                int studentID = Convert.ToInt32(Session["StudentID"]);
                var selectedOfferings = new List<int>();

                foreach (GridViewRow row in gvCourses.Rows)
                {
                    var chk = (CheckBox)row.FindControl("chkSelect");
                    var hf = (HiddenField)row.FindControl("hfOfferingID");

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

                        case "DIFFERENT_SEMESTER":
                            ShowMessage("Selected courses belong to different semesters.",
                                isError: true);
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
                var chk = (CheckBox)e.Row.FindControl("chkSelect");

                if (chk != null)
                {
                    if (seatsLeft <= 0 && CurrentState != EnrollState.Open)
                    {
                        chk.Enabled = false;
                        if (seatsLeft <= 0)
                            e.Row.CssClass += " row-full";
                    }
                }
            }
        }

        protected string GetSeatBarStyle(object pctObj)
        {
            double pct = pctObj == null || pctObj == DBNull.Value
                ? 0 : Convert.ToDouble(pctObj);
            pct = Math.Max(0, Math.Min(100, pct));
            string color = pct > 40 ? "#10b981"
                         : pct > 15 ? "#f59e0b"
                         : "#ef4444";
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
            switch ((statusObj?.ToString() ?? "").ToLower())
            {
                case "enrolled": return "<span class=\"badge badge-green\">Enrolled</span>";
                case "pending": return "<span class=\"badge badge-amber\">Pending</span>";
                case "dropped": return "<span class=\"badge badge-red\">Dropped</span>";
                case "completed": return "<span class=\"badge badge-blue\">Completed</span>";
                default: return $"<span class=\"badge badge-gray\">{statusObj}</span>";
            }
        }
    }
}