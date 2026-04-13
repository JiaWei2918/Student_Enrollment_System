using System;
using System.Web.UI.HtmlControls;

namespace StudentEnrollmentSystem
{
    public partial class AdminMaster : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["AdminID"] == null)
            {
                Response.Redirect("~/Account/Login.aspx");
            }
            else
            {
                lblAdminName.Text = Session["Username"]?.ToString() ?? "Admin";
            }

            //SetActiveMenuItem();
        }

        private void SetActiveMenuItem()
        {
            string currentPage = System.IO.Path.GetFileName(Request.FilePath);

            if (currentPage.EndsWith(".aspx", StringComparison.OrdinalIgnoreCase))
                currentPage = currentPage.Substring(0, currentPage.Length - 5);

            ResetMenuLinks();

            if (currentPage.Equals("Dashboard", StringComparison.OrdinalIgnoreCase))
                lnkDashboard.Attributes["class"] = "nav-link active";
            else if (currentPage.Equals("ManageCourse", StringComparison.OrdinalIgnoreCase))
                lnkCourse.Attributes["class"] = "nav-link active";
            else if (currentPage.Equals("ManageCourseOffering", StringComparison.OrdinalIgnoreCase))
                lnkOffering.Attributes["class"] = "nav-link active";
            else if (currentPage.Equals("ManageSemester", StringComparison.OrdinalIgnoreCase))
                lnkSemester.Attributes["class"] = "nav-link active";
            else if (currentPage.Equals("ManageStudent", StringComparison.OrdinalIgnoreCase))
                lnkStudent.Attributes["class"] = "nav-link active";
            else if (currentPage.Equals("Report", StringComparison.OrdinalIgnoreCase))
                lnkReport.Attributes["class"] = "nav-link active";
            else if (currentPage.Equals("ViewEnquiries", StringComparison.OrdinalIgnoreCase))
                lnkEnquiry.Attributes["class"] = "nav-link active";
        }

        private void ResetMenuLinks()
        {
            lnkDashboard.Attributes["class"] = "nav-link";
            lnkCourse.Attributes["class"] = "nav-link";
            lnkOffering.Attributes["class"] = "nav-link";
            lnkSemester.Attributes["class"] = "nav-link";
            lnkStudent.Attributes["class"] = "nav-link";
            lnkReport.Attributes["class"] = "nav-link";
            lnkEnquiry.Attributes["class"] = "nav-link";
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Account/Login.aspx");
        }
    }
}