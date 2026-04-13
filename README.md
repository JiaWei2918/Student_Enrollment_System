=====================================
STUDENT ENROLLMENT SYSTEM 
DATABASE & PROJECT SETUP GUIDE
====================================================

=================================
1. DATABASE CONFIGURATION
   
=================================

IMPORTANT:

Please ensure your connection string in Web.config is correct.

If your SQL Server does NOT use SQLEXPRESS,
REMOVE "\SQLEXPRESS" from the Data Source.

Example:

WRONG:
Data Source=.\SQLEXPRESS;

CORRECT:
Data Source=.;

Also ensure:
- Database name = StudentEnrollmentSystem
- SQL Server service is running


=====================================
2. DATABASE SETUP (RECOMMENDED METHOD)
========================================

We provide a MASTER SCRIPT to simplify setup.

FILE:
RunAll.sql

STEPS:

1. Open SQL Server Management Studio (SSMS)
2. File → Open → Database Folder → Select "RunAll.sql"
3. Execute the script

This script will:
- Automatically run all required SQL scripts
- Ensure correct execution order
- Prevent missing dependencies

✅ This is the FASTEST and SAFEST method


=====================================
3. MANUAL SETUP (OPTIONAL)
========================================

If you prefer manual setup:

1. Execute SQL scripts ONE BY ONE
2. Follow the NUMBER ORDER strictly

IMPORTANT:
- Do NOT skip scripts
- Do NOT change execution order
- Each script should only be executed ONCE


=====================================
4. DATABASE VERSION CONTROL
========================================

The system uses a version tracking mechanism.

TABLE:
DatabaseVersion

Purpose:
- Tracks executed SQL scripts
- Prevents duplicate execution

IMPORTANT:
- Do NOT re-run old scripts
- Re-running may cause conflicts or duplicate data


=====================================
5. DEVELOPMENT RULES
========================================

- Do NOT modify and re-run existing SQL scripts
- Always create a NEW script for:
  - Table changes
  - Stored procedure updates
  - Logic fixes

- Always use STORED PROCEDURES in C#
  (Avoid direct SQL queries unless necessary)

Examples of stored procedures:
- Student Management
- Login
- Enrollment
- Payment
- Statement


=====================================
6. SYSTEM STARTUP CHECKLIST
========================================

Before running the system:

✔ Database is created successfully  
✔ All tables exist  
✔ Stored procedures exist  
✔ Connection string is correct  
✔ Admin account is available  
✔ Login function is working  


=====================================
7. IMPORTANT NOTES
========================================

- The system uses a DUMMY PAYMENT mechanism
  (No real payment gateway integration)

- Student accounts are created by ADMIN only
  (No self-registration feature)

- The system is designed for LOCALHOST deployment


=====================================
END OF SETUP GUIDE
========================================
