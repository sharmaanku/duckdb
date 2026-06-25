----------------------------------------------------------------------
-- STEP 1 : Create Sample Employee Table
----------------------------------------------------------------------

DROP TABLE IF EXISTS employee;

CREATE TABLE employee
(
    emp_id INTEGER,
    emp_name VARCHAR,
    department VARCHAR,
    salary INTEGER,
    age INTEGER,
    city VARCHAR
);

----------------------------------------------------------------------
-- STEP 2 : Insert Sample Data
----------------------------------------------------------------------

INSERT INTO employee VALUES
(101,'John','IT',50000,28,'Delhi'),
(102,'Mary','HR',60000,32,'Mumbai'),
(103,'David','Finance',70000,35,'Bangalore'),
(104,'Lisa','IT',55000,30,'Chennai'),
(105,'Tom','HR',65000,31,'Pune');

----------------------------------------------------------------------
-- STEP 3 : Display Table
----------------------------------------------------------------------

SELECT * FROM employee;

----------------------------------------------------------------------
-- STEP 4 : Export Table to JSON File
----------------------------------------------------------------------

COPY employee
TO 'employees.json'
(FORMAT JSON);

----------------------------------------------------------------------
-- STEP 5 : Read Complete JSON File
----------------------------------------------------------------------

SELECT *
FROM read_json('employees.json');

----------------------------------------------------------------------
-- STEP 6 : Automatically Detect Schema
----------------------------------------------------------------------

SELECT *
FROM read_json_auto('employees.json');

----------------------------------------------------------------------
-- STEP 7 : Display Schema
----------------------------------------------------------------------

DESCRIBE
SELECT *
FROM read_json('employees.json');

----------------------------------------------------------------------
-- STEP 8 : Read Specific Columns
----------------------------------------------------------------------

SELECT
    emp_id,
    emp_name,
    salary
FROM read_json('employees.json');

----------------------------------------------------------------------
-- STEP 9 : Rename Columns
----------------------------------------------------------------------

SELECT
    emp_id AS Employee_ID,
    emp_name AS Employee_Name,
    salary AS Employee_Salary
FROM read_json('employees.json');

----------------------------------------------------------------------
-- STEP 10 : Filter Records
----------------------------------------------------------------------

SELECT *
FROM read_json('employees.json')
WHERE salary > 55000;

----------------------------------------------------------------------
-- STEP 11 : Multiple Conditions
----------------------------------------------------------------------

SELECT *
FROM read_json('employees.json')
WHERE department='IT'
AND salary>=50000;

----------------------------------------------------------------------
-- STEP 12 : Sorting
----------------------------------------------------------------------

SELECT *
FROM read_json('employees.json')
ORDER BY salary DESC;

----------------------------------------------------------------------
-- STEP 13 : Sort on Multiple Columns
----------------------------------------------------------------------

SELECT *
FROM read_json('employees.json')
ORDER BY department,salary DESC;

----------------------------------------------------------------------
-- STEP 14 : Count Records
----------------------------------------------------------------------

SELECT
COUNT(*) AS Total_Employees
FROM read_json('employees.json');

----------------------------------------------------------------------
-- STEP 15 : Distinct Values
----------------------------------------------------------------------

SELECT DISTINCT department
FROM read_json('employees.json');

----------------------------------------------------------------------
-- STEP 16 : Aggregate Functions
----------------------------------------------------------------------

SELECT
    COUNT(*) AS Employee_Count,
    SUM(salary) AS Total_Salary,
    AVG(salary) AS Average_Salary,
    MIN(salary) AS Minimum_Salary,
    MAX(salary) AS Maximum_Salary
FROM read_json('employees.json');

----------------------------------------------------------------------
-- STEP 17 : Group By
----------------------------------------------------------------------

SELECT
    department,
    COUNT(*) AS Employee_Count,
    AVG(salary) AS Average_Salary
FROM read_json('employees.json')
GROUP BY department;

----------------------------------------------------------------------
-- STEP 18 : LIMIT
----------------------------------------------------------------------

SELECT *
FROM read_json('employees.json')
LIMIT 3;

----------------------------------------------------------------------
-- STEP 19 : OFFSET
----------------------------------------------------------------------

SELECT *
FROM read_json('employees.json')
LIMIT 2 OFFSET 2;

----------------------------------------------------------------------
-- STEP 20 : LIKE
----------------------------------------------------------------------

SELECT *
FROM read_json('employees.json')
WHERE emp_name LIKE 'J%';

----------------------------------------------------------------------
-- STEP 21 : BETWEEN
----------------------------------------------------------------------

SELECT *
FROM read_json('employees.json')
WHERE salary BETWEEN 50000 AND 65000;

----------------------------------------------------------------------
-- STEP 22 : IN
----------------------------------------------------------------------

SELECT *
FROM read_json('employees.json')
WHERE department IN ('IT','HR');

----------------------------------------------------------------------
-- STEP 23 : Calculated Column
----------------------------------------------------------------------

SELECT
    emp_name,
    salary,
    salary*12 AS Annual_Salary
FROM read_json('employees.json');

----------------------------------------------------------------------
-- STEP 24 : NULL Handling
----------------------------------------------------------------------

SELECT
    emp_name,
    COALESCE(city,'Unknown') AS City
FROM read_json('employees.json');

----------------------------------------------------------------------
-- STEP 25 : Explicit Schema
----------------------------------------------------------------------

SELECT *
FROM read_json(
    'employees.json',
    columns = {
        emp_id:'INTEGER',
        emp_name:'VARCHAR',
        department:'VARCHAR',
        salary:'INTEGER',
        age:'INTEGER',
        city:'VARCHAR'
    }
);

----------------------------------------------------------------------
-- STEP 26 : Create Temporary Table
----------------------------------------------------------------------

CREATE OR REPLACE TEMP TABLE employee_temp AS
SELECT *
FROM read_json('employees.json');

SELECT *
FROM employee_temp;

----------------------------------------------------------------------
-- STEP 27 : Create View
----------------------------------------------------------------------

CREATE OR REPLACE VIEW employee_view AS
SELECT *
FROM read_json('employees.json');

SELECT *
FROM employee_view;

----------------------------------------------------------------------
-- STEP 28 : Window Functions
----------------------------------------------------------------------

SELECT
    emp_name,
    salary,
    ROW_NUMBER() OVER(ORDER BY salary DESC) AS Row_Number,
    RANK() OVER(ORDER BY salary DESC) AS Rank_Number,
    DENSE_RANK() OVER(ORDER BY salary DESC) AS Dense_Rank
FROM read_json('employees.json');

----------------------------------------------------------------------
-- STEP 29 : Running Total
----------------------------------------------------------------------

SELECT
    emp_name,
    salary,
    SUM(salary)
    OVER(ORDER BY emp_id) AS Running_Total
FROM read_json('employees.json');

----------------------------------------------------------------------
-- STEP 30 : LAG
----------------------------------------------------------------------

SELECT
    emp_name,
    salary,
    LAG(salary)
    OVER(ORDER BY emp_id) AS Previous_Salary
FROM read_json('employees.json');

----------------------------------------------------------------------
-- STEP 31 : LEAD
----------------------------------------------------------------------

SELECT
    emp_name,
    salary,
    LEAD(salary)
    OVER(ORDER BY emp_id) AS Next_Salary
FROM read_json('employees.json');

----------------------------------------------------------------------
-- STEP 32 : Verify JSON Data
----------------------------------------------------------------------

SELECT *
FROM read_json('employees.json')
LIMIT 5;
