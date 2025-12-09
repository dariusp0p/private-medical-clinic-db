USE private_medical_clinic_db;


-- Create the Test

INSERT INTO dbo.tests (name, description)
VALUES (
    N'Test 1 - Full Chain',
    N'Performance test for the full hierarchy: Persons -> Employees/Patients -> Doctors/Cases -> Case_Doctors'
);

DECLARE @test_id INT = SCOPE_IDENTITY();


-- Register Tables 

IF NOT EXISTS (SELECT 1 FROM dbo.tables_meta WHERE table_name = N'persons')
    INSERT INTO dbo.tables_meta (table_name, insert_proc_name) VALUES (N'persons', N'usp_insert_persons');

IF NOT EXISTS (SELECT 1 FROM dbo.tables_meta WHERE table_name = N'employees')
    INSERT INTO dbo.tables_meta (table_name, insert_proc_name) VALUES (N'employees', N'usp_insert_employees');

IF NOT EXISTS (SELECT 1 FROM dbo.tables_meta WHERE table_name = N'patients')
    INSERT INTO dbo.tables_meta (table_name, insert_proc_name) VALUES (N'patients', N'usp_insert_patients');

IF NOT EXISTS (SELECT 1 FROM dbo.tables_meta WHERE table_name = N'doctors')
    INSERT INTO dbo.tables_meta (table_name, insert_proc_name) VALUES (N'doctors', N'usp_insert_doctors');

IF NOT EXISTS (SELECT 1 FROM dbo.tables_meta WHERE table_name = N'cases')
    INSERT INTO dbo.tables_meta (table_name, insert_proc_name) VALUES (N'cases', N'usp_insert_cases');

IF NOT EXISTS (SELECT 1 FROM dbo.tables_meta WHERE table_name = N'case_doctors')
    INSERT INTO dbo.tables_meta (table_name, insert_proc_name) VALUES (N'case_doctors', N'usp_insert_case_doctors');

-- Get Table IDs

DECLARE @tid_persons INT, @tid_employees INT, @tid_patients INT;
DECLARE @tid_doctors INT, @tid_cases INT, @tid_case_docs INT;

SELECT @tid_persons   = table_id FROM dbo.tables_meta WHERE table_name = N'persons';
SELECT @tid_employees = table_id FROM dbo.tables_meta WHERE table_name = N'employees';
SELECT @tid_patients  = table_id FROM dbo.tables_meta WHERE table_name = N'patients';
SELECT @tid_doctors   = table_id FROM dbo.tables_meta WHERE table_name = N'doctors';
SELECT @tid_cases     = table_id FROM dbo.tables_meta WHERE table_name = N'cases';
SELECT @tid_case_docs = table_id FROM dbo.tables_meta WHERE table_name = N'case_doctors';

-- Configure Test Tables


INSERT INTO dbo.test_tables (test_id, table_id, no_of_rows, position)
VALUES
    (@test_id, @tid_case_docs,  1000, 1),
    (@test_id, @tid_cases,      1000, 2),
    (@test_id, @tid_doctors,    1000, 3),
    (@test_id, @tid_patients,   1000, 4),
    (@test_id, @tid_employees,  1000, 5),
    (@test_id, @tid_persons,    3000, 6);

-- Register Views

IF NOT EXISTS (SELECT 1 FROM dbo.views_meta WHERE view_name = N'v_persons_basic')
    INSERT INTO dbo.views_meta (view_name) VALUES (N'v_persons_basic');

IF NOT EXISTS (SELECT 1 FROM dbo.views_meta WHERE view_name = N'v_employees_with_person')
    INSERT INTO dbo.views_meta (view_name) VALUES (N'v_employees_with_person');

IF NOT EXISTS (SELECT 1 FROM dbo.views_meta WHERE view_name = N'v_cases_by_doctor')
    INSERT INTO dbo.views_meta (view_name) VALUES (N'v_cases_by_doctor');

DECLARE @vid_1 INT, @vid_2 INT, @vid_3 INT;

SELECT @vid_1 = view_id FROM dbo.views_meta WHERE view_name = N'v_persons_basic';
SELECT @vid_2 = view_id FROM dbo.views_meta WHERE view_name = N'v_employees_with_person';
SELECT @vid_3 = view_id FROM dbo.views_meta WHERE view_name = N'v_cases_by_doctor';

INSERT INTO dbo.test_views (test_id, view_id)
VALUES
    (@test_id, @vid_1),
    (@test_id, @vid_2),
    (@test_id, @vid_3);
