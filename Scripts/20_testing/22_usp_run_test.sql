USE private_medical_clinic_db;

-- The actual procedure that runs a given test


CREATE OR ALTER PROCEDURE dbo.usp_run_test
    @test_id INT
AS
BEGIN
    SET NOCOUNT ON;
   
    IF NOT EXISTS (SELECT 1 FROM dbo.tests WHERE test_id = @test_id)
    BEGIN
        RAISERROR('Test %d does not exist.', 16, 1, @test_id);
        RETURN;
    END;

    DECLARE @TableResults TABLE (
        table_id    INT,
        start_at    DATETIME2(3),
        end_at      DATETIME2(3),
        duration_ms INT
    );

    DECLARE @ViewResults TABLE (
        view_id     INT,
        start_at    DATETIME2(3),
        end_at      DATETIME2(3),
        duration_ms INT
    );

    DECLARE
        @table_id      INT,
        @table_name    NVARCHAR(128),
        @no_of_rows    INT,
        @insert_proc   NVARCHAR(128),
        @view_id       INT,
        @view_name     NVARCHAR(128),
        @sql           NVARCHAR(MAX),
        @start_time    DATETIME2(3),
        @end_time      DATETIME2(3),
        @duration_ms   INT,
        @test_run_id   INT,
        @overall_start DATETIME2(3),
        @p_rows        INT;

    SET @overall_start = SYSUTCDATETIME();

    BEGIN TRY
        BEGIN TRAN TestData;
    
    	-- Delete

        DECLARE cur_delete CURSOR LOCAL FAST_FORWARD FOR
            SELECT tt.table_id, tm.table_name
            FROM dbo.test_tables tt
            JOIN dbo.tables_meta tm ON tm.table_id = tt.table_id
            WHERE tt.test_id = @test_id
            ORDER BY tt.position ASC;

        OPEN cur_delete;
        FETCH NEXT FROM cur_delete INTO @table_id, @table_name;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            
            SET @sql = N'DELETE FROM dbo.' + QUOTENAME(@table_name) + N';';
            EXEC sp_executesql @sql;

            FETCH NEXT FROM cur_delete INTO @table_id, @table_name;
        END;

        CLOSE cur_delete;
        DEALLOCATE cur_delete;

        -- Inserts 
        
        DECLARE cur_insert CURSOR LOCAL FAST_FORWARD FOR
            SELECT tt.table_id, tm.table_name, tm.insert_proc_name, tt.no_of_rows
            FROM dbo.test_tables tt
            JOIN dbo.tables_meta tm ON tm.table_id = tt.table_id
            WHERE tt.test_id = @test_id
            ORDER BY tt.position DESC;

        OPEN cur_insert;
        FETCH NEXT FROM cur_insert INTO @table_id, @table_name, @insert_proc, @no_of_rows;

        WHILE @@FETCH_STATUS = 0
        BEGIN

            SET @start_time = SYSUTCDATETIME();

            SET @sql = N'EXEC dbo.' + QUOTENAME(@insert_proc) + N' @rows = @x_rows;';
            
            EXEC sp_executesql @sql,
                               N'@x_rows INT',
                               @x_rows = @no_of_rows;

            SET @end_time    = SYSUTCDATETIME();
            SET @duration_ms = DATEDIFF(MILLISECOND, @start_time, @end_time);

            INSERT INTO @TableResults (table_id, start_at, end_at, duration_ms)
            VALUES (@table_id, @start_time, @end_time, @duration_ms);

            FETCH NEXT FROM cur_insert INTO @table_id, @table_name, @insert_proc, @no_of_rows;
        END;

        CLOSE cur_insert;
        DEALLOCATE cur_insert;

        -- Views 
        
        DECLARE cur_views CURSOR LOCAL FAST_FORWARD FOR
            SELECT tv.view_id, vm.view_name
            FROM dbo.test_views tv
            JOIN dbo.views_meta vm ON vm.view_id = tv.view_id
            WHERE tv.test_id = @test_id;

        OPEN cur_views;
        FETCH NEXT FROM cur_views INTO @view_id, @view_name;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @start_time = SYSUTCDATETIME();

            SET @sql = N'SELECT * FROM dbo.' + QUOTENAME(@view_name) + N';';
            EXEC sp_executesql @sql;

            SET @end_time    = SYSUTCDATETIME();
            SET @duration_ms = DATEDIFF(MILLISECOND, @start_time, @end_time);

            INSERT INTO @ViewResults (view_id, start_at, end_at, duration_ms)
            VALUES (@view_id, @start_time, @end_time, @duration_ms);

            FETCH NEXT FROM cur_views INTO @view_id, @view_name;
        END;

        CLOSE cur_views;
        DEALLOCATE cur_views;

        
        ROLLBACK TRAN TestData;

        INSERT INTO dbo.test_runs (test_id, started_at, ended_at)
        VALUES (
            @test_id,
            @overall_start,
            SYSUTCDATETIME()
        );

        SET @test_run_id = SCOPE_IDENTITY();

        INSERT INTO dbo.test_run_tables (test_run_id, table_id, start_at, end_at, duration_ms)
        SELECT @test_run_id, table_id, start_at, end_at, duration_ms
        FROM @TableResults;

        INSERT INTO dbo.test_run_views (test_run_id, view_id, start_at, end_at, duration_ms)
        SELECT @test_run_id, view_id, start_at, end_at, duration_ms
        FROM @ViewResults;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN TestData;

        IF CURSOR_STATUS('local', 'cur_delete') >= -1 DEALLOCATE cur_delete;
        IF CURSOR_STATUS('local', 'cur_insert') >= -1 DEALLOCATE cur_insert;
        IF CURSOR_STATUS('local', 'cur_views')  >= -1 DEALLOCATE cur_views;

        DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('usp_run_test failed: %s', 16, 1, @msg);
        RETURN;
    END CATCH;
END;
