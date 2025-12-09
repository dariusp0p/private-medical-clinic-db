USE private_medical_clinic_db;


-- v1 - modifies the length of the phone field

CREATE PROCEDURE dbo.usp_v1_up
AS
BEGIN
    SET NOCOUNT ON;

    ALTER TABLE dbo.persons
        ALTER COLUMN phone NVARCHAR(30) NULL;
END;

CREATE PROCEDURE dbo.usp_v1_down
AS
BEGIN
    SET NOCOUNT ON;

    ALTER TABLE dbo.persons
        ALTER COLUMN phone NVARCHAR(40) NULL;
END;


-- v2 - adds emergency phone number and removes the insurance provider

CREATE PROCEDURE dbo.usp_v2_up
AS
BEGIN
    SET NOCOUNT ON;

    ALTER TABLE dbo.patients
        ADD emergency_contact_phone NVARCHAR(20) NULL;
    
    ALTER TABLE dbo.patients
        DROP COLUMN insurance_provider;
END;

CREATE PROCEDURE dbo.usp_v2_down
AS
BEGIN
    SET NOCOUNT ON;

    ALTER TABLE dbo.patients
        DROP COLUMN emergency_contact_phone;
    
    ALTER TABLE dbo.patients
        ADD insurance_provider NVARCHAR(150) NULL;
END;


-- v3 - adds a default value for the payment method

CREATE OR ALTER PROCEDURE dbo.usp_v3_up
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @dcName SYSNAME;
    DECLARE @sql NVARCHAR(MAX);

    SELECT @dcName = dc.name
    FROM sys.default_constraints dc
    JOIN sys.columns c 
        ON dc.parent_object_id = c.object_id 
       AND dc.parent_column_id = c.column_id
    JOIN sys.tables t 
        ON t.object_id = dc.parent_object_id
    WHERE t.name = 'payments'
      AND OBJECT_SCHEMA_NAME(t.object_id) = 'dbo'
      AND c.name = 'method';

    IF @dcName IS NOT NULL
    BEGIN
        SET @sql =
            N'ALTER TABLE dbo.payments DROP CONSTRAINT ' + QUOTENAME(@dcName) + N';';
        EXEC sp_executesql @sql;
    END;

    ALTER TABLE dbo.payments
        ADD CONSTRAINT DF_payments_method_default
            DEFAULT (N'cash') FOR method;
END;

CREATE OR ALTER PROCEDURE dbo.usp_v3_down
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM sys.default_constraints dc
        JOIN sys.tables t ON dc.parent_object_id = t.object_id
        WHERE dc.name = 'DF_payments_method_default'
          AND t.name = 'payments'
          AND OBJECT_SCHEMA_NAME(t.object_id) = 'dbo'
    )
    BEGIN
        ALTER TABLE dbo.payments
            DROP CONSTRAINT DF_payments_method_default;
    END
END;


-- v4 - drops PRIMARY KEY pe dbo.appointments

CREATE PROCEDURE dbo.usp_v4_up
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @pkName SYSNAME;

    SELECT @pkName = kc.name
    FROM sys.key_constraints kc
    JOIN sys.tables t ON kc.parent_object_id = t.object_id
    WHERE kc.[type] = 'PK'
      AND t.[name] = 'appointments'
      AND t.[schema_id] = SCHEMA_ID('dbo');

    IF @pkName IS NOT NULL
    BEGIN
        DECLARE @sql NVARCHAR(MAX) =
            N'ALTER TABLE dbo.appointments DROP CONSTRAINT ' + QUOTENAME(@pkName) + N';';
        EXEC sp_executesql @sql;
    END
END;

CREATE PROCEDURE dbo.usp_v4_down
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.key_constraints kc
        JOIN sys.tables t ON kc.parent_object_id = t.object_id
        WHERE kc.[type] = 'PK'
          AND t.[name] = 'appointments'
          AND t.[schema_id] = SCHEMA_ID('dbo')
    )
    BEGIN
        ALTER TABLE dbo.appointments
            ADD CONSTRAINT PK_appointments PRIMARY KEY(ID);
    END
END;


-- v5 - adds candidate key (UNIQUE) pe persons.email

CREATE PROCEDURE dbo.usp_v5_up
AS
BEGIN
    SET NOCOUNT ON;

    ALTER TABLE dbo.persons
        ADD CONSTRAINT UQ_persons_email UNIQUE (email);
END;

CREATE PROCEDURE dbo.usp_v5_down
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM sys.key_constraints kc
        JOIN sys.tables t ON kc.parent_object_id = t.object_id
        WHERE kc.[type] = 'UQ'
          AND kc.[name] = 'UQ_persons_email'
          AND t.[name] = 'persons'
          AND t.[schema_id] = SCHEMA_ID('dbo')
    )
    BEGIN
        ALTER TABLE dbo.persons
            DROP CONSTRAINT UQ_persons_email;
    END
END;


-- v6 - drop FOREIGN KEY FK_payments_invoice

CREATE PROCEDURE dbo.usp_v6_up
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_payments_invoice'
          AND parent_object_id = OBJECT_ID('dbo.payments')
    )
    BEGIN
        ALTER TABLE dbo.payments
            DROP CONSTRAINT FK_payments_invoice;
    END
END;

CREATE PROCEDURE dbo.usp_v6_down
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_payments_invoice'
          AND parent_object_id = OBJECT_ID('dbo.payments')
    )
    BEGIN
        ALTER TABLE dbo.payments
            ADD CONSTRAINT FK_payments_invoice
                FOREIGN KEY (invoice_id)
                REFERENCES dbo.invoices(id)
                ON DELETE CASCADE;
    END
END;


-- v7 - create table dbo.audit_log

CREATE PROCEDURE dbo.usp_v7_up
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('dbo.audit_log', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.audit_log (
            ID INT IDENTITY(1,1) PRIMARY KEY,
            table_name NVARCHAR(128) NOT NULL,
            operation  NVARCHAR(50)  NOT NULL,
            description NVARCHAR(4000) NULL,
            changed_at DATETIME2(0) NOT NULL
                CONSTRAINT DF_audit_log_changed_at DEFAULT (SYSUTCDATETIME())
        );
    END
END;

CREATE PROCEDURE dbo.usp_v7_down
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('dbo.audit_log', 'U') IS NOT NULL
    BEGIN
        DROP TABLE dbo.audit_log;
    END
END;



-- inserting the procedures into the version step table

INSERT INTO dbo.schema_version_steps (version_number, up_procedure_name, down_procedure_name)
VALUES
    (1, 'dbo.usp_v1_up', 'dbo.usp_v1_down'),
    (2, 'dbo.usp_v2_up', 'dbo.usp_v2_down'),
    (3, 'dbo.usp_v3_up', 'dbo.usp_v3_down'),
    (4, 'dbo.usp_v4_up', 'dbo.usp_v4_down'),
    (5, 'dbo.usp_v5_up', 'dbo.usp_v5_down'),
    (6, 'dbo.usp_v6_up', 'dbo.usp_v6_down'),
    (7, 'dbo.usp_v7_up', 'dbo.usp_v7_down');
