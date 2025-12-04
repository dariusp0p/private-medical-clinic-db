USE private_medical_clinic_db;
GO


-- Inserts for all tables

INSERT INTO dbo.persons (first_name, last_name, birthday, phone, email)
VALUES
(N'Andrei', N'Popa', '1990-03-12', N'+40 721 111 222', N'andrei.popa@gmail.com'),
(N'Elena', N'Ionescu', '1985-07-25', N'+40 722 333 444', N'elena.ionescu@yahoo.com'),
(N'Mihai', N'Dumitrescu', '1992-11-09', N'+40 723 555 666', N'mihai.dumitrescu@outlook.com'),
(N'Ioana', N'Radu', '1998-01-18', N'+40 724 777 888', N'ioana.radu@gmail.com'),
(N'Cristian', N'Marin', '1987-06-05', N'+40 725 999 000', N'cristian.marin@yahoo.com'),
(N'Gabriela', N'Pop', '1995-09-30', N'+40 726 123 456', N'gabriela.pop@gmail.com'),
(N'Alexandru', N'Stan', '1989-04-10', N'+40 727 234 567', N'alexandru.stan@clinic.ro'),
(N'Raluca', N'Georgescu', '1993-12-02', N'+40 728 345 678', N'raluca.georgescu@gmail.com'),
(N'Florin', N'Moldovan', '1991-08-16', N'+40 729 456 789', N'florin.moldovan@yahoo.com'),
(N'Denisa', N'Petrescu', '1997-02-21', N'+40 730 567 890', N'denisa.petrescu@gmail.com'),
(N'Vlad', N'Enache', '1984-10-07', N'+40 731 678 901', N'vlad.enache@outlook.com'),
(N'Monica', N'Iliescu', '1999-05-14', N'+40 732 789 012', N'monica.iliescu@gmail.com'),
(N'Rares', N'Serban', '1996-03-03', N'+40 733 890 123', N'rares.serban@yahoo.com'),
(N'Anca', N'Barbu', '1988-12-11', N'+40 734 901 234', N'anca.barbu@gmail.com'),
(N'Stefan', N'Costache', '1994-09-27', N'+40 735 012 345', N'stefan.costache@clinic.ro');

INSERT INTO dbo.employees (person_id, title, hire_date, salary)
VALUES
(1, N'Doctor', '2015-04-12', 12500.00),
(2, N'Nurse', '2018-07-01', 6800.00),
(3, N'Doctor', '2012-10-09', 13800.00),
(4, N'Receptionist', '2020-03-18', 5200.00),
(5, N'Doctor', '2010-11-22', 14500.00),
(6, N'Assistant', '2019-05-30', 4800.00),
(7, N'Nurse', '2016-09-10', 7100.00);

INSERT INTO dbo.patients (person_id, registration_date, insurance_provider)
VALUES
(8,  '2023-02-05', N'RegioSan'),
(9,  '2022-11-12', N'MedLife'),
(10, '2024-04-18', N'RegioSan'),
(11, '2024-06-27', N'MediHelp'),
(12, '2023-08-14', N'Allianz'),
(13, '2023-03-09', N'MedLife'),
(14, '2024-09-01', N'Allianz'),
(15, '2025-01-15', N'RegioSan');

INSERT INTO dbo.app_users (person_id, username, password_hash, role)
VALUES
(1,  N'andrei.popa', 0xABCD, N'doctor'),
(2,  N'elena.ionescu', 0xABCD, N'nurse'),
(3,  N'mihai.dumitrescu', 0xABCD, N'doctor'),
(4,  N'ioana.radu', 0xABCD, N'receptionist'),
(5,  N'cristian.marin', 0xABCD, N'doctor'),
(6,  N'gabriela.pop', 0xABCD, N'nurse'),
(8,  N'raluca.georgescu', 0xABCD, N'patient'),
(9,  N'florin.moldovan', 0xABCD, N'patient'),
(10, N'denisa.petrescu', 0xABCD, N'patient'),
(12, N'monica.iliescu', 0xABCD, N'patient');

INSERT INTO dbo.doctors (employee_id, specialization, license_number)
VALUES
(1, N'Cardiology', N'RO-DOC-001'),
(3, N'Neurology',  N'RO-DOC-002'),
(5, N'Dermatology', N'RO-DOC-003');

INSERT INTO dbo.cases (patient_id, title, description, severity, status, opened_at)
VALUES
(1, N'General checkup', N'Routine annual health evaluation', N'low', N'open', SYSUTCDATETIME()),
(2, N'Chest pain', N'Patient reports occasional chest pain during exercise', N'medium', N'open', SYSUTCDATETIME()),
(3, N'Migraine headaches', N'Chronic headaches for the past month', N'medium', N'open', SYSUTCDATETIME()),
(4, N'Skin irritation', N'Allergic reaction on hands', N'low', N'pending', SYSUTCDATETIME()),
(5, N'High blood pressure', N'Increased BP readings observed in the last week', N'high', N'open', SYSUTCDATETIME()),
(6, N'Fatigue', N'Low energy and tiredness', N'low', N'open', SYSUTCDATETIME()),
(7, N'Heart arrhythmia', N'Irregular heartbeat detected', N'high', N'pending', SYSUTCDATETIME()),
(8, N'Sore throat', N'Mild infection suspected', N'low', N'open', SYSUTCDATETIME());

INSERT INTO dbo.case_doctors (case_id, doctor_id)
VALUES
(1, 1),  -- Andrei Popa (Cardiology)
(2, 1),
(3, 2),  -- Mihai Dumitrescu (Neurology)
(4, 3),  -- Cristian Marin (Dermatology)
(5, 1),
(6, 2),
(7, 1),
(8, 3);

INSERT INTO dbo.appointments (case_id, title, description, price, appointment_at, status)
VALUES
(1, N'Initial consult', N'Vitals + anamnesis', 300.00, '2025-10-21 09:00:00', N'completed'),
(1, N'Follow-up ECG', N'ECG + BP monitoring', 250.00, '2025-10-28 09:30:00', N'scheduled'),
(2, N'Cardio assessment', N'Treadmill test preparation', 450.00, '2025-10-22 11:00:00', N'scheduled'),
(3, N'Neurology consult', N'Migraine evaluation', 400.00, '2025-10-21 14:00:00', N'completed'),
(3, N'MRI referral', N'Head MRI planning', 150.00, '2025-10-25 10:00:00', N'scheduled'),
(4, N'Dermatology exam', N'Allergy patch test', 220.00, '2025-10-23 10:30:00', N'scheduled'),
(5, N'Hypertension workup', N'ABPM setup', 500.00, '2025-10-21 16:00:00', N'completed'),
(6, N'General consult', N'Fatigue investigation', 280.00, '2025-10-24 09:45:00', N'scheduled'),
(7, N'Arrhythmia check', N'Holter placement', 520.00, '2025-10-22 08:30:00', N'completed'),
(7, N'Holter reading', N'Results discussion', 260.00, '2025-10-23 08:30:00', N'cancelled'),
(8, N'ENT consult', N'Throat culture', 210.00, '2025-10-21 10:30:00', N'completed');

INSERT INTO dbo.invoices (case_id, payment_status)
VALUES
(1, N'paid'), 
(2, N'unpaid'), 
(3, N'paid'), 
(4, N'unpaid'),
(5, N'paid'), 
(6, N'unpaid'), 
(7, N'paid'), 
(8, N'unpaid');

INSERT INTO dbo.payments (invoice_id, payment_date, amount, method, status)
VALUES
(1, '2025-10-21 11:00:00', 550.00, N'card', N'completed'),
(3, '2025-10-22 15:30:00', 400.00, N'cash', N'completed'),
(5, '2025-10-21 17:00:00', 500.00, N'bank transfer', N'completed'),
(7, '2025-10-23 10:00:00', 520.00, N'card', N'completed');
