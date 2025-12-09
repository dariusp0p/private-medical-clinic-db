USE private_medical_clinic_db;


PRINT '--- WIPING DATABASE ---';


-- Drop all stored procedures
DECLARE @sql NVARCHAR(MAX);

SET @sql = N'';

SELECT @sql = @sql + N'
DROP PROCEDURE ' + QUOTENAME(s.name) + N'.' + QUOTENAME(p.name) + ';'
FROM sys.procedures p
JOIN sys.schemas s ON p.schema_id = s.schema_id
WHERE p.is_ms_shipped = 0;

IF @sql <> N'' EXEC(@sql);


-- Drop all user-defined functions (scalar, inline, TVF)

SET @sql = N'';

SELECT @sql = @sql + N'
DROP FUNCTION ' + QUOTENAME(s.name) + N'.' + QUOTENAME(f.name) + ';'
FROM sys.objects f
JOIN sys.schemas s ON f.schema_id = s.schema_id
WHERE f.is_ms_shipped = 0
  AND f.type IN ('FN','IF','TF');   -- scalar, inline, table-valued

IF @sql <> N'' EXEC(@sql);


-- Drop all views

SET @sql = N'';

SELECT @sql = @sql + N'
DROP VIEW ' + QUOTENAME(s.name) + N'.' + QUOTENAME(v.name) + ';'
FROM sys.views v
JOIN sys.schemas s ON v.schema_id = s.schema_id
WHERE v.is_ms_shipped = 0;

IF @sql <> N'' EXEC(@sql);


-- Drop all foreign keys

SET @sql = N'';

SELECT @sql = @sql + N'
ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(fk.parent_object_id)) +
    N'.' + QUOTENAME(OBJECT_NAME(fk.parent_object_id)) +
    N' DROP CONSTRAINT ' + QUOTENAME(fk.name) + ';'
FROM sys.foreign_keys fk
WHERE fk.is_ms_shipped = 0;

IF @sql <> N'' EXEC(@sql);


-- Drop all tables

SET @sql = N'';

SELECT @sql = @sql + N'
DROP TABLE ' + QUOTENAME(s.name) + N'.' + QUOTENAME(t.name) + ';'
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE t.is_ms_shipped = 0;

IF @sql <> N'' EXEC(@sql);


PRINT '--- DATABASE WIPED ---';
