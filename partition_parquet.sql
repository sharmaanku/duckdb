--=========================================================
-- PARQUET PARTITIONING BY DEPARTMENT
--=========================================================

DROP TABLE IF EXISTS employees;

CREATE TABLE employees
(
    emp_id INTEGER,
    emp_name VARCHAR,
    department VARCHAR,
    salary INTEGER,
    city VARCHAR
);

INSERT INTO employees VALUES
(101,'John','IT',50000,'Delhi'),
(102,'Mary','HR',60000,'Mumbai'),
(103,'David','Finance',75000,'Bengaluru'),
(104,'Sarah','Sales',55000,'Pune'),
(105,'Michael','IT',80000,'Chennai'),
(106,'Emma','HR',62000,'Hyderabad'),
(107,'James','Finance',72000,'Kolkata'),
(108,'Sophia','Marketing',58000,'Ahmedabad'),
(109,'Daniel','Sales',53000,'Noida'),
(110,'Olivia','IT',90000,'Gurugram'),
(111,'Chris','Marketing',61000,'Delhi'),
(112,'Robert','Finance',95000,'Mumbai');

-- Verify Data
SELECT *
FROM employees;

----------------------------------------------------------
-- Export Partitioned by Department
----------------------------------------------------------

COPY employees
TO 'C:/DuckDB/Data/employees_partitioned'
(
    FORMAT PARQUET,
    PARTITION_BY (department)
);

----------------------------------------------------------
-- Read Entire Partitioned Folder
----------------------------------------------------------

SELECT *
FROM read_parquet('C:/DuckDB/Data/employees_partitioned/**/*.parquet');

----------------------------------------------------------
-- Read Only IT Department Partition
----------------------------------------------------------

SELECT *
FROM read_parquet('C:/DuckDB/Data/employees_partitioned/department=IT/*.parquet');

----------------------------------------------------------
-- Read Only Finance Department
----------------------------------------------------------

SELECT *
FROM read_parquet('C:/DuckDB/Data/employees_partitioned/department=Finance/*.parquet');
