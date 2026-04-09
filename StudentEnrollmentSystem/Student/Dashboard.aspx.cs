using System;
using System.Collections.Generic;
using System.Data;

namespace StudentEnrollmentSystem.Student
{
    public partial class Dashboard : System.Web.UI.Page
    {
        // ── Data models ──────────────────────────────────────────────

        public class ClassItem
        {
            public string Code { get; set; }
            public string Name { get; set; }
            public string Time { get; set; }
            public string Room { get; set; }
            public string IconClass { get; set; }  // CSS class for gradient color
        }

        public class ActivityItem
        {
            public string Title { get; set; }
            public string Description { get; set; }
            public string Time { get; set; }
            public string BgClass { get; set; }  // act-emerald / act-blue / act-amber / act-purple
            public string IconClass { get; set; }  // font-awesome class e.g. "fa fa-check-circle"
        }

        public class AnnouncementItem
        {
            public string Title { get; set; }
            public string Description { get; set; }
            public string Date { get; set; }
            public string DotClass { get; set; }  // dot-info / dot-warning / dot-success
        }

        // ── Page Load ─────────────────────────────────────────────────

        protected void Page_Load(object sender, EventArgs e)
        {
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

        // ── Welcome Banner ────────────────────────────────────────────

        private void BindWelcomeBanner()
        {
            // Pull first name only for the greeting
            string fullName = Session["FullName"]?.ToString() ?? "Student";
            string firstName = fullName.Split(' ')[0];

            lblWelcomeName.Text = firstName;
            lblWelcomeID.Text = Session["Username"]?.ToString() ?? "";
            lblWelcomeProgram.Text = Session["Program"]?.ToString() ?? "Computer Science";
            lblWelcomeSemester.Text = GetCurrentSemester();
            lblTodayDate.Text = DateTime.Now.ToString("dddd, MMMM d, yyyy");
        }

        private string GetCurrentSemester()
        {
            // Simple logic: Jan-May = Spring, Jun-Aug = Summer, Sep-Dec = Fall
            int month = DateTime.Now.Month;
            int year = DateTime.Now.Year;
            if (month <= 5) return $"Spring {year}";
            if (month <= 8) return $"Summer {year}";
            return $"Fall {year}";
        }

        // ── Stats Cards ───────────────────────────────────────────────

        private void BindStats()
        {
            // TODO: Replace with real DB queries
            lblGPA.Text = "3.85";
            lblEnrolledCount.Text = "6";
            lblTotalCredits.Text = "18";
            lblCompletedCredits.Text = "87";
            lblRequiredCredits.Text = "120";
            lblBalance.Text = "2.5K";
            lblDueDate.Text = "Apr 20";
        }

        // ── Today's Schedule ─────────────────────────────────────────

        private void BindTodaySchedule()
        {
            // TODO: Replace with real DB query filtered by today's day of week
            var classes = new List<ClassItem>
            {
                new ClassItem
                {
                    Code      = "CS101",
                    Name      = "Introduction to Computer Science",
                    Time      = "Today, 9:00 AM - 10:30 AM",
                    Room      = "Room 101, Building A",
                    IconClass = "icon-blue-cyan"
                },
                new ClassItem
                {
                    Code      = "MATH201",
                    Name      = "Calculus II",
                    Time      = "Today, 2:00 PM - 3:30 PM",
                    Room      = "Room 205, Building B",
                    IconClass = "icon-purple-pink"
                },
                new ClassItem
                {
                    Code      = "ENG102",
                    Name      = "English Literature",
                    Time      = "Tomorrow, 11:00 AM - 12:00 PM",
                    Room      = "Room 302, Building C",
                    IconClass = "icon-emerald-teal"
                }
            };

            rptClasses.DataSource = classes;
            rptClasses.DataBind();
        }

        // ── Recent Activities ────────────────────────────────────────

        private void BindRecentActivities()
        {
            // TODO: Replace with real DB query
            var activities = new List<ActivityItem>
            {
                new ActivityItem
                {
                    Title       = "Course enrollment completed",
                    Description = "Successfully enrolled in Physics I",
                    Time        = "2 hours ago",
                    BgClass     = "act-emerald",
                    IconClass   = "fa fa-check-circle"
                },
                new ActivityItem
                {
                    Title       = "Payment received",
                    Description = "Tuition payment of $2,500 processed",
                    Time        = "1 day ago",
                    BgClass     = "act-blue",
                    IconClass   = "fa fa-credit-card"
                },
                new ActivityItem
                {
                    Title       = "Grade posted",
                    Description = "Database Systems midterm: A",
                    Time        = "2 days ago",
                    BgClass     = "act-amber",
                    IconClass   = "fa fa-star"
                },
                new ActivityItem
                {
                    Title       = "Document uploaded",
                    Description = "Transcript request submitted",
                    Time        = "3 days ago",
                    BgClass     = "act-purple",
                    IconClass   = "fa fa-file-text"
                }
            };

            rptActivities.DataSource = activities;
            rptActivities.DataBind();
        }

        // ── Announcements ────────────────────────────────────────────

        private void BindAnnouncements()
        {
            // TODO: Replace with real DB query
            var announcements = new List<AnnouncementItem>
            {
                new AnnouncementItem
                {
                    Title       = "Spring 2024 Registration Opens",
                    Description = "Course registration for Spring 2024 semester begins on April 15th",
                    Date        = "Apr 7, 2026",
                    DotClass    = "dot-info"
                },
                new AnnouncementItem
                {
                    Title       = "Payment Deadline Reminder",
                    Description = "Tuition payment for current semester is due by April 20th",
                    Date        = "Apr 6, 2026",
                    DotClass    = "dot-warning"
                },
                new AnnouncementItem
                {
                    Title       = "Campus Events This Week",
                    Description = "Join us for the Annual Science Fair on Thursday at 3 PM",
                    Date        = "Apr 5, 2026",
                    DotClass    = "dot-success"
                }
            };

            rptAnnouncements.DataSource = announcements;
            rptAnnouncements.DataBind();
        }

        // ── Academic Progress ────────────────────────────────────────

        private void BindAcademicProgress()
        {
            // TODO: Replace with real DB query
            int earned = 87;
            int required = 120;
            double pct = Math.Round((double)earned / required * 100, 1);

            lblProgressText.Text = $"{earned}/{required}";
            lblProgressPct.Text = pct.ToString("0.#");
            lblGradYear.Text = "May 2027";

            // Store for use in GetProgressWidth()
            ViewState["ProgressPct"] = pct;
        }

        // Called inline from .aspx for the progress bar width
        protected double GetProgressWidth()
        {
            return ViewState["ProgressPct"] != null
                ? (double)ViewState["ProgressPct"]
                : 0;
        }
    }
}