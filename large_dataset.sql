-- ==========================================================
-- HANDLING LARGE DATASETS WITH MINIMAL SCANS IN DUCKDB
-- Demonstrates Column Pruning (Avoiding Unnecessary Scans)
-- ==========================================================

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
    DATE '2024-01-01' + (i % 365) AS joining_date,
    'Address_' || i AS address,
    'City_' || (i % 100) AS city,
    'Country_' || (i % 10) AS country
FROM range(1000000) t(i);

-- Export to Parquet (Columnar Storage)
COPY employee_data
TO 'employee_data.parquet'
(FORMAT PARQUET);

-- Enable profiling so execution details are displayed
PRAGMA enable_profiling;

-- ==========================================================
-- Query 1 : Inefficient
-- Reads ALL columns from the Parquet file
-- ==========================================================

SELECT *
FROM read_parquet('employee_data.parquet')
WHERE department = 'IT';

-- ==========================================================
-- Query 2 : Optimized
-- Reads only required columns
-- DuckDB scans:
-- department (for filtering)
-- employee_id
-- salary
-- ==========================================================

SELECT
    employee_id,
    salary
FROM read_parquet('employee_data.parquet')
WHERE department = 'IT';

-- ==========================================================
-- Compare the profiling output of both queries.
--
-- Query 1 scans:
-- employee_id
-- employee_name
-- department
-- salary
-- joining_date
-- address
-- city
-- country
--
-- Query 2 scans:
-- employee_id
-- salary
-- department
--
-- Result:
-- Less data scanned
-- Less memory used
-- Faster execution
-- ==========================================================
