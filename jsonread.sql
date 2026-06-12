--------------------------------------------------------
-- JSON PROCESSING IN DUCKDB
--------------------------------------------------------

-- Create table with JSON data

CREATE TABLE employees_json (
    id INTEGER,
    employee JSON
);

INSERT INTO employees_json VALUES
(
1,
'{
    "name":"John",
    "department":"IT",
    "salary":70000,
    "skills":["Python","SQL","Spark"]
}'
),
(
2,
'{
    "name":"Mary",
    "department":"HR",
    "salary":60000,
    "skills":["Excel","Recruitment"]
}'
);

--------------------------------------------------------
-- View Raw JSON
--------------------------------------------------------

SELECT * FROM employees_json;

--------------------------------------------------------
-- Extract Name
--------------------------------------------------------

SELECT
    id,
    employee->>'name' AS employee_name
FROM employees_json;

--------------------------------------------------------
-- Extract Department
--------------------------------------------------------

SELECT
    id,
    employee->>'department' AS department
FROM employees_json;

--------------------------------------------------------
-- Extract Salary
--------------------------------------------------------

SELECT
    id,
    employee->>'salary' AS salary
FROM employees_json;

--------------------------------------------------------
-- Extract Complete Skills Array
--------------------------------------------------------

SELECT
    id,
    employee->'skills' AS skills
FROM employees_json;

--------------------------------------------------------
-- Filter JSON Data
--------------------------------------------------------

SELECT *
FROM employees_json
WHERE CAST(employee->>'salary' AS INTEGER) > 65000;

--------------------------------------------------------
-- Multiple JSON Fields
--------------------------------------------------------

SELECT
    employee->>'name' AS name,
    employee->>'department' AS department,
    employee->>'salary' AS salary
FROM employees_json;
