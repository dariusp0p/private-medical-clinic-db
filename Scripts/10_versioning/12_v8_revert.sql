USE private_medical_clinic_db;


-- v8 - undo everything v1 -> v7 did

CREATE PROCEDURE dbo.usp_v8_up
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.usp_v7_down;  -- drop audit_log
    EXEC dbo.usp_v6_down;  -- re-add FK_payments_invoice
    EXEC dbo.usp_v5_down;  -- drop UQ_persons_email
    EXEC dbo.usp_v4_down;  -- re-add PK_appointments
    EXEC dbo.usp_v3_down;  -- drop DF_payments_method_default
    EXEC dbo.usp_v2_down;  -- drop emergency_contact_phone, re-add insurance_provider
    EXEC dbo.usp_v1_down;  -- set persons.phone back to NVARCHAR(40)
END;

CREATE PROCEDURE dbo.usp_v8_down
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.usp_v1_up;  -- phone NVARCHAR(30)
    EXEC dbo.usp_v2_up;  -- add emergency_contact_phone, drop insurance_provider
    EXEC dbo.usp_v3_up;  -- add DF_payments_method_default
    EXEC dbo.usp_v4_up;  -- drop PK on appointments
    EXEC dbo.usp_v5_up;  -- add UQ_persons_email
    EXEC dbo.usp_v6_up;  -- drop FK_payments_invoice
    EXEC dbo.usp_v7_up;  -- create audit_log
END;


-- Register v8 in schema_version_steps

INSERT INTO dbo.schema_version_steps (version_number, up_procedure_name, down_procedure_name)
VALUES (8, 'dbo.usp_v8_up', 'dbo.usp_v8_down');
