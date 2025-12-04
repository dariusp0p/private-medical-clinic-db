USE private_medical_clinic_db;


-- a)

-- queries the union of employees and patients
SELECT first_name, last_name
FROM dbo.persons
WHERE id IN (SELECT person_id FROM dbo.employees)
UNION
SELECT first_name, last_name
FROM dbo.persons
WHERE id IN (SELECT person_id FROM dbo.patients);

-- queries the patient name and title of the cases with medium and high severity
SELECT pe.first_name, pe.last_name, title
FROM dbo.cases c
JOIN dbo.patients pa ON c.patient_id = pa.id
JOIN dbo.persons pe ON pa.person_id = pe.id
WHERE severity = N'high'
UNION
SELECT pe.first_name, pe.last_name, title
FROM dbo.cases c
JOIN dbo.patients pa ON c.patient_id = pa.id
JOIN dbo.persons pe ON pa.person_id = pe.id
WHERE severity = N'medium'


-- b)

-- queries the employees that also have an app account
SELECT person_id
FROM dbo.employees 
INTERSECT
SELECT person_id
FROM dbo.app_users;

SELECT e.person_id
FROM dbo.employees e
WHERE e.person_id IN (SELECT person_id FROM dbo.app_users);

-- queries the names pf patients that also have an app account
SELECT pe.first_name + ' ' + pe.last_name as full_name
FROM dbo.patients pa
JOIN dbo.persons pe ON pa.person_id = pe.id
INTERSECT
SELECT pe.first_name + ' ' + pe.last_name as full_name
FROM dbo.app_users au
JOIN dbo.persons pe ON au.person_id = pe.id;

SELECT pe.first_name + ' ' + pe.last_name as full_name
FROM dbo.patients pa
JOIN dbo.persons pe ON pa.person_id = pe.ID
WHERE pa.person_id IN (SELECT person_id FROM dbo.app_users)


-- c)

-- queries the employees that don't have an app account
SELECT person_id
FROM dbo.employees
EXCEPT
SELECT person_id
FROM dbo.app_users;

SELECT person_id
FROM dbo.employees
WHERE person_id NOT IN (SELECT person_id FROM dbo.app_users);


-- d)

-- queries the top 2 best paid doctors
SELECT DISTINCT TOP (2) d.id AS doctor_id,
       p.first_name + ' ' + p.last_name AS doctor_name,
       d.specialization,
       (e.salary * 12) AS annual_salary
FROM dbo.doctors d
INNER JOIN dbo.employees e ON e.id = d.employee_id
INNER JOIN dbo.persons  p ON p.id = e.person_id
ORDER BY annual_salary DESC;

-- queries the each patient with the associated case count
SELECT pa.id AS patient_id, per.first_name + ' ' + per.last_name AS patient_name,
       COUNT(c.id) AS case_count
FROM dbo.patients pa
LEFT JOIN dbo.cases c ON c.patient_id = pa.id
INNER JOIN dbo.persons per ON per.id = pa.person_id
GROUP BY pa.id, per.first_name, per.last_name
ORDER BY case_count DESC;

-- queries the cases and the associated doctors 
SELECT c.id AS case_id, c.title, cd.doctor_id
FROM dbo.case_doctors cd
RIGHT JOIN dbo.cases c ON c.id = cd.case_id
ORDER BY c.id;

-- queries the cases with associated doctors and payment status
SELECT 
	d.id AS doctor_id, 
	CONCAT(p.first_name, ' ', p.last_name) AS doctor_name,
    ca.id AS case_id,
    ca.title AS case_title,
    pay.amount AS payment_amount,
    pay.status AS payment_status
FROM dbo.case_doctors cd
INNER JOIN dbo.doctors d ON cd.doctor_id = d.id
INNER JOIN dbo.employees e ON d.employee_id = e.id
INNER JOIN dbo.persons p ON e.person_id = p.id
INNER JOIN dbo.cases ca ON cd.case_id = ca.id
INNER JOIN dbo.invoices i ON i.case_id = ca.id
INNER JOIN dbo.payments pay ON pay.invoice_id = i.id
ORDER BY doctor_name;


-- e)

-- queries the patients that are active in the app
SELECT p.id AS patient_id, CONCAT(per.first_name, ' ', per.last_name) AS full_name
FROM dbo.patients p
JOIN dbo.persons per ON p.person_id = per.id
WHERE p.person_id IN (SELECT person_id FROM dbo.app_users WHERE is_active = 1);

-- queries the doctors assigned to cases of patients that have an app account
SELECT DISTINCT d.id AS doctor_id, CONCAT(per.first_name, ' ', per.last_name) AS doctor_name
FROM dbo.doctors d
JOIN dbo.employees e ON d.employee_id = e.id
JOIN dbo.persons per ON e.person_id = per.id
WHERE d.id IN (
	SELECT cd.doctor_id
    FROM dbo.case_doctors cd
    WHERE cd.case_id IN (
        SELECT c.id 
        FROM dbo.cases c
        WHERE c.patient_id IN (
            SELECT p.id 
            FROM dbo.patients p
            WHERE p.person_id IN (
                SELECT person_id FROM dbo.app_users WHERE role = N'patient'
            )
        )
    )
);


-- f)

-- queries the doctors that have at least one assigned case
SELECT d.id, CONCAT(per.first_name, ' ', per.last_name) AS doctor_name
FROM dbo.doctors d
JOIN dbo.employees e ON d.employee_id = e.id
JOIN dbo.persons per ON e.person_id = per.id
WHERE EXISTS (
    SELECT 1
    FROM dbo.case_doctors cd
    WHERE cd.doctor_id = d.id
);

-- queries the patients that have at least an unpaid service
SELECT p.id AS patient_id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM dbo.patients p
JOIN dbo.persons per ON p.person_id = per.id
WHERE EXISTS (
    SELECT 1
    FROM dbo.cases c
    JOIN dbo.invoices i ON i.case_id = c.id
    WHERE c.patient_id = p.id 
      AND i.payment_status = N'unpaid'
);


-- g)

-- queries the average payment amount per invoice
SELECT inv_id, AVG(amount) AS avg_payment
FROM (
    SELECT invoice_id AS inv_id, amount
    FROM dbo.payments
) AS sub
GROUP BY inv_id;


-- queries the doctors with annual salary above the overall average
SELECT d.id AS doctor_id, 
	CONCAT(p.first_name, ' ', p.last_name) AS doctor_name,
    e.salary * 12 AS annual_salary
FROM (
    SELECT AVG(e.salary * 12) AS avg_annual_salary
    FROM dbo.doctors d
    INNER JOIN dbo.employees e ON d.employee_id = e.ID 
) AS avg_tbl
JOIN dbo.doctors d ON 1=1
JOIN dbo.employees e ON d.employee_id = e.id
JOIN dbo.persons p ON e.person_id = p.id
WHERE e.salary * 12 > avg_tbl.avg_annual_salary;


-- h)

-- queries the doctors with the number of associated cases
SELECT d.id AS doctor_id, COUNT(cd.case_id) AS total_cases
FROM dbo.case_doctors cd
JOIN dbo.doctors d ON cd.doctor_id = d.id
GROUP BY d.id;

-- queries the doctors with more than 3 cases
SELECT d.id AS doctor_id, COUNT(cd.case_id) AS total_cases
FROM dbo.case_doctors cd
JOIN dbo.doctors d ON cd.doctor_id = d.id
GROUP BY d.id
HAVING COUNT(cd.case_id) > 3;

-- queries the patient that paid more than the average patient 
SELECT p.id AS patient_id, SUM(pay.amount) AS total_paid
FROM dbo.patients p
JOIN dbo.cases c ON c.patient_id = p.id
JOIN dbo.invoices i ON i.case_id = c.id
JOIN dbo.payments pay ON pay.invoice_id = i.id
GROUP BY p.id
HAVING SUM(pay.amount) > (
    SELECT AVG(amount) FROM dbo.payments
);

-- doctors with a number of cases that exceeds the average
SELECT d.id AS doctor_id, COUNT(DISTINCT cd.case_id) AS total_cases
FROM dbo.case_doctors cd
JOIN dbo.doctors d ON cd.doctor_id = d.id
GROUP BY d.id
HAVING COUNT(DISTINCT cd.case_id) >
(
    SELECT AVG(case_count)
    FROM (
        SELECT COUNT(DISTINCT case_id) AS case_count
        FROM dbo.case_doctors
        GROUP BY doctor_id
    ) AS sub
);


-- i)

-- queries the doctors that have salaries bigger than any nurse
SELECT d.id, CONCAT(p.first_name, ' ', p.last_name) AS doctor_name
FROM dbo.doctors d
JOIN dbo.employees e ON d.employee_id = e.id
JOIN dbo.persons p ON e.person_id = p.id
WHERE e.salary > ANY (
    SELECT e2.salary
    FROM dbo.employees e2
    WHERE e2.title LIKE '%nurse%'
);

SELECT d.id, CONCAT(p.first_name, ' ', p.last_name) AS doctor_name
FROM dbo.doctors d
JOIN dbo.employees e ON d.employee_id = e.id
JOIN dbo.persons p ON e.person_id = p.id
WHERE e.salary > (SELECT MIN(e2.salary) FROM dbo.employees e2 WHERE e2.title LIKE '%nurse%');


-- queries the doctors that have salaries bigger than all receptionists
SELECT d.id, CONCAT(p.first_name, ' ', p.last_name) AS doctor_name
FROM dbo.doctors d
JOIN dbo.employees e ON d.employee_id = e.id
JOIN dbo.persons p ON e.person_id = p.id
WHERE e.salary > ALL (
    SELECT e2.salary
    FROM dbo.employees e2
    WHERE e2.title LIKE '%receptionist%'
);

SELECT d.id, CONCAT(p.first_name, ' ', p.last_name) AS doctor_name
FROM dbo.doctors d
JOIN dbo.employees e ON d.employee_id = e.id
JOIN dbo.persons p ON e.person_id = p.id
WHERE e.salary > (SELECT MAX(e2.salary) FROM dbo.employees e2 WHERE e2.title LIKE '%receptionist%');

-- queries employees whose salary is greater than any of the nurse salaries
SELECT e.id AS employee_id, CONCAT(p.first_name, ' ', p.last_name) AS employee_name, e.salary
FROM dbo.employees e
JOIN dbo.persons p ON e.person_id = p.id
WHERE e.salary > (
    SELECT MIN(e2.salary)
    FROM dbo.employees e2
    WHERE e2.title IN ('nurse', 'assistant nurse')
);

-- queries employees whose salary is not the same as anyone in a certain group
SELECT e.id AS employee_id, CONCAT(p.first_name, ' ', p.last_name) AS employee_name, e.title, e.salary
FROM dbo.employees e
JOIN dbo.persons p ON e.person_id = p.id
WHERE e.salary NOT IN (
    SELECT salary
    FROM dbo.employees e2
    WHERE e2.title LIKE '%receptionist%'
);




