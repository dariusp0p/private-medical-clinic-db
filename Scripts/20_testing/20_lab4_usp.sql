USE private_medical_clinic_db;

-- This script contains the procedures that are used by the tests to insert data into the table


CREATE OR ALTER PROCEDURE dbo.usp_insert_persons
    @rows INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 1;
   
    DECLARE @offset INT = (SELECT ISNULL(MAX(id), 0) FROM dbo.persons);

    WHILE @i <= @rows
    BEGIN
        INSERT INTO dbo.persons (first_name, last_name, birthday, phone, email)
        VALUES (
            CONCAT(N'First', @i + @offset),
            CONCAT(N'Last',  @i + @offset),
            DATEADD(DAY, -(@i % 10000), CAST('1985-01-01' AS date)),
            CONCAT(N'+40 7', RIGHT('00000000' + CAST(@i + @offset AS NVARCHAR(8)), 8)),
            CONCAT(N'user', @i + @offset, N'@example.com')
        );

        SET @i += 1;
    END
END;


CREATE OR ALTER PROCEDURE dbo.usp_insert_employees
    @rows INT
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH free_persons AS (
        SELECT TOP (@rows)
               p.id,
               ROW_NUMBER() OVER (ORDER BY p.id) AS rn
        FROM dbo.persons p
        LEFT JOIN dbo.employees e ON e.person_id = p.id
        WHERE e.id IS NULL
    )
    INSERT INTO dbo.employees (person_id, title, hire_date, salary)
    SELECT
        fp.id,
        CONCAT(N'Title ', fp.rn),
        DATEADD(DAY, -fp.rn, CAST('2020-01-01' AS date)),
        3000 + 10 * fp.rn
    FROM free_persons fp;
END;


CREATE OR ALTER PROCEDURE dbo.usp_insert_doctors
    @rows INT
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH candidate_employees AS (
        SELECT TOP (@rows)
            e.id AS employee_id,
            ROW_NUMBER() OVER (ORDER BY e.id) AS rn
        FROM dbo.employees e
        LEFT JOIN dbo.doctors d ON d.employee_id = e.id
        WHERE d.id IS NULL
    )
    INSERT INTO dbo.doctors (employee_id, specialization, license_number)
    SELECT 
        employee_id,
        'General Specialist', 
        CONCAT('LIC-', employee_id, '-', LEFT(CAST(NEWID() AS VARCHAR(36)), 8))
    FROM candidate_employees;
END;


CREATE OR ALTER PROCEDURE dbo.usp_insert_patients
    @rows INT
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH free_persons AS (
        SELECT TOP (@rows)
               p.id,
               ROW_NUMBER() OVER (ORDER BY p.id) AS rn
        FROM dbo.persons p
        LEFT JOIN dbo.patients pt ON pt.person_id = p.id
        LEFT JOIN dbo.employees e ON e.person_id = p.id
        WHERE pt.id IS NULL AND e.id IS NULL 
    )
    INSERT INTO dbo.patients (person_id, registration_date, insurance_provider)
    SELECT
        id,
        DATEADD(DAY, -rn, CAST('2023-01-01' AS date)),
        'HealthCare Inc.'
    FROM free_persons;
END;


CREATE OR ALTER PROCEDURE dbo.usp_insert_cases
    @rows INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.patients)
    BEGIN
         RAISERROR('No patients found. Cannot insert cases.', 16, 1);
         RETURN;
    END

    INSERT INTO dbo.cases (patient_id, title, description, status, opened_at)
    SELECT TOP (@rows)
        p.id,
        CONCAT(N'Case for Patient ', p.id),
        N'Routine checkup description',
        N'open',
        SYSUTCDATETIME()
    FROM dbo.patients p;
END;


CREATE OR ALTER PROCEDURE dbo.usp_insert_case_doctors
    @rows INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.cases) OR NOT EXISTS (SELECT 1 FROM dbo.doctors)
    BEGIN
        RAISERROR('Need existing cases and doctors before inserting into case_doctors.', 16, 1);
        RETURN;
    END;

    ;WITH c AS (
        SELECT id AS case_id, ROW_NUMBER() OVER (ORDER BY id) AS rn FROM dbo.cases
    ),
    d AS (
        SELECT id AS doctor_id, ROW_NUMBER() OVER (ORDER BY id) AS rn FROM dbo.doctors
    ),
    n AS (
        SELECT TOP (@rows) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
        FROM sys.all_objects a CROSS JOIN sys.all_objects b
    ),
    pairs AS (
        SELECT
            c.case_id,
            d.doctor_id,
            ROW_NUMBER() OVER (ORDER BY c.case_id, d.doctor_id) AS row_num
        FROM n
        CROSS JOIN (SELECT MAX(rn) AS max_c FROM c) mc
        CROSS JOIN (SELECT MAX(rn) AS max_d FROM d) md
        JOIN c ON c.rn = ((n.rn - 1) % mc.max_c) + 1
        JOIN d ON d.rn = ((n.rn - 1) % md.max_d) + 1
    )
    INSERT INTO dbo.case_doctors (case_id, doctor_id, assigned_at)
    SELECT 
        case_id, 
        doctor_id, 
        DATEADD(MINUTE, -row_num, SYSUTCDATETIME())
    FROM pairs
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.case_doctors cd 
        WHERE cd.case_id = pairs.case_id AND cd.doctor_id = pairs.doctor_id
    );
END;
