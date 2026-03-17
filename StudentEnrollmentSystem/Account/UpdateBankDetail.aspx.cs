using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace StudentEnrollmentSystem.Account
{
    public partial class UpdateBank : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["DBConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StudentID"] == null)
                Response.Redirect("~/Account/Login.aspx");

            if (!IsPostBack)
                LoadBanks();
        }

        private void LoadBanks()
        {
            int studentID = Convert.ToInt32(Session["StudentID"]);

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetBankDetails", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@StudentID", studentID);

                conn.Open();
                gvBank.DataSource = cmd.ExecuteReader();
                gvBank.DataBind();
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            int studentID = Convert.ToInt32(Session["StudentID"]);

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_SaveBankDetail", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@BankDetailID", 
                    string.IsNullOrEmpty(hfBankDetailID.Value) 
                    ? (object)DBNull.Value : Convert.ToInt32(hfBankDetailID.Value));

                cmd.Parameters.AddWithValue("@StudentID", studentID);
                cmd.Parameters.AddWithValue("@BankName", txtBankName.Text.Trim());
                cmd.Parameters.AddWithValue("@AccountNumber", txtAccountNumber.Text.Trim());
                cmd.Parameters.AddWithValue("@AccountHolderName", txtHolderName.Text.Trim());
                cmd.Parameters.AddWithValue("@AccountType", ddlType.SelectedValue);
                cmd.Parameters.AddWithValue("@IsPrimary", chkPrimary.Checked);

                try
                {
                    conn.Open();
                    string result = cmd.ExecuteScalar()?.ToString();

                    if (result == "SUCCESS")
                    {
                        lblMessage.Text = "Saved successfully.";
                        lblMessage.ForeColor = System.Drawing.Color.Green;

                        gvBank.EditIndex = -1;
                        ClearForm();
                        LoadBanks();
                    }
                    else if (result == "DUPLICATE_ACCOUNT")
                    {
                        lblMessage.Text = "Account already exists.";
                        lblMessage.ForeColor = System.Drawing.Color.Red;
                    }
                    else
                    {
                        lblMessage.Text = "Error occurred.";
                        lblMessage.ForeColor = System.Drawing.Color.Red;
                    }
                }
                catch
                {
                    lblMessage.Text = "Database error occurred.";
                    lblMessage.ForeColor = System.Drawing.Color.Red;
                }
            }
        }

        protected void gvBank_RowEditing(object sender, GridViewEditEventArgs e)
        {
            e.Cancel = true;

            int id = Convert.ToInt32(gvBank.DataKeys[e.NewEditIndex].Value);
            LoadBankByID(id);
        }

        private void LoadBankByID(int id)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("SELECT * FROM BankDetail WHERE BankDetailID=@ID", conn))
            {
                cmd.Parameters.AddWithValue("@ID", id);
                conn.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        hfBankDetailID.Value = id.ToString();
                        txtBankName.Text = reader["BankName"].ToString();
                        txtAccountNumber.Text = reader["AccountNumber"].ToString();
                        txtHolderName.Text = reader["AccountHolderName"].ToString();
                        ddlType.SelectedValue = reader["AccountType"].ToString();
                        chkPrimary.Checked = Convert.ToBoolean(reader["IsPrimary"]);
                    }
                }
            }
        }

        protected void gvBank_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int id = Convert.ToInt32(gvBank.DataKeys[e.RowIndex].Value);

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_DeleteBankDetail", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@BankDetailID", id);

                conn.Open();
                cmd.ExecuteNonQuery();
            }

            LoadBanks();
        }

        private void ClearForm()
        {
            hfBankDetailID.Value = "";
            txtBankName.Text = "";
            txtAccountNumber.Text = "";
            txtHolderName.Text = "";
            chkPrimary.Checked = false;
        }
    }
}