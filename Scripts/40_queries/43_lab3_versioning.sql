USE private_medical_clinic_db;
GO


-- test

SELECT * FROM dbo.schema_version;
SELECT * FROM dbo.schema_version_steps ORDER BY version_number;


EXEC dbo.usp_get_version @target_version = 0;
SELECT * FROM dbo.schema_version;


EXEC sp_help 'dbo.persons';   
EXEC dbo.usp_get_version @target_version = 1;
SELECT * FROM dbo.schema_version;
EXEC sp_help 'dbo.persons';  


EXEC sp_help 'dbo.patients'; 
EXEC sp_help 'dbo.payments'; 
EXEC dbo.usp_get_version @target_version = 3;
SELECT * FROM dbo.schema_version;
EXEC sp_help 'dbo.patients'; 
EXEC sp_help 'dbo.payments'; 


EXEC sp_help 'dbo.appointments'; -- drops primary
EXEC sp_help 'dbo.persons'; -- adds unique
EXEC sp_help 'dbo.payments'; -- drops foreign

EXEC dbo.usp_get_version @target_version = 7;
SELECT * FROM dbo.schema_version;

EXEC sp_help 'dbo.appointments'; 
EXEC sp_help 'dbo.persons'; 
EXEC sp_help 'dbo.payments'; 
SELECT * FROM sys.tables WHERE name = 'audit_log';


EXEC dbo.usp_get_version @target_version = 4;
SELECT * FROM dbo.schema_version;

EXEC sp_help 'dbo.persons'; 
EXEC sp_help 'dbo.payments'; 



EXEC dbo.usp_get_version @target_version = 4;
SELECT * FROM dbo.schema_version;


BEGIN TRY
    EXEC dbo.usp_get_version @target_version = 999;
END TRY
BEGIN CATCH
    PRINT 'ERROR CAUGHT (GOOD):';
    PRINT ERROR_MESSAGE();
END CATCH;
