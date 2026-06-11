--------------------------------------------------------
-- PARALLEL EXECUTION DEMO IN DUCKDB
--------------------------------------------------------

-- Clean up if table already exists
DROP TABLE IF EXISTS sales;

--------------------------------------------------------
-- Step 1: Create Large Sample Dataset
--------------------------------------------------------

CREATE TABLE sales AS
SELECT
    i AS sale_id,
    CAST(RANDOM() * 1000 AS DOUBLE) AS amount,
    CAST(RANDOM() * 100 AS INTEGER) AS region_id,
    CAST(RANDOM() * 50 AS INTEGER) AS product_id
FROM range(10000000) t(i);

--------------------------------------------------------
-- Step 2: Check Current Thread Setting
--------------------------------------------------------

SELECT current_setting('threads');

--------------------------------------------------------
-- Step 3: Run Query Using SINGLE THREAD
--------------------------------------------------------

SET threads = 1;

.timer on

SELECT
    region_id,
    COUNT(*) AS total_orders,
    SUM(amount) AS total_sales,
    AVG(amount) AS avg_sales
FROM sales
GROUP BY region_id
ORDER BY total_sales DESC;

--------------------------------------------------------
-- Step 4: Run Same Query Using 4 THREADS
--------------------------------------------------------

SET threads = 4;

SELECT
    region_id,
    COUNT(*) AS total_orders,
    SUM(amount) AS total_sales,
    AVG(amount) AS avg_sales
FROM sales
GROUP BY region_id
ORDER BY total_sales DESC;

--------------------------------------------------------
-- Step 5: Verify Thread Configuration
--------------------------------------------------------

SELECT current_setting('threads');

--------------------------------------------------------
-- Step 6: View Query Plan
--------------------------------------------------------

EXPLAIN ANALYZE
SELECT
    region_id,
    COUNT(*) AS total_orders,
    SUM(amount) AS total_sales,
    AVG(amount) AS avg_sales
FROM sales
GROUP BY region_id;

--------------------------------------------------------
-- Step 7: Another CPU-Heavy Query
--------------------------------------------------------

SET threads = 1;

SELECT
    product_id,
    region_id,
    SUM(amount) AS revenue
FROM sales
GROUP BY product_id, region_id;

SET threads = 4;

SELECT
    product_id,
    region_id,
    SUM(amount) AS revenue
FROM sales
GROUP BY product_id, region_id;

--------------------------------------------------------
-- End of Demo
--------------------------------------------------------
