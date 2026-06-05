CREATE DATABASE IF NOT EXISTS motorph_employee_management_system;

USE motorph_employee_management_system;


/*CORE EMPLOYEE MANAGEMENT*/
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
    approved_by VARCHAR(50),
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
CREATE TABLE INFO(StudentNo smallint not null auto_increment,;
USE motorph_employee_management_system;
USE motorph_employee_management_system;
