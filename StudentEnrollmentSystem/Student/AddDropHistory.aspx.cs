using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;

namespace StudentEnrollmentSystem.Student
{
    public partial class AddDropHistory : System.Web.UI.Page
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
                LoadHistory();
            }
        }

        private void LoadHistory()
        {
            int studentID = Convert.ToInt32(Session["StudentID"]);

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("sp_GetStudentAddDropHistory", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count == 0)
                    {
                        RenderEmptyState();
                        return;
                    }

                    lblTotalActions.Text = dt.Rows[0]["TotalActions"].ToString();
                    lblTotalAdded.Text = dt.Rows[0]["TotalAdded"].ToString();
                    lblTotalDropped.Text = dt.Rows[0]["TotalDropped"].ToString();

                    var groups = new Dictionary<string, List<DataRow>>();
                    foreach (DataRow row in dt.Rows)
                    {
                        string key = row["SemesterName"] + " " + row["AcademicYear"];
                        if (!groups.ContainsKey(key))
                            groups[key] = new List<DataRow>();
                        groups[key].Add(row);
                    }

                    RenderGroups(groups);
                }
            }
            catch (Exception ex)
            {
                ShowError("Error loading history. Please try again.");
            }
        }

        private void RenderGroups(Dictionary<string, List<DataRow>> groups)
        {
            StringBuilder html = new StringBuilder();

            foreach (var group in groups)
            {
                string semester = group.Key;
                List<DataRow> rows = group.Value;

                html.Append("<div class='semester-group'>");

                // Semester heading
                html.Append("<div class='semester-heading'>");
                html.Append("<i class='fa fa-calendar'></i>");
                html.AppendFormat("<span>{0}</span>", semester);
                html.Append("</div>");

                // Cards
                foreach (DataRow row in rows)
                {
                    string actionType = row["ActionType"]?.ToString() ?? "";
                    string courseCode = row["CourseCode"]?.ToString() ?? "";
                    string courseName = row["CourseName"]?.ToString() ?? "";
                    string creditHours = row["CreditHours"]?.ToString() ?? "—";
                    string requestStatus = row["RequestStatus"]?.ToString() ?? "";
                    string approvedBy = row["ApprovedByName"]?.ToString() ?? "";

                    string actionDate = FormatDateTime(row["ActionDate"]);
                    string approvedDate = FormatDateTime(row["ApprovedDate"]);

                    bool isAdd = actionType == "Add";

                    // Card
                    html.Append("<div class='history-card'>");

                    // Action icon
                    html.AppendFormat(
                        "<div class='action-icon {0}'><i class='fa {1}'></i></div>",
                        isAdd ? "action-add" : "action-drop",
                        isAdd ? "fa-plus" : "fa-minus"
                    );

                    // Body
                    html.Append("<div class='hc-body'>");

                    // Top row: action label + date
                    html.Append("<div class='hc-top'>");
                    html.Append("<div>");
                    html.AppendFormat(
                        "<div class='hc-action-label'>{0} {1} &nbsp; {2}</div>",
                        isAdd ? "Added" : "Dropped",
                        courseCode,
                        GetActionBadge(actionType)
                    );
                    html.AppendFormat("<div class='hc-course-name'>{0}</div>", courseName);
                    html.Append("</div>");
                    html.AppendFormat("<div class='hc-date'>{0}</div>", actionDate);
                    html.Append("</div>"); // hc-top

                    // Meta row: credits + status
                    html.Append("<div class='hc-meta'>");
                    html.AppendFormat(
                        "<div class='hc-meta-item'><i class='fa fa-book'></i><span>{0} Credit{1}</span></div>",
                        creditHours,
                        creditHours == "1" ? "" : "s"
                    );
                    html.AppendFormat(
                        "<div class='hc-meta-item'>{0}</div>",
                        GetStatusBadge(requestStatus)
                    );
                    html.Append("</div>"); // hc-meta

                    // Approved by (only if available)
                    if (!string.IsNullOrWhiteSpace(approvedBy))
                    {
                        html.Append("<div class='hc-approved'>");
                        html.Append("<i class='fa fa-check-circle'></i>");
                        html.AppendFormat(
                            "<span>Approved by <strong>{0}</strong> on {1}</span>",
                            approvedBy,
                            approvedDate
                        );
                        html.Append("</div>");
                    }

                    html.Append("</div>"); // hc-body
                    html.Append("</div>"); // history-card
                }

                html.Append("</div>"); // semester-group
                html.Append("<div style='height:8px;'></div>");
            }

            phHistory.Controls.Add(new LiteralControl(html.ToString()));
        }

        private void RenderEmptyState()
        {
            lblTotalActions.Text = "0";
            lblTotalAdded.Text = "0";
            lblTotalDropped.Text = "0";

            string html = @"
                <div class='empty-state'>
                    <div class='empty-icon'><i class='fa fa-history'></i></div>
                    <div class='empty-title'>No history yet</div>
                    <div class='empty-sub'>Your add/drop actions will appear here once you make changes to your enrollment.</div>
                </div>";

            phHistory.Controls.Add(new LiteralControl(html));
        }

        private void ShowError(string message)
        {
            lblMessage.Text = $"<div class='msg-error'><i class='fa fa-exclamation-circle'></i> {message}</div>";
        }

        private string GetActionBadge(string actionType)
        {
            switch (actionType)
            {
                case "Add": return "<span class='badge badge-add'>Add</span>";
                case "Drop": return "<span class='badge badge-drop'>Drop</span>";
                default: return $"<span class='badge badge-gray'>{actionType}</span>";
            }
        }

        private string GetStatusBadge(string status)
        {
            switch (status)
            {
                case "Approved": return "<span class='badge badge-green'>Approved</span>";
                case "Pending": return "<span class='badge badge-amber'>Pending</span>";
                case "Rejected": return "<span class='badge badge-red'>Rejected</span>";
                default: return $"<span class='badge badge-gray'>{status}</span>";
            }
        }

        private string FormatDateTime(object dateObj)
        {
            if (dateObj == null || dateObj == DBNull.Value) return "—";
            return Convert.ToDateTime(dateObj).ToString("dd MMM yyyy, h:mm tt");
        }
    }
}