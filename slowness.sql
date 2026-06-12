---------------------------------------------------------
-- CLEANUP
---------------------------------------------------------

DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS orders;

---------------------------------------------------------
-- CREATE LARGE CUSTOMERS TABLE
---------------------------------------------------------

CREATE TABLE customers AS
SELECT
    i AS customer_id,
    'Customer_' || i AS customer_name,
    CASE
        WHEN i % 4 = 0 THEN 'North'
        WHEN i % 4 = 1 THEN 'South'
        WHEN i % 4 = 2 THEN 'East'
        ELSE 'West'
    END AS region
FROM range(1,100001) tbl(i);

---------------------------------------------------------
-- CREATE LARGE ORDERS TABLE
---------------------------------------------------------

CREATE TABLE orders AS
SELECT
    i AS order_id,
    1 + CAST(random()*99999 AS INTEGER) AS customer_id,
    ROUND(random()*1000,2) AS amount
FROM range(1,1000001) tbl(i);

---------------------------------------------------------
-- CHECK RECORD COUNTS
---------------------------------------------------------

SELECT COUNT(*) AS customer_count
FROM customers;

SELECT COUNT(*) AS order_count
FROM orders;

---------------------------------------------------------
-- SLOW JOIN ANALYSIS
---------------------------------------------------------

EXPLAIN ANALYZE
SELECT
    c.region,
    o.amount
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id;

---------------------------------------------------------
-- SLOW AGGREGATION ANALYSIS
---------------------------------------------------------

EXPLAIN ANALYZE
SELECT
    c.region,
    SUM(o.amount) AS total_sales
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.region;

---------------------------------------------------------
-- MORE EXPENSIVE AGGREGATION
---------------------------------------------------------

EXPLAIN ANALYZE
SELECT
    c.region,
    c.customer_name,
    COUNT(*) AS order_count,
    SUM(o.amount) AS total_sales,
    AVG(o.amount) AS avg_sales
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY
    c.region,
    c.customer_name;

---------------------------------------------------------
-- OPTIMIZED VERSION
---------------------------------------------------------

EXPLAIN ANALYZE
SELECT
    region,
    SUM(amount) AS total_sales
FROM
(
    SELECT
        c.region,
        o.amount
    FROM customers c
    JOIN orders o
    ON c.customer_id = o.customer_id
) t
GROUP BY region;
