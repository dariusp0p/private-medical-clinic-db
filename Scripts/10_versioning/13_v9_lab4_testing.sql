USE private_medical_clinic_db;


CREATE OR ALTER PROCEDURE dbo.usp_v9_up
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('dbo.tests', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.tests (
            test_id      INT IDENTITY(1,1) PRIMARY KEY,
            name         NVARCHAR(100) NOT NULL,
            description  NVARCHAR(1000) NULL
        );
    END

    IF OBJECT_ID('dbo.tables_meta', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.tables_meta (
            table_id         INT IDENTITY(1,1) PRIMARY KEY,
            table_name       NVARCHAR(128) NOT NULL UNIQUE,
            insert_proc_name NVARCHAR(128) NOT NULL
        );
    END

    IF OBJECT_ID('dbo.test_tables', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.test_tables (
            test_id    INT NOT NULL
                REFERENCES dbo.tests(test_id) ON DELETE CASCADE,
            table_id   INT NOT NULL
                REFERENCES dbo.tables_meta(table_id) ON DELETE CASCADE,
            no_of_rows INT NOT NULL,
            position   INT NOT NULL,
            PRIMARY KEY (test_id, table_id)
        );
    END

    IF OBJECT_ID('dbo.views_meta', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.views_meta (
            view_id   INT IDENTITY(1,1) PRIMARY KEY,
            view_name NVARCHAR(128) NOT NULL UNIQUE
        );
    END

    IF OBJECT_ID('dbo.test_views', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.test_views (
            test_id INT NOT NULL
                REFERENCES dbo.tests(test_id) ON DELETE CASCADE,
            view_id INT NOT NULL
                REFERENCES dbo.views_meta(view_id) ON DELETE CASCADE,
            PRIMARY KEY (test_id, view_id)
        );
    END

    IF OBJECT_ID('dbo.test_runs', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.test_runs (
            test_run_id INT IDENTITY(1,1) PRIMARY KEY,
            test_id     INT NOT NULL
                REFERENCES dbo.tests(test_id) ON DELETE CASCADE,
            started_at  DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
            ended_at    DATETIME2(3) NULL
        );
    END

    IF OBJECT_ID('dbo.test_run_tables', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.test_run_tables (
            test_run_id INT NOT NULL
                REFERENCES dbo.test_runs(test_run_id) ON DELETE CASCADE,
            table_id    INT NOT NULL
                REFERENCES dbo.tables_meta(table_id) ON DELETE CASCADE,
            start_at    DATETIME2(3) NOT NULL,
            end_at      DATETIME2(3) NOT NULL,
            duration_ms INT NOT NULL,
            PRIMARY KEY (test_run_id, table_id)
        );
    END

    IF OBJECT_ID('dbo.test_run_views', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.test_run_views (
            test_run_id INT NOT NULL
                REFERENCES dbo.test_runs(test_run_id) ON DELETE CASCADE,
            view_id     INT NOT NULL
                REFERENCES dbo.views_meta(view_id) ON DELETE CASCADE,
            start_at    DATETIME2(3) NOT NULL,
            end_at      DATETIME2(3) NOT NULL,
            duration_ms INT NOT NULL,
            PRIMARY KEY (test_run_id, view_id)
        );
    END
END;


CREATE OR ALTER PROCEDURE dbo.usp_v9_down
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('dbo.test_run_views', 'U') IS NOT NULL
        DROP TABLE dbo.test_run_views;

    IF OBJECT_ID('dbo.test_run_tables', 'U') IS NOT NULL
        DROP TABLE dbo.test_run_tables;

    IF OBJECT_ID('dbo.test_runs', 'U') IS NOT NULL
        DROP TABLE dbo.test_runs;

    IF OBJECT_ID('dbo.test_views', 'U') IS NOT NULL
        DROP TABLE dbo.test_views;

    IF OBJECT_ID('dbo.views_meta', 'U') IS NOT NULL
        DROP TABLE dbo.views_meta;

    IF OBJECT_ID('dbo.test_tables', 'U') IS NOT NULL
        DROP TABLE dbo.test_tables;

    IF OBJECT_ID('dbo.tables_meta', 'U') IS NOT NULL
        DROP TABLE dbo.tables_meta;

    IF OBJECT_ID('dbo.tests', 'U') IS NOT NULL
        DROP TABLE dbo.tests;
END;


-- register version 9

INSERT INTO dbo.schema_version_steps (version_number, up_procedure_name, down_procedure_name)
VALUES (9, 'dbo.usp_v9_up', 'dbo.usp_v9_down');
