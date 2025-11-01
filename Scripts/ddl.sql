USE private_medical_clinic_db;

CREATE TABLE dbo.persons (
	ID INT IDENTITY(1,1) PRIMARY KEY,
	first_name NVARCHAR(50) NOT NULL,
	last_name NVARCHAR(50) NOT NULL,
	birthday DATE,
	phone NVARCHAR(20),
	email NVARCHAR(150)	
);

CREATE TABLE dbo.employees (
	ID INT IDENTITY(1, 1) PRIMARY KEY,
	person_id INT NOT NULL,
	title NVARCHAR(100) NOT NULL,
	hire_date DATE NOT NULL,
	salary DECIMAL(8,2)
	CONSTRAINT UQ_employees_person UNIQUE (person_id), 
	CONSTRAINT FK_employees_persons
		FOREIGN KEY (person_id) REFERENCES dbo.persons(id) ON DELETE CASCADE
);

CREATE TABLE dbo.doctors (
	ID INT IDENTITY(1, 1) PRIMARY KEY,
	employee_id INT NOT NULL,
	specialization NVARCHAR(150),
	license_number NVARCHAR(50) NULL UNIQUE,
	CONSTRAINT UQ_doctors_employee UNIQUE (employee_id),
	CONSTRAINT FK_doctors_employees
		FOREIGN KEY (employee_id) REFERENCES dbo.employees(id) ON DELETE CASCADE
);

CREATE TABLE dbo.app_users (
	ID INT IDENTITY(1,1) PRIMARY KEY,
	person_id INT,
	username NVARCHAR(50) NOT NULL,
	password_hash VARBINARY(256) NOT NULL,
	role NVARCHAR(50) NOT NULL CONSTRAINT DF_app_users_role DEFAULT (N'guest'),
	is_active BIT NOT NULL CONSTRAINT DF_app_users_is_active DEFAULT (1),
	created_at DATETIME2(0) NOT NULL CONSTRAINT DF_app_users_created_at DEFAULT (SYSUTCDATETIME()),
	CONSTRAINT UQ_app_users_username UNIQUE (username),
	CONSTRAINT CK_app_users_role CHECK (role IN (N'doctor', N'nurse', N'patient', N'admin', N'receptionist', N'guest')),
    CONSTRAINT FK_app_users_persons
        FOREIGN KEY (person_id) REFERENCES dbo.persons(id) ON DELETE SET NULL
);

CREATE TABLE dbo.patients (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    person_id INT NOT NULL,
    registration_date DATE NOT NULL,
    insurance_provider NVARCHAR(150) NULL,
    CONSTRAINT UQ_patients_person UNIQUE (person_id),
    CONSTRAINT FK_patients_persons
        FOREIGN KEY (person_id) REFERENCES dbo.persons(id) ON DELETE CASCADE
);

CREATE TABLE dbo.cases (
	ID INT IDENTITY(1,1) PRIMARY KEY,
	patient_id INT NOT NULL
		CONSTRAINT FK_cases_patients REFERENCES dbo.patients(id) ON DELETE CASCADE,
	title NVARCHAR(200) NOT NULL,
	description NVARCHAR(2000) NULL,
	severity NVARCHAR(20) NULL,
	status NVARCHAR(20) NOT NULL 
		CONSTRAINT DF_cases_status DEFAULT (N'open'),
	opened_at DATETIME2(0) NOT NULL
		CONSTRAINT DF_cases_opened_at DEFAULT (SYSUTCDATETIME()),
	closed_at DATETIME2(0) NULL,
	CONSTRAINT CK_cases_status CHECK (status IN (N'open', N'closed')),
	CONSTRAINT CK_cases_time CHECK (closed_at IS NULL OR closed_at >= opened_at)
);

CREATE TABLE dbo.case_doctors (
    case_id INT NOT NULL
        CONSTRAINT FK_case_doctors_case REFERENCES dbo.cases(id) ON DELETE CASCADE,
    doctor_id INT NOT NULL
        CONSTRAINT FK_case_doctors_doctor REFERENCES dbo.doctors(id) ON DELETE NO ACTION,
    assigned_at DATETIME2(0) NOT NULL
        CONSTRAINT DF_case_doctors_assigned_at DEFAULT (SYSUTCDATETIME()),
    unassigned_at DATETIME2(0) NULL,
    CONSTRAINT PK_case_doctors PRIMARY KEY (case_id, doctor_id),
);

CREATE TABLE dbo.appointments (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    case_id INT NULL
        CONSTRAINT FK_appointments_case REFERENCES dbo.cases(id) ON DELETE CASCADE,
    title NVARCHAR(200) NOT NULL,
    description NVARCHAR(2000) NULL,
    price DECIMAL(8,2) NOT NULL,
    appointment_at DATETIME2(0) NOT NULL
        CONSTRAINT DF_appointments_date DEFAULT (SYSUTCDATETIME()),
    status NVARCHAR(20) NOT NULL
        CONSTRAINT DF_appointments_status DEFAULT (N'scheduled'),
    CONSTRAINT CK_appointments_status CHECK (status IN (N'scheduled', N'completed', N'cancelled'))
);

CREATE TABLE dbo.invoices (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    case_id INT NOT NULL
        CONSTRAINT FK_invoices_case REFERENCES dbo.cases(id) ON DELETE CASCADE,
    issued_at DATETIME2(0) NOT NULL
        CONSTRAINT DF_invoices_issued_at DEFAULT (SYSUTCDATETIME()),
    payment_status NVARCHAR(20) NOT NULL
        CONSTRAINT DF_invoices_payment_status DEFAULT (N'unpaid'),
    CONSTRAINT CK_invoices_payment_status CHECK (payment_status IN (N'unpaid', N'paid'))
);

CREATE TABLE dbo.payments (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    invoice_id INT NOT NULL
        CONSTRAINT FK_payments_invoice REFERENCES dbo.invoices(id) ON DELETE CASCADE,
    payment_date DATETIME2(0) NOT NULL
        CONSTRAINT DF_payments_date DEFAULT (SYSUTCDATETIME()),
    amount DECIMAL(12,2) NOT NULL,
    method NVARCHAR(30) NOT NULL,
    status NVARCHAR(20) NOT NULL
        CONSTRAINT DF_payments_status DEFAULT (N'completed'),
    CONSTRAINT CK_payments_status CHECK (status IN (N'completed', N'pending', N'failed'))
);