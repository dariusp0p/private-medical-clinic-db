USE private_medical_clinic_db;


EXEC dbo.usp_get_version @target_version = 9;
SELECT * FROM dbo.schema_version;


DEALLOCATE cur_delete;
DEALLOCATE cur_insert;
DEALLOCATE cur_views;


SELECT * FROM dbo.tests;
EXEC dbo.usp_run_test @test_id = 3;


SELECT * FROM dbo.test_runs;

SELECT 
    tr.test_run_id,
    t.name AS test_name,
    tr.started_at,
    tr.ended_at,
    DATEDIFF(MILLISECOND, tr.started_at, tr.ended_at) AS total_duration_ms
FROM dbo.test_runs tr
JOIN dbo.tests t ON t.test_id = tr.test_id
ORDER BY tr.started_at DESC;


SELECT * FROM dbo.tests;

SELECT * FROM dbo.views_meta;
SELECT * FROM dbo.test_views;

SELECT * FROM dbo.tables_meta;
SELECT * FROM dbo.test_tables;

SELECT * FROM dbo.test_run_views;
SELECT * FROM dbo.test_run_tables;

SELECT * FROM dbo.test_runs;
