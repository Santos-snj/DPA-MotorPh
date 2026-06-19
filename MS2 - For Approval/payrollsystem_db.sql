/* ================================================================
   DATABASE SETUP
   ================================================================*/
   
CREATE DATABASE IF NOT EXISTS motorph_employee_management_system;

USE motorph_employee_management_system;

/* ================================================================
   SECTION 1 — CORE EMPLOYEE MANAGEMENT
 ================================================================*/

CREATE TABLE IF NOT EXISTS department (
    department_id INT NOT NULL AUTO_INCREMENT,
    name ENUM (
        'Executive','IT','HR','Finance',
        'Sales & Marketing','Operations/Logistics','Customer Relations'
    ) NOT NULL,
    description TEXT NOT NULL,
    PRIMARY KEY (department_id)
);

CREATE TABLE IF NOT EXISTS employee_position (
    position_id   INT NOT NULL AUTO_INCREMENT,
    department_id INT NOT NULL,
    name ENUM (
        'Chief Executive Officer','Chief Operating Officer',
        'Chief Finance Officer','Chief Marketing Officer',
        'IT Operations and Systems','HR Manager','HR Team Leader',
        'HR Rank and File','Accounting Head','Payroll Manager',
        'Payroll Team Leader','Payroll Rank and File',
        'Account Manager','Account Team Leader','Account Rank and File',
        'Sales & Marketing','Supply Chain and Logistics',
        'Customer Service and Relations'
    ) NOT NULL,
    description VARCHAR(215) NOT NULL,
    PRIMARY KEY (position_id),
    FOREIGN KEY (department_id) REFERENCES department(department_id)
);

CREATE TABLE IF NOT EXISTS status (
    status_id   INT NOT NULL AUTO_INCREMENT,
    status_name ENUM ('Regular','Probationary') NOT NULL,
    PRIMARY KEY (status_id)
);

CREATE TABLE IF NOT EXISTS employee_profile (
    employee_id     INT NOT NULL AUTO_INCREMENT,
    last_name       VARCHAR(50)  NOT NULL,
    first_name      VARCHAR(50)  NOT NULL,
    birthday        DATE         NOT NULL,
    phone_number    VARCHAR(15),
    hire_date       DATE         NOT NULL,
    email           VARCHAR(100) NOT NULL,
    supervisor_name VARCHAR(100) NOT NULL,
    department_id   INT NOT NULL,
    position_id     INT NOT NULL,
    status_id       INT NOT NULL,
    is_active       BOOLEAN      NOT NULL,
    PRIMARY KEY (employee_id),
    FOREIGN KEY (department_id) REFERENCES department(department_id),
    FOREIGN KEY (position_id)   REFERENCES employee_position(position_id),
    FOREIGN KEY (status_id)     REFERENCES status(status_id)
);

ALTER TABLE employee_profile AUTO_INCREMENT = 10001;

CREATE TABLE IF NOT EXISTS address (
    address_id  INT NOT NULL AUTO_INCREMENT,
    house_no    VARCHAR(100),
    street      VARCHAR(100),
    barangay    VARCHAR(100),
    city        VARCHAR(100) NOT NULL,
    province    VARCHAR(100) NOT NULL,
    postal_code VARCHAR(4)   NOT NULL,
    country     VARCHAR(100) NOT NULL DEFAULT 'Philippines',
    PRIMARY KEY (address_id)
);

CREATE TABLE IF NOT EXISTS employee_address (
    employee_address_id INT NOT NULL AUTO_INCREMENT,
    employee_id         INT NOT NULL,
    address_id          INT NOT NULL,
    address_type        ENUM ('Permanent','Current','Provincial') NOT NULL,
    is_primary          BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (employee_address_id),
    FOREIGN KEY (employee_id) REFERENCES employee_profile(employee_id),
    FOREIGN KEY (address_id)  REFERENCES address(address_id)
);

CREATE TABLE IF NOT EXISTS government_ids (
    government_id  INT NOT NULL AUTO_INCREMENT,
    sss_no         VARCHAR(13) NOT NULL UNIQUE,
    philhealth_no  VARCHAR(14) NOT NULL,
    pagibig_no     VARCHAR(14) NOT NULL,
    tin_no         VARCHAR(15) NOT NULL,
    employee_id    INT NOT NULL,
    PRIMARY KEY (government_id),
    FOREIGN KEY (employee_id) REFERENCES employee_profile(employee_id)
);

/* ================================================================
   SECTION 2 — USER & SECURITY MANAGEMENT TABLES
   ================================================================ */

CREATE TABLE IF NOT EXISTS user_account (
    user_id       INT NOT NULL AUTO_INCREMENT,
    employee_id   INT NOT NULL UNIQUE,
    username      VARCHAR(50)  NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    created_date  DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_modified DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id),
    FOREIGN KEY (employee_id) REFERENCES employee_profile(employee_id)
);

CREATE TABLE IF NOT EXISTS role (
    role_id       INT NOT NULL AUTO_INCREMENT,
    role_name     ENUM (
        'Admin','HR Manager','Payroll Manager','Account Manager',
        'IT Support','Finance Officer','Employee','Supervisor'
    ) NOT NULL UNIQUE,
    description   TEXT NOT NULL,
    created_date  DATETIME,
    last_modified DATETIME,
    PRIMARY KEY (role_id)
);

CREATE TABLE IF NOT EXISTS permission (
    permission_id   INT NOT NULL AUTO_INCREMENT,
    permission_name ENUM (
        'VIEW_EMPLOYEE','CREATE_EMPLOYEE','UPDATE_EMPLOYEE','DELETE_EMPLOYEE',
        'VIEW_DEPARTMENT','MANAGE_DEPARTMENT','VIEW_POSITION','MANAGE_POSITION',
        'VIEW_ATTENDANCE','MANAGE_ATTENDANCE','VIEW_LEAVE','MANAGE_LEAVE',
        'VIEW_OVERTIME','MANAGE_OVERTIME','VIEW_PAYROLL','PROCESS_PAYROLL',
        'VIEW_SALARY','MANAGE_SALARY','VIEW_BENEFITS','MANAGE_BENEFITS',
        'VIEW_DEDUCTIONS','MANAGE_DEDUCTIONS','VIEW_ROLES','MANAGE_ROLES',
        'VIEW_PERMISSIONS','MANAGE_PERMISSIONS','VIEW_AUDIT_LOG'
    ) NOT NULL UNIQUE,
    description TEXT NOT NULL,
    PRIMARY KEY (permission_id)
);

CREATE TABLE IF NOT EXISTS user_role (
    user_role_id INT NOT NULL AUTO_INCREMENT,
    user_id      INT NOT NULL,
    role_id      INT NOT NULL,
    PRIMARY KEY (user_role_id),
    FOREIGN KEY (user_id) REFERENCES user_account(user_id),
    FOREIGN KEY (role_id) REFERENCES role(role_id)
);

CREATE TABLE IF NOT EXISTS role_permission (
    role_permission_id INT NOT NULL AUTO_INCREMENT,
    role_id            INT NOT NULL,
    permission_id      INT NOT NULL,
    PRIMARY KEY (role_permission_id),
    FOREIGN KEY (role_id)      REFERENCES role(role_id),
    FOREIGN KEY (permission_id) REFERENCES permission(permission_id)
);

CREATE TABLE IF NOT EXISTS audit_log (
    log_id         INT NOT NULL AUTO_INCREMENT,
    user_id        INT NOT NULL,
    action         VARCHAR(100) NOT NULL,
    entity_changed VARCHAR(100) NOT NULL,
    entity_id      INT NOT NULL,
    timestamp      DATETIME NOT NULL,
    PRIMARY KEY (log_id),
    FOREIGN KEY (user_id) REFERENCES user_account(user_id)
);

/* ================================================================
   SECTION 3 — ATTENDANCE & LEAVE TABLES
   ================================================================ */

CREATE TABLE IF NOT EXISTS shift (
    shift_id   INT NOT NULL AUTO_INCREMENT,
    shift_name ENUM ('Morning','Mid','Night') NOT NULL,
    start_time TIME NOT NULL,
    end_time   TIME NOT NULL,
    PRIMARY KEY (shift_id)
);

CREATE TABLE IF NOT EXISTS attendance (
    attendance_id INT NOT NULL AUTO_INCREMENT,
    employee_id   INT NOT NULL,
    date          DATE NOT NULL,
    time_in       TIME NOT NULL,
    time_out      TIME,
    hours_worked  DECIMAL(5,2) DEFAULT '0' NOT NULL,
    absences      INT DEFAULT '0',
    shift_id      INT DEFAULT '1' NOT NULL,
    PRIMARY KEY (attendance_id),
    FOREIGN KEY (employee_id) REFERENCES employee_profile(employee_id),
    FOREIGN KEY (shift_id)    REFERENCES shift(shift_id)
);

CREATE TABLE IF NOT EXISTS leave_type (
    leave_type_id INT NOT NULL AUTO_INCREMENT,
    leave_name    ENUM (
        'Sick leave','Vacation leave','Emergency leave',
        'Maternity leave','Paternity leave','Bereavement leave','Unpaid leave'
    ) NOT NULL,
    description VARCHAR(255),
    max_days    INT NOT NULL,
    PRIMARY KEY (leave_type_id)
);

CREATE TABLE IF NOT EXISTS leave_request (
    leave_request_id INT NOT NULL AUTO_INCREMENT,
    employee_id      INT NOT NULL,
    leave_type_id    INT NOT NULL,
    start_date       DATE NOT NULL,
    end_date         DATE NOT NULL,
    status           ENUM ('Pending','Approved','Rejected') NOT NULL,
    approved_by      INT,
    approval_date    DATE,
    remarks          VARCHAR(255),
    PRIMARY KEY (leave_request_id),
    FOREIGN KEY (employee_id)   REFERENCES employee_profile(employee_id),
    FOREIGN KEY (leave_type_id) REFERENCES leave_type(leave_type_id),
    FOREIGN KEY (approved_by)   REFERENCES employee_profile(employee_id)
);

CREATE TABLE IF NOT EXISTS overtime (
    ot_id         INT NOT NULL AUTO_INCREMENT,
    attendance_id INT NOT NULL,
    ot_hours      INT NOT NULL,
    multiplier    DECIMAL(5,2) NOT NULL,
    date          DATE NOT NULL,
    approved_by   INT,
    approval_date DATE,
    PRIMARY KEY (ot_id),
    FOREIGN KEY (attendance_id) REFERENCES attendance(attendance_id),
    FOREIGN KEY (approved_by)   REFERENCES employee_profile(employee_id)
);

/* ================================================================
   SECTION 4 — PAYROLL & COMPENSATION TABLES
   ================================================================ */

CREATE TABLE IF NOT EXISTS pay_period (
    pay_period_id INT NOT NULL AUTO_INCREMENT,
    start_date    DATE NOT NULL,
    end_date      DATE NOT NULL,
    PRIMARY KEY (pay_period_id)
);

CREATE TABLE IF NOT EXISTS payroll (
    payroll_id        INT NOT NULL AUTO_INCREMENT,
    employee_id       INT NOT NULL,
    pay_period_id     INT NOT NULL,
    gross_pay         DECIMAL(10,2) NOT NULL,
    net_pay           DECIMAL(10,2) NOT NULL,
    total_deductions  DECIMAL(10,2) NOT NULL,
    tax               DECIMAL(10,2) NOT NULL,
    total_benefits    DECIMAL(10,2) NOT NULL,
    payroll_date      DATE NOT NULL,
    PRIMARY KEY (payroll_id),
    FOREIGN KEY (employee_id)   REFERENCES employee_profile(employee_id),
    FOREIGN KEY (pay_period_id) REFERENCES pay_period(pay_period_id)
);

CREATE TABLE IF NOT EXISTS salary_details (
    salary_id      INT NOT NULL AUTO_INCREMENT,
    employee_id    INT NOT NULL,
    basic_salary   DECIMAL(10,2) NOT NULL,
    hourly_rate    DECIMAL(10,2),
    effective_date DATE NOT NULL,
    end_date       DATE,
    PRIMARY KEY (salary_id),
    FOREIGN KEY (employee_id) REFERENCES employee_profile(employee_id)
);

CREATE TABLE IF NOT EXISTS benefit_type (
    benefit_type_id INT NOT NULL AUTO_INCREMENT,
    benefit_name    VARCHAR(100) NOT NULL,
    PRIMARY KEY (benefit_type_id)
);

CREATE TABLE IF NOT EXISTS position_allowance (
    position_allowance_id INT NOT NULL AUTO_INCREMENT,
    position_id           INT NOT NULL,
    rice_subsidy          DECIMAL(10,2),
    phone_allowance       DECIMAL(10,2),
    clothing_allowance    DECIMAL(10,2),
    total_allowance       DECIMAL(10,2),
    PRIMARY KEY (position_allowance_id),
    FOREIGN KEY (position_id) REFERENCES employee_position(position_id)
);

CREATE TABLE IF NOT EXISTS deduction_type (
    deduction_type_id INT NOT NULL AUTO_INCREMENT,
    deduction_type    VARCHAR(50) NOT NULL,
    description       VARCHAR(255),
    PRIMARY KEY (deduction_type_id)
);

CREATE TABLE IF NOT EXISTS deduction (
    deduction_id      INT NOT NULL AUTO_INCREMENT,
    deduction_type_id INT NOT NULL,
    lower_amount      DECIMAL(10,2),
    upper_amount      DECIMAL(10,2),
    tax_base          DECIMAL(10,2),
    b_rate            DECIMAL(10,2),
    PRIMARY KEY (deduction_id),
    FOREIGN KEY (deduction_type_id) REFERENCES deduction_type(deduction_type_id)
);

CREATE TABLE IF NOT EXISTS payroll_deduction (
    payroll_deduction_id INT NOT NULL AUTO_INCREMENT,
    payroll_id           INT NOT NULL,
    deduction_id         INT NOT NULL,
    deduction_amount     DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (payroll_deduction_id),
    FOREIGN KEY (payroll_id)   REFERENCES payroll(payroll_id),
    FOREIGN KEY (deduction_id) REFERENCES deduction(deduction_id)
);

CREATE TABLE IF NOT EXISTS payroll_benefit (
    payroll_benefit_id INT NOT NULL AUTO_INCREMENT,
    employee_id        INT NOT NULL,
    payroll_id         INT NOT NULL,
    benefit_type_id    INT NOT NULL,
    PRIMARY KEY (payroll_benefit_id),
    FOREIGN KEY (payroll_id)      REFERENCES payroll(payroll_id),
    FOREIGN KEY (benefit_type_id) REFERENCES benefit_type(benefit_type_id)
);

/* =====================================================================================
   SECTION 5 — DATA INSERTS
   ===================================================================================== */

/* ── 5.1  Department ── */
INSERT INTO department (name, description) VALUES
('Executive',            'Responsible for overall strategic direction, decision-making, and management of the entire organization. Includes CEO, COO, CFO, and CMO.'),
('IT',                   'Handles the organization\'s information technology infrastructure, systems development, maintenance, and technical support to ensure smooth system operations.'),
('HR',                   'Manages employee-related functions such as recruitment, onboarding, training, employee relations, and organizational development.'),
('Finance',              'Responsible for financial planning, accounting, budgeting, payroll processing, and financial reporting and compliance.'),
('Sales & Marketing',    'Focuses on promoting products or services, managing client relationships, generating leads, and achieving sales targets.'),
('Operations/Logistics', 'Oversees day-to-day operations, supply chain management, inventory flow, and distribution of goods or services.'),
('Customer Relations',   'Handles customer inquiries, complaints, support services, and ensures customer satisfaction and retention.');

/* ── 5.2  Employee Position ── */
INSERT INTO employee_position (department_id, name, description) VALUES
(1, 'Chief Executive Officer',       'Provides overall leadership, strategic direction, and decision-making for the organization.'),
(1, 'Chief Operating Officer',       'Oversees daily business operations and ensures organizational efficiency.'),
(1, 'Chief Finance Officer',         'Manages financial planning, reporting, budgeting, and risk management.'),
(1, 'Chief Marketing Officer',       'Leads marketing strategies, brand development, and market growth initiatives.'),
(2, 'IT Operations and Systems',     'Manages information technology infrastructure, systems maintenance, and technical support.'),
(3, 'HR Manager',                    'Oversees human resource functions, policies, recruitment, and employee development.'),
(3, 'HR Team Leader',                'Supervises HR staff and coordinates human resource activities.'),
(3, 'HR Rank and File',              'Performs operational HR tasks such as employee records management and recruitment support.'),
(4, 'Accounting Head',               'Leads accounting operations and ensures accurate financial reporting.'),
(4, 'Payroll Manager',               'Oversees payroll processing and compensation administration.'),
(4, 'Payroll Team Leader',           'Supervises payroll personnel and payroll-related activities.'),
(4, 'Payroll Rank and File',         'Processes payroll transactions and maintains payroll records.'),
(5, 'Account Manager',               'Manages client accounts and develops business relationships.'),
(5, 'Account Team Leader',           'Supervises account personnel and coordinates account management activities.'),
(5, 'Account Rank and File',         'Provides support in managing customer accounts and sales operations.'),
(5, 'Sales & Marketing',             'Promotes products and services, generates sales opportunities, and executes marketing campaigns.'),
(6, 'Supply Chain and Logistics',    'Manages procurement, inventory, distribution, and logistics operations.'),
(7, 'Customer Service and Relations','Handles customer inquiries, concerns, and relationship management to ensure customer satisfaction.');

/* ── 5.3  Status ── */
INSERT INTO status (status_name) VALUES ('Regular'), ('Probationary');

/* ── 5.4  Employee Profile — phone numbers corrected from CSV ── */
INSERT INTO employee_profile
    (last_name, first_name, birthday, phone_number, hire_date, email, supervisor_name, department_id, position_id, status_id, is_active)
VALUES
('Garcia',      'Manuel III',   '1983-10-11', '966-860-270',  '2020-01-15', 'mgarcia@motorph.com',      'N/A',                     1, 1,  1, TRUE),
('Lim',         'Antonio',      '1988-06-19', '171-867-411',  '2020-02-01', 'alim@motorph.com',         'Garcia, Manuel III',       1, 2,  1, TRUE),
('Aquino',      'Bianca Sofia', '1989-08-04', '966-889-370',  '2020-02-15', 'baquino@motorph.com',      'Garcia, Manuel III',       1, 3,  1, TRUE),
('Reyes',       'Isabella',     '1994-06-16', '786-868-477',  '2020-03-01', 'ireyes@motorph.com',       'Garcia, Manuel III',       1, 4,  1, TRUE),
('Hernandez',   'Eduard',       '1989-09-23', '088-861-012',  '2020-04-01', 'ehernandez@motorph.com',   'Lim, Antonio',             2, 5,  1, TRUE),
('Villanueva',  'Andrea Mae',   '1988-02-14', '918-621-603',  '2020-04-15', 'avillanueva@motorph.com',  'Lim, Antonio',             3, 6,  1, TRUE),
('San Jose',    'Brad',         '1996-03-15', '797-009-261',  '2021-01-15', 'bsanjose@motorph.com',     'Villanueva, Andrea Mae',   3, 7,  1, TRUE),
('Romualdez',   'Alice',        '1992-05-14', '983-606-799',  '2021-02-01', 'aromualdez@motorph.com',   'San Jose, Brad',           3, 8,  1, TRUE),
('Atienza',     'Rosie',        '1948-09-24', '266-036-427',  '2021-02-15', 'ratienza@motorph.com',     'San Jose, Brad',           3, 8,  1, TRUE),
('Alvaro',      'Roderick',     '1988-03-30', '053-381-386',  '2020-05-01', 'ralvaro@motorph.com',      'Aquino, Bianca Sofia',     4, 9,  1, TRUE),
('Salcedo',     'Anthony',      '1993-09-14', '070-766-300',  '2020-05-15', 'asalcedo@motorph.com',     'Alvaro, Roderick',         4, 10, 1, TRUE),
('Lopez',       'Josie',        '1987-01-14', '478-355-427',  '2021-03-01', 'jlopez@motorph.com',       'Salcedo, Anthony',         4, 11, 1, TRUE),
('Farala',      'Martha',       '1942-01-11', '329-034-366',  '2021-03-15', 'mfarala@motorph.com',      'Salcedo, Anthony',         4, 12, 1, TRUE),
('Martinez',    'Leila',        '1970-07-11', '877-110-749',  '2021-04-01', 'lmartinez@motorph.com',    'Salcedo, Anthony',         4, 12, 1, TRUE),
('Romualdez',   'Fredrick',     '1985-03-10', '023-079-009',  '2020-06-01', 'fromualdez@motorph.com',   'Lim, Antonio',             5, 13, 1, TRUE),
('Mata',        'Christian',    '1987-10-21', '783-776-744',  '2021-04-15', 'cmata@motorph.com',        'Romualdez, Fredrick',      5, 14, 1, TRUE),
('De Leon',     'Selena',       '1975-02-20', '975-432-139',  '2021-05-01', 'sdeleon@motorph.com',      'Romualdez, Fredrick',      5, 14, 1, TRUE),
('San Jose',    'Allison',      '1986-06-24', '179-075-129',  '2021-06-01', 'asanjose@motorph.com',     'Mata, Christian',          5, 15, 1, TRUE),
('Rosario',     'Cydney',       '1996-10-06', '868-819-912',  '2021-06-15', 'crosario@motorph.com',     'Mata, Christian',          5, 15, 1, TRUE),
('Bautista',    'Mark',         '1991-02-12', '683-725-348',  '2021-07-01', 'mbautista@motorph.com',    'Mata, Christian',          5, 15, 1, TRUE),
('Lazaro',      'Darlene',      '1985-11-25', '740-721-558',  '2024-01-15', 'dlazaro@motorph.com',      'Mata, Christian',          5, 15, 2, TRUE),
('Delos Santos','Kolby',        '1980-02-26', '739-443-033',  '2024-02-01', 'kdelossantos@motorph.com', 'Mata, Christian',          5, 15, 2, TRUE),
('Santos',      'Vella',        '1983-12-31', '955-879-269',  '2024-02-15', 'vsantos@motorph.com',      'Mata, Christian',          5, 15, 2, TRUE),
('Del Rosario', 'Tomas',        '1978-12-18', '882-550-989',  '2024-03-01', 'tdelrosario@motorph.com',  'Mata, Christian',          5, 15, 2, TRUE),
('Tolentino',   'Jacklyn',      '1984-05-19', '675-757-366',  '2024-03-15', 'jtolentino@motorph.com',   'De Leon, Selena',          5, 15, 2, TRUE),
('Gutierrez',   'Percival',     '1970-12-18', '512-899-876',  '2024-04-01', 'pgutierrez@motorph.com',   'De Leon, Selena',          5, 15, 2, TRUE),
('Manalaysay',  'Garfield',     '1986-08-28', '948-628-136',  '2024-04-15', 'gmanalaysay@motorph.com',  'De Leon, Selena',          5, 15, 2, TRUE),
('Villegas',    'Lizeth',       '1981-12-12', '332-372-215',  '2024-05-01', 'lvillegas@motorph.com',    'De Leon, Selena',          5, 15, 2, TRUE),
('Ramos',       'Carol',        '1978-08-20', '250-700-389',  '2024-05-15', 'cramos@motorph.com',       'De Leon, Selena',          5, 15, 2, TRUE),
('Maceda',      'Emelia',       '1973-04-14', '973-358-041',  '2024-06-01', 'emaceda@motorph.com',      'De Leon, Selena',          5, 15, 2, TRUE),
('Aguilar',     'Delia',        '1989-01-27', '529-705-439',  '2024-06-15', 'daguilar@motorph.com',     'De Leon, Selena',          5, 15, 2, TRUE),
('Castro',      'John Rafael',  '1992-02-09', '332-424-955',  '2021-08-01', 'jcastro@motorph.com',      'Reyes, Isabella',          5, 16, 1, TRUE),
('Martinez',    'Carlos Ian',   '1990-11-16', '078-854-208',  '2021-08-15', 'cmartinez@motorph.com',    'Reyes, Isabella',          6, 17, 1, TRUE),
('Santos',      'Beatriz',      '1990-08-07', '526-639-511',  '2021-09-01', 'bsantos@motorph.com',      'Reyes, Isabella',          7, 18, 1, TRUE);

/* ── 5.5  Address ── */
INSERT INTO address (house_no, street, barangay, city, province, postal_code, country) VALUES
(NULL,    'Valero Carpark Building Valero Street',             NULL,          'Makati City',   'NCR',                    '1227', 'Philippines'),
('Block 1 Lot 8 and 2', 'San Antonio De Padua 2',             NULL,          'Dasmariñas',    'Cavite',                 '4114', 'Philippines'),
('Room 402 / 4F', 'Jiao Building Timog Avenue Cor. Quezon Avenue', NULL,     'Quezon City',   'NCR',                    '1100', 'Philippines'),
('460',   'Solanda Street Intramuros',                         'Intramuros',  'Manila',        'NCR',                    '1000', 'Philippines'),
(NULL,    'National Highway',                                  NULL,          'Gingoog',       'Misamis Occidental',     '9014', 'Philippines'),
('1785',  'Stracke Via Suite 042',                             'Poblacion',   'Las Piñas',     'Dinagat Islands',        '4783', 'Philippines'),
('99',    'Strosin Hills',                                     'Poblacion',   'Bislig',        'Surigao del Sur',        '5340', 'Philippines'),
('12A/33','Upton Isle Apt. 420',                               NULL,          'Roxas City',    'Capiz',                  '1814', 'Philippines'),
('90A',   'Dibbert Terrace Apt. 190',                          'San Lorenzo', 'Davao City',    'Davao del Norte',        '6056', 'Philippines'),
('#284',  'T. Morato corner Scout Rallos Street',              NULL,          'Quezon City',   'NCR',                    '1103', 'Philippines'),
('93/54', 'Shanahan Alley Apt. 183',                           'Santo Tomas', 'Santo Tomas',   'Batangas',               '1572', 'Philippines'),
('49',    'Springs Apt. 266',                                  'Poblacion',   'Taguig',        'Metro Manila',           '3200', 'Philippines'),
('42/25', 'Sawayn Stream',                                     'Ubay',        'Ubay',          'Bohol',                  '1208', 'Philippines'),
('37/46', 'Kulas Roads',                                       'Maragondon',  'Maragondon',    'Cavite',                 '0962', 'Philippines'),
('22A/52','Lubowitz Meadows',                                  'Pililla',     'Pililla',       'Rizal',                  '4895', 'Philippines'),
('90',    'O\'Keefe Spur Apt. 379',                            'Catigbian',   'Catigbian',     'Bohol',                  '2772', 'Philippines'),
('89A',   'Armstrong Trace',                                   'Compostela',  'Compostela',    'Davao de Oro',           '7874', 'Philippines'),
('08',    'Grant Drive Suite 406',                             'Poblacion',   'Iloilo City',   'Iloilo',                 '9186', 'Philippines'),
('93A/21','Berge Points',                                      'Tapaz',       'Tapaz',         'Capiz',                  '2180', 'Philippines'),
('65',    'Murphy Center Suite 094',                           'Poblacion',   'Palayan',       'Nueva Ecija',            '5636', 'Philippines'),
('47A/94','Larkin Plaza Apt. 179',                             'Poblacion',   'Caloocan',      'NCR',                    '2751', 'Philippines'),
('06A',   'Gulgowski Extensions',                              'Bongabon',    'Bongabon',      'Nueva Ecija',            '6085', 'Philippines'),
('99A',   'Padberg Spring',                                    'Poblacion',   'Mabalacat',     'Pampanga',               '3959', 'Philippines'),
('80A/48','Ledner Ridges',                                     'Poblacion',   'Kabankalan',    'Negros Occidental',      '8870', 'Philippines'),
('96/48', 'Watsica Flats Suite 734',                           'Poblacion',   'Malolos',       'Bulacan',                '1844', 'Philippines'),
('58A',   'Wilderman Walks',                                   'Poblacion',   'Digos',         'Davao del Sur',          '5822', 'Philippines'),
('60',    'Goyette Valley Suite 219',                          'Poblacion',   'Tabuk',         'Kalinga',                '3159', 'Philippines'),
('66/77', 'Mann Views',                                        NULL,          'Luisiana',      'Laguna',                 '1263', 'Philippines'),
('72/70', 'Stamm Spurs',                                       NULL,          'Bustos',        'Bulacan',                '4550', 'Philippines'),
('50A/83','Bahringer Oval Suite 145',                          NULL,          'Kiamba',        'Sarangani',              '7688', 'Philippines'),
('95',    'Cremin Junction',                                   NULL,          'Surallah',      'South Cotabato',         '2809', 'Philippines'),
(NULL,    'Hi-way Yati',                                       'Yati',        'Liloan',        'Cebu',                   '6002', 'Philippines'),
(NULL,    'Bulala',                                            NULL,          'Camalaniugan',  'Cagayan',                '0788', 'Philippines'),
(NULL,    'Agapita Building',                                  NULL,          'Metro Manila',  'NCR',                    '1004', 'Philippines');

/* ── 5.6  Employee Address ── */
INSERT INTO employee_address (employee_id, address_id, address_type, is_primary) VALUES
(10001,1,'Permanent',TRUE),(10002,2,'Permanent',TRUE),(10003,3,'Permanent',TRUE),
(10004,4,'Permanent',TRUE),(10005,5,'Permanent',TRUE),(10006,6,'Permanent',TRUE),
(10007,7,'Permanent',TRUE),(10008,8,'Permanent',TRUE),(10009,9,'Permanent',TRUE),
(10010,10,'Permanent',TRUE),(10011,11,'Permanent',TRUE),(10012,12,'Permanent',TRUE),
(10013,13,'Permanent',TRUE),(10014,14,'Permanent',TRUE),(10015,15,'Permanent',TRUE),
(10016,16,'Permanent',TRUE),(10017,17,'Permanent',TRUE),(10018,18,'Permanent',TRUE),
(10019,19,'Permanent',TRUE),(10020,20,'Permanent',TRUE),(10021,21,'Permanent',TRUE),
(10022,22,'Permanent',TRUE),(10023,23,'Permanent',TRUE),(10024,24,'Permanent',TRUE),
(10025,25,'Permanent',TRUE),(10026,26,'Permanent',TRUE),(10027,27,'Permanent',TRUE),
(10028,28,'Permanent',TRUE),(10029,29,'Permanent',TRUE),(10030,30,'Permanent',TRUE),
(10031,31,'Permanent',TRUE),(10032,32,'Permanent',TRUE),(10033,33,'Permanent',TRUE),
(10034,34,'Permanent',TRUE);

/* ── 5.7  Government IDs — values from CSV ── */
INSERT INTO government_ids (sss_no, philhealth_no, pagibig_no, tin_no, employee_id) VALUES
('44-4506057-3','820126853951','691295330870','442-605-657-000',10001),
('52-2061274-9','331735646338','663904995411','683-102-776-000',10002),
('30-8870406-2','177451189665','171519773969','971-711-280-000',10003),
('40-2511815-0','341911411254','416946776041','876-809-437-000',10004),
('50-5577638-1','957436191812','952347222457','031-702-374-000',10005),
('49-1632020-8','382189453145','441093369646','317-674-022-000',10006),
('40-2400714-1','239192926939','210850209964','672-474-690-000',10007),
('55-4476527-2','545652640232','211385556888','888-572-294-000',10008),
('41-0644692-3','708988234853','260107732354','604-997-793-000',10009),
('64-7605054-4','578114853194','799254095212','525-420-419-000',10010),
('26-9647608-3','126445315651','218002473454','210-805-911-000',10011),
('44-8563448-3','431709011012','113071293354','218-489-737-000',10012),
('45-5656375-0','233693897247','631130283546','210-835-851-000',10013),
('27-2090996-4','515741057496','101205445886','275-792-513-000',10014),
('26-8768374-1','308366860059','223057707853','598-065-761-000',10015),
('49-2959312-6','824187961962','631052853464','103-100-522-000',10016),
('27-2090208-8','587272469938','719007608464','482-259-498-000',10017),
('45-3251383-0','745148459521','114901859343','121-203-336-000',10018),
('49-1629900-2','579253435499','265104358643','122-244-511-000',10019),
('49-1647342-5','399665157135','260054585575','273-970-941-000',10020),
('45-5617168-2','606386917510','104907708845','354-650-951-000',10021),
('52-0109570-6','357451271274','113017988667','187-500-345-000',10022),
('52-9883524-3','548670482885','360028104576','101-558-994-000',10023),
('45-5866331-6','953901539995','913108649964','560-735-732-000',10024),
('47-1692793-0','753800654114','210546661243','841-177-857-000',10025),
('40-9504657-8','797639382265','210897095686','502-995-671-000',10026),
('45-3298166-4','810909286264','211274476563','336-676-445-000',10027),
('40-2400719-4','934389652994','122238077997','210-395-397-000',10028),
('60-1152206-4','351830469744','212141893454','395-032-717-000',10029),
('54-1331005-0','465087894112','515012579765','215-973-013-000',10030),
('52-1859253-1','136451303068','110018813465','599-312-588-000',10031),
('26-7145133-4','601644902402','697764069311','404-768-309-000',10032),
('11-5062972-7','380685387212','993372963726','256-436-296-000',10033),
('20-2987501-5','918460050077','874042259378','911-529-713-000',10034);

/* ── 5.8  User Accounts ── */
INSERT INTO user_account (employee_id, username, password_hash, email) VALUES
(10001,'mgarcia',    'Grca1201', 'mgarcia@motorph.com'),
(10002,'alim',       'Alim1988', 'alim@motorph.com'),
(10003,'baquino',    'Aqno8904', 'baquino@motorph.com'),
(10004,'ireyes',     'Ryes1994', 'ireyes@motorph.com'),
(10005,'ehernandez', 'HdzP8905', 'ehernandez@motorph.com'),
(10006,'avillanueva','Vill0206', 'avillanueva@motorph.com'),
(10007,'bsanjose',   'SJose0307','bsanjose@motorph.com'),
(10008,'aromualdez', 'Rmdl0508', 'aromualdez@motorph.com'),
(10009,'ratienza',   'Atzn0909', 'ratienza@motorph.com'),
(10010,'ralvaro',    'Alvr1010', 'ralvaro@motorph.com'),
(10011,'asalcedo',   'Slcd1111', 'asalcedo@motorph.com'),
(10012,'jlopez',     'Lopz1212', 'jlopez@motorph.com'),
(10013,'mfarala',    'Frla1313', 'mfarala@motorph.com'),
(10014,'lmartinez',  'Mrtz1414', 'lmartinez@motorph.com'),
(10015,'fromualdez', 'Rmdl1515', 'fromualdez@motorph.com'),
(10016,'cmata',      'Mata1616', 'cmata@motorph.com'),
(10017,'sdeleon',    'DLeo1717', 'sdeleon@motorph.com'),
(10018,'asanjose',   'SJse1818', 'asanjose@motorph.com'),
(10019,'crosario',   'Rsro1919', 'crosario@motorph.com'),
(10020,'mbautista',  'Buts2020', 'mbautista@motorph.com'),
(10021,'dlazaro',    'Lzro2121', 'dlazaro@motorph.com'),
(10022,'kdelossantos','Dlss2222','kdelossantos@motorph.com'),
(10023,'vsantos',    'Snts2323', 'vsantos@motorph.com'),
(10024,'tdelrosario','Dlrs2424', 'tdelrosario@motorph.com'),
(10025,'jtolentino', 'Tlnt2525', 'jtolentino@motorph.com'),
(10026,'pgutierrez', 'Gtzr2626', 'pgutierrez@motorph.com'),
(10027,'gmanalaysay','Mnls2727', 'gmanalaysay@motorph.com'),
(10028,'lvillegas',  'Vllg2828', 'lvillegas@motorph.com'),
(10029,'cramos',     'Rmos2929', 'cramos@motorph.com'),
(10030,'emaceda',    'Mcds3030', 'emaceda@motorph.com'),
(10031,'daguilar',   'Aglr3131', 'daguilar@motorph.com'),
(10032,'jcastro',    'Cstr3232', 'jcastro@motorph.com'),
(10033,'cmartinez',  'Mrtn3333', 'cmartinez@motorph.com'),
(10034,'bsantos',    'Snts3434', 'bsantos@motorph.com');

/* ── 5.9  Roles ── */
INSERT INTO role (role_name, description, created_date, last_modified) VALUES
('Admin',           'Full system access including user management and system configuration',     NOW(), NOW()),
('HR Manager',      'Manages employee records, attendance, and HR operations',                   NOW(), NOW()),
('Payroll Manager', 'Handles payroll processing, salary computation, and deductions',            NOW(), NOW()),
('Account Manager', 'Manages client accounts and financial transactions',                        NOW(), NOW()),
('IT Support',      'Maintains system infrastructure and technical support',                     NOW(), NOW()),
('Finance Officer', 'Oversees financial reporting, budgeting, and compliance',                   NOW(), NOW()),
('Employee',        'Standard user with limited access to personal records',                     NOW(), NOW()),
('Supervisor',      'Monitors and approves team activities and performance',                     NOW(), NOW());

/* ── 5.10  Permissions ── */
INSERT INTO permission (permission_name, description) VALUES
('VIEW_EMPLOYEE',       'View employee profile and personal information'),
('CREATE_EMPLOYEE',     'Create new employee records'),
('UPDATE_EMPLOYEE',     'Update employee profile information'),
('DELETE_EMPLOYEE',     'Delete employee records'),
('VIEW_DEPARTMENT',     'View department information'),
('MANAGE_DEPARTMENT',   'Create, update, or delete departments'),
('VIEW_POSITION',       'View employee positions'),
('MANAGE_POSITION',     'Create, update, or delete positions'),
('VIEW_ATTENDANCE',     'View attendance records'),
('MANAGE_ATTENDANCE',   'Create and update attendance logs'),
('VIEW_LEAVE',          'View leave requests and status'),
('MANAGE_LEAVE',        'Approve or reject leave requests'),
('VIEW_OVERTIME',       'View overtime records'),
('MANAGE_OVERTIME',     'Approve and manage overtime entries'),
('VIEW_PAYROLL',        'View payroll records'),
('PROCESS_PAYROLL',     'Generate and compute payroll'),
('VIEW_SALARY',         'View salary details'),
('MANAGE_SALARY',       'Update salary records'),
('VIEW_BENEFITS',       'View employee benefits'),
('MANAGE_BENEFITS',     'Assign and manage benefits'),
('VIEW_DEDUCTIONS',     'View deduction rules and records'),
('MANAGE_DEDUCTIONS',   'Configure deduction rules'),
('VIEW_ROLES',          'View system roles'),
('MANAGE_ROLES',        'Create and assign roles'),
('VIEW_PERMISSIONS',    'View system permissions'),
('MANAGE_PERMISSIONS',  'Assign permissions to roles'),
('VIEW_AUDIT_LOG',      'View system audit logs for tracking user actions');

/* ── 5.11  User Roles ── */
INSERT INTO user_role (user_id, role_id) VALUES
(1,1),(6,2),(11,3),(15,4),(5,5),(10,6),(2,8),(3,8),(4,8),
(7,7),(8,7),(9,7),(12,7),(13,7),(14,7),(16,7),(17,7),(18,7),
(19,7),(20,7),(21,7),(22,7),(23,7),(24,7),(25,7),(26,7),(27,7),
(28,7),(29,7),(30,7),(31,7),(32,7),(33,7),(34,7);

/* ── 5.12  Role Permissions ── */
INSERT INTO role_permission (role_id, permission_id) VALUES
/* Admin – all 27 */
(1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8),(1,9),(1,10),
(1,11),(1,12),(1,13),(1,14),(1,15),(1,16),(1,17),(1,18),(1,19),(1,20),
(1,21),(1,22),(1,23),(1,24),(1,25),(1,26),(1,27),
/* HR Manager */
(2,1),(2,2),(2,3),(2,5),(2,6),(2,7),(2,8),(2,9),(2,10),(2,11),(2,12),(2,23),(2,25),
/* Payroll Manager */
(3,15),(3,16),(3,17),(3,18),(3,21),(3,22),(3,9),(3,11),
/* Account Manager */
(4,1),(4,15),(4,17),(4,19),(4,21),
/* IT Support */
(5,23),(5,24),(5,25),(5,26),
/* Finance Officer */
(6,15),(6,16),(6,17),(6,21),(6,22),
/* Employee */
(7,1),(7,11),(7,15),(7,17),
/* Supervisor */
(8,1),(8,9),(8,11),(8,13),(8,15),(8,23);

/* ── 5.13  Audit Log (sample) ── */
INSERT INTO audit_log (user_id, action, entity_changed, entity_id, timestamp) VALUES
(1,'LOGIN','user_account',10001,NOW()),(1,'CREATE','employee_profile',10001,NOW()),
(2,'UPDATE','employee_profile',10010,NOW()),(3,'DELETE','employee_profile',10001,NOW()),
(4,'VIEW','payroll',10001,NOW()),(5,'CONFIGURE','permission',10001,NOW()),
(6,'APPROVE','leave_request',10001,NOW()),(7,'LOGIN','user_account',10007,NOW()),
(8,'UPDATE','employee_profile',10008,NOW()),(9,'VIEW','attendance',10001,NOW()),
(10,'CREATE','attendance',10001,NOW()),(11,'PROCESS','payroll',10001,NOW()),
(12,'CREATE','leave_request',10002,NOW()),(13,'APPROVE','overtime',10001,NOW()),
(14,'VIEW','salary_details',10001,NOW()),(15,'UPDATE','salary_details',10001,NOW()),
(16,'UPDATE','benefit_type',10001,NOW()),(17,'CREATE','deduction',10001,NOW()),
(18,'VIEW','department',10001,NOW()),(19,'LOGIN','user_account',10019,NOW()),
(20,'UPDATE','position',10001,NOW()),(21,'VIEW','employee_profile',10021,NOW()),
(22,'CREATE','attendance',10002,NOW()),(23,'APPROVE','leave_request',10002,NOW()),
(24,'VIEW','payroll',10002,NOW()),(25,'LOGIN','user_account',10025,NOW()),
(26,'PROCESS','payroll',10002,NOW()),(27,'UPDATE','employee_profile',10027,NOW()),
(28,'VIEW','audit_log',10001,NOW()),(29,'CREATE','salary_details',10002,NOW()),
(30,'VIEW','benefit_type',10001,NOW()),(31,'UPDATE','deduction',10001,NOW()),
(32,'LOGIN','user_account',10032,NOW()),(33,'VIEW','employee_profile',10033,NOW()),
(34,'UPDATE','attendance',10001,NOW());

/* ── 5.14  Shifts ── */
INSERT INTO shift (shift_name, start_time, end_time) VALUES
('Morning','08:00:00','17:00:00'),
('Mid',    '10:00:00','19:00:00'),
('Night',  '22:00:00','07:00:00');

/* ── 5.15  Attendance — sourced from Attendance Record CSV ──
   NOTE: hours_worked is auto-calculated as (time_out - time_in) in hours,
   capped at a max of 8 h regular hours (overtime is tracked separately).
   The INSERT uses the raw log-in/log-out values; the trigger/view below
   calculates actual hours_worked. Here we insert the raw times.           */
INSERT INTO attendance (employee_id, date, time_in, time_out) VALUES
(10001,'2024-06-03','08:59','18:31'),(10002,'2024-06-03','10:35','19:44'),
(10003,'2024-06-03','10:23','18:32'),(10004,'2024-06-03','10:57','18:14'),
(10005,'2024-06-03','09:48','17:13'),(10006,'2024-06-03','09:31','19:29'),
(10007,'2024-06-03','09:09','16:30'),(10008,'2024-06-03','09:02','18:06'),
(10009,'2024-06-03','08:18','17:40'),(10010,'2024-06-03','08:10','15:13'),
(10011,'2024-06-03','09:08','19:36'),(10012,'2024-06-03','09:47','18:43'),
(10013,'2024-06-03','09:48','19:21'),(10014,'2024-06-03','09:23','18:09'),
(10015,'2024-06-03','08:41','19:27'),(10016,'2024-06-03','08:41','16:45'),
(10017,'2024-06-03','09:40','17:24'),(10018,'2024-06-03','08:22','16:46'),
(10019,'2024-06-03','09:53','17:24'),(10020,'2024-06-03','08:47','16:27'),
(10021,'2024-06-03','09:37','18:45'),(10022,'2024-06-03','10:54','20:10'),
(10023,'2024-06-03','10:27','20:10'),(10024,'2024-06-03','09:16','17:57'),
(10025,'2024-06-03','10:18','18:07'),(10026,'2024-06-03','08:17','18:31'),
(10027,'2024-06-03','09:05','19:14'),(10028,'2024-06-03','08:52','17:23'),
(10029,'2024-06-03','10:57','21:44'),(10030,'2024-06-03','09:04','16:39'),
(10031,'2024-06-03','10:07','20:51'),(10032,'2024-06-03','08:29','16:46'),
(10033,'2024-06-03','10:02','19:39'),(10034,'2024-06-03','10:05','18:12'),
-- 2024-06-04
(10001,'2024-06-04','09:47','19:07'),(10002,'2024-06-04','10:11','20:16'),
(10003,'2024-06-04','10:45','20:37'),(10004,'2024-06-04','09:45','16:54'),
(10005,'2024-06-04','09:50','20:20'),(10006,'2024-06-04','10:00','20:12'),
(10007,'2024-06-04','09:16','16:18'),(10008,'2024-06-04','09:36','18:56'),
(10009,'2024-06-04','10:41','19:21'),(10010,'2024-06-04','08:05','18:36'),
(10011,'2024-06-04','09:58','17:04'),(10012,'2024-06-04','08:41','16:55'),
(10013,'2024-06-04','08:13','17:58'),(10014,'2024-06-04','09:11','17:10'),
(10015,'2024-06-04','10:35','18:43'),(10016,'2024-06-04','10:15','18:12'),
(10017,'2024-06-04','09:04','17:32'),(10018,'2024-06-04','10:40','21:01'),
(10019,'2024-06-04','08:05','18:10'),(10020,'2024-06-04','09:05','18:27'),
(10021,'2024-06-04','08:59','19:50'),(10022,'2024-06-04','10:58','18:51'),
(10023,'2024-06-04','10:06','20:32'),(10024,'2024-06-04','08:35','18:14'),
(10025,'2024-06-04','08:01','15:39'),(10026,'2024-06-04','08:25','16:41'),
(10027,'2024-06-04','10:47','20:39'),(10028,'2024-06-04','10:05','19:33'),
(10029,'2024-06-04','10:38','20:56'),(10030,'2024-06-04','08:20','16:30'),
(10031,'2024-06-04','10:13','17:52'),(10032,'2024-06-04','08:48','16:36'),
(10033,'2024-06-04','10:10','18:54'),(10034,'2024-06-04','09:35','19:15'),
-- 2024-06-05
(10001,'2024-06-05','10:57','21:32'),(10002,'2024-06-05','09:24','19:19'),
(10003,'2024-06-05','09:18','18:46'),(10004,'2024-06-05','08:44','18:31'),
(10005,'2024-06-05','09:10','17:17'),(10006,'2024-06-05','08:28','16:52'),
(10007,'2024-06-05','09:25','17:45'),(10008,'2024-06-05','10:44','18:51'),
(10009,'2024-06-05','10:46','17:54'),(10010,'2024-06-05','09:48','19:19'),
(10011,'2024-06-05','10:50','20:28'),(10012,'2024-06-05','08:52','19:40'),
(10013,'2024-06-05','08:49','16:12'),(10014,'2024-06-05','08:50','18:10'),
(10015,'2024-06-05','08:06','17:06'),(10016,'2024-06-05','09:29','19:25'),
(10017,'2024-06-05','08:08','17:06'),(10018,'2024-06-05','09:09','19:20'),
(10019,'2024-06-05','09:14','19:40'),(10020,'2024-06-05','10:42','21:00'),
(10021,'2024-06-05','10:18','18:05'),(10022,'2024-06-05','10:55','21:26'),
(10023,'2024-06-05','10:01','20:19'),(10024,'2024-06-05','09:19','19:00'),
(10025,'2024-06-05','10:50','18:44'),(10026,'2024-06-05','10:11','19:17'),
(10027,'2024-06-05','08:57','17:35'),(10028,'2024-06-05','10:14','19:01'),
(10029,'2024-06-05','08:02','15:06'),(10030,'2024-06-05','09:24','17:30'),
(10031,'2024-06-05','09:24','18:09'),(10032,'2024-06-05','10:33','19:11'),
(10033,'2024-06-05','09:59','18:34'),(10034,'2024-06-05','10:38','18:12'),
-- 2024-06-06
(10001,'2024-06-06','09:32','19:15'),(10002,'2024-06-06','10:47','20:43'),
(10003,'2024-06-06','10:10','18:01'),(10004,'2024-06-06','10:09','18:01'),
(10005,'2024-06-06','10:47','19:28'),(10006,'2024-06-06','10:11','17:27'),
(10007,'2024-06-06','09:51','19:58'),(10008,'2024-06-06','09:21','16:49'),
(10009,'2024-06-06','08:47','17:44'),(10010,'2024-06-06','10:51','19:37'),
(10011,'2024-06-06','10:31','20:05'),(10012,'2024-06-06','08:55','15:56'),
(10013,'2024-06-06','10:55','21:18'),(10014,'2024-06-06','09:08','17:30'),
(10015,'2024-06-06','08:12','18:22'),(10016,'2024-06-06','09:11','18:56'),
(10017,'2024-06-06','10:10','19:33'),(10018,'2024-06-06','08:25','15:51'),
(10019,'2024-06-06','09:08','17:46'),(10020,'2024-06-06','08:39','17:39'),
(10021,'2024-06-06','08:03','16:44'),(10022,'2024-06-06','08:09','18:21'),
(10023,'2024-06-06','10:55','19:53'),(10024,'2024-06-06','10:00','19:11'),
(10025,'2024-06-06','10:05','17:32'),(10026,'2024-06-06','08:13','15:42'),
(10027,'2024-06-06','09:01','18:33'),(10028,'2024-06-06','08:02','17:46'),
(10029,'2024-06-06','08:56','17:22'),(10030,'2024-06-06','09:59','20:54'),
(10031,'2024-06-06','09:23','16:24'),(10032,'2024-06-06','10:24','20:21'),
(10033,'2024-06-06','10:55','21:16'),(10034,'2024-06-06','09:49','19:09'),
-- 2024-06-07
(10001,'2024-06-07','09:46','19:15'),(10002,'2024-06-07','09:41','20:01'),
(10003,'2024-06-07','10:22','20:15'),(10004,'2024-06-07','09:28','18:11'),
(10005,'2024-06-07','08:14','16:58'),(10006,'2024-06-07','08:18','18:23'),
(10007,'2024-06-07','08:12','15:12'),(10008,'2024-06-07','08:19','16:22'),
(10009,'2024-06-07','10:09','20:58'),(10010,'2024-06-07','09:08','17:12'),
(10011,'2024-06-07','08:05','18:24'),(10012,'2024-06-07','10:26','19:03'),
(10013,'2024-06-07','08:37','16:15'),(10014,'2024-06-07','08:30','17:31'),
(10015,'2024-06-07','09:56','20:26'),(10016,'2024-06-07','09:41','16:51'),
(10017,'2024-06-07','09:50','18:23'),(10018,'2024-06-07','09:19','17:38'),
(10019,'2024-06-07','10:04','17:34'),(10020,'2024-06-07','08:45','17:21'),
(10021,'2024-06-07','09:52','19:04'),(10022,'2024-06-07','09:02','16:29'),
(10023,'2024-06-07','10:13','18:01'),(10024,'2024-06-07','09:56','16:59'),
(10025,'2024-06-07','10:23','20:19'),(10026,'2024-06-07','08:04','17:41'),
(10027,'2024-06-07','09:36','17:22'),(10028,'2024-06-07','08:29','19:24'),
(10029,'2024-06-07','09:56','20:35'),(10030,'2024-06-07','08:33','19:10'),
(10031,'2024-06-07','09:18','18:25'),(10032,'2024-06-07','08:52','19:40'),
(10033,'2024-06-07','08:02','15:02'),(10034,'2024-06-07','10:38','21:21'),
-- 2024-06-10
(10001,'2024-06-10','09:10','18:36'),(10002,'2024-06-10','08:02','18:40'),
(10003,'2024-06-10','08:58','17:52'),(10004,'2024-06-10','10:10','18:58'),
(10005,'2024-06-10','08:05','18:04'),(10006,'2024-06-10','08:10','16:39'),
(10007,'2024-06-10','10:03','17:48'),(10008,'2024-06-10','10:06','19:18'),
(10009,'2024-06-10','08:21','17:52'),(10010,'2024-06-10','10:55','19:46'),
(10011,'2024-06-10','08:34','18:32'),(10012,'2024-06-10','08:58','17:00'),
(10013,'2024-06-10','08:06','15:55'),(10014,'2024-06-10','09:43','19:52'),
(10015,'2024-06-10','10:27','20:11'),(10016,'2024-06-10','09:58','20:46'),
(10017,'2024-06-10','09:52','18:35'),(10018,'2024-06-10','10:51','20:16'),
(10019,'2024-06-10','09:10','17:11'),(10020,'2024-06-10','10:10','18:23'),
(10021,'2024-06-10','09:03','16:45'),(10022,'2024-06-10','10:26','17:58'),
(10023,'2024-06-10','09:25','16:34'),(10024,'2024-06-10','10:08','19:10'),
(10025,'2024-06-10','08:18','18:17'),(10026,'2024-06-10','08:42','17:01'),
(10027,'2024-06-10','08:06','15:36'),(10028,'2024-06-10','09:28','16:52'),
(10029,'2024-06-10','09:09','17:05'),(10030,'2024-06-10','08:21','17:24'),
(10031,'2024-06-10','10:24','20:26'),(10032,'2024-06-10','10:13','20:59'),
(10033,'2024-06-10','08:14','17:40'),(10034,'2024-06-10','08:01','17:28'),
-- 2024-06-11 to 2024-06-14
(10001,'2024-06-11','10:30','20:53'),(10002,'2024-06-11','09:55','19:49'),
(10003,'2024-06-11','09:35','17:06'),(10004,'2024-06-11','09:28','20:26'),
(10005,'2024-06-11','08:48','16:10'),(10006,'2024-06-11','09:26','18:47'),
(10007,'2024-06-11','09:18','17:50'),(10008,'2024-06-11','08:09','17:46'),
(10009,'2024-06-11','08:28','18:03'),(10010,'2024-06-11','08:23','15:46'),
(10011,'2024-06-11','10:09','17:16'),(10012,'2024-06-11','10:11','18:50'),
(10013,'2024-06-11','08:40','19:20'),(10014,'2024-06-11','10:46','20:44'),
(10015,'2024-06-11','08:51','17:19'),(10016,'2024-06-11','09:10','16:26'),
(10017,'2024-06-11','09:47','19:03'),(10018,'2024-06-11','09:32','17:59'),
(10019,'2024-06-11','09:49','19:35'),(10020,'2024-06-11','09:59','17:53'),
(10021,'2024-06-11','09:33','18:51'),(10022,'2024-06-11','09:28','18:33'),
(10023,'2024-06-11','08:48','19:10'),(10024,'2024-06-11','09:49','17:56'),
(10025,'2024-06-11','08:21','17:48'),(10026,'2024-06-11','10:35','20:15'),
(10027,'2024-06-11','10:18','19:33'),(10028,'2024-06-11','08:56','18:11'),
(10029,'2024-06-11','09:43','19:23'),(10030,'2024-06-11','08:20','18:18'),
(10031,'2024-06-11','09:04','17:38'),(10032,'2024-06-11','09:11','17:52'),
(10033,'2024-06-11','10:15','20:21'),(10034,'2024-06-11','10:39','17:46'),
(10001,'2024-06-12','08:37','18:25'),(10002,'2024-06-12','09:04','18:20'),
(10003,'2024-06-12','10:51','20:14'),(10004,'2024-06-12','09:12','16:56'),
(10005,'2024-06-12','10:10','18:34'),(10006,'2024-06-12','09:15','18:49'),
(10007,'2024-06-12','09:01','16:14'),(10008,'2024-06-12','09:55','17:36'),
(10009,'2024-06-12','10:27','20:01'),(10010,'2024-06-12','10:48','19:52'),
(10011,'2024-06-12','08:57','19:50'),(10012,'2024-06-12','10:45','19:08'),
(10013,'2024-06-12','09:34','19:14'),(10014,'2024-06-12','09:06','18:52'),
(10015,'2024-06-12','08:53','17:12'),(10016,'2024-06-12','10:38','20:53'),
(10017,'2024-06-12','09:05','16:27'),(10018,'2024-06-12','08:25','15:59'),
(10019,'2024-06-12','10:09','18:38'),(10020,'2024-06-12','08:50','16:42'),
(10021,'2024-06-12','10:09','19:52'),(10022,'2024-06-12','10:35','21:04'),
(10023,'2024-06-12','10:53','20:58'),(10024,'2024-06-12','10:05','18:59'),
(10025,'2024-06-12','08:23','17:26'),(10026,'2024-06-12','08:03','17:02'),
(10027,'2024-06-12','09:15','16:57'),(10028,'2024-06-12','10:33','18:46'),
(10029,'2024-06-12','08:37','16:08'),(10030,'2024-06-12','08:20','16:05'),
(10031,'2024-06-12','09:36','20:16'),(10032,'2024-06-12','09:16','19:11'),
(10033,'2024-06-12','08:11','17:57'),(10034,'2024-06-12','08:56','18:37'),
(10001,'2024-06-13','08:24','19:20'),(10002,'2024-06-13','08:35','18:33'),
(10003,'2024-06-13','08:53','19:06'),(10004,'2024-06-13','09:49','17:38'),
(10005,'2024-06-13','09:56','18:07'),(10006,'2024-06-13','10:47','19:54'),
(10007,'2024-06-13','10:00','18:49'),(10008,'2024-06-13','09:14','19:44'),
(10009,'2024-06-13','10:09','17:16'),(10010,'2024-06-13','10:59','21:30'),
(10011,'2024-06-13','08:08','17:12'),(10012,'2024-06-13','09:10','17:36'),
(10013,'2024-06-13','09:13','18:23'),(10014,'2024-06-13','10:56','21:55'),
(10015,'2024-06-13','09:49','17:47'),(10016,'2024-06-13','08:48','16:16'),
(10017,'2024-06-13','09:10','19:57'),(10018,'2024-06-13','08:02','17:45'),
(10019,'2024-06-13','09:44','20:13'),(10020,'2024-06-13','10:17','18:23'),
(10021,'2024-06-13','08:47','17:17'),(10022,'2024-06-13','09:11','17:26'),
(10023,'2024-06-13','09:30','19:55'),(10024,'2024-06-13','10:53','18:33'),
(10025,'2024-06-13','09:11','17:41'),(10026,'2024-06-13','09:35','18:44'),
(10027,'2024-06-13','08:44','19:30'),(10028,'2024-06-13','10:22','19:14'),
(10029,'2024-06-13','08:06','17:03'),(10030,'2024-06-13','09:34','16:40'),
(10031,'2024-06-13','08:20','17:02'),(10032,'2024-06-13','09:00','18:18'),
(10033,'2024-06-13','10:17','18:35'),(10034,'2024-06-13','08:35','15:37'),
(10001,'2024-06-14','09:28','19:24'),(10002,'2024-06-14','08:22','17:34'),
(10003,'2024-06-14','10:20','18:16'),(10004,'2024-06-14','09:32','20:09'),
(10005,'2024-06-14','08:50','16:13'),(10006,'2024-06-14','09:36','16:42'),
(10007,'2024-06-14','08:12','16:15'),(10008,'2024-06-14','08:40','18:51'),
(10009,'2024-06-14','08:16','18:15'),(10010,'2024-06-14','09:41','20:11'),
(10011,'2024-06-14','09:49','17:31'),(10012,'2024-06-14','08:39','16:13'),
(10013,'2024-06-14','08:11','16:02'),(10014,'2024-06-14','10:43','21:35'),
(10015,'2024-06-14','08:25','18:56'),(10016,'2024-06-14','08:23','16:51'),
(10017,'2024-06-14','09:40','17:06'),(10018,'2024-06-14','10:43','18:48'),
(10019,'2024-06-14','09:30','20:15'),(10020,'2024-06-14','08:53','18:16'),
(10021,'2024-06-14','09:44','18:25'),(10022,'2024-06-14','10:50','18:13'),
(10023,'2024-06-14','10:53','18:21'),(10024,'2024-06-14','10:32','20:01'),
(10025,'2024-06-14','10:47','20:27'),(10026,'2024-06-14','08:34','16:56'),
(10027,'2024-06-14','10:59','19:33'),(10028,'2024-06-14','08:09','18:57'),
(10029,'2024-06-14','08:06','18:49'),(10030,'2024-06-14','10:29','20:21'),
(10031,'2024-06-14','10:28','21:27'),(10032,'2024-06-14','10:40','20:16'),
(10033,'2024-06-14','09:32','19:35'),(10034,'2024-06-14','09:26','19:24');
-- NOTE: Remaining attendance rows (Jun 17 – Aug 30) are identical to the original

/* ── 5.16  Leave Types ── */
INSERT INTO leave_type (leave_name, description, max_days) VALUES
('Sick leave',       'Leave for illness or medical-related concerns',            15),
('Vacation leave',   'Personal or leisure leave',                                15),
('Emergency leave',  'Unplanned urgent situations',                               5),
('Maternity leave',  'Leave for childbirth and recovery',                       105),
('Paternity leave',  'Leave for fathers after childbirth',                        7),
('Bereavement leave','Leave due to death of immediate family member',             3),
('Unpaid leave',     'Leave without pay for personal reasons',                    0);

/* ── 5.17  Leave Requests ── */
INSERT INTO leave_request (employee_id, leave_type_id, start_date, end_date, status, approved_by, approval_date, remarks) VALUES
(10001,1,'2026-06-01','2026-06-03','Pending',  NULL,  NULL,         'For approval - sick leave request'),
(10002,2,'2026-06-05','2026-06-06','Approved', 10001,'2026-06-01', 'Approved'),
(10003,3,'2026-06-10','2026-06-12','Rejected', 10001,'2026-06-02', 'Insufficient supporting documents'),
(10004,1,'2026-06-15','2026-06-17','Pending',  NULL,  NULL,         'Awaiting manager review'),
(10005,2,'2026-06-20','2026-06-21','Approved', 10002,'2026-06-18', 'Approved'),
(10006,2,'2026-06-20','2026-06-21','Pending',  10002,'2026-06-18', 'For approval - vacation leave request');

/* ── 5.18  Overtime ── */
INSERT INTO overtime (attendance_id, ot_hours, multiplier, date, approved_by, approval_date) VALUES
(1,2,1.25,'2024-06-03',10001,'2024-06-04'),
(2,2,1.25,'2024-06-03',10001,'2024-06-04'),
(3,2,1.25,'2024-06-03',NULL, NULL),
(4,1,1.25,'2024-06-03',10001,'2024-06-04'),
(5,1,1.25,'2024-06-03',10003,'2024-06-04');

/* ── 5.19  Pay Periods ── */
INSERT INTO pay_period (start_date, end_date) VALUES
('2024-06-01','2024-06-15'),('2024-06-16','2024-06-30'),
('2024-07-01','2024-07-15'),('2024-07-16','2024-07-31'),
('2024-08-01','2024-08-15'),('2024-08-16','2024-08-31'),
('2024-09-01','2024-09-15'),('2024-09-16','2024-09-30'),
('2024-10-01','2024-10-15'),('2024-10-16','2024-10-31'),
('2024-11-01','2024-11-15'),('2024-11-16','2024-11-30'),
('2024-12-01','2024-12-15'),('2024-12-16','2024-12-31');

/* ── 5.20  Salary Details — ALL VALUES FROM CSV ── */
INSERT INTO salary_details (employee_id, basic_salary, hourly_rate, effective_date, end_date) VALUES
(10001, 90000.00, 535.71, '2020-01-15', NULL),
(10002, 60000.00, 357.14, '2020-02-01', NULL),
(10003, 60000.00, 357.14, '2020-02-15', NULL),
(10004, 60000.00, 357.14, '2020-03-01', NULL),
(10005, 52670.00, 313.51, '2020-04-01', NULL),
(10006, 52670.00, 313.51, '2020-04-15', NULL),
(10007, 42975.00, 255.80, '2021-01-15', NULL),
(10008, 22500.00, 133.93, '2021-02-01', NULL),
(10009, 22500.00, 133.93, '2021-02-15', NULL),
(10010, 52670.00, 313.51, '2020-05-01', NULL),
(10011, 50825.00, 302.53, '2020-05-15', NULL),
(10012, 38475.00, 229.02, '2021-03-01', NULL),
(10013, 24000.00, 142.86, '2021-03-15', NULL),
(10014, 24000.00, 142.86, '2021-04-01', NULL),
(10015, 53500.00, 318.45, '2020-06-01', NULL),
(10016, 42975.00, 255.80, '2021-04-15', NULL),
(10017, 41850.00, 249.11, '2021-05-01', NULL),
(10018, 22500.00, 133.93, '2021-06-01', NULL),
(10019, 22500.00, 133.93, '2021-06-15', NULL),
(10020, 23250.00, 138.39, '2021-07-01', NULL),
(10021, 23250.00, 138.39, '2024-01-15', NULL),
(10022, 24000.00, 142.86, '2024-02-01', NULL),
(10023, 22500.00, 133.93, '2024-02-15', NULL),
(10024, 22500.00, 133.93, '2024-03-01', NULL),
(10025, 24000.00, 142.86, '2024-03-15', NULL),
(10026, 24750.00, 147.32, '2024-04-01', NULL),
(10027, 24750.00, 147.32, '2024-04-15', NULL),
(10028, 24000.00, 142.86, '2024-05-01', NULL),
(10029, 22500.00, 133.93, '2024-05-15', NULL),
(10030, 22500.00, 133.93, '2024-06-01', NULL),
(10031, 22500.00, 133.93, '2024-06-15', NULL),
(10032, 52670.00, 313.51, '2021-08-01', NULL),
(10033, 52670.00, 313.51, '2021-08-15', NULL),
(10034, 52670.00, 313.51, '2021-09-01', NULL);

/* ── 5.21  Benefit Types ── */
INSERT INTO benefit_type (benefit_name) VALUES
('Rice Subsidy'), ('Phone Allowance'), ('Clothing Allowance');

/* ── 5.22  Position Allowance — ALL VALUES FROM CSV ── */
INSERT INTO position_allowance (position_id, rice_subsidy, phone_allowance, clothing_allowance, total_allowance) VALUES
-- Executives (position_id 1–4): RS=1500, PA=2000, CA=1000, Total=4500
(1,  1500.00, 2000.00, 1000.00, 4500.00),
(2,  1500.00, 2000.00, 1000.00, 4500.00),
(3,  1500.00, 2000.00, 1000.00, 4500.00),
(4,  1500.00, 2000.00, 1000.00, 4500.00),
-- IT Ops / HR Manager / Accounting Head / Payroll Manager / Account Manager / Sales & Marketing / Logistics / CustSvc
-- (position_id 5,6,9,10,13,16,17,18): RS=1500, PA=1000, CA=1000, Total=3500
(5,  1500.00, 1000.00, 1000.00, 3500.00),
(6,  1500.00, 1000.00, 1000.00, 3500.00),
(9,  1500.00, 1000.00, 1000.00, 3500.00),
(10, 1500.00, 1000.00, 1000.00, 3500.00),
(13, 1500.00, 1000.00, 1000.00, 3500.00),
(16, 1500.00, 1000.00, 1000.00, 3500.00),
(17, 1500.00, 1000.00, 1000.00, 3500.00),
(18, 1500.00, 1000.00, 1000.00, 3500.00),
-- Team Leaders (position_id 7,11,14): RS=1500, PA=800, CA=800, Total=3100
(7,  1500.00, 800.00,  800.00,  3100.00),
(11, 1500.00, 800.00,  800.00,  3100.00),
(14, 1500.00, 800.00,  800.00,  3100.00),
-- Rank & File (position_id 8,12,15): RS=1500, PA=500, CA=500, Total=2500
(8,  1500.00, 500.00,  500.00,  2500.00),
(12, 1500.00, 500.00,  500.00,  2500.00),
(15, 1500.00, 500.00,  500.00,  2500.00);

/* ── 5.23  Deduction Types ── */
INSERT INTO deduction_type (deduction_type, description) VALUES
('SSS Contribution',       'Mandatory Social Security System employee share'),
('PhilHealth Contribution','Mandatory PhilHealth contribution (employee share = 50% of monthly premium)'),
('Pag-IBIG Contribution',  'Mandatory Pag-IBIG Fund employee contribution'),
('Withholding Tax',        'Monthly income tax withheld based on BIR tax table'),
('Late Deduction',         'Deduction for tardiness based on attendance records'),
('Undertime Deduction',    'Deduction for hours worked below required shift hours'),
('Absence Deduction',      'Deduction for unexcused absences');

/* ── 5.24  Deduction Brackets (2024 Philippine rates) ── */
INSERT INTO deduction (deduction_type_id, lower_amount, upper_amount, tax_base, b_rate) VALUES
-- SSS (monthly salary credit → monthly contribution, employee share)
(1,    0.00,  3249.99, NULL,   135.00),
(1, 3250.00,  3749.99, NULL,   157.50),
(1, 3750.00,  4249.99, NULL,   180.00),
(1, 4250.00,  4749.99, NULL,   202.50),
(1, 4750.00,  5249.99, NULL,   225.00),
(1, 5250.00,  5749.99, NULL,   247.50),
(1, 5750.00,  6249.99, NULL,   270.00),
(1, 6250.00,  6749.99, NULL,   292.50),
(1, 6750.00,  7249.99, NULL,   315.00),
(1, 7250.00,  7749.99, NULL,   337.50),
(1, 7750.00,  8249.99, NULL,   360.00),
(1, 8250.00,  8749.99, NULL,   382.50),
(1, 8750.00,  9249.99, NULL,   405.00),
(1, 9250.00,  9749.99, NULL,   427.50),
(1, 9750.00, 10249.99, NULL,   450.00),
(1,10250.00, 10749.99, NULL,   472.50),
(1,10750.00, 11249.99, NULL,   495.00),
(1,11250.00, 11749.99, NULL,   517.50),
(1,11750.00, 12249.99, NULL,   540.00),
(1,12250.00, 12749.99, NULL,   562.50),
(1,12750.00, 13249.99, NULL,   585.00),
(1,13250.00, 13749.99, NULL,   607.50),
(1,13750.00, 14249.99, NULL,   630.00),
(1,14250.00, 14749.99, NULL,   652.50),
(1,14750.00, 15249.99, NULL,   675.00),
(1,15250.00, 15749.99, NULL,   697.50),
(1,15750.00, 16249.99, NULL,   720.00),
(1,16250.00, 16749.99, NULL,   742.50),
(1,16750.00, 17249.99, NULL,   765.00),
(1,17250.00, 17749.99, NULL,   787.50),
(1,17750.00, 18249.99, NULL,   810.00),
(1,18250.00, 18749.99, NULL,   832.50),
(1,18750.00, 19249.99, NULL,   855.00),
(1,19250.00, 19749.99, NULL,   877.50),
(1,19750.00, 20249.99, NULL,   900.00),
(1,20250.00, 20749.99, NULL,   922.50),
(1,20750.00, 21249.99, NULL,   945.00),
(1,21250.00, 21749.99, NULL,   967.50),
(1,21750.00, 22249.99, NULL,   990.00),
(1,22250.00, 22749.99, NULL,  1012.50),
(1,22750.00, 23249.99, NULL,  1035.00),
(1,23250.00, 23749.99, NULL,  1057.50),
(1,23750.00, 24249.99, NULL,  1080.00),
(1,24250.00, 24749.99, NULL,  1102.50),
(1,24750.00,99999999.99,NULL, 1125.00),
-- PhilHealth (monthly premium = 3% of basic salary; employee pays 50%)
-- tax_base = 0.03 (3% total premium rate); b_rate = fixed floor/ceiling (TOTAL premium, not EE share)
(2,     0.00,  10000.00, 0.03,  300.00),   -- floor: monthly premium = 300, EE pays 150
(2, 10000.01,  59999.99, 0.03,  NULL),     -- no cap until ceiling: EE pays 1.5% of basic
(2, 60000.00,99999999.99,0.03, 1800.00),   -- ceiling: monthly premium = 1800, EE pays 900
-- Pag-IBIG (employee contribution rate varies by salary, capped at 100 per month)
(3,  1000.00,   1500.00, 0.01, 0.01),      -- 1% for 1,000–1,500
(3,  1500.01,99999999.99,0.02, 0.02),      -- 2% for over 1,500
-- Withholding Tax (monthly taxable income brackets, TRAIN Law)
(4,      0.00,  20832.00, 0.00,  0.00),
(4,  20833.00,  33332.00, 0.00,  0.20),
(4,  33333.00,  66666.00, 2500.00, 0.25),
(4,  66667.00, 166666.00,10833.33, 0.30),
(4, 166667.00, 666666.00,40833.33, 0.32),
(4, 666667.00,99999999.99,200833.33,0.35);

/* ── 5.25  Sample Payroll Records ── */
INSERT INTO payroll (employee_id, pay_period_id, gross_pay, net_pay, total_deductions, tax, total_benefits, payroll_date) VALUES
(10001,1,45000.00,38000.00,4000.00,3000.00,3000.00,'2024-06-15'),
(10002,1,30000.00,25500.00,2500.00,2000.00,2000.00,'2024-06-15'),
(10003,1,30000.00,25700.00,2400.00,1900.00,2000.00,'2024-06-15'),
(10001,2,45000.00,38200.00,4200.00,2800.00,3000.00,'2024-06-30'),
(10002,2,30000.00,25800.00,2600.00,1600.00,2000.00,'2024-06-30'),
(10003,2,30000.00,25900.00,2500.00,1600.00,2000.00,'2024-06-30'),
(10001,3,45000.00,38100.00,4100.00,2800.00,3000.00,'2024-07-15'),
(10002,3,30000.00,25600.00,2600.00,1800.00,2000.00,'2024-07-15'),
(10001,4,45000.00,38300.00,4000.00,2700.00,3000.00,'2024-07-31'),
(10002,4,30000.00,25750.00,2550.00,1700.00,2000.00,'2024-07-31'),
(10001,5,45000.00,38400.00,3900.00,2700.00,3000.00,'2024-08-15'),
(10002,5,30000.00,25850.00,2500.00,1650.00,2000.00,'2024-08-15'),
(10001,6,45000.00,38500.00,3800.00,2700.00,3000.00,'2024-08-31'),
(10002,6,30000.00,25900.00,2500.00,1600.00,2000.00,'2024-08-31');

/* ── 5.26  Payroll Benefits (sample) ── */
INSERT INTO payroll_benefit (employee_id, payroll_id, benefit_type_id) VALUES
(10001,1,1),(10001,1,2),(10001,1,3),
(10002,1,1),(10002,1,2),(10002,1,3);

/* =====================================================================================
   SECTION 6 — PAYSLIP CALCULATION QUERY & STORED PROCEDURE
   
   Philippine mandatory deductions applied:
     1. SSS         — Employee share per monthly salary credit bracket (2024 table)
     2. PhilHealth  — Employee pays 2.5% of monthly basic salary
                      (floor: ₱250, ceiling: ₱5,000 per month)
                      Divided by 2 for semi-monthly payroll.
     3. Pag-IBIG    — 2% of monthly basic salary, capped at ₱100/month.
                      Divided by 2 for semi-monthly payroll.
     4. Withholding Tax — TRAIN Law monthly bracket, divided by 2 for semi-monthly.
   
   Benefits (non-taxable, added back):
     Rice Subsidy, Phone Allowance, Clothing Allowance
     (prorated semi-monthly = monthly amount / 2)
   
   Gross Semi-monthly Pay = (Basic Monthly Salary / 2) + (Total Monthly Allowances / 2)
   Net Pay = Gross Semi-monthly Pay − SSS_semi − PhilHealth_semi − PagIBIG_semi − Tax_semi
   ===================================================================================== */

/* ─────────────────────────────────────────────────────────────────
   6.1  Helper VIEW: vw_payslip_calculation
        Returns one row per employee with all computed components.
        Call this for any pay period to build a payslip.
   ───────────────────────────────────────────────────────────────── */
CREATE OR REPLACE VIEW vw_payslip_calculation AS
WITH salary AS (
    SELECT
        sd.employee_id,
        sd.basic_salary                               AS monthly_basic,
        sd.basic_salary / 2                           AS semi_monthly_basic,
        sd.hourly_rate
    FROM salary_details sd
    WHERE sd.end_date IS NULL                          -- active salary record
),
allowance AS (
    SELECT
        ep.employee_id,
        ep.position_id,
        COALESCE(pa.rice_subsidy, 0)                  AS rice_subsidy_monthly,
        COALESCE(pa.phone_allowance, 0)               AS phone_allowance_monthly,
        COALESCE(pa.clothing_allowance, 0)            AS clothing_allowance_monthly,
        COALESCE(pa.total_allowance, 0)               AS total_allowance_monthly,
        COALESCE(pa.rice_subsidy, 0)       / 2        AS rice_subsidy_semi,
        COALESCE(pa.phone_allowance, 0)    / 2        AS phone_allowance_semi,
        COALESCE(pa.clothing_allowance, 0) / 2        AS clothing_allowance_semi,
        COALESCE(pa.total_allowance, 0)    / 2        AS total_allowance_semi
    FROM employee_profile ep
    LEFT JOIN position_allowance pa ON pa.position_id = ep.position_id
),
sss_calc AS (
    /* SSS: monthly contribution based on monthly basic salary bracket.
       The full monthly contribution is split equally — employee pays half
       each cut-off (semi-monthly payroll).                               */
    SELECT
        s.employee_id,
        d.b_rate                                      AS sss_monthly,
        d.b_rate / 2                                  AS sss_semi
    FROM salary s
    JOIN deduction d   ON d.deduction_type_id = 1
    JOIN deduction_type dt ON dt.deduction_type_id = 1
    WHERE s.monthly_basic BETWEEN d.lower_amount AND d.upper_amount
),
philhealth_calc AS (
    /* PhilHealth (per provided table): 3% of monthly basic = TOTAL premium.
       Employee pays 50% = 1.5% of monthly basic.
       Floor: basic <= 10,000  -> total premium = 300  -> EE share = 150
       Ceiling: basic >= 60,000 -> total premium = 1,800 -> EE share = 900
       For semi-monthly payroll, divide monthly employee share by 2.      */
    SELECT
        s.employee_id,
        ROUND(
            CASE
                WHEN s.monthly_basic <= 10000.00  THEN 150.00
                WHEN s.monthly_basic >= 60000.00  THEN 900.00
                ELSE s.monthly_basic * 0.015
            END, 2
        )                                             AS philhealth_monthly_ee,
        ROUND(
            CASE
                WHEN s.monthly_basic <= 10000.00  THEN 150.00
                WHEN s.monthly_basic >= 60000.00  THEN 900.00
                ELSE s.monthly_basic * 0.015
            END / 2, 2
        )                                             AS philhealth_semi
    FROM salary s
),
pagibig_calc AS (
    /* Pag-IBIG (per provided table): 1% of monthly basic for ₱1,000–₱1,500,
       2% of monthly basic for over ₱1,500. Capped at ₱100/month either way.
       For semi-monthly payroll, divide by 2.                             */
    SELECT
        s.employee_id,
        ROUND(
            LEAST(
                s.monthly_basic * CASE WHEN s.monthly_basic <= 1500.00 THEN 0.01 ELSE 0.02 END,
                100.00
            ), 2
        )                                                AS pagibig_monthly,
        ROUND(
            LEAST(
                s.monthly_basic * CASE WHEN s.monthly_basic <= 1500.00 THEN 0.01 ELSE 0.02 END,
                100.00
            ) / 2, 2
        )                                                AS pagibig_semi
    FROM salary s
),
gross_calc AS (
    /* Gross semi-monthly = semi_monthly_basic + semi-monthly allowances  */
    SELECT
        s.employee_id,
        s.monthly_basic,
        s.semi_monthly_basic,
        s.hourly_rate,
        a.rice_subsidy_monthly,
        a.phone_allowance_monthly,
        a.clothing_allowance_monthly,
        a.total_allowance_monthly,
        a.rice_subsidy_semi,
        a.phone_allowance_semi,
        a.clothing_allowance_semi,
        a.total_allowance_semi,
        ROUND(s.semi_monthly_basic + a.total_allowance_semi, 2) AS gross_semi_monthly
    FROM salary s
    JOIN allowance a ON a.employee_id = s.employee_id
),
tax_calc AS (
    /* Withholding Tax (TRAIN Law 2024):
       Taxable income = monthly basic − SSS_monthly − PhilHealth_monthly_ee − PagIBIG_monthly
       Tax is computed monthly then divided by 2 for semi-monthly deduction. */
    SELECT
        g.employee_id,
        g.monthly_basic,
        sss.sss_monthly,
        ph.philhealth_monthly_ee,
        pi.pagibig_monthly,
        GREATEST(
            g.monthly_basic
            - sss.sss_monthly
            - ph.philhealth_monthly_ee
            - pi.pagibig_monthly,
            0
        )
        
	AS taxable_monthly,
        ROUND(
            CASE
                WHEN (g.monthly_basic - sss.sss_monthly - ph.philhealth_monthly_ee - pi.pagibig_monthly) <= 20832
                    THEN 0
                WHEN (g.monthly_basic - sss.sss_monthly - ph.philhealth_monthly_ee - pi.pagibig_monthly) <= 33332
                    THEN (g.monthly_basic - sss.sss_monthly - ph.philhealth_monthly_ee - pi.pagibig_monthly - 20833) * 0.20
                WHEN (g.monthly_basic - sss.sss_monthly - ph.philhealth_monthly_ee - pi.pagibig_monthly) <= 66666
                    THEN 2500  + (g.monthly_basic - sss.sss_monthly - ph.philhealth_monthly_ee - pi.pagibig_monthly - 33333) * 0.25
                WHEN (g.monthly_basic - sss.sss_monthly - ph.philhealth_monthly_ee - pi.pagibig_monthly) <= 166666
                    THEN 10833.33 + (g.monthly_basic - sss.sss_monthly - ph.philhealth_monthly_ee - pi.pagibig_monthly - 66667) * 0.30
                WHEN (g.monthly_basic - sss.sss_monthly - ph.philhealth_monthly_ee - pi.pagibig_monthly) <= 666666
                    THEN 40833.33 + (g.monthly_basic - sss.sss_monthly - ph.philhealth_monthly_ee - pi.pagibig_monthly - 166667) * 0.32
                ELSE 200833.33  + (g.monthly_basic - sss.sss_monthly - ph.philhealth_monthly_ee - pi.pagibig_monthly - 666667) * 0.35
            END, 2
        )                                             AS tax_monthly,
        ROUND(
            CASE
                WHEN (g.monthly_basic - sss.sss_monthly - ph.philhealth_monthly_ee - pi.pagibig_monthly) <= 20832
                    THEN 0
                WHEN (g.monthly_basic - sss.sss_monthly - ph.philhealth_monthly_ee - pi.pagibig_monthly) <= 33332
                    THEN (g.monthly_basic - sss.sss_monthly - ph.philhealth_monthly_ee - pi.pagibig_monthly - 20833) * 0.20
                WHEN (g.monthly_basic - sss.sss_monthly - ph.philhealth_monthly_ee - pi.pagibig_monthly) <= 66666
                    THEN 2500  + (g.monthly_basic - sss.sss_monthly - ph.philhealth_monthly_ee - pi.pagibig_monthly - 33333) * 0.25
                WHEN (g.monthly_basic - sss.sss_monthly - ph.philhealth_monthly_ee - pi.pagibig_monthly) <= 166666
                    THEN 10833.33 + (g.monthly_basic - sss.sss_monthly - ph.philhealth_monthly_ee - pi.pagibig_monthly - 66667) * 0.30
                WHEN (g.monthly_basic - sss.sss_monthly - ph.philhealth_monthly_ee - pi.pagibig_monthly) <= 666666
                    THEN 40833.33 + (g.monthly_basic - sss.sss_monthly - ph.philhealth_monthly_ee - pi.pagibig_monthly - 166667) * 0.32
                ELSE 200833.33  + (g.monthly_basic - sss.sss_monthly - ph.philhealth_monthly_ee - pi.pagibig_monthly - 666667) * 0.35
            END / 2, 2
        )                                             AS tax_semi
    FROM gross_calc g
    JOIN sss_calc  sss ON sss.employee_id = g.employee_id
    JOIN philhealth_calc ph ON ph.employee_id = g.employee_id
    JOIN pagibig_calc    pi ON pi.employee_id = g.employee_id
)
SELECT
    ep.employee_id,
    CONCAT(ep.last_name, ', ', ep.first_name)         AS employee_name,
    ep2.name                                          AS position,
    d.name                                            AS department,
    s2.status_name                                    AS employment_status,
    ep.supervisor_name,

    /* ─── Earnings ─── */
    g.monthly_basic,
    g.semi_monthly_basic,
    g.rice_subsidy_monthly,
    g.phone_allowance_monthly,
    g.clothing_allowance_monthly,
    g.total_allowance_monthly,
    g.rice_subsidy_semi,
    g.phone_allowance_semi,
    g.clothing_allowance_semi,
    g.total_allowance_semi,
    g.gross_semi_monthly,

    /* ─── Mandatory Deductions ─── */
    sss.sss_monthly,
    sss.sss_semi,
    ph.philhealth_monthly_ee,
    ph.philhealth_semi,
    pi.pagibig_monthly,
    pi.pagibig_semi,
    tx.taxable_monthly,
    tx.tax_monthly,
    tx.tax_semi,

    /* ─── Summary ─── */
    ROUND(sss.sss_semi + ph.philhealth_semi + pi.pagibig_semi + tx.tax_semi, 2)
													AS total_deductions_semi,
    ROUND(g.gross_semi_monthly
        - sss.sss_semi
        - ph.philhealth_semi
        - pi.pagibig_semi
        - tx.tax_semi, 2)                           AS net_pay_semi,

    g.hourly_rate
FROM employee_profile ep
JOIN employee_position ep2 ON ep2.position_id   = ep.position_id
JOIN department         d  ON d.department_id   = ep.department_id
JOIN status             s2 ON s2.status_id      = ep.status_id
JOIN gross_calc         g  ON g.employee_id     = ep.employee_id
JOIN sss_calc         sss  ON sss.employee_id   = ep.employee_id
JOIN philhealth_calc   ph  ON ph.employee_id    = ep.employee_id
JOIN pagibig_calc      pi  ON pi.employee_id    = ep.employee_id
JOIN tax_calc          tx  ON tx.employee_id    = ep.employee_id
WHERE ep.is_active = TRUE;


/* ─────────────────────────────────────────────────────────────────
   6.2  Payslip Stored Procedure
        Usage:  CALL sp_generate_payslip(10001, 1);
                → generates a payslip for EMP 10001 for pay_period_id 1
        If pay_period_id = 0, returns the standing computed payslip
        without linking to a specific payroll record.
   ───────────────────────────────────────────────────────────────── */
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_generate_payslip$$

CREATE PROCEDURE sp_generate_payslip(
    IN  p_employee_id   INT,
    IN  p_pay_period_id INT          -- pass 0 to use current computed values only
)
BEGIN
    DECLARE v_period_start  DATE;
    DECLARE v_period_end    DATE;

    -- Get pay period dates if provided
    IF p_pay_period_id > 0 THEN
        SELECT start_date, end_date
          INTO v_period_start, v_period_end
          FROM pay_period
         WHERE pay_period_id = p_pay_period_id;
    ELSE
        SET v_period_start = CURDATE();
        SET v_period_end   = CURDATE();
    END IF;

    SELECT
        /* ── Header ── */
        pc.employee_id                          AS `Employee ID`,
        pc.employee_name                        AS `Employee Name`,
        pc.position                             AS `Position`,
        pc.department                           AS `Department`,
        pc.employment_status                    AS `Status`,
        pc.supervisor_name                      AS `Supervisor`,
        v_period_start                          AS `Pay Period Start`,
        v_period_end                            AS `Pay Period End`,

        /* ── Earnings ── */
        FORMAT(pc.monthly_basic, 2)             AS `Monthly Basic Salary`,
        FORMAT(pc.semi_monthly_basic, 2)        AS `Semi-Monthly Basic`,

        /* ── Allowances (semi-monthly) ── */
        FORMAT(pc.rice_subsidy_semi, 2)         AS `Rice Subsidy (Semi)`,
        FORMAT(pc.phone_allowance_semi, 2)      AS `Phone Allowance (Semi)`,
        FORMAT(pc.clothing_allowance_semi, 2)   AS `Clothing Allowance (Semi)`,
        FORMAT(pc.total_allowance_semi, 2)      AS `Total Allowances (Semi)`,
        FORMAT(pc.gross_semi_monthly, 2)        AS `Gross Semi-Monthly Pay`,

        /* ── Mandatory Deductions (semi-monthly) ── */
        FORMAT(pc.sss_semi, 2)                  AS `SSS Contribution (Semi)`,
        FORMAT(pc.philhealth_semi, 2)           AS `PhilHealth Contribution (Semi)`,
        FORMAT(pc.pagibig_semi, 2)              AS `Pag-IBIG Contribution (Semi)`,
        FORMAT(pc.tax_semi, 2)                  AS `Withholding Tax (Semi)`,
        FORMAT(pc.total_deductions_semi, 2)     AS `Total Deductions (Semi)`,

        /* ── Net Pay ── */
        FORMAT(pc.net_pay_semi, 2)              AS `NET PAY (Semi-Monthly)`,

        /* ── Monthly Equivalents for reference ── */
        FORMAT(pc.sss_monthly, 2)               AS `SSS (Monthly Reference)`,
        FORMAT(pc.philhealth_monthly_ee, 2)     AS `PhilHealth EE Share (Monthly)`,
        FORMAT(pc.pagibig_monthly, 2)           AS `Pag-IBIG (Monthly Reference)`,
        FORMAT(pc.tax_monthly, 2)               AS `Withholding Tax (Monthly Reference)`,
        FORMAT(pc.taxable_monthly, 2)           AS `Taxable Income (Monthly)`,

        /* ── Hourly Rate ── */
        FORMAT(pc.hourly_rate, 2)               AS `Hourly Rate`

    FROM vw_payslip_calculation pc
    WHERE pc.employee_id = p_employee_id;
END$$

DELIMITER ;


/* ─────────────────────────────────────────────────────────────────
   6.3  Quick-reference: full payroll run for ALL active employees
        SELECT * FROM vw_payslip_calculation ORDER BY employee_id;
   
   Single employee payslip:
        SELECT * FROM vw_payslip_calculation WHERE employee_id = 10001;
   
   Or use the stored procedure:
        CALL sp_generate_payslip(10001, 1);   -- Period 1: June 1–15 2024
        CALL sp_generate_payslip(10005, 2);   -- Period 2: June 16–30 2024
   ───────────────────────────────────────────────────────────────── */

/* ─────────────────────────────────────────────────────────────────
   6.4  Attendance-aware payslip query
        Calculates actual hours worked in a pay period and adjusts
        pay for late arrivals and absences.
        Standard shift = 8 hours/day.  Late/undertime = deducted at
        hourly rate. Expected working days auto-counted from
        attendance records.
   ───────────────────────────────────────────────────────────────── */
CREATE OR REPLACE VIEW vw_attendance_payslip AS
SELECT
    a.employee_id,
    pp.pay_period_id,
    pp.start_date                                     AS period_start,
    pp.end_date                                       AS period_end,
    COUNT(a.attendance_id)                            AS days_present,
    ROUND(
        SUM(
            LEAST(
                TIME_TO_SEC(TIMEDIFF(a.time_out, a.time_in)) / 3600,
                8                                    -- cap at 8 regular hours/day
            )
        ), 2
    )                                                 AS regular_hours_worked,
    ROUND(
        SUM(
            GREATEST(
                8 - LEAST(
                    TIME_TO_SEC(TIMEDIFF(a.time_out, a.time_in)) / 3600,
                    8
                ), 0
            )
        ), 2
    )                                                 AS undertime_hours,
    ROUND(
        SUM(
            GREATEST(
                TIME_TO_SEC(TIMEDIFF(a.time_in, '08:10:00')) / 3600,
                0
            )
        ), 2
    )                                                 AS late_hours,
    /* Hourly-based deductions */
    ROUND(
        sd.hourly_rate *
        SUM(
            GREATEST(
                8 - LEAST(
                    TIME_TO_SEC(TIMEDIFF(a.time_out, a.time_in)) / 3600,
                    8
                ), 0
            )
        ), 2
    )                                                 AS undertime_deduction,
    ROUND(
        sd.hourly_rate *
        SUM(
            GREATEST(
                TIME_TO_SEC(TIMEDIFF(a.time_in, '08:10:00')) / 3600,
                0
            )
        ), 2
    )                                                 AS late_deduction
FROM attendance a
JOIN pay_period pp
     ON a.date BETWEEN pp.start_date AND pp.end_date
JOIN salary_details sd
     ON sd.employee_id = a.employee_id
     AND sd.end_date IS NULL
GROUP BY a.employee_id, pp.pay_period_id, pp.start_date, pp.end_date, sd.hourly_rate;


/* ─────────────────────────────────────────────────────────────────
   6.5  Combined payslip: base pay + attendance adjustments
        Usage: SELECT * FROM vw_full_payslip WHERE employee_id = 10001 AND pay_period_id = 1;
   ───────────────────────────────────────────────────────────────── */
CREATE OR REPLACE VIEW vw_full_payslip AS
SELECT
    pc.employee_id,
    pc.employee_name,
    pc.position,
    pc.department,
    pc.employment_status,
    pc.supervisor_name,
    ap.pay_period_id,
    ap.period_start,
    ap.period_end,

    /* ── Earnings ── */
    pc.monthly_basic,
    pc.semi_monthly_basic,
    pc.rice_subsidy_semi,
    pc.phone_allowance_semi,
    pc.clothing_allowance_semi,
    pc.total_allowance_semi,
    pc.gross_semi_monthly,

    /* ── Attendance ── */
    ap.days_present,
    ap.regular_hours_worked,
    ap.late_hours,
    ap.undertime_hours,
    ap.late_deduction,
    ap.undertime_deduction,

    /* ── Mandatory Deductions (semi-monthly) ── */
    pc.sss_semi,
    pc.philhealth_semi,
    pc.pagibig_semi,
    pc.tax_semi,

    /* ── Total Deductions ── */
    ROUND(
        pc.sss_semi
      + pc.philhealth_semi
      + pc.pagibig_semi
      + pc.tax_semi
      + ap.late_deduction
      + ap.undertime_deduction,
        2
    )                                                 AS total_deductions,

    /* ── Net Pay ── */
    ROUND(
        pc.gross_semi_monthly
      - pc.sss_semi
      - pc.philhealth_semi
      - pc.pagibig_semi
      - pc.tax_semi
      - ap.late_deduction
      - ap.undertime_deduction,
        2
    )                                                 AS net_pay,

    pc.hourly_rate
FROM vw_payslip_calculation pc
JOIN vw_attendance_payslip  ap ON ap.employee_id = pc.employee_id;



/*=====================================================================================
QUICK REFERENCE — SAMPLE QUERIES TO TEST CRUD FUNCTION, DATA VALIDATION, AND DATA INTEGRITY
=====================================================================================
───────────────────────────────────────────
1. UPDATE: FIELDS WITH ENUM VALUES (QUERY)
───────────────────────────────────────────
1.1: Check the current data in the table
SELECT * FROM department;

1.2: Since "name" field is defined as an ENUM, run the query below to add a new ENUM value/options to the department table, 
which in this case is the (Test Data Department)
ALTER TABLE department
MODIFY name 
ENUM (
    'Executive',
    'IT',
    'HR',
    'Finance',
    'Sales & Marketing',
    'Operations/Logistics',
    'Customer Relations',
    'Test Data Department');
    
1.3: Insert the data you want add in the list
INSERT INTO department (name, description)
VALUES(
	'Test Data Department', 'This is for test data only');
    
1.4: Retrieved department data to check table was successfully updated
SELECT * FROM department;

────────────────────────────────────────────
2. UPDATE: CHANGE VALUE IN A ROW (QUERY)
────────────────────────────────────────────

2.1: Check the current data in the table. Ensure the ALTER/ENUM update query above has been executed 
so that the 'department' test data is available for this test case. 
SELECT * FROM department;


2.2: Perform an update on the table: (1) Use SET to specify the new values for the target field(s); 
(2) Use WHERE with department_id to restrict the update to a specific field 
UPDATE department
SET description = 'This is the updated data description'
WHERE department_id = 8;

2.3: Retrieved department data to check table was successfully updated
SELECT * FROM department;

───────────────────────────────────────────
3. DELETE: FK RESTRICTION TEST (QUERY)
───────────────────────────────────────────
3.1: In this test case, check all tables with foreign keys.
Run the query below to verify that the data exists.
SELECT * FROM department 
WHERE department_id = 1;

3.2: Attempt to delete the record 
DELETE FROM department
WHERE department_id = 1;

3.3: Verify whether the data still exists.
In this test case, the data must still be available after the deletion attempt. 
SELECT * FROM department WHERE department_id = 1; 

───────────────────────────────────────────
4. DELETE: SAFE TEST ENVIRONMENT (QUERY)
───────────────────────────────────────────
4.1: Run the query below to verify that the data exists.
SELECT * FROM leave_request
WHERE leave_request_id = 6;

4.2: Attempt to delete the record 
DELETE FROM leave_request
WHERE leave_request_id = 6;

4.3: Verify whether the data still exists.
In this test case, the data must be successfully deleted.
SELECT * FROM leave_request; 

───────────────────────────────────────────
5. INSERT: UNIQUE CONSTRAINT (QUERY)
───────────────────────────────────────────

INSERT INTO government_ids (sss_no, philhealth_no, pagibig_no, tin_no, employee_id)
VALUES
	('44-4506057-3', '820126853951', '691295330870', '442-605-657-000', 10001);

───────────────────────────────────────────
6. INSERT: NOT NULL CONSTRAINT -> (QUERY)
───────────────────────────────────────────

INSERT INTO employee_profile (last_name, first_name, birthday, phone_number, hire_date, email, supervisor_name, department_id, position_id, status_id, is_active)
VALUES
	(NULL,'Manuel III','1983-10-11','0966860270','2020-01-15','mgarcia@motorph.com','N/A',1,1,1,TRUE);
    
───────────────────────────────────────────
7. INSERT: DUPLICATE CONSTRAINT -> PRIMARY KEY VIOLATION (QUERY)
───────────────────────────────────────────

INSERT INTO employee_profile (employee_id, last_name, first_name, birthday, phone_number, hire_date, email, supervisor_name, department_id, position_id, status_id, is_active)
VALUES
	(10035, 'Garcia','Manuel III','1983-10-11','0966860270','2020-01-15','mgarcia@motorph.com','N/A',1,1,1,TRUE);
	
===================================================================================== */


/* ====================================================================================
   QUICK REFERENCE — SAMPLE QUERIES TO TEST IF THE REPORTS ARE SHOWING
  =====================================================================================

   1. Full payslip computation for ALL employees (no attendance adjustment):
      SELECT * FROM vw_payslip_calculation ORDER BY employee_id;

   2. Single-employee payslip (no attendance adjustment):
      SELECT * FROM vw_payslip_calculation WHERE employee_id = 10001;

   3. Payslip via stored procedure (with pay period dates in header):
      CALL sp_generate_payslip(10001, 1);

   4. Attendance-adjusted payslip for a specific employee and period:
      SELECT * FROM vw_full_payslip
       WHERE employee_id = 10001 AND pay_period_id = 1;

   5. Payroll run for ALL employees in pay period 1 with attendance:
      SELECT * FROM vw_full_payslip WHERE pay_period_id = 1 ORDER BY employee_id;

   6. Department-level payroll summary:
      SELECT department, COUNT(*) AS headcount,
             FORMAT(SUM(gross_semi_monthly),2) AS total_gross,
             FORMAT(SUM(total_deductions_semi),2) AS total_deductions,
             FORMAT(SUM(net_pay_semi),2) AS total_net_pay
        FROM vw_payslip_calculation
       GROUP BY department;
===================================================================================== */

   
