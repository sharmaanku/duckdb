--------------------------------------------------------
-- HANDLING LARGE DATASETS WITH MINIMAL SCANS IN DUCKDB
-- Demonstration: Column Pruning
--------------------------------------------------------

-- Create a large table

CREATE OR REPLACE TABLE employee_data AS
SELECT
    i AS employee_id,
    'Employee_' || i AS employee_name,
    CASE
        WHEN i % 3 = 0 THEN 'IT'
        WHEN i % 3 = 1 THEN 'HR'
        ELSE 'Finance'
    END AS department,
    30000 + (i % 50000) AS salary,
    'Address_' || i AS address,
    'City_' || (i % 100) AS city,
    'Country_' || (i % 10) AS country
FROM range(1000000) t(i);

--------------------------------------------------------
-- Store data in Parquet format
--------------------------------------------------------

COPY employee_data
TO 'employee_data.parquet'
(FORMAT PARQUET);

--------------------------------------------------------
-- Enable profiling
--------------------------------------------------------

PRAGMA enable_profiling;

--------------------------------------------------------
-- Query 1 : Reads ALL columns
-- Large Scan
--------------------------------------------------------

SELECT *
FROM read_parquet('employee_data.parquet')
WHERE department = 'IT';

--------------------------------------------------------
-- Query 2 : Reads only required columns
-- Minimal Scan
--------------------------------------------------------

SELECT
    employee_id,
    salary
FROM read_parquet('employee_data.parquet')
WHERE department = 'IT';

--------------------------------------------------------
-- Compare profiling output
--------------------------------------------------------
