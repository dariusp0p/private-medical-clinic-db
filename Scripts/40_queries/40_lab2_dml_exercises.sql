-- Failing Insert

INSERT INTO dbo.cases (patient_id, title, status)
VALUES (1, N'Impossible status test', N'waiting');


-- Updates 

UPDATE dbo.employees
SET salary = salary + 700
WHERE title = N'Doctor' AND salary BETWEEN 12000 AND 14000;

UPDATE dbo.persons
SET phone = NULL
WHERE email LIKE N'%@clinic.ro' AND phone IS NOT NULL AND NOT (last_name LIKE N'Stan%');

UPDATE dbo.invoices
SET payment_status = N'paid'
WHERE id IN (2) AND payment_status <> N'paid';


-- Deletes

DELETE a
FROM dbo.appointments AS a
WHERE a.status = N'cancelled' OR a.appointment_at < '2025-10-21 00:00:00';

DELETE cd
FROM dbo.case_doctors AS cd
JOIN dbo.cases AS c ON c.id = cd.case_id
WHERE c.severity IN (N'low') AND cd.assigned_at BETWEEN '2025-10-21' AND '2025-10-24' AND cd.doctor_id <> 2;
