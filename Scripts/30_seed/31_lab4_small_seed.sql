USE private_medical_clinic_db;


DECLARE 
    @person_doc_id INT,
    @employee_id   INT,
    @doctor_id     INT,
    @person_pat_id INT,
    @patient_id    INT,
    @case_id       INT;

-- doctor side
INSERT INTO dbo.persons (first_name, last_name, birthday, phone, email)
VALUES (N'TestDoctor', N'One', '1980-01-01', N'+40 700 000 001', N'test.doctor@example.com');
SET @person_doc_id = SCOPE_IDENTITY();

INSERT INTO dbo.employees (person_id, title, hire_date, salary)
VALUES (@person_doc_id, N'Doctor', GETDATE(), 10000);
SET @employee_id = SCOPE_IDENTITY();

INSERT INTO dbo.doctors (employee_id, specialization, license_number)
VALUES (@employee_id, N'Cardiology', N'TEST-DOC-001');
SET @doctor_id = SCOPE_IDENTITY();

-- patient + case side
INSERT INTO dbo.persons (first_name, last_name, birthday, phone, email)
VALUES (N'TestPatient', N'One', '1990-01-01', N'+40 700 000 002', N'test.patient@example.com');
SET @person_pat_id = SCOPE_IDENTITY();

-- at version >= 2 you have emergency_contact_phone instead of insurance_provider
INSERT INTO dbo.patients (person_id, registration_date, emergency_contact_phone)
VALUES (@person_pat_id, CAST(GETDATE() AS date), N'+40 711 111 111');
SET @patient_id = SCOPE_IDENTITY();


INSERT INTO dbo.cases (patient_id, title, description, severity, status, opened_at)
VALUES (@patient_id, N'Test case', N'Auto-generated for Lab 4', N'low', N'open', SYSUTCDATETIME());
SET @case_id = SCOPE_IDENTITY();