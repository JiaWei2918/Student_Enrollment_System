# Student Enrollment System
A web-based Student Enrollment System built with **ASP.NET, C#, and Microsoft SQL Server**. The application supports student management, enrollment, payment-related functions, and statement generation.

## Features
- **Student Management** — Manage student accounts and related information.
- **Login and Authentication** — Access the system through the login function.
- **Enrollment Management** — Manage student enrollment processes.
- **Payment Management** — Handle payment records using a dummy payment mechanism.
- **Statement Management** — Support statement-related operations.
- **Database Version Control** — Track executed database scripts to help manage database updates.

## Technology Stack
- **Backend:** ASP.NET, C#
- **Database:** Microsoft SQL Server
- **Database Management:** SQL Server Management Studio (SSMS)
- **Configuration:** `Web.config`
- **Database Operations:** SQL scripts and stored procedures

## Prerequisites
Before running the project, ensure you have:
- Windows 10+
- Visual Studio 2022 with the required ASP.NET development components
- Microsoft SQL Server 2022+
- SQL Server Management Studio (SSMS) 20.2+

## Getting Started
### 1. Clone the Repository

```bash
git clone https://github.com/JiaWei2918/Student_Enrollment_System.git
cd Student_Enrollment_System
```

Open `StudentEnrollmentSystem.sln` in Visual Studio.

### 2. Configure the Database Connection
Locate `Web.config` and check the SQL Server connection string.

The database name should be:

`StudentEnrollmentSystem`

If your SQL Server instance uses `SQLEXPRESS`, the data source may be:

```text
Data Source=.\SQLEXPRESS;
```

If you use the default SQL Server instance, it may instead be:

```text
Data Source=.;
```

Use the configuration that matches your installed SQL Server instance. Ensure that the SQL Server service is running.

### 3. Set Up the Database
The recommended setup method uses the master script `RunAll.sql`.
1. Open SQL Server Management Studio (SSMS).
2. Connect to your SQL Server instance.
3. Open `RunAll.sql` from the project's database scripts folder.
4. Review the script and confirm that it targets the correct database.
5. Execute the script.
6. Check the Messages tab for errors.

The master script is intended to execute the required SQL scripts in the correct order.

**Alternative:** If setting up the database manually, execute the numbered SQL scripts in their prescribed order. Do not skip scripts or rerun previously executed scripts unless they are designed to be rerun safely.

### 4. Create the Initial Admin Account
**Important:** The application does not currently provide admin registration or automatic admin account creation.

To access the administrator functions for a fresh installation, you must manually add an admin account to the database using the appropriate SQL operation.
- Identify the database table and required fields used by the admin login.
- Follow the password format and authentication logic expected by the application.
- Ensure that the account has the correct administrator role or permissions.
- Verify that the account can log in successfully.

Do not publish real passwords or credentials in this repository. Use a secure password-handling approach consistent with the application's existing authentication implementation.

### 5. Run the Application
1. Confirm that the database setup is complete.
2. Verify that the required tables and stored procedures exist.
3. Confirm that the connection string is correct.
4. Ensure an admin account has been created.
5. Build the solution in Visual Studio.
6. Run the application using the configured local development server, such as IIS Express.
7. Test the login and main application functions.

## Database Version Control
The project uses a `DatabaseVersion` table to track executed SQL scripts.

Development guidelines:
- Avoid modifying previously executed database scripts.
- Create a new script for table changes, stored procedure updates, and database logic fixes.
- Follow the existing script numbering and execution order.
- Back up important data before making database changes.

These practices help keep database updates organized and reduce the risk of duplicate execution.

## Important Limitations
- **Manual Admin Setup:** An admin account must be inserted into the database manually. No admin registration or automatic account creation is currently available.
- **Admin-Created Student Accounts:** Student accounts are created by an administrator; student self-registration is unavailable.
- **Dummy Payment:** The system does not integrate with a real payment gateway.
- **Local Deployment:** The project is intended for localhost development and demonstration.

## Troubleshooting
| Issue | What to check |
|---|---|
| Cannot connect to SQL Server | Check the SQL Server service and instance name. |
| Database not found | Confirm that `StudentEnrollmentSystem` has been created. |
| Stored procedure not found | Verify that the required SQL scripts were executed. |
| Admin login fails | Check the admin record, password format, and login validation logic. |
| Application fails to build | Review the Visual Studio build errors and required development components. |

## Development Notes
This project demonstrates web application development with ASP.NET, C#, SQL Server, and stored procedures. Review its authentication, database access, and payment implementation before considering any production deployment.
