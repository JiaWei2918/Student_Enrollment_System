using iTextSharp.text;
using iTextSharp.text.pdf;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web.UI;

namespace StudentEnrollmentSystem.Student
{
    public partial class TimeTable : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["DBConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StudentID"] == null)
            {
                Response.Redirect("~/Account/Login.aspx");
                return;
            }    

            if (!IsPostBack)
            {
                LoadSemester();
            }
        }

        private void LoadSemester()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("" +
                "SELECT SemesterID, RTRIM(SemesterName) + ' ' + RTRIM(AcademicYear) AS SemesterLabel " +
                "FROM Semester ORDER BY SemesterID DESC", conn))
            {
                conn.Open();
                DataTable dt = new DataTable();
                dt.Load(cmd.ExecuteReader());

                ddlSemester.DataSource = dt;
                ddlSemester.DataTextField = "SemesterLabel";
                ddlSemester.DataValueField = "SemesterID";
                ddlSemester.DataBind();

                ddlSemester.Items.Insert(0, new System.Web.UI.WebControls.ListItem("-- Select Semester --", ""));
            }

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("SELECT TOP 1 SemesterID FROM Semester WHERE Status='Active'", conn))
            {
                conn.Open();
                var id = cmd.ExecuteScalar();

                if (id != null)
                {
                    ddlSemester.SelectedValue = id.ToString();
                    LoadData();
                }
            }
        }

        protected void ddlSemester_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadData();
        }

        private void LoadData()
        {
            lblMessage.Text = "";

            int studentID;
            if (!int.TryParse(Session["StudentID"]?.ToString(), out studentID)) return;

            int semesterID;
            if (!int.TryParse(ddlSemester.SelectedValue, out semesterID))
            {
                ShowMessage("Please select a valid semester.", isWarning: false);
                return;
            }

            DataTable dt = GetTimeTable(studentID, semesterID);

            if (dt.Rows.Count == 0)
            {
                pnlSummary.Visible = false;
                pnlTimetable.Visible = false;
                pnlGrid.Visible = false;
                pnlEmpty.Visible = true;
                ShowMessage("No registered courses for this semester.", isWarning: false);
                return;
            }

            pnlEmpty.Visible = false;
            pnlSummary.Visible = true;
            pnlTimetable.Visible = true;
            pnlGrid.Visible = true;

            lblStudentName.Text = Session["FullName"]?.ToString() ?? "—";
            lblStudentID.Text = Session["Username"]?.ToString() ?? "—";
            lblProgram.Text = Session["Program"]?.ToString() ?? "Computer Science";
            lblSemesterName.Text = ddlSemester.SelectedItem?.Text ?? "—";

            lblTotalSubjects.Text = dt.Rows[0]["TotalCourses"].ToString();

            gvTimetable.DataSource = dt;
            gvTimetable.DataBind();

            RenderCoursecards(dt);
            LoadGrid(dt);
            LoadSummary(studentID, semesterID);
        }

        private DataTable GetTimeTable(int studentID, int semesterID)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetStudentTimetable", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@StudentID", studentID);
                cmd.Parameters.AddWithValue("@SemesterID", semesterID);

                conn.Open();
                DataTable dt = new DataTable();
                dt.Load(cmd.ExecuteReader());
                return dt;
            }
        }

        private void RenderCoursecards(DataTable dt)
        {
            var seen = new System.Collections.Generic.HashSet<string>();
            var sb = new StringBuilder();

            foreach (DataRow row in dt.Rows)
            {
                string code = row["CourseCode"].ToString();
                if (seen.Contains(code)) continue;
                seen.Add(code);

                var slots = new StringBuilder();
                foreach (DataRow r in dt.Rows)
                {
                    if (r["CourseCode"].ToString() != code) continue;
                    slots.AppendFormat(
                        "<div class='cc-meta-item'><i class='fa fa-clock-o'></i><span>{0} {1}–{2}</span></div>",
                        r["DayOfWeek"], r["StartTime"], r["EndTime"]
                    );
                }

                sb.Append("<div class='course-card'>");
                sb.Append("<div class='course-card-top'>");
                sb.Append("<div>");
                sb.AppendFormat("<div class='cc-code'>{0}</div>", code);
                sb.AppendFormat("<div class='cc-name'>{0}</div>", row["CourseName"]);
                sb.Append("</div>");
                sb.AppendFormat("<span class='badge badge-blue'>Section</span>");
                sb.Append("</div>");

                sb.Append("<div class='cc-meta'>");
                sb.AppendFormat(
                    "<div class='cc-meta-item'><i class='fa fa-user'></i><span>{0}</span></div>",
                    row["Lecturer"]);
                sb.AppendFormat(
                    "<div class='cc-meta-item'><i class='fa fa-map-marker'></i><span>{0}</span></div>",
                    row["Venue"]);
                sb.Append(slots.ToString());
                sb.Append("</div>");
                sb.Append("</div>");
            }

            phCourses.Controls.Add(new LiteralControl(sb.ToString()));
        }

        private void LoadGrid(DataTable dt)
        {
            DataView dv = dt.DefaultView;
            dv.Sort = "StartTime";
            DataTable times = dv.ToTable(true, "StartTime", "EndTime");

            DataTable grid = new DataTable();
            grid.Columns.Add("TimeSlot");
            grid.Columns.Add("Monday");
            grid.Columns.Add("Tuesday");
            grid.Columns.Add("Wednesday");
            grid.Columns.Add("Thursday");
            grid.Columns.Add("Friday");
            grid.Columns.Add("Saturday");

            string today = DateTime.Now.DayOfWeek.ToString();

            foreach (DataRow t in times.Rows)
            {
                string time = t["StartTime"] + " - " + t["EndTime"];
                DataRow row = grid.NewRow();
                row["TimeSlot"] = time;

                foreach (DataRow d in dt.Rows)
                {
                    string dTime = d["StartTime"] + " - " + d["EndTime"];
                    if (dTime != time) continue;

                    string day = d["DayOfWeek"].ToString().Trim();
                    bool isToday = day == today;

                    string cellClass = isToday ? "grid-cell grid-cell-today" : "grid-cell";
                    string content =
                        $"<div class='{cellClass}'>" +
                        $"<b>{d["CourseCode"]}</b>" +
                        $"<span style='font-size:11px;display:block;margin-top:2px;'>{d["Venue"]}</span>" +
                        "</div>";

                    if (!grid.Columns.Contains(day)) continue;

                    if (!string.IsNullOrEmpty(row[day].ToString()))
                        row[day] += "<div class='grid-clash'><i class='fa fa-exclamation-triangle'></i> CLASH</div>" + content;
                    else
                        row[day] = content;
                }

                grid.Rows.Add(row);
            }

            gvGrid.DataSource = grid;
            gvGrid.DataBind();
        }

        private void LoadSummary(int studentID, int semesterID)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetRegistrationSummary", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@StudentID", studentID);
                cmd.Parameters.AddWithValue("@SemesterID", semesterID);

                conn.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        int credits = Convert.ToInt32(reader["TotalCredits"]);

                        lblTotalCredits.Text = credits.ToString();

                        if (credits > 18)
                            ShowMessage("⚠ Credit limit exceeded! You are registered for " + credits + " credits.", isWarning: true);
                    }
                }
            }
        }

        protected void btnExport_Click(object sender, EventArgs e)
        {
            int studentID, semesterID;
            if (!int.TryParse(Session["StudentID"]?.ToString(), out studentID)) return;
            if (!int.TryParse(ddlSemester.SelectedValue, out semesterID)) return;

            DataTable dt = GetTimeTable(studentID, semesterID);

            using (var ms = new MemoryStream())
            {
                Document doc = new Document(PageSize.A4, 20f, 20f, 30f, 20f);
                PdfWriter.GetInstance(doc, ms);
                doc.Open();

                var titleFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 14);
                var subFont = FontFactory.GetFont(FontFactory.HELVETICA, 10);
                var boldFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 10);

                var title = new Paragraph("Student Class Schedule", titleFont);
                title.Alignment = Element.ALIGN_CENTER;
                doc.Add(title);
                doc.Add(new Paragraph(" "));
                doc.Add(new Paragraph("Student: " + lblStudentName.Text, subFont));
                doc.Add(new Paragraph("ID: " + lblStudentID.Text, subFont));
                doc.Add(new Paragraph("Semester: " + lblSemesterName.Text, subFont));
                doc.Add(new Paragraph(" "));

                PdfPTable table = new PdfPTable(7);
                table.WidthPercentage = 100;
                table.SetWidths(new float[] { 12f, 22f, 12f, 10f, 10f, 18f, 16f });

                string[] headers = { "Code", "Course", "Day", "Start", "End", "Venue", "Lecturer" };
                foreach (string h in headers)
                {
                    PdfPCell cell = new PdfPCell(new Phrase(h, boldFont));
                    cell.BackgroundColor = new BaseColor(248, 250, 252);
                    cell.Padding = 6;
                    table.AddCell(cell);
                }

                foreach (DataRow row in dt.Rows)
                {
                    table.AddCell(new Phrase(row["CourseCode"].ToString(), subFont));
                    table.AddCell(new Phrase(row["CourseName"].ToString(), subFont));
                    table.AddCell(new Phrase(row["DayOfWeek"].ToString(), subFont));
                    table.AddCell(new Phrase(row["StartTime"].ToString(), subFont));
                    table.AddCell(new Phrase(row["EndTime"].ToString(), subFont));
                    table.AddCell(new Phrase(row["Venue"].ToString(), subFont));
                    table.AddCell(new Phrase(row["Lecturer"].ToString(), subFont));
                }

                doc.Add(table);
                doc.Add(new Paragraph(" "));
                doc.Add(new Paragraph(
                    "Total: " + lblTotalSubjects.Text + " courses, " + lblTotalCredits.Text + " credits",
                    boldFont));

                doc.Close();

                Response.ContentType = "application/pdf";
                Response.AddHeader("content-disposition", "attachment;filename=ClassSchedule.pdf");
                Response.BinaryWrite(ms.ToArray());
                Response.End();
            }
        }

        private void ShowMessage(string text, bool isWarning)
        {
            lblMessage.ForeColor = isWarning
                ? System.Drawing.Color.FromArgb(146, 64, 14)
                : System.Drawing.Color.FromArgb(185, 28, 28);
            lblMessage.Text = text;
        }
    }
}