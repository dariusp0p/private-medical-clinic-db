USE private_medical_clinic_db;


CREATE OR ALTER PROCEDURE dbo.usp_v10_up
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('dbo.patient_doctor_links', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.patient_doctor_links (
            cid INT IDENTITY(1,1) PRIMARY KEY,
            aid INT NOT NULL,
            bid INT NOT NULL,
            relation_type INT NULL,

            CONSTRAINT FK_pdl_patients
                FOREIGN KEY (aid)
                REFERENCES dbo.patients(ID)
                ON DELETE CASCADE,

            CONSTRAINT FK_pdl_doctors
                FOREIGN KEY (bid)
                REFERENCES dbo.doctors(ID)
                ON DELETE CASCADE
        );
    END;

            
    -- Indexes

    -- On Ta = patients (for scans/seeks/key lookups)
    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = 'IX_patients_person_id'
          AND object_id = OBJECT_ID('dbo.patients')
    )
    BEGIN
        CREATE NONCLUSTERED INDEX IX_patients_person_id
        ON dbo.patients(person_id);
    END;

    -- On Tb = doctors (for WHERE b2 = value; here b2 = employee_id)
    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = 'IX_doctors_employee_id'
          AND object_id = OBJECT_ID('dbo.doctors')
    )
    BEGIN
        CREATE NONCLUSTERED INDEX IX_doctors_employee_id
        ON dbo.doctors(employee_id);
    END;

    -- On Tc-like join table = case_doctors (for doctor-centric queries / view)
    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = 'IX_case_doctors_doctor_id'
          AND object_id = OBJECT_ID('dbo.case_doctors')
    )
    BEGIN
        CREATE NONCLUSTERED INDEX IX_case_doctors_doctor_id
        ON dbo.case_doctors(doctor_id);
    END;
END;


CREATE OR ALTER PROCEDURE dbo.usp_v10_down
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = 'IX_case_doctors_doctor_id'
          AND object_id = OBJECT_ID('dbo.case_doctors')
    )
    BEGIN
        DROP INDEX IX_case_doctors_doctor_id ON dbo.case_doctors;
    END;

    IF EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = 'IX_doctors_employee_id'
          AND object_id = OBJECT_ID('dbo.doctors')
    )
    BEGIN
        DROP INDEX IX_doctors_employee_id ON dbo.doctors;
    END;

    IF EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = 'IX_patients_person_id'
          AND object_id = OBJECT_ID('dbo.patients')
    )
    BEGIN
        DROP INDEX IX_patients_person_id ON dbo.patients;
    END;


    IF OBJECT_ID('dbo.patient_doctor_links', 'U') IS NOT NULL
    BEGIN
        DROP TABLE dbo.patient_doctor_links;
    END;
END;


INSERT INTO dbo.schema_version_steps (version_number, up_procedure_name, down_procedure_name)
VALUES (9, 'dbo.usp_v10_up', 'dbo.usp_v10_down');
