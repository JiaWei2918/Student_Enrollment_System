/*
============================================================================
Master Script: Student Enrollment System - Database Deployment
============================================================================
Instructions:
1. Open this file in SQL Server Management Studio (SSMS)
2. Open a new query using Ctrl+N or File > New > Query with Current Connection. (If you haven't see Query in top navigator bar)
2. Enable SQLCMD mode: Query Menu -> SQLCMD Mode (or Alt+Q, M)
3. Change the path below to point to your scripts folder
4. Execute (F5)
============================================================================
*/

-- Set the path to your scripts folder (change this!)
:setvar scriptpath "C:\Users\User\Desktop\StudentEnrollmentSystem\StudentEnrollmentSystem\Database\"

PRINT '=========================================================='
PRINT 'Starting database deployment...'
PRINT '=========================================================='
GO

PRINT 'Executing: v1_00_CreateDatabase.sql'
:r $(scriptpath)v1_00_CreateDatabase.sql

PRINT 'Executing: v1_01_CreateVersionTable.sql'
:r $(scriptpath)v1_01_CreateVersionTable.sql

PRINT 'Executing: v1_02_CreateCoreTables.sql'
:r $(scriptpath)v1_02_CreateCoreTables.sql

PRINT 'Executing: v1_03_CreateLoginProcedure.sql'
:r $(scriptpath)v1_03_CreateLoginProcedure.sql

PRINT 'Executing: v1_04_CreateAcademicTables.sql'
:r $(scriptpath)v1_04_CreateAcademicTables.sql

PRINT 'Executing: v1_05_CreateEnrollmentTables.sql'
:r $(scriptpath)v1_05_CreateEnrollmentTables.sql

PRINT 'Executing: v1_06_CreateFinanceTables.sql'
:r $(scriptpath)v1_06_CreateFinanceTables.sql

PRINT 'Executing: v1_07_CreateSupportingTables.sql'
:r $(scriptpath)v1_07_CreateSupportingTables.sql

PRINT 'Executing: v1_08_CreateResetPasswordProcedures.sql'
:r $(scriptpath)v1_08_CreateResetPasswordProcedures.sql

PRINT 'Executing: v2_01_AddSemesterRule.sql'
:r $(scriptpath)v2_01_AddSemesterRule.sql

PRINT 'Executing: v2_02_CreateSemesterProcedures.sql'
:r $(scriptpath)v2_02_CreateSemesterProcedures.sql

PRINT 'Executing: v2_03_CreateCourseProcedure.sql'
:r $(scriptpath)v2_03_CreateCourseProcedure.sql

PRINT 'Executing: v2_04_CreateCourseOffering.sql'
:r $(scriptpath)v2_04_CreateCourseOffering.sql

PRINT 'Executing: v2_05_CreateStudents.sql'
:r $(scriptpath)v2_05_CreateStudents.sql

PRINT 'Executing: v3_01_CreateEnrollmentProcedure.sql'
:r $(scriptpath)v3_01_CreateEnrollmentProcedure.sql

PRINT 'Executing: v3_02_CreateAddDropProcedure.sql'
:r $(scriptpath)v3_02_CreateAddDropProcedure.sql

PRINT 'Executing: v3_03_CreateAccountProcedure.sql'
:r $(scriptpath)v3_03_CreateAccountProcedure.sql

PRINT 'Executing: v3_04_CreateStatementProcedure.sql'
:r $(scriptpath)v3_04_CreateStatementProcedure.sql

PRINT 'Executing: v3_05_CreateEnquiryProcedure.sql'
:r $(scriptpath)v3_05_CreateEnquiryProcedure.sql

PRINT 'Executing: v3_06_CreatePaymentProcedure.sql'
:r $(scriptpath)v3_06_CreatePaymentProcedure.sql

PRINT '=========================================================='
PRINT 'Database deployment completed successfully.'
PRINT '=========================================================='
GO