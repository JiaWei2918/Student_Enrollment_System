using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace StudentEnrollmentSystem.Student
{
    public partial class AddDropHistory : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["DBConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StudentID"] == null || Session["Role"] == null || Session["Role"].ToString() != "Student")
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

                    conn.Open();

                    gvHistory.DataSource = cmd.ExecuteReader();
                    gvHistory.DataBind();
                }
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Error loading history.";
            }
        }
    }
}