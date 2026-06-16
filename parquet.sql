Sure. Here's a complete **DuckDB SQL script** that:

1. Creates a table
2. Inserts sample data
3. Writes the table data to a Parquet file at a specific location
4. Reads the Parquet file back
5. Verifies the data

```sql
-- ==========================================
-- Step 1: Create a table
-- ==========================================

CREATE TABLE employees (
    emp_id INTEGER,
    emp_name VARCHAR,
    department VARCHAR,
    salary DECIMAL(10,2)
);

-- ==========================================
-- Step 2: Insert sample data
-- ==========================================

INSERT INTO employees VALUES
(101, 'John', 'IT', 75000),
(102, 'Alice', 'HR', 65000),
(103, 'Bob', 'Finance', 80000),
(104, 'Emma', 'IT', 90000);

-- ==========================================
-- Step 3: Verify inserted data
-- ==========================================

SELECT * FROM employees;

-- ==========================================
-- Step 4: Export table to Parquet
-- Change the path as needed
-- ==========================================

COPY employees
TO '/tmp/employees.parquet'
(FORMAT PARQUET);

-- Windows Example:
-- COPY employees
-- TO 'C:/duckdb/data/employees.parquet'
-- (FORMAT PARQUET);

-- ==========================================
-- Step 5: Read data directly from Parquet
-- ==========================================

SELECT *
FROM read_parquet('/tmp/employees.parquet');

-- ==========================================
-- Step 6: Create a new table from Parquet
-- ==========================================

CREATE TABLE employees_from_parquet AS
SELECT *
FROM read_parquet('/tmp/employees.parquet');

-- ==========================================
-- Step 7: Verify data loaded from Parquet
-- ==========================================

SELECT *
FROM employees_from_parquet;
```

### Running from DuckDB CLI

Save as:

```text
employee_parquet_demo.sql
```

Execute:

```bash
duckdb mydb.duckdb < employee_parquet_demo.sql
```

---

### Python Example (Single Script)

```python
import duckdb

con = duckdb.connect("mydb.duckdb")

# Create table
con.execute("""
CREATE OR REPLACE TABLE employees (
    emp_id INTEGER,
    emp_name VARCHAR,
    department VARCHAR,
    salary DECIMAL(10,2)
)
""")

# Insert data
con.execute("""
INSERT INTO employees VALUES
(101, 'John', 'IT', 75000),
(102, 'Alice', 'HR', 65000),
(103, 'Bob', 'Finance', 80000),
(104, 'Emma', 'IT', 90000)
""")

# Write to parquet
parquet_file = "/tmp/employees.parquet"

con.execute(f"""
COPY employees
TO '{parquet_file}'
(FORMAT PARQUET)
""")

print("Parquet file written:", parquet_file)

# Read parquet
result = con.execute(f"""
SELECT *
FROM read_parquet('{parquet_file}')
""").fetchdf()

print(result)
```

Output:

```text
   emp_id emp_name department   salary
0     101     John         IT  75000.0
1     102    Alice         HR  65000.0
2     103      Bob    Finance  80000.0
3     104     Emma         IT  90000.0
```

This demonstrates the complete lifecycle: **Table → Insert → Parquet File → Read Parquet → Query Results**.
