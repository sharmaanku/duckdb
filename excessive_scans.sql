--------------------------------------------------
-- STEP 1 : CREATE SAMPLE SALES TABLE
--------------------------------------------------

DROP TABLE IF EXISTS sales;

CREATE TABLE sales AS
SELECT
    i AS sale_id,
    'Customer_' || CAST(i % 1000 AS VARCHAR) AS customer_id,
    CASE
        WHEN i % 4 = 0 THEN 'North'
        WHEN i % 4 = 1 THEN 'South'
        WHEN i % 4 = 2 THEN 'East'
        ELSE 'West'
    END AS region,
    RANDOM()*1000 AS amount
FROM range(1000000) t(i);

--------------------------------------------------
-- STEP 2 : BAD QUERY (FULL TABLE SCAN)
--------------------------------------------------

EXPLAIN ANALYZE
SELECT *
FROM sales;

--------------------------------------------------
-- STEP 3 : FILTERED QUERY
--------------------------------------------------

EXPLAIN ANALYZE
SELECT *
FROM sales
WHERE region='North';

--------------------------------------------------
-- STEP 4 : EXPENSIVE GROUP BY
--------------------------------------------------

EXPLAIN ANALYZE
SELECT
    customer_id,
    SUM(amount) AS total_sales
FROM sales
GROUP BY customer_id;

--------------------------------------------------
-- STEP 5 : SORT OPERATION
--------------------------------------------------

EXPLAIN ANALYZE
SELECT *
FROM sales
ORDER BY amount DESC
LIMIT 100;

--------------------------------------------------
-- STEP 6 : CREATE SECOND TABLE
--------------------------------------------------

DROP TABLE IF EXISTS customer_master;

CREATE TABLE customer_master AS
SELECT
    'Customer_' || CAST(i AS VARCHAR) AS customer_id,
    'Category_' || CAST(i % 10 AS VARCHAR) AS customer_type
FROM range(1000) t(i);

--------------------------------------------------
-- STEP 7 : JOIN OPERATION
--------------------------------------------------

EXPLAIN ANALYZE
SELECT
    s.customer_id,
    c.customer_type,
    SUM(s.amount) AS revenue
FROM sales s
JOIN customer_master c
ON s.customer_id = c.customer_id
GROUP BY
    s.customer_id,
    c.customer_type;

--------------------------------------------------
-- STEP 8 : CHECK QUERY PLAN ONLY
--------------------------------------------------

EXPLAIN
SELECT
    customer_id,
    SUM(amount)
FROM sales
GROUP BY customer_id;
