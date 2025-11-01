Private Medical Clinic

==Tables==
persons (id, first_name, last_name, birthday, phone, email)
employees (id, title, person_id, hire_date, salary)
doctors (id, employee_id, specialization, license_number)
patients (id, person_id, registration_date, insurance_provider)
app_users (id, person_id, username, password_hash, role, is_active, created at)

cases (MM: doctors)
appointments

invoices
payments

*staff_shifts
*lab_tests
*interventions
*prescriptions