using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;
using iTextSharp.text;
using iTextSharp.text.pdf;

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
            using (SqlCommand cmd = new SqlCommand("SELECT SemesterID, SemesterName FROM Semester", conn))
            {
                conn.Open();
                ddlSemester.DataSource = cmd.ExecuteReader();
                ddlSemester.DataTextField = "SemesterName";
                ddlSemester.DataValueField = "SemesterID";
                ddlSemester.DataBind();
            }

            ddlSemester.Items.Insert(0, new System.Web.UI.WebControls.ListItem("-- Select Semester --", ""));

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
            int studentID = Convert.ToInt32(Session["StudentID"]);

            int semesterID;
            if (!int.TryParse(ddlSemester.SelectedValue, out semesterID))
            {
                lblMessage.Text = "Please select a valid semester.";
                return;
            }

            DataTable dt = GetTimeTable(studentID, semesterID);

            if (dt.Rows.Count == 0)
            {
                lblMessage.Text = "No registered courses.";
                pnlGrid.Visible = pnlSummary.Visible = pnlTimetable.Visible = false;
                return;
            }

            gvTimetable.DataSource = dt;
            gvTimetable.DataBind();

            LoadGrid(dt);

            pnlSummary.Visible = pnlTimetable.Visible = pnlGrid.Visible = true;

            LoadSummary(studentID, semesterID);
            lblMessage.Text = "";
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

                    if (dTime == time)
                    {
                        string day = d["DayOfWeek"].ToString();

                        string content =
                            "<div class='grid-cell'>" +
                            "<b>" + d["CourseCode"] + "</b><br/>" +
                            d["Venue"] +
                            "</div";
                        
                        if (day == today)
                        {
                            content = "<div style='background:#fff3cd'>" + content + "</div>";
                        }

                        if (grid.Columns.Contains(day))
                        {
                            if (!string.IsNullOrEmpty(row[day].ToString()))
                                row[day] += "<br/><span style='color:red'>CLASH</span><br/>" + content;
                            else
                                row[day] = content;
                        }
                    }
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
                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    int credits = Convert.ToInt32(reader["TotalCredits"]);

                    lblSummary.Text = "Subjects: " + reader["TotalSubjects"] + 
                                    " | Credits: " + credits;

                    if (credits > 18)
                        lblMessage.Text = "⚠ Credit limit exceeded!";
                }
            }
        }

        protected void btnExport_Click(object sender, EventArgs e)
        {
            Document doc = new Document();
            PdfWriter.GetInstance(doc, Response.OutputStream);

            Response.ContentType = "application/pdf";
            Response.AddHeader("content-disposition", "attachment;filename=Timetable.pdf");

            doc.Open();
            doc.Add(new Paragraph("Student Timetable\n\n"));

            PdfPTable table = new PdfPTable(gvTimetable.Columns.Count);
            table.WidthPercentage = 100;

            foreach (DataControlField col in gvTimetable.Columns)
            {
                PdfPCell cell = new PdfPCell(new Phrase(col.HeaderText));
                cell.BackgroundColor = BaseColor.LIGHT_GRAY;
                table.AddCell(cell);
            }

            foreach (GridViewRow row in gvTimetable.Rows)
                foreach (TableCell cell in row.Cells)
                    table.AddCell(cell.Text);

            doc.Add(table);
            doc.Close();
            Response.End();
        }
    }
}