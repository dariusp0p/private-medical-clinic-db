USE private_medical_clinic_db;


-- Q1. Find all patients (with ID, full name, and registration date)
-- who have an insurance provider registered.

SELECT p.id AS patient_id, 
	   per.first_name + ' ' + per.last_name AS full_name,
       p.registration_date
FROM dbo.patients AS p
JOIN dbo.persons AS per ON p.person_id = per.id
WHERE p.insurance_provider IS NOT NULL;


-- Q2. List all doctors along with their full names and specialization.
SELECT d.id AS doctor_id,
       per.first_name + ' ' + per.last_name AS doctor_name,
       d.specialization
FROM dbo.doctors AS d
JOIN dbo.employees AS e ON d.employee_id = e.id
JOIN dbo.persons AS per ON e.person_id = per.id;


-- Q3. Show all scheduled appointments with their title and the related case title.
SELECT a.id AS appointment_id,
       a.title AS appointment_title,
       a.status,
       c.title AS case_title
FROM dbo.appointments AS a
JOIN dbo.cases AS c ON a.case_id = c.id
WHERE a.status = 'scheduled';


-- Q4. Retrieve all persons who are either patients or doctors (using UNION to avoid duplicates).
SELECT per.id, per.first_name, per.last_name 
FROM dbo.persons AS per
JOIN dbo.patients AS p ON p.person_id = per.id
UNION
SELECT per.id, per.first_name, per.last_name 
FROM dbo.persons AS per
JOIN dbo.employees AS e ON e.person_id = per.id
JOIN dbo.doctors AS d ON d.employee_id = e.id;
