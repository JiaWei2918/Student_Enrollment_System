<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="StudentEnrollmentSystem.Student.Dashboard" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Student Dashboard</title>

    <style>
        body {
            font-family: Arial;
            background-color: #f4f6f9;
        }

        .header {
            background-color: #2c3e50;
            color: white;
            padding: 15px;
        }

        .container {
            margin: 30px;
        }

        .menu-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
        }

        .card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            border: 1px solid #ddd;
            transition: 0.2s;
        }

            .card:hover {
                background-color: #f1f1f1;
            }

            .card a {
                text-decoration: none;
                color: #2c3e50;
                font-weight: bold;
                font-size: 16px;
            }

        .logout {
            float: right;
        }

        .welcome {
            font-size: 18px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="header">
            <span class="welcome">Welcome, 
                <asp:Label ID="lblStudentName" runat="server"></asp:Label>
            </span>

            <asp:Button
                ID="btnLogout"
                runat="server"
                Text="Logout"
                CssClass="logout"
                OnClick="btnLogout_Click" />
        </div>

        <div class="container">
            <h2>Student Dashboard</h2>
            <div class="menu-grid">
                <!-- Enrollment -->
                <div class="card">
                    <a href="Enrollment.aspx">Online Enrollment</a>
                    <p>Register courses for current semester.</p>
                </div>

                <div class="card">
                    <a href="AddDrop.aspx">Course Add / Drop</a>
                    <p>Add or drop courses during add/drop period.</p>
                </div>

                <div class="card">
                    <a href="AddDropHistory.aspx">Add / Drop History</a>
                    <p>View history of course changes.</p>
                </div>


                <!-- Enquiry -->
                <div class="card">
                    <a href="Enquiry/ContactUs.aspx">Contact Us</a>
                    <p>Submit enquiry to administration.</p>
                </div>

                <div class="card">
                    <a href="Enquiry/TimetableMatching.aspx">Timetable Matching</a>
                    <p>Check timetable conflict.</p>
                </div>

                <div class="card">
                    <a href="Enquiry/TeachingEvaluation.aspx">Teaching Evaluation</a>
                    <p>Evaluate course instructors.</p>
                </div>


                <!-- Statement -->
                <div class="card">
                    <a href="Statement.aspx">Student Statement</a>
                    <p>View academic and financial statement.</p>
                </div>

                <div class="card">
                    <a href="Statement/RegistrationSummary.aspx">Registration Summary</a>
                    <p>View class timetable and summary.</p>
                </div>


                <!-- Payment -->
                <div class="card">
                    <a href="Payment.aspx">Payment</a>
                    <p>Make payment for invoices.</p>
                </div>

                <div class="card">
                    <a href="Payment/PaymentHistory.aspx">Payment History</a>
                    <p>View payment records and receipts.</p>
                </div>

                <div class="card">
                    <a href="Payment/Invoice.aspx">Invoice</a>
                    <p>View invoices and adjustment notes.</p>
                </div>


                <!-- Account -->
                <div class="card">
                    <a href="../Account/ChangePassword.aspx">Change Password</a>
                    <p>Update account password.</p>
                </div>

                <div class="card">
                    <a href="../Account/UpdateProfile.aspx">Update Profile</a>
                    <p>Update phone and email.</p>
                </div>

                <div class="card">
                    <a href="../Account/UpdateBankDetails.aspx">Update Bank Details</a>
                    <p>Manage bank account information.</p>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
