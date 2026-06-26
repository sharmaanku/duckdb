#=========================================================
# DuckDB + Parquet + Arrow + Pandas + Polars Demo
#=========================================================

# Install packages (Run once)
# pip install duckdb pandas pyarrow polars

import duckdb
import pandas as pd
import polars as pl
import pyarrow as pa

#---------------------------------------------------------
# Step 1 : Connect to DuckDB
#---------------------------------------------------------

con = duckdb.connect("company.duckdb")

print("Connected to DuckDB")

#---------------------------------------------------------
# Step 2 : Create Employee Table
#---------------------------------------------------------

con.execute("""

CREATE OR REPLACE TABLE employees
(
    emp_id INTEGER,
    emp_name VARCHAR,
    department VARCHAR,
    salary INTEGER,
    joining_date DATE
);

""")

#---------------------------------------------------------
# Step 3 : Insert Sample Data
#---------------------------------------------------------

con.execute("""

INSERT INTO employees VALUES
(101,'John','IT',70000,'2022-01-15'),
(102,'David','HR',55000,'2021-03-20'),
(103,'Sara','Finance',85000,'2020-07-10'),
(104,'Alice','IT',72000,'2023-02-05'),
(105,'Bob','Sales',65000,'2022-11-01');

""")

print("Employee data inserted")

#---------------------------------------------------------
# Step 4 : View Employee Table
#---------------------------------------------------------

print("\nEmployee Table")

print(
    con.execute("""
    SELECT *
    FROM employees
    """).fetchdf()
)

#=========================================================
# PARQUET
#=========================================================

#---------------------------------------------------------
# Step 5 : Save Table as Parquet
#---------------------------------------------------------

con.execute("""

COPY employees
TO 'employees.parquet'
(FORMAT PARQUET);

""")

print("\nParquet file created")

#---------------------------------------------------------
# Step 6 : Read Parquet File
#---------------------------------------------------------

print("\nReading Parquet")

print(
    con.execute("""
    SELECT *
    FROM read_parquet('employees.parquet')
    """).fetchdf()
)

#=========================================================
# PANDAS
#=========================================================

#---------------------------------------------------------
# Step 7 : Convert DuckDB Table to Pandas
#---------------------------------------------------------

pandas_df = con.execute("""

SELECT *
FROM employees

""").fetchdf()

print("\nPandas DataFrame")

print(pandas_df)

#---------------------------------------------------------
# Step 8 : Query Pandas DataFrame using DuckDB
#---------------------------------------------------------

print("\nQuerying Pandas DataFrame")

print(

con.execute("""

SELECT
department,
AVG(salary) AS avg_salary

FROM pandas_df

GROUP BY department

""").fetchdf()

)

#---------------------------------------------------------
# Step 9 : Save Pandas DataFrame to Parquet
#---------------------------------------------------------

pandas_df.to_parquet(
    "pandas_employee.parquet",
    index=False
)

print("\nPandas exported to Parquet")

#=========================================================
# POLARS
#=========================================================

#---------------------------------------------------------
# Step 10 : Convert DuckDB Table to Polars
#---------------------------------------------------------

polars_df = con.execute("""

SELECT *
FROM employees

""").pl()

print("\nPolars DataFrame")

print(polars_df)

#---------------------------------------------------------
# Step 11 : Query Polars DataFrame from DuckDB
#---------------------------------------------------------

print("\nQuerying Polars DataFrame")

print(

con.execute("""

SELECT
department,
MAX(salary) AS highest_salary

FROM polars_df

GROUP BY department

""").fetchdf()

)

#---------------------------------------------------------
# Step 12 : Save Polars DataFrame to Parquet
#---------------------------------------------------------

polars_df.write_parquet(
    "polars_employee.parquet"
)

print("\nPolars exported to Parquet")

#=========================================================
# APACHE ARROW
#=========================================================

#---------------------------------------------------------
# Step 13 : Convert DuckDB Result to Arrow Table
#---------------------------------------------------------

arrow_table = con.execute("""

SELECT *
FROM employees

""").arrow()

print("\nArrow Table")

print(arrow_table)

#---------------------------------------------------------
# Step 14 : Query Arrow Table using DuckDB
#---------------------------------------------------------

print("\nQuery Arrow Table")

print(

con.execute("""

SELECT
department,
COUNT(*) AS total_employees,
SUM(salary) AS total_salary

FROM arrow_table

GROUP BY department

""").fetchdf()

)

#=========================================================
# Read Saved Parquet using Pandas
#=========================================================

print("\nRead Parquet with Pandas")

pd_parquet = pd.read_parquet("employees.parquet")

print(pd_parquet)

#=========================================================
# Read Saved Parquet using Polars
#=========================================================

print("\nRead Parquet with Polars")

pl_parquet = pl.read_parquet("employees.parquet")

print(pl_parquet)

#=========================================================
# Read Saved Parquet using Arrow
#=========================================================

import pyarrow.parquet as pq

arrow_parquet = pq.read_table("employees.parquet")

print("\nRead Parquet with Arrow")

print(arrow_parquet)

#=========================================================
# Create DuckDB View from Parquet
#=========================================================

con.execute("""

CREATE OR REPLACE VIEW employee_view AS

SELECT *
FROM read_parquet('employees.parquet');

""")

print("\nEmployee View")

print(

con.execute("""

SELECT
department,
AVG(salary) AS average_salary

FROM employee_view

GROUP BY department

""").fetchdf()

)

#=========================================================
# Close Connection
#=========================================================

con.close()

print("\nDuckDB connection closed")
