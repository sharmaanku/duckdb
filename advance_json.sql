
> **Sample JSON file (`employees.json`)**

```json
[
    {
        "emp_id": 101,
        "emp_name": "John",
        "department": "IT",
        "salary": 50000,
        "age": 28,
        "city": "Delhi"
    },
    {
        "emp_id": 102,
        "emp_name": "Mary",
        "department": "HR",
        "salary": 60000,
        "age": 32,
        "city": "Mumbai"
    },
    {
        "emp_id": 103,
        "emp_name": "David",
        "department": "Finance",
        "salary": 70000,
        "age": 35,
        "city": "Bangalore"
    },
    {
        "emp_id": 104,
        "emp_name": "Lisa",
        "department": "IT",
        "salary": 55000,
        "age": 30,
        "city": "Chennai"
    }
]
```

---

# Consolidated DuckDB JSON Script

```sql
-----------------------------------------------------------------------
-- 1. Read the complete JSON file
-----------------------------------------------------------------------

SELECT *
FROM read_json('employees.json');



-----------------------------------------------------------------------
-- 2. Automatically infer schema
-----------------------------------------------------------------------

SELECT *
FROM read_json_auto('employees.json');



-----------------------------------------------------------------------
-- 3. Display the inferred schema
-----------------------------------------------------------------------

DESCRIBE
SELECT *
FROM read_json('employees.json');



-----------------------------------------------------------------------
-- 4. Read only specific columns
-----------------------------------------------------------------------

SELECT
    emp_id,
    emp_name,
    salary
FROM read_json('employees.json');



-----------------------------------------------------------------------
-- 5. Rename columns using aliases
-----------------------------------------------------------------------

SELECT
    emp_id AS Employee_ID,
    emp_name AS Employee_Name,
    salary AS Employee_Salary
FROM read_json('employees.json');



-----------------------------------------------------------------------
-- 6. Filter records
-----------------------------------------------------------------------

SELECT *
FROM read_json('employees.json')
WHERE salary > 55000;



-----------------------------------------------------------------------
-- 7. Multiple filter conditions
-----------------------------------------------------------------------

SELECT *
FROM read_json('employees.json')
WHERE department = 'IT'
AND salary >= 50000;



-----------------------------------------------------------------------
-- 8. Sort data
-----------------------------------------------------------------------

SELECT *
FROM read_json('employees.json')
ORDER BY salary DESC;



-----------------------------------------------------------------------
-- 9. Sort by multiple columns
-----------------------------------------------------------------------

SELECT *
FROM read_json('employees.json')
ORDER BY department, salary DESC;



-----------------------------------------------------------------------
-- 10. Count records
-----------------------------------------------------------------------

SELECT COUNT(*) AS Total_Employees
FROM read_json('employees.json');



-----------------------------------------------------------------------
-- 11. Distinct values
-----------------------------------------------------------------------

SELECT DISTINCT department
FROM read_json('employees.json');



-----------------------------------------------------------------------
-- 12. Aggregate Functions
-----------------------------------------------------------------------

SELECT
    COUNT(*) AS Employee_Count,
    SUM(salary) AS Total_Salary,
    AVG(salary) AS Average_Salary,
    MIN(salary) AS Minimum_Salary,
    MAX(salary) AS Maximum_Salary
FROM read_json('employees.json');



-----------------------------------------------------------------------
-- 13. Group By
-----------------------------------------------------------------------

SELECT
    department,
    COUNT(*) AS Employee_Count,
    AVG(salary) AS Average_Salary
FROM read_json('employees.json')
GROUP BY department;



-----------------------------------------------------------------------
-- 14. Limit rows
-----------------------------------------------------------------------

SELECT *
FROM read_json('employees.json')
LIMIT 2;



-----------------------------------------------------------------------
-- 15. Skip rows
-----------------------------------------------------------------------

SELECT *
FROM read_json('employees.json')
LIMIT 2 OFFSET 1;



-----------------------------------------------------------------------
-- 16. Search using LIKE
-----------------------------------------------------------------------

SELECT *
FROM read_json('employees.json')
WHERE emp_name LIKE 'J%';



-----------------------------------------------------------------------
-- 17. BETWEEN condition
-----------------------------------------------------------------------

SELECT *
FROM read_json('employees.json')
WHERE salary BETWEEN 50000 AND 65000;



-----------------------------------------------------------------------
-- 18. IN condition
-----------------------------------------------------------------------

SELECT *
FROM read_json('employees.json')
WHERE department IN ('IT','HR');



-----------------------------------------------------------------------
-- 19. Handle NULL values
-----------------------------------------------------------------------

SELECT
    emp_name,
    COALESCE(city,'Unknown') AS City
FROM read_json('employees.json');



-----------------------------------------------------------------------
-- 20. Calculated Columns
-----------------------------------------------------------------------

SELECT
    emp_name,
    salary,
    salary * 12 AS Annual_Salary
FROM read_json('employees.json');



-----------------------------------------------------------------------
-- 21. Read JSON with Explicit Column Types
-----------------------------------------------------------------------

SELECT *
FROM read_json(
    'employees.json',
    columns = {
        emp_id : 'INTEGER',
        emp_name : 'VARCHAR',
        department : 'VARCHAR',
        salary : 'INTEGER',
        age : 'INTEGER',
        city : 'VARCHAR'
    }
);



-----------------------------------------------------------------------
-- 22. Create a View from JSON
-----------------------------------------------------------------------

CREATE OR REPLACE VIEW employee_view AS
SELECT *
FROM read_json('employees.json');

SELECT *
FROM employee_view;



-----------------------------------------------------------------------
-- 23. Create a Temporary Table from JSON
-----------------------------------------------------------------------

CREATE OR REPLACE TEMP TABLE employee_temp AS
SELECT *
FROM read_json('employees.json');

SELECT *
FROM employee_temp;



-----------------------------------------------------------------------
-- 24. Read JSON using Absolute Path
-----------------------------------------------------------------------

SELECT *
FROM read_json('C:/Data/employees.json');



-----------------------------------------------------------------------
-- 25. Preview first few records
-----------------------------------------------------------------------

SELECT *
FROM read_json('employees.json')
LIMIT 5;
```
