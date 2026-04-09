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

            string initials = GetInitials(fullName);
            lblAvatar.Text = initials;

            SetActiveMenu();
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

        private void SetActiveMenu()
        {
            string page = System.IO.Path.GetFileName(Request.Path);

            switch (page)
            {
                case "Dashboard.aspx":
                    menuDashboard.Attributes["class"] = "active";
                    break;
                case "Enrollment.aspx":
                    menuEnroll.Attributes["class"] = "active";
                    break;
                case "AddDrop.aspx":
                    menuAddDrop.Attributes["class"] = "active";
                    break;
                case "AddDropHistory.aspx":
                    menuHistory.Attributes["class"] = "active";
                    break;
                case "Payment.aspx":
                    menuPayment.Attributes["class"] = "active";
                    break;
                case "UpdateProfile.aspx":
                    menuProfile.Attributes["class"] = "active";
                    break;
            }
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