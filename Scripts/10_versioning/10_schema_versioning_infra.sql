USE private_medical_clinic_db;


-- current schema version table

IF OBJECT_ID('dbo.schema_version', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.schema_version (
        current_version INT NOT NULL
    );

	INSERT INTO dbo.schema_version(current_version) VALUES (0);
END;


-- version steps table

IF OBJECT_ID('dbo.schema_version_steps', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.schema_version_steps (
        version_number      INT      NOT NULL PRIMARY KEY,
        up_procedure_name   SYSNAME  NOT NULL,
        down_procedure_name SYSNAME  NOT NULL
    );
END;


-- get version procedure

CREATE OR ALTER PROCEDURE dbo.usp_get_version
    @target_version INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @current INT;
    DECLARE @maxVersion INT;

    SELECT @current = current_version
    FROM dbo.schema_version WITH (UPDLOCK, HOLDLOCK);

    SELECT @maxVersion = ISNULL(MAX(version_number), 0)
    FROM dbo.schema_version_steps;

    IF @target_version < 0 OR @target_version > @maxVersion
    BEGIN
        RAISERROR('Target version %d is outside allowed range [0, %d].',
                  16, 1, @target_version, @maxVersion);
        RETURN;
    END;

    IF @current = @target_version
        RETURN;

    DECLARE @step INT;
    DECLARE @proc SYSNAME;
    DECLARE @sql  NVARCHAR(MAX);

    BEGIN TRY
        BEGIN TRAN;

        IF @current < @target_version
        BEGIN
            SET @step = @current + 1;

            WHILE @step <= @target_version
            BEGIN
                SET @proc = NULL;

                SELECT @proc = up_procedure_name
                FROM dbo.schema_version_steps
                WHERE version_number = @step;

                IF @proc IS NULL
                BEGIN
                    RAISERROR('No UP procedure defined for version %d.', 16, 1, @step);
                END;

                SET @sql = N'EXEC ' + @proc + N';';
                EXEC sp_executesql @sql;

                UPDATE dbo.schema_version SET current_version = @step;

                SET @step = @step + 1;
            END
        END
        ELSE
        BEGIN
            SET @step = @current;

            WHILE @step > @target_version
            BEGIN
                SET @proc = NULL;

                SELECT @proc = down_procedure_name
                FROM dbo.schema_version_steps
                WHERE version_number = @step;

                IF @proc IS NULL
                BEGIN
                    RAISERROR('No DOWN procedure defined for version %d.', 16, 1, @step);
                END;

                SET @sql = N'EXEC ' + @proc + N';';
                EXEC sp_executesql @sql;

                SET @step = @step - 1;

                UPDATE dbo.schema_version SET current_version = @step;
            END
        END

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;
        THROW;
    END CATCH
END;
