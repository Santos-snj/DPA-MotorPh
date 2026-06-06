CREATE DATABASE IF NOT EXISTS motorph_employee_management_system;

USE motorph_employee_management_system;


/*CORE EMPLOYEE MANAGEMENT */

CREATE TABLE IF NOT EXISTS department (
    department_id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(50),
    description TEXT,
    PRIMARY KEY (department_id)
);


CREATE TABLE IF NOT EXISTS employee_position (
    position_id INT NOT NULL AUTO_INCREMENT,
    department_id INT,
    name VARCHAR(50),
    description VARCHAR(215),
    PRIMARY KEY (position_id),
    FOREIGN KEY (department_id) REFERENCES department(department_id)
);


CREATE TABLE IF NOT EXISTS status (
    status_id INT NOT NULL AUTO_INCREMENT,
    status_name VARCHAR(20),
    PRIMARY KEY (status_id)
);


CREATE TABLE IF NOT EXISTS employee_profile (
    employee_id INT NOT NULL AUTO_INCREMENT,
    last_name VARCHAR(50),
    first_name VARCHAR(50),
    address_id INT, 
    birthday DATE,
    phone_number VARCHAR(15),
    hire_date DATE,
    email VARCHAR(25),
    department_id INT,
    position_id INT,
    status_id INT,
    supervisor_id INT,
    is_active BOOLEAN,
    PRIMARY KEY (employee_id),
    FOREIGN KEY (department_id) REFERENCES department(department_id),
    FOREIGN KEY (position_id) REFERENCES employee_position(position_id),
    FOREIGN KEY (status_id) REFERENCES status(status_id),
    FOREIGN KEY (supervisor_id) REFERENCES employee_profile(employee_id)
);

CREATE TABLE IF NOT EXISTS address (
    address_id INT NOT NULL AUTO_INCREMENT,
    house_no VARCHAR(20) NULL,
    street VARCHAR(100) NULL,
    barangay VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    province VARCHAR(100) NOT NULL,
    postal_code VARCHAR(10) NOT NULL,
    country VARCHAR(100) NOT NULL DEFAULT 'Philippines',
    employee_id INT,
    PRIMARY KEY (address_id),
    FOREIGN KEY (employee_id) REFERENCES employee_profile(employee_id)
);

CREATE TABLE IF NOT EXISTS government_ids (
    government_id INT NOT NULL AUTO_INCREMENT,
    sss_no VARCHAR(50),
    philhealth_no VARCHAR(50),
    pagibig_no VARCHAR(50),
    tin_no VARCHAR(50),
    employee_id INT,
    PRIMARY KEY (government_id),
    FOREIGN KEY (employee_id) REFERENCES employee_profile(employee_id)
);


/*USER ACCESS AND SECURITY*/
CREATE TABLE IF NOT EXISTS user_account (
    user_id INT NOT NULL AUTO_INCREMENT,
    employee_id INT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_modified DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id),
    FOREIGN KEY (employee_id) REFERENCES employee_profile(employee_id)
);

CREATE TABLE IF NOT EXISTS role (
    role_id INT NOT NULL AUTO_INCREMENT,
    role_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NULL,
    created_date DATETIME,
    last_modified DATETIME,
    PRIMARY KEY (role_id)
);

CREATE TABLE IF NOT EXISTS permission (
    permission_id INT NOT NULL AUTO_INCREMENT,
    permission_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT NULL,
    PRIMARY KEY (permission_id)
);

CREATE TABLE IF NOT EXISTS user_role (
    user_role_id INT NOT NULL AUTO_INCREMENT,
    user_id INT,
    role_id INT,
    PRIMARY KEY (user_role_id),
    FOREIGN KEY (user_id) REFERENCES user_account(user_id),
    FOREIGN KEY (role_id) REFERENCES Role(role_id)
);

CREATE TABLE IF NOT EXISTS role_permission (
    role_permission_id INT NOT NULL AUTO_INCREMENT,
    role_id INT,
    permission_id INT,
    PRIMARY KEY (role_permission_id),
    FOREIGN KEY (role_id) REFERENCES Role(role_id),
    FOREIGN KEY (permission_id) REFERENCES permission(permission_id)
);

CREATE TABLE IF NOT EXISTS audit_log (
    log_id INT NOT NULL AUTO_INCREMENT,
    user_id INT,
    action VARCHAR(100),
    entity_changed VARCHAR(100),
    entity_id INT,
    timestamp DATETIME,
    PRIMARY KEY (log_id),
    FOREIGN KEY (user_id) REFERENCES user_account(user_id)
);


/*ATTENDANCE AND LEAVE MANAGEMENT*/
CREATE TABLE IF NOT EXISTS shift (
    shift_id INT NOT NULL AUTO_INCREMENT,
    shift_name VARCHAR(50),
    start_time TIME,
    end_time TIME,
    PRIMARY KEY (shift_id)
);

CREATE TABLE IF NOT EXISTS attendance (
    attendance_id INT NOT NULL AUTO_INCREMENT,
    employee_id INT,
    date DATE,
    time_in TIME,
    time_out TIME,
    hours_worked DECIMAL(5,2),
    absences INT,
    leave_without_pay DECIMAL(5,2),
    shift_id INT,
    PRIMARY KEY (attendance_id),
    FOREIGN KEY (employee_id) REFERENCES employee_profile(employee_id),
    FOREIGN KEY (shift_id) REFERENCES shift(shift_id)
);

CREATE TABLE IF NOT EXISTS leave_type (
    leave_type_id INT NOT NULL AUTO_INCREMENT,
    leave_name ENUM('Vacation leave', 'Sick leave', 'Emergency leave', 'Maternity leave', 'Paternity leave', 'Leave without pay'),
    description VARCHAR(255) NULL,
    max_days INT,
    pay_flag BOOLEAN COMMENT 'Paid or Unpaid',
    PRIMARY KEY (leave_type_id)
);

CREATE TABLE IF NOT EXISTS leave_request (
    leave_request_id INT NOT NULL AUTO_INCREMENT,
    employee_id INT,
    leave_type_id INT,
    start_date DATE,
    end_date DATE,
    status ENUM('Pending', 'Approved', 'Rejected'),
    PRIMARY KEY (leave_request_id),
    FOREIGN KEY (employee_id) REFERENCES employee_profile(employee_id),
    FOREIGN KEY (leave_type_id) REFERENCES leave_type(leave_type_id)
);

CREATE TABLE IF NOT EXISTS overtime (
    ot_id INT NOT NULL AUTO_INCREMENT,
    attendance_id INT,
    ot_hours INT,
    multiplier DECIMAL(5,2),
    date DATE,
    approved_by INT,
    PRIMARY KEY (ot_id),
    FOREIGN KEY (attendance_id) REFERENCES attendance(attendance_id)
);


/*PAYROLL MANAGEMENT*/
CREATE TABLE IF NOT EXISTS pay_period (
    pay_period_id INT NOT NULL AUTO_INCREMENT,
    start_date DATE,
    end_date DATE,
    PRIMARY KEY (pay_period_id)
);

CREATE TABLE IF NOT EXISTS payroll (
    payroll_id INT NOT NULL AUTO_INCREMENT,
    employee_id INT,
    pay_period_id INT,
    gross_pay DECIMAL(10,2),
    net_pay DECIMAL(10,2),
    total_deductions DECIMAL(10,2),
    tax DECIMAL(10,2),
    total_benefits DECIMAL(10,2),
    payroll_date DATE,
    PRIMARY KEY (payroll_id),
    FOREIGN KEY (employee_id) REFERENCES employee_profile(employee_id),
    FOREIGN KEY (pay_period_id) REFERENCES pay_period(pay_period_id)
);

CREATE TABLE IF NOT EXISTS salary_details (
    salary_id INT NOT NULL AUTO_INCREMENT,
    employee_id INT,
    basic_salary DECIMAL(10,2),
    hourly_rate DECIMAL(10,2),
    effective_date DATE,
    end_date DATE,
    PRIMARY KEY (salary_id),
    FOREIGN KEY (employee_id) REFERENCES employee_profile(employee_id)
);

CREATE TABLE IF NOT EXISTS benefit_type (
    benefit_type_id INT NOT NULL AUTO_INCREMENT,
    description VARCHAR(100),
    benefit_amt DECIMAL(10,2),
    PRIMARY KEY (benefit_type_id)
);

CREATE TABLE IF NOT EXISTS position_allowance (
    position_allowance_id INT NOT NULL AUTO_INCREMENT,
    position_id INT,
    rice_subsidy DECIMAL(10,1),
    phone_allowance DECIMAL(10,2),
    clothing_allowance DECIMAL(10,2),
    total_allowance DECIMAL(10,2),
    PRIMARY KEY (position_allowance_id),
    FOREIGN KEY (position_id) REFERENCES employee_position(position_id)
);

CREATE TABLE IF NOT EXISTS deduction_type (
    deduction_type_id INT NOT NULL AUTO_INCREMENT,
    deduction_type VARCHAR(50),
    description VARCHAR(255),
    PRIMARY KEY (deduction_type_id)
);

CREATE TABLE IF NOT EXISTS deduction (
    deduction_id INT NOT NULL AUTO_INCREMENT,
    deduction_type_id INT,
    lower_amount DECIMAL(10,2),
    upper_amount DECIMAL(10,2),
    tax_base DECIMAL(10,2),
    b_rate DECIMAL(10,2),
    PRIMARY KEY (deduction_id),
    FOREIGN KEY (deduction_type_id) REFERENCES deduction_type(deduction_type_id)
);

CREATE TABLE IF NOT EXISTS payroll_deduction (
    payroll_deduction_id INT NOT NULL AUTO_INCREMENT,
    payroll_id INT,
    deduction_id INT,
    deduction_amount DECIMAL(10,2),
    PRIMARY KEY (payroll_deduction_id),
    FOREIGN KEY (payroll_id) REFERENCES payroll(payroll_id),
    FOREIGN KEY (deduction_id) REFERENCES deduction(deduction_id)
);

CREATE TABLE IF NOT EXISTS payroll_benefit (
    payroll_benefit_id INT NOT NULL AUTO_INCREMENT,
    employee_profile varchar(50),
    payroll_id INT,
    benefit_type_id INT,
    benefit_amount DECIMAL(10,2),
    PRIMARY KEY (payroll_benefit_id),
    FOREIGN KEY (payroll_id) REFERENCES payroll(payroll_id),
    FOREIGN KEY (benefit_type_id) REFERENCES benefit_type(benefit_type_id)
);


/*INSERTION OF VALUES*/
/*department*/
INSERT INTO department (department_id, name, description)
VALUES (1, 'Sales & Marketing', 'Handles product sales, promotions, and customer relations');

/*employee_position*/
INSERT INTO employee_position (position_id, department_id, name, description)
VALUES (1, 1, 'Sales Associate', 'Responsible for product sales, client management, and sales reporting');

/*status*/
INSERT INTO status (status_id, status_name)
VALUES (1, 'Regular');

/*employee_profile*/
INSERT INTO employee_profile
    (employee_id, last_name, first_name, address_id, birthday,
     phone_number, hire_date, email, department_id, position_id,
     status_id, supervisor_id, is_active)
VALUES
    (10006, 'Villanueva', 'Andrea Mae', NULL, '1995-03-21',
     '09176000006', '2021-03-15', 'avillanueva@motorph.com', 1, 1,
     1, NULL, TRUE);

/*address*/
INSERT INTO address
    (address_id, house_no, street, barangay, city, province, postal_code, country, employee_id)
VALUES
    (1, '22', 'Sampaguita Street', 'Barangay Sta. Cruz', 'Makati City', 'Metro Manila', '1200', 'Philippines', 10006);

/*Link address back to employee_profile*/
UPDATE employee_profile SET address_id = 1 WHERE employee_id = 10006;

/*government_ids*/
INSERT INTO government_ids
    (government_id, sss_no, philhealth_no, pagibig_no, tin_no, employee_id)
VALUES
    (1, '34-6000067-9', '02-600067890-3', '1006-6007-0089', '600-067-890-006', 10006);

/*user_account*/
INSERT INTO user_account
    (user_id, employee_id, username, password_hash, email, created_date)
VALUES
    (1, 10006, 'avillanueva', '$2b$12$VillanuevaHashedPassword789xyz', 'avillanueva@motorph.com', '2021-03-15 08:00:00');

/*role*/
INSERT INTO role
    (role_id, role_name, description, created_date)
VALUES
    (1, 'Employee', 'Standard employee — can view own payslip, file leaves, and check attendance', '2021-01-01 00:00:00');

/*permission*/
INSERT INTO permission
    (permission_id, permission_name, description)
VALUES
    (1, 'VIEW_OWN_PAYSLIP', 'Can view own payslip only');

/*user_role*/
INSERT INTO user_role (user_role_id, user_id, role_id)
VALUES (1, 1, 1);

/*role_permission*/
INSERT INTO role_permission (role_permission_id, role_id, permission_id)
VALUES (1, 1, 1);

/*audit_log*/
INSERT INTO audit_log
    (log_id, user_id, action, entity_changed, entity_id, timestamp)
VALUES
    (1, 1, 'LOGIN', 'user_account', 1, '2024-06-03 09:31:00');

/*shift*/
INSERT INTO shift (shift_id, shift_name, start_time, end_time)
VALUES (1, 'Regular Shift', '08:00:00', '17:00:00');

/*attendance*/
INSERT INTO attendance
    (attendance_id, employee_id, date, time_in, time_out,
     hours_worked, absences, leave_without_pay, shift_id)
VALUES
    (1, 10006, '2024-06-03', '09:31:00', '19:29:00', 9.97, 0, 0.00, 1);

/*leave_type*/
INSERT INTO leave_type
    (leave_type_id, leave_name, description, max_days, pay_flag)
VALUES
    (1, 'Sick leave', 'Paid leave for health-related absences', 15, TRUE);

/*leave_request*/
INSERT INTO leave_request
    (leave_request_id, employee_id, leave_type_id, start_date, end_date, status)
VALUES
    (1, 10006, 1, '2024-08-05', '2024-08-06', 'Approved');

/*overtime*/
INSERT INTO overtime
    (ot_id, attendance_id, ot_hours, multiplier, date, approved_by_id)
VALUES
    (1, 1, 2, 1.25, '2024-06-03', 10006);

/*pay_period*/
INSERT INTO pay_period (pay_period_id, start_date, end_date)
VALUES (1, '2024-06-01', '2024-06-15');

/*salary_details*/
INSERT INTO salary_details
    (salary_id, employee_id, basic_salary, hourly_rate, effective_date, end_date)
VALUES
    (1, 10006, 52670.00, 299.26, '2021-03-15', NULL);

/*benefit_type*/
INSERT INTO benefit_type (benefit_type_id, description, benefit_amt)
VALUES (1, 'Rice Subsidy', 1500.00);

/*position_allowance*/
INSERT INTO position_allowance
    (position_allowance_id, position_id, rice_subsidy, phone_allowance, clothing_allowance, total_allowance)
VALUES
    (1, 1, 1500.0, 800.00, 500.00, 2800.00);

/*deduction_type*/
INSERT INTO deduction_type (deduction_type_id, deduction_type, description)
VALUES (1, 'SSS', 'Social Security System monthly employee contribution');

/*deduction*/
INSERT INTO deduction
    (deduction_id, deduction_type_id, lower_amount, upper_amount, tax_base, b_rate)
VALUES
    (1, 1, 0.00, 24750.00, 0.00, 0.045);

/*payroll*/
INSERT INTO payroll
    (payroll_id, employee_id, pay_period_id, gross_pay, net_pay,
     total_deductions, tax, total_benefits, payroll_date)
VALUES
    (1, 10006, 1, 27735.00, 23935.00, 3800.00, 2100.00, 1400.00, '2024-06-15');


/*payroll_deduction*/
INSERT INTO payroll_deduction
    (payroll_deduction_id, payroll_id, deduction_id, deduction_amount)
VALUES
    (1, 1, 1, 1185.00);

/*payroll_benefit*/
INSERT INTO payroll_benefit
    (payroll_benefit_id, payroll_id, benefit_type_id, benefit_amount)
VALUES
    (1, 1, 1, 750.00);
 



/*testing and validation*/
/*to check if the dabase is right*/
SELECT DATABASE();

/*validation of 26 tables*/
SHOW TABLES;

/*to view the table structure*/
DESCRIBE department;
DESCRIBE employee_position;
DESCRIBE status;
DESCRIBE employee_profile;
DESCRIBE address;
DESCRIBE government_ids;
DESCRIBE user_account;
DESCRIBE role;
DESCRIBE permission;
DESCRIBE user_role;
DESCRIBE role_permission;
DESCRIBE audit_log;
DESCRIBE shift;
DESCRIBE attendance;
DESCRIBE leave_type;
DESCRIBE leave_request;
DESCRIBE overtime;
DESCRIBE pay_period;
DESCRIBE payroll;
DESCRIBE salary_details;
DESCRIBE benefit_type;
DESCRIBE position_allowance;
DESCRIBE deduction_type;
DESCRIBE deduction;
DESCRIBE payroll_deduction;
DESCRIBE payroll_benefit;


/*to check if the data was inserted*/
SELECT * from department;
SELECT * from employee_position;
SELECT * from status;
SELECT * from employee_profile;
SELECT * from address;
SELECT * from government_ids;
SELECT * from user_account;
SELECT * from role;
SELECT * from permission;
SELECT * from user_role;
SELECT * from role_permission;
SELECT * from audit_log;
SELECT * from shift;
SELECT * from attendance;
SELECT * from leave_type;
SELECT * from leave_request;
SELECT * from overtime;
SELECT * from pay_period;
SELECT * from payroll;
SELECT * from salary_details;
SELECT * from benefit_type;
SELECT * from position_allowance;
SELECT * from deduction_type;
SELECT * from deduction;
SELECT * from payroll_deduction;
SELECT * from payroll_benefit;