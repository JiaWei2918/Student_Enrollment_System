using System;

namespace StudentEnrollmentSystem
{
    public partial class StudentMaster : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StudentID"] == null)
            {
                Response.Redirect("~/Account/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            string fullName = Session["FullName"]?.ToString() ?? "";
            string username = Session["Username"]?.ToString() ?? "";
            string program = Session["Program"]?.ToString() ?? "Computer Science";

            lblStudentName.Text = fullName;
            lblStudentID.Text = username;
            lblStudentProg.Text = program;
            lblDebug.Text = "Current page: " + System.IO.Path.GetFileName(Request.Url.AbsolutePath);

            string initials = GetInitials(fullName);
            lblAvatar.Text = initials;
        }

        private string GetInitials(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName)) return "?";

            string[] parts = fullName.Trim().Split(' ');
            if (parts.Length >= 2)
                return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
            else
                return parts[0][0].ToString().ToUpper();
        }

        public string GetMenuClass(string pageName)
        {
            string currentPage = System.IO.Path.GetFileName(Request.Path);
            if (currentPage.EndsWith(".aspx", StringComparison.OrdinalIgnoreCase))
                currentPage = currentPage.Substring(0, currentPage.Length - 5);

            if (pageName.EndsWith(".aspx", StringComparison.OrdinalIgnoreCase))
                pageName = pageName.Substring(0, pageName.Length - 5);

            return currentPage.Equals(pageName, StringComparison.OrdinalIgnoreCase) ? "active" : "";
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Account/Login.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}