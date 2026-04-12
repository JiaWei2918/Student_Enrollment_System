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

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("sp_GetBankDetails", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@StudentID", studentID);
                    conn.Open();

                    DataTable dt = new DataTable();
                    dt.Load(cmd.ExecuteReader());

                    bool hasData = dt.Rows.Count > 0;
                    gvBank.Visible = hasData;
                    pnlBankEmpty.Visible = !hasData;

                    if (hasData)
                    {
                        gvBank.DataSource = dt;
                        gvBank.DataBind();
                    }
                }
            }
            catch
            {
                ShowMessage("Error loading bank accounts.", isError: true);
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            int studentID = Convert.ToInt32(Session["StudentID"]);

            try
            {
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


                    conn.Open();
                    string result = cmd.ExecuteScalar()?.ToString();

                    switch (result)
                    {
                        case "SUCCESS":
                            ShowMessage(
                                string.IsNullOrEmpty(hfBankDetailID.Value)
                                    ? "Bank account added successfully!" : "Bank account updated successfully!",
                                isError: false);
                            ClearForm();
                            LoadBanks();
                            break;

                        case "DUPLICATE_ACCOUNT":
                            ShowMessage("This account number already exists in your profile.", isError: true);
                            break;

                        case "ERROR":
                            ShowMessage("A database error occurred. Please try again.", isError: true);
                            break;

                        default:
                            ShowMessage("An unexpected error occurred.", isError: true);
                            break;
                    }
                }
            }
            catch
            {
                ShowMessage("A system error occurred. Please try again.", isError: true);
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
            try
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
            catch
            {
                ShowMessage("Error loading bank account details.", isError: true);
            }
        }

        protected void gvBank_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int id = Convert.ToInt32(gvBank.DataKeys[e.RowIndex].Value);

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("sp_DeleteBankDetail", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@BankDetailID", id);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Bank account removed successfully.", isError: false);
                LoadBanks();
            }
            catch
            {
                ShowMessage("Error deleting bank account.", isError: true);
            }
        }

        private void ClearForm()
        {
            hfBankDetailID.Value = "";
            txtBankName.Text = "";
            txtAccountNumber.Text = "";
            txtHolderName.Text = "";
            chkPrimary.Checked = false;
            ddlType.SelectedIndex = 0;
        }

        private void ShowMessage(string text, bool isError)
        {
            lblMessage.ForeColor = isError
                ? System.Drawing.Color.Red
                : System.Drawing.Color.Green;
            lblMessage.Text = text;
        }
    }
}