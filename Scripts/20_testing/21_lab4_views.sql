USE private_medical_clinic_db;

-- Here we add the views for testing


-- 1) View on ONE table (persons)

CREATE OR ALTER VIEW dbo.v_persons_basic
AS
SELECT
    id,
    first_name,
    last_name,
    email,
    birthday
FROM dbo.persons;


-- 2) View with JOIN on >= 2 tables (employees + persons)

CREATE OR ALTER VIEW dbo.v_employees_with_person
AS
SELECT
    e.id          AS employee_id,
    p.first_name,
    p.last_name,
    e.title,
    e.hire_date,
    e.salary
FROM dbo.employees e
JOIN dbo.persons   p ON e.person_id = p.id;


-- 3) View with JOIN + GROUP BY on >= 2 tables
--    (doctors + employees + persons + case_doctors + cases)

CREATE OR ALTER VIEW dbo.v_cases_by_doctor
AS
SELECT
    d.id              AS doctor_id,
    p.first_name,
    p.last_name,
    d.specialization,
    COUNT(DISTINCT c.id) AS no_cases
FROM dbo.doctors d
JOIN dbo.employees    e  ON e.id = d.employee_id
JOIN dbo.persons      p  ON p.id = e.person_id
LEFT JOIN dbo.case_doctors cd ON cd.doctor_id = d.id
LEFT JOIN dbo.cases         c ON c.id = cd.case_id
GROUP BY
    d.id,
    p.first_name,
    p.last_name,
    d.specialization;
