USE private_medical_clinic_db;
GO

PRINT '--- WIPING DATABASE ---';


-- 1) Drop all foreign keys

DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql = @sql + N'
ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) 
    + N'.' + QUOTENAME(OBJECT_NAME(parent_object_id)) +
    N' DROP CONSTRAINT ' + QUOTENAME(name) + ';'
FROM sys.foreign_keys;

EXEC (@sql);


-- 2) Drop all tables

SET @sql = N'';

SELECT @sql = @sql + N'
DROP TABLE ' + QUOTENAME(s.name) + N'.' + QUOTENAME(t.name) + ';'
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
ORDER BY t.name;

EXEC (@sql);


-- 3) Drop all views

SET @sql = N'';

SELECT @sql = @sql + N'
DROP VIEW ' + QUOTENAME(s.name) + N'.' + QUOTENAME(v.name) + ';'
FROM sys.views v
JOIN sys.schemas s ON v.schema_id = s.schema_id;

EXEC (@sql);


-- 4) Drop all stored procedures

SET @sql = N'';

SELECT @sql = @sql + N'
DROP PROCEDURE ' + QUOTENAME(s.name) + N'.' + QUOTENAME(p.name) + ';'
FROM sys.procedures p
JOIN sys.schemas s ON p.schema_id = s.schema_id;

EXEC (@sql);


-- 5) Drop all user-defined functions

SET @sql = N'';

SELECT @sql = @sql + N'
DROP FUNCTION ' + QUOTENAME(s.name) + N'.' + QUOTENAME(f.name) + ';'
FROM sys.objects f
JOIN sys.schemas s ON f.schema_id = s.schema_id
WHERE f.type IN ('FN','IF','TF');

EXEC (@sql);


-- 6) Drop all triggers

SET @sql = N'';

SELECT @sql = @sql + N'
DROP TRIGGER ' + QUOTENAME(s.name) + N'.' + QUOTENAME(t.name) + ';'
FROM sys.triggers t
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE t.parent_id = 0;

EXEC (@sql);


PRINT '--- DATABASE WIPED ---';
