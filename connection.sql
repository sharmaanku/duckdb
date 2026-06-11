# ============================================================
# DuckDB + Parquet + Arrow + Pandas + Polars Demo
# ============================================================

# Install once if needed:
# pip install duckdb pandas pyarrow polars

import duckdb
import pandas as pd
import pyarrow as pa
import polars as pl

print("\n==============================")
print("1. CONNECT TO DUCKDB")
print("==============================")

con = duckdb.connect("demo.duckdb")

# ------------------------------------------------------------
# Create Sample Table
# ------------------------------------------------------------

print("\n==============================")
print("2. CREATE SAMPLE TABLE")
print("==============================")

con.execute("""
CREATE OR REPLACE TABLE sales AS
SELECT
    i AS sale_id,
    'Product_' || (i % 5) AS product_name,
    ROUND(random()*1000,2) AS amount
FROM range(1,10001) t(i);
""")

print("Table created successfully.")

# ------------------------------------------------------------
# Export Table to Parquet
# ------------------------------------------------------------

print("\n==============================")
print("3. EXPORT TO PARQUET")
print("==============================")

con.execute("""
COPY sales
TO 'sales.parquet'
(FORMAT PARQUET);
""")

print("Parquet file created: sales.parquet")

# ------------------------------------------------------------
# Read Parquet using DuckDB
# ------------------------------------------------------------

print("\n==============================")
print("4. READ PARQUET USING DUCKDB")
print("==============================")

result = con.execute("""
SELECT
    COUNT(*) AS total_rows,
    ROUND(SUM(amount),2) AS total_sales
FROM read_parquet('sales.parquet');
""").fetchdf()

print(result)

# ------------------------------------------------------------
# Convert DuckDB Result to Pandas
# ------------------------------------------------------------

print("\n==============================")
print("5. DUCKDB -> PANDAS")
print("==============================")

pandas_df = con.execute("""
SELECT *
FROM sales
LIMIT 5;
""").fetchdf()

print(type(pandas_df))
print(pandas_df)

# ------------------------------------------------------------
# Query Pandas DataFrame using DuckDB
# ------------------------------------------------------------

print("\n==============================")
print("6. QUERY PANDAS DATAFRAME")
print("==============================")

result = con.execute("""
SELECT
    product_name,
    COUNT(*) AS cnt,
    ROUND(AVG(amount),2) AS avg_sales
FROM pandas_df
GROUP BY product_name
ORDER BY cnt DESC;
""").fetchdf()

print(result)

# ------------------------------------------------------------
# Convert DuckDB Result to Arrow Table
# ------------------------------------------------------------

print("\n==============================")
print("7. DUCKDB -> ARROW")
print("==============================")

arrow_table = con.execute("""
SELECT *
FROM sales
LIMIT 5;
""").arrow()

print(type(arrow_table))
print(arrow_table)

# ------------------------------------------------------------
# Query Arrow Table using DuckDB
# ------------------------------------------------------------

print("\n==============================")
print("8. QUERY ARROW TABLE")
print("==============================")

result = con.execute("""
SELECT
    COUNT(*) AS total_rows
FROM arrow_table;
""").fetchdf()

print(result)

# ------------------------------------------------------------
# Create Polars DataFrame
# ------------------------------------------------------------

print("\n==============================")
print("9. DUCKDB -> POLARS")
print("==============================")

polars_df = con.execute("""
SELECT *
FROM sales
LIMIT 10;
""").pl()

print(type(polars_df))
print(polars_df)

# ------------------------------------------------------------
# Query Polars DataFrame using DuckDB
# ------------------------------------------------------------

print("\n==============================")
print("10. QUERY POLARS DATAFRAME")
print("==============================")

result = con.execute("""
SELECT
    product_name,
    MAX(amount) AS highest_sale
FROM polars_df
GROUP BY product_name
ORDER BY highest_sale DESC;
""").fetchdf()

print(result)

# ------------------------------------------------------------
# Read Parquet Directly Into Polars
# ------------------------------------------------------------

print("\n==============================")
print("11. PARQUET -> POLARS")
print("==============================")

pl_df = pl.read_parquet("sales.parquet")

print(pl_df.head())

# ------------------------------------------------------------
# Read Parquet Directly Into Pandas
# ------------------------------------------------------------

print("\n==============================")
print("12. PARQUET -> PANDAS")
print("==============================")

pd_df = pd.read_parquet("sales.parquet")

print(pd_df.head())

# ------------------------------------------------------------
# Summary Query Across Parquet
# ------------------------------------------------------------

print("\n==============================")
print("13. ANALYTICS ON PARQUET")
print("==============================")

result = con.execute("""
SELECT
    product_name,
    COUNT(*) AS total_orders,
    ROUND(SUM(amount),2) AS total_sales
FROM read_parquet('sales.parquet')
GROUP BY product_name
ORDER BY total_sales DESC;
""").fetchdf()

print(result)

# ------------------------------------------------------------
# Close Connection
# ------------------------------------------------------------

con.close()

print("\n==============================")
print("DEMO COMPLETED SUCCESSFULLY")
print("==============================")
