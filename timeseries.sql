--==========================================================
-- DUCKDB STRING, DATE & TIME FUNCTIONS
--==========================================================

DROP TABLE IF EXISTS employee_sales;

CREATE TABLE employee_sales
(
    emp_id INTEGER,
    emp_name VARCHAR,
    department VARCHAR,
    city VARCHAR,
    email VARCHAR,
    salary DECIMAL(10,2),
    joining_date DATE,
    login_time TIME,
    last_login TIMESTAMP
);

INSERT INTO employee_sales VALUES
(101,'John Smith','IT','Delhi','john@gmail.com',65000,'2023-01-15','09:15:20','2025-06-01 09:15:20'),
(102,'Mary Jones','HR','Mumbai','mary@gmail.com',55000,'2022-07-20','09:30:10','2025-06-02 09:30:10'),
(103,'David Miller','Finance','Bengaluru','david@gmail.com',72000,'2021-05-12','08:55:30','2025-06-03 08:55:30'),
(104,'Sarah Wilson','Sales','Pune','sarah@gmail.com',50000,'2020-09-01','10:05:15','2025-06-04 10:05:15'),
(105,'Michael Brown','IT','Chennai','michael@gmail.com',85000,'2019-12-18','08:45:00','2025-06-05 08:45:00');

------------------------------------------------------------
-- View Data
------------------------------------------------------------

SELECT * FROM employee_sales;

------------------------------------------------------------
-- STRING FUNCTIONS
------------------------------------------------------------

-- Convert to Uppercase
SELECT emp_name, UPPER(emp_name) AS upper_name
FROM employee_sales;

-- Convert to Lowercase
SELECT emp_name, LOWER(emp_name) AS lower_name
FROM employee_sales;

-- Length of String
SELECT emp_name, LENGTH(emp_name) AS name_length
FROM employee_sales;

-- First 4 Characters
SELECT emp_name, SUBSTRING(emp_name,1,4) AS short_name
FROM employee_sales;

-- Replace Text
SELECT email,
REPLACE(email,'gmail.com','company.com') AS company_email
FROM employee_sales;

-- Concatenate
SELECT
CONCAT(emp_name,' works in ',department) AS employee_info
FROM employee_sales;

-- Left Characters
SELECT emp_name,
LEFT(emp_name,5) AS left_part
FROM employee_sales;

-- Right Characters
SELECT emp_name,
RIGHT(emp_name,5) AS right_part
FROM employee_sales;

-- Trim Spaces
SELECT TRIM('     DuckDB Training     ') AS trimmed_text;

------------------------------------------------------------
-- DATE FUNCTIONS
------------------------------------------------------------

-- Current Date
SELECT CURRENT_DATE;

-- Current Timestamp
SELECT CURRENT_TIMESTAMP;

-- Year
SELECT emp_name,
YEAR(joining_date) AS joining_year
FROM employee_sales;

-- Month
SELECT emp_name,
MONTH(joining_date) AS joining_month
FROM employee_sales;

-- Day
SELECT emp_name,
DAY(joining_date) AS joining_day
FROM employee_sales;

-- Quarter
SELECT emp_name,
QUARTER(joining_date) AS joining_quarter
FROM employee_sales;

-- Day Name
SELECT emp_name,
DAYNAME(joining_date) AS day_name
FROM employee_sales;

-- Month Name
SELECT emp_name,
MONTHNAME(joining_date) AS month_name
FROM employee_sales;

------------------------------------------------------------
-- DATE DIFFERENCE
------------------------------------------------------------

SELECT
emp_name,
DATE_DIFF('day', joining_date, CURRENT_DATE) AS days_worked
FROM employee_sales;

------------------------------------------------------------
-- ADD DAYS
------------------------------------------------------------

SELECT
emp_name,
joining_date,
joining_date + INTERVAL 30 DAY AS after_30_days
FROM employee_sales;

------------------------------------------------------------
-- SUBTRACT DAYS
------------------------------------------------------------

SELECT
emp_name,
joining_date,
joining_date - INTERVAL 15 DAY AS before_15_days
FROM employee_sales;

------------------------------------------------------------
-- EXTRACT FUNCTION
------------------------------------------------------------

SELECT
emp_name,
EXTRACT(YEAR FROM joining_date) AS year,
EXTRACT(MONTH FROM joining_date) AS month,
EXTRACT(DAY FROM joining_date) AS day
FROM employee_sales;

------------------------------------------------------------
-- DATE_TRUNC
------------------------------------------------------------

SELECT
joining_date,
DATE_TRUNC('month',joining_date) AS month_start
FROM employee_sales;

------------------------------------------------------------
-- TIME FUNCTIONS
------------------------------------------------------------

SELECT
emp_name,
login_time,
EXTRACT(HOUR FROM login_time) AS hour,
EXTRACT(MINUTE FROM login_time) AS minute,
EXTRACT(SECOND FROM login_time) AS second
FROM employee_sales;

------------------------------------------------------------
-- TIMESTAMP FUNCTIONS
------------------------------------------------------------

SELECT
emp_name,
last_login,
DATE_TRUNC('day',last_login) AS login_day
FROM employee_sales;

------------------------------------------------------------
-- AGGREGATE FUNCTIONS
------------------------------------------------------------

SELECT
department,
COUNT(*) AS employees,
SUM(salary) AS total_salary,
AVG(salary) AS average_salary,
MIN(salary) AS minimum_salary,
MAX(salary) AS maximum_salary
FROM employee_sales
GROUP BY department;

------------------------------------------------------------
-- WINDOW FUNCTION
------------------------------------------------------------

SELECT
emp_name,
department,
salary,
RANK() OVER
(
PARTITION BY department
ORDER BY salary DESC
) AS salary_rank
FROM employee_sales;

------------------------------------------------------------
-- ORDER BY DATE
------------------------------------------------------------

SELECT *
FROM employee_sales
ORDER BY joining_date;

------------------------------------------------------------
-- EMPLOYEES JOINED AFTER 2022
------------------------------------------------------------

SELECT *
FROM employee_sales
WHERE joining_date > '2022-01-01';

------------------------------------------------------------
-- EMPLOYEES LOGGED IN AFTER 9 AM
------------------------------------------------------------

SELECT *
FROM employee_sales
WHERE login_time > '09:00:00';

------------------------------------------------------------
-- EMPLOYEES WHOSE NAME STARTS WITH 'M'
------------------------------------------------------------

SELECT *
FROM employee_sales
WHERE emp_name LIKE 'M%';

------------------------------------------------------------
-- EMPLOYEES FROM IT DEPARTMENT
------------------------------------------------------------

SELECT *
FROM employee_sales
WHERE department='IT';
