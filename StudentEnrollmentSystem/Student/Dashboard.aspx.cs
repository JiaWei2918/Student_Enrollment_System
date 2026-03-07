using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentEnrollmentSystem.Student
{
    public partial class Dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

            // Prevent unauthorized access
            if (Session["UserID"] == null || Session["Role"] == null)
            {
                Response.Redirect("~/Account/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            // Only Student role allowed
            if (Session["Role"].ToString() != "Student")
            {
                Response.Redirect("~/Account/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                LoadStudentInfo();
            }

        }

        private void LoadStudentInfo()
        {
            if (Session["FullName"] != null)
            {
                lblStudentName.Text = Session["FullName"].ToString();
            }
            else
            {
                lblStudentName.Text = Session["Username"].ToString();
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