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

        private void ShowMessage(string message, bool isError = true)
        {
            lblMessage.ForeColor = isError
                 ? System.Drawing.Color.Red
                 : System.Drawing.Color.Green;
            lblMessage.Text = message;
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
                ShowMessage("Database error while loading courses.", true, ex);
            }
            catch (Exception ex)
            {
                ShowMessage("Unexpected system error while loading courses.", true, ex);
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

                    if (dt.Rows.Count > 0)
                    {
                        lblEnrolledCount.Text = dt.Rows[0]["TotalEnrolled"].ToString();
                        lblTotalCredits.Text = dt.Rows[0]["TotalCredits"].ToString();
                    }
                    else
                    {
                        lblEnrolledCount.Text = "0";
                        lblTotalCredits.Text = "0";
                    }

                    gvMyCourses.DataSource = dt;
                    gvMyCourses.DataBind();
                }
            }
            catch (SqlException ex)
            {
                ShowMessage("Database error while loading enrolled courses.", true, ex);
            }
            catch (Exception ex)
            {
                ShowMessage("Unexpected syste error while loading enrolled courses.", true, ex);
            }
        }

        protected void gvAvailable_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                int seatsLeft = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "SeatsLeft"));
                CheckBox chk = (CheckBox)e.Row.FindControl("chkAdd");

                if (seatsLeft <= 0 && chk != null)
                {
                    chk.Enabled = false;
                    e.Row.CssClass += " row-full";
                }
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

                if (chk != null && chk.Checked && hf != null)
                    list.Add(Convert.ToInt32(hf.Value));
            }

            if (list.Count == 0)
            {
                ShowMessage("Please select at least one course.", true);
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

                switch (result)
                {
                    case "SUCCESS":
                        string verb = action == "ADD" ? "added" : "dropped";
                        ShowMessage($"Course(s) successfully {verb}.", isError: false);
                        break;
                    case "FULL":
                        ShowMessage("One or more selected courses are full.", true);
                        break;
                    case "CREDIT_LIMIT":
                        ShowMessage("Credit limit exceeded. Please deselect some courses.", true);
                        break;
                    case "CLASH":
                        ShowMessage("Timetable clash detected. Please choose non-overlapping courses.", true);
                        break;
                    case "DROP_PERIOD_CLOSED":
                        ShowMessage("The drop period for this semester has ended.", true);
                        break;
                    case "ADD_PERIOD_CLOSED":
                        ShowMessage("The add period for this semester has ended.", true);
                        break;
                    default:
                        ShowMessage(!string.IsNullOrEmpty(result) ? result : "Action failed. Please try again.", true);
                        break;
                }
            }

            LoadAvailableCourses();
            LoadMyCourses();
        }

        protected string GetSeatBarStyle(object pctObj)
        {
            double pct = pctObj == DBNull.Value ? 0 : Convert.ToDouble(pctObj);
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
            switch (statusObj?.ToString()?.ToLower())
            {
                case "enrolled": return "<span class=\"badge badge-green\">Enrolled</span>";
                case "pending": return "<span class=\"badge badge-amber\">Pending</span>";
                case "dropped": return "<span class=\"badge badge-red\">Dropped</span>";
                case "completed": return "<span class=\"badge badge-blue\">Completed</span>";
                default: return $"<span class=\"badge badge-gray\">{statusObj}</span>";
            }
        }

        protected string FormatDate(object dateObj)
        {
            if (dateObj == null || dateObj == DBNull.Value) return "—";
            return Convert.ToDateTime(dateObj).ToString("dd MMM yyyy");
        }
    }
}