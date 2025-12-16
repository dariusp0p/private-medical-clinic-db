USE private_medical_clinic_db;


--  a) 

-- clustered index scan (patients)
SELECT *
FROM dbo.patients;

-- another clustered index scan (no index on registration_date).
SELECT *
FROM dbo.patients
WHERE registration_date >= '2000-01-01';


-- clustered index seek (patients)
SELECT *
FROM dbo.patients
WHERE ID = 1;


-- nonclustered index scan (IX_patients_person_id)
SELECT person_id
FROM dbo.patients;


-- nonclustered index seek (IX_patients_person_id)
SELECT person_id
FROM dbo.patients
WHERE person_id = 1;


-- nonclustered index seek + key lookup
-- Uses nonclustered index on person_id, then key lookup to get extra columns.
SELECT person_id, 
FROM dbo.patients
WHERE person_id = 10;


-- b) 

SELECT ID,
	   specialization
FROM dbo.doctors
WHERE employee_id = 1;



-- c) View joining at least 2 tables: vw_open_cases_per_doctor (doctors + case_doctors + cases)

CREATE OR ALTER VIEW dbo.vw_open_cases_per_doctor
AS
SELECT
    d.ID              AS doctor_id,
    d.employee_id     AS doctor_employee_id,
    d.specialization,
    cd.case_id,
    cd.assigned_at,
    cd.unassigned_at,
    c.patient_id,
    c.title           AS case_title,
    c.description     AS case_description,
    c.severity,
    c.status          AS case_status,
    c.opened_at,
    c.closed_at
FROM dbo.doctors d
JOIN dbo.case_doctors cd
    ON cd.doctor_id = d.ID
JOIN dbo.cases c
    ON c.ID = cd.case_id
WHERE
    c.status = N'open'
    AND cd.unassigned_at IS NULL;


SELECT *
FROM dbo.vw_open_cases_per_doctor
WHERE doctor_id = 1;

SELECT *
FROM dbo.vw_open_cases_per_doctor;
