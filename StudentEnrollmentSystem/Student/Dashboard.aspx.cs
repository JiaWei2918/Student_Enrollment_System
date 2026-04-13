using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace StudentEnrollmentSystem.Student
{
    public partial class Dashboard : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["DBConnection"].ConnectionString;

        public class ClassItem
        {
            public string Code { get; set; }
            public string Name { get; set; }
            public string Time { get; set; }
            public string Room { get; set; }
            public string IconClass { get; set; }
        }

        public class ActivityItem
        {
            public string Title { get; set; }
            public string Description { get; set; }
            public string Time { get; set; }
            public string BgClass { get; set; }
            public string IconClass { get; set; }
        }

        public class AnnouncementItem
        {
            public string Title { get; set; }
            public string Description { get; set; }
            public string Date { get; set; }
            public string DotClass { get; set; }
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
                BindWelcomeBanner();
                BindStats();
                BindTodaySchedule();
                BindRecentActivities();
                BindAnnouncements();
                BindAcademicProgress();
            }
        }

        private void BindWelcomeBanner()
        {
            string fullName = Session["FullName"]?.ToString() ?? "Student";
            string firstName = fullName.Split(' ')[0];

            lblWelcomeName.Text = firstName;
            lblWelcomeID.Text = Session["Username"]?.ToString() ?? "";
            lblWelcomeProgram.Text = Session["Program"]?.ToString() ?? "Computer Science";
            lblWelcomeSemester.Text = GetActiveSemesterName();
            lblTodayDate.Text = DateTime.Now.ToString("dddd, MMMM d, yyyy");
        }

        private string GetActiveSemesterName()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetActiveSemester", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                    if (r.Read())
                        return r["SemesterName"].ToString().Trim() + " " +
                                r["AcademicYear"].ToString().Trim();
            }

            int month = DateTime.Now.Month, year = DateTime.Now.Year;
            if (month <= 5) return $"Spring {year}";
            if (month <= 8) return $"Summer {year}";
            return $"Fall {year}";
        }

        private int GetActiveSemesterID()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetActiveSemester", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                    if (r.Read() && r["SemesterID"] != DBNull.Value)
                        return Convert.ToInt32(r["SemesterID"]);
            }

            return 0;
        }

        private string GetRelativeTime(DateTime dt)
        {
            TimeSpan diff = DateTime.Now - dt;

            if (diff.TotalMinutes < 60) return $"{(int)diff.TotalMinutes} minutes ago";
            if (diff.TotalHours < 24) return $"{(int)diff.TotalHours} hour{((int)diff.TotalHours == 1 ? "" : "s")} ago";
            if (diff.TotalDays < 7) return $"{(int)diff.TotalDays} day{((int)diff.TotalDays == 1 ? "" : "s")} ago";
            return dt.ToString("dd MMM yyyy");
        }

        private void BindStats()
        {
            int studentID = Convert.ToInt32(Session["StudentID"]);

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetStudentCredits", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        lblTotalCredits.Text = (r["TotalCredits"] == DBNull.Value ? 0
                                                    : Convert.ToInt32(r["TotalCredits"])).ToString();
                        lblRequiredCredits.Text = (r["MaxCredits"] == DBNull.Value ? 18
                                                    : Convert.ToInt32(r["MaxCredits"])).ToString();
                    }
                }
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("sp_GetStudentEnrollments", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                    conn.Open();
                    DataTable dt = new DataTable();
                    dt.Load(cmd.ExecuteReader());
                    lblEnrolledCount.Text = dt.Rows.Count.ToString();
                }
            }
            catch
            {
                lblEnrolledCount.Text = "0";
            }

            try
            {
                string sql = @"
                    SELECT ISNULL(SUM(c.CreditHours), 0) AS CompletedCredits
                    FROM Enrollment e
                    JOIN CourseOffering co ON e.OfferingID = co.OfferingID
                    JOIN Course c ON co.CourseID = c.CourseID
                    WHERE e.StudentID = @StudentID AND e.Status = 'Enrolled'";

                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                    conn.Open();
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            decimal gpa = 3.5M;
                            int completed = r["CompletedCredits"] == DBNull.Value ? 0
                                            : Convert.ToInt32(r["CompletedCredits"]);
                            lblGPA.Text = gpa.ToString("0.00");
                            lblCompletedCredits.Text = completed.ToString();
                        }
                    }
                }
            }
            catch
            {
                lblGPA.Text = "—";
                lblCompletedCredits.Text = "0";
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("sp_GetStudentInvoices", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                    conn.Open();
                    DataTable dt = new DataTable();
                    dt.Load(cmd.ExecuteReader());

                    if (dt.Rows.Count > 0 && dt.Columns.Contains("TotalOutstanding"))
                    {
                        decimal outstanding = Convert.ToDecimal(dt.Rows[0]["TotalOutstanding"]);
                        lblBalance.Text = outstanding >= 1000
                            ? (outstanding / 1000).ToString("0.#") + "K"
                            : outstanding.ToString("N0");

                        DateTime? nearestDue = null;
                        foreach (DataRow row in dt.Rows)
                        {
                            string status = row["Status"]?.ToString() ?? "";
                            if ((status == "Issued" || status == "Partial" || status == "Overdue")
                                && row["DueDate"] != DBNull.Value)
                            {
                                DateTime due = Convert.ToDateTime(row["DueDate"]);
                                if (nearestDue == null || due < nearestDue) nearestDue = due;
                            }
                        }
                        lblDueDate.Text = nearestDue.HasValue
                            ? nearestDue.Value.ToString("MMM d") : "—";
                    }
                    else
                    {
                        lblBalance.Text = "0";
                        lblDueDate.Text = "—";
                    }
                }
            }
            catch
            {
                lblBalance.Text = "0";
                lblDueDate.Text = "—";
            }
        }

        private void BindTodaySchedule()
        {
            int studentID = Convert.ToInt32(Session["StudentID"]);
            int semesterID = GetActiveSemesterID();

            if (semesterID == 0)
            {
                rptClasses.DataSource = new List<ClassItem>();
                rptClasses.DataBind();
                return;
            }

            string sql = @"
                SELECT
                    c.CourseCode,
                    c.CourseName,
                    CONVERT(VARCHAR(5), cs.StartTime, 108) AS StartTime,
                    CONVERT(VARCHAR(5), cs.EndTime, 108) AS EndTime,
                    ISNULL(cs.Venue, '') AS Venue,
                    ISNULL(co.Lecturer, '') AS Lecturer,
                    CASE (ROW_NUMBER() OVER (ORDER BY cs.StartTime) % 3)
                        WHEN 1 THEN 'icon-blue-cyan'
                        WHEN 2 THEN 'icon-purple-pink'
                        ELSE 'icon-emerald-teal'
                    END AS IconClass
                FROM Enrollment e
                JOIN CourseOffering co ON e.OfferingID = co.OfferingID
                JOIN Course c ON co.CourseID = c.CourseID
                JOIN CourseSchedule cs ON co.OfferingID = cs.OfferingID
                WHERE e.StudentID = @StudentID
                AND co.SemesterID = @SemesterID
                AND e.Status = 'Enrolled'
                AND cs.DayOfWeek = @Day
                ORDER BY cs.StartTime";

            var classes = new List<ClassItem>();

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                cmd.Parameters.Add("@SemesterID", SqlDbType.Int).Value = semesterID;
                cmd.Parameters.Add("@Day", SqlDbType.VarChar, 20).Value = DateTime.Now.DayOfWeek.ToString();
                conn.Open();

                DataTable dt = new DataTable();
                dt.Load(cmd.ExecuteReader());

                string dayLabel = "Today";

                if (dt.Rows.Count == 0)
                {
                    cmd.Parameters["@Day"].Value = DateTime.Now.AddDays(1).DayOfWeek.ToString();
                    DataTable dt2 = new DataTable();
                    using (SqlDataReader r2 = cmd.ExecuteReader())
                        dt2.Load(r2);
                    dt = dt2;
                    dayLabel = "Tomorrow";
                }

                foreach (DataRow row in dt.Rows)
                {
                    classes.Add(new ClassItem
                    {
                        Code = row["CourseCode"].ToString(),
                        Name = row["CourseName"].ToString(),
                        Time = dayLabel + ", " + row["StartTime"] + " – " + row["EndTime"],
                        Room = row["Venue"].ToString(),
                        IconClass = row["IconClass"].ToString()
                    });
                }
            }

            rptClasses.DataSource = classes;
            rptClasses.DataBind();
        }

        private void BindRecentActivities()
        {
            int studentID = Convert.ToInt32(Session["StudentID"]);
            var activities = new List<ActivityItem>();

            string sql = @"
                SELECT TOP 4 * FROM (
                    SELECT
                        CASE h.ActionType
                            WHEN 'Add' THEN 'Course enrollment completed'
                            WHEN 'Drop' THEN 'Course dropped'
                            ELSE h.ActionType
                        END AS Title,
                        c.CourseCode + ' — ' + c.CourseName AS Description,
                        h.ActionDate AS EventDate,
                        CASE h.ActionType
                            WHEN 'Add' THEN 'act-emerald'
                            ELSE 'act-purple'
                        END AS BgClass,
                        CASE h.ActionType
                            WHEN 'Add' THEN 'fa fa-check-circle'
                            ELSE 'fa fa-minus-circle'
                        END AS IconClass
                    FROM AddDropHistory h
                    JOIN CourseOffering co ON h.OfferingID = co.OfferingID
                    JOIN Course c ON co.CourseID  = c.CourseID
                    WHERE h.StudentID = @StudentID

                    UNION ALL

                    SELECT
                        'Payment received' AS Title,
                        'Tuition payment of RM ' + FORMAT(p.Amount,'N2')
                            + ' processed' AS Description,
                        p.PaymentDate AS EventDate,
                        'act-blue' AS BgClass,
                        'fa fa-credit-card' AS IconClass
                    FROM Payment p
                    WHERE p.StudentID = @StudentID
                    AND p.Status = 'Completed'
                ) t
                ORDER BY EventDate DESC";

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                conn.Open();

                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        activities.Add(new ActivityItem
                        {
                            Title = r["Title"].ToString(),
                            Description = r["Description"].ToString(),
                            Time = GetRelativeTime(Convert.ToDateTime(r["EventDate"])),
                            BgClass = r["BgClass"].ToString(),
                            IconClass = r["IconClass"].ToString()
                        });
                    }
                }
            }

            if (activities.Count == 0)
                activities.Add(new ActivityItem
                {
                    Title = "Welcome to the portal",
                    Description = "Start by enrolling in your courses",
                    Time = "Just now",
                    BgClass = "act-blue",
                    IconClass = "fa fa-info-circle"
                });

            rptActivities.DataSource = activities;
            rptActivities.DataBind();
        }

        private void BindAnnouncements()
        {
            int studentID = Convert.ToInt32(Session["StudentID"]);
            var list = new List<AnnouncementItem>();

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetActiveSemester", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        string sem = r["SemesterName"].ToString().Trim() + " " + r["AcademicYear"].ToString().Trim();
                        DateTime addEnd = Convert.ToDateTime(r["AddPeriodEnd"]);
                        DateTime dropEnd = Convert.ToDateTime(r["DropPeriodEnd"]);

                        list.Add(new AnnouncementItem
                        {
                            Title = sem + " Registration Open",
                            Description = "Course registration is active. Enroll through the Enrollment page.",
                            Date = "Active semester",
                            DotClass = "dot-info"
                        });

                        int daysAdd = (int)(addEnd - DateTime.Now).TotalDays;
                        if (daysAdd >= 0 && daysAdd <= 30)
                            list.Add(new AnnouncementItem
                            {
                                Title = "Add Period Ends " + addEnd.ToString("MMM d"),
                                Description = daysAdd == 0
                                    ? "Today is the last day to add courses!"
                                    : $"Add period closes in {daysAdd} day{(daysAdd == 1 ? "" : "s")}.",
                                Date = addEnd.ToString("dd MMM yyyy"),
                                DotClass = daysAdd <= 3 ? "dot-warning" : "dot-info"
                            });

                        int daysDrop = (int)(dropEnd - DateTime.Now).TotalDays;
                        if (daysDrop >= 0 && daysDrop <= 14)
                            list.Add(new AnnouncementItem
                            {
                                Title = "Drop Deadline " + dropEnd.ToString("MMM d"),
                                Description = "Last day to drop courses without academic penalty.",
                                Date = dropEnd.ToString("dd MMM yyyy"),
                                DotClass = "dot-warning"
                            });
                    }
                }
            }

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetStudentInvoices", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                conn.Open();
                DataTable dt = new DataTable();
                dt.Load(cmd.ExecuteReader());

                foreach (DataRow row in dt.Rows)
                {
                    string status = row["Status"]?.ToString() ?? "";
                    if (status == "Issued" || status == "Overdue")
                    {
                        decimal balance = row["Balance"] == DBNull.Value ? 0
                                            : Convert.ToDecimal(row["Balance"]);
                        DateTime due = row["DueDate"] == DBNull.Value ? DateTime.Now
                                        : Convert.ToDateTime(row["DueDate"]);
                        int daysLeft = (int)(due - DateTime.Now).TotalDays;

                        list.Add(new AnnouncementItem
                        {
                            Title = status == "Overdue" ? "⚠ Payment Overdue" : "Payment Deadline Reminder",
                            Description = $"Tuition balance of RM {balance:N2} due by {due:MMM d}.",
                            Date = due.ToString("dd MMM yyyy"),
                            DotClass = (status == "Overdue" || daysLeft <= 3) ? "dot-warning" : "dot-info"
                        });
                        break;
                    }
                }
            }

            if (list.Count > 3) list = list.GetRange(0, 3);

            if (list.Count == 0)
                list.Add(new AnnouncementItem
                {
                    Title = "Welcome to the Student Portal",
                    Description = "Use the navigation menu to manage your enrollment, payments, and profile.",
                    Date = DateTime.Now.ToString("dd MMM yyyy"),
                    DotClass = "dot-success"
                });

            rptAnnouncements.DataSource = list;
            rptAnnouncements.DataBind();
        }

        private void BindAcademicProgress()
        {
            int studentID = Convert.ToInt32(Session["StudentID"]);
            int earned = 0, required = 120;

            string sql = @"
                SELECT
                    ISNULL(SUM(c.CreditHours), 0) AS CompletedCredits
                FROM Enrollment e
                JOIN CourseOffering co ON e.OfferingID = co.OfferingID
                JOIN Course c ON co.CourseID = c.CourseID
                WHERE e.StudentID = @StudentID
                AND e.Status = 'Enrolled'";

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                conn.Open();
                object result = cmd.ExecuteScalar();
                earned = result == null || result == DBNull.Value ? 0 : Convert.ToInt32(result);
            }

            double pct = required > 0 ? Math.Round((double)earned / required * 100, 1) : 0;

            lblProgressText.Text = $"{earned}/{required}";
            lblProgressPct.Text = pct.ToString("0.#");

            int yearsLeft = (int)Math.Ceiling(Math.Max(0, required - earned) / 30.0);
            lblGradYear.Text = "May " + (DateTime.Now.Year + yearsLeft);

            ViewState["ProgressPct"] = pct;
        }

        protected double GetProgressWidth()
        {
            return ViewState["ProgressPct"] != null
                ? (double)ViewState["ProgressPct"] : 0;
        }
    }
}