-- =====================================================
-- PREDICATE PUSHDOWN DEMO IN DUCKDB
-- =====================================================

-- Cleanup
DROP TABLE IF EXISTS sales;

-- Create sample table
CREATE TABLE sales (
    order_id INTEGER,
    customer_id INTEGER,
    country VARCHAR,
    order_date DATE,
    amount DOUBLE
);

-- Generate large sample data
INSERT INTO sales
SELECT
    i AS order_id,
    1000 + (i % 10000) AS customer_id,
    CASE
        WHEN i % 5 = 0 THEN 'US'
        WHEN i % 5 = 1 THEN 'UK'
        WHEN i % 5 = 2 THEN 'IN'
        WHEN i % 5 = 3 THEN 'DE'
        ELSE 'CA'
    END AS country,
    DATE '2024-01-01' + (i % 1000) AS order_date,
    RANDOM() * 10000 AS amount
FROM range(1000000) t(i);

-- =====================================================
-- EXPORT TO PARQUET
-- =====================================================

COPY sales
TO 'sales.parquet'
(FORMAT PARQUET);

-- =====================================================
-- EXAMPLE 1 : PREDICATE PUSHDOWN
-- =====================================================

EXPLAIN ANALYZE
SELECT *
FROM read_parquet('sales.parquet')
WHERE country = 'US'
  AND order_date >= '2026-01-01'
  AND amount > 5000;

-- Expected:
-- Filters should appear inside PARQUET_SCAN
-- DuckDB will read only required row groups


-- =====================================================
-- EXAMPLE 2 : NO PREDICATE PUSHDOWN
-- =====================================================

EXPLAIN ANALYZE
SELECT *
FROM (
        SELECT *
        FROM read_parquet('sales.parquet')
     ) s
WHERE UPPER(country) = 'US'
  AND YEAR(order_date) >= 2026
  AND amount > 5000;

-- Expected:
-- DuckDB may not push all filters because
-- functions are applied on columns.
-- More data may be scanned before filtering.


-- =====================================================
-- EXAMPLE 3 : WORST CASE
-- =====================================================

EXPLAIN ANALYZE
SELECT *
FROM (
        SELECT *,
               UPPER(country) AS country_upper,
               YEAR(order_date) AS order_year
        FROM read_parquet('sales.parquet')
     ) s
WHERE country_upper = 'US'
  AND order_year >= 2026
  AND amount > 5000;

-- Expected:
-- Entire parquet file may be scanned.
-- Filtering happens after computed columns.


-- =====================================================
-- EXAMPLE 4 : OPTIMIZED REWRITE
-- =====================================================

EXPLAIN ANALYZE
SELECT *
FROM read_parquet('sales.parquet')
WHERE country = 'US'
  AND order_date >= DATE '2026-01-01'
  AND amount > 5000;

-- This is the preferred version.
-- Maximum predicate pushdown.


-- =====================================================
-- CHECK EXECUTION PLAN ONLY
-- =====================================================

EXPLAIN
SELECT *
FROM read_parquet('sales.parquet')
WHERE country = 'US'
  AND order_date >= DATE '2026-01-01';

-- Look for:
--
-- PARQUET_SCAN
-- Filters:
-- country='US'
-- order_date>='2026-01-01'
--
-- If filters appear under PARQUET_SCAN,
-- predicate pushdown is occurring.


-- =====================================================
-- COMPARISON SUMMARY
-- =====================================================

-- GOOD (Pushdown Possible)

SELECT *
FROM read_parquet('sales.parquet')
WHERE country = 'US'
  AND order_date >= DATE '2026-01-01';

-- BAD (Pushdown Reduced)

SELECT *
FROM read_parquet('sales.parquet')
WHERE UPPER(country) = 'US';

-- BAD (Pushdown Reduced)

SELECT *
FROM read_parquet('sales.parquet')
WHERE YEAR(order_date) = 2026;

-- BETTER REWRITE

SELECT *
FROM read_parquet('sales.parquet')
WHERE order_date >= DATE '2026-01-01'
  AND order_date < DATE '2027-01-01';
