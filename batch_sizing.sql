----------------------------------------------------
-- STEP 1 : Create Large Dataset
----------------------------------------------------

CREATE TABLE sales AS
SELECT
    i AS sale_id,
    'Customer_' || i AS customer_name,
    RANDOM()*1000 AS amount,
    RANDOM()*100 AS discount,
    RANDOM()*10000 AS profit,
    RANDOM()*5000 AS tax,
    RANDOM()*1000 AS shipping_cost,
    RANDOM()*10000 AS inventory_cost,
    RANDOM()*10000 AS marketing_cost,
    RANDOM()*10000 AS misc_cost
FROM range(1000000) t(i);

----------------------------------------------------
-- STEP 2 : Enable Profiling
----------------------------------------------------

PRAGMA enable_profiling;
PRAGMA profiling_output='query_profile.json';

----------------------------------------------------
-- STEP 3 : Wide Table Query (Bad)
----------------------------------------------------

SELECT *
FROM sales
WHERE amount > 500;

----------------------------------------------------
-- STEP 4 : Wide Table Query (Good)
-- Column Pruning
----------------------------------------------------

SELECT sale_id, amount
FROM sales
WHERE amount > 500;

----------------------------------------------------
-- STEP 5 : Aggregation
-- Observe vectorized execution
----------------------------------------------------

SELECT
    AVG(amount),
    SUM(profit),
    MAX(discount)
FROM sales;

----------------------------------------------------
-- STEP 6 : Create Nested Data
----------------------------------------------------

CREATE TABLE customer_profile AS
SELECT
    i AS customer_id,
    {
      'city':'Delhi',
      'state':'Delhi',
      'country':'India'
    } AS address
FROM range(100000) t(i);

----------------------------------------------------
-- STEP 7 : Read Entire Struct
----------------------------------------------------

SELECT *
FROM customer_profile;

----------------------------------------------------
-- STEP 8 : Read Only Nested Field
----------------------------------------------------

SELECT
    address.city
FROM customer_profile;

----------------------------------------------------
-- STEP 9 : Compare Execution Plans
----------------------------------------------------

EXPLAIN
SELECT *
FROM sales
WHERE amount > 500;

EXPLAIN
SELECT sale_id, amount
FROM sales
WHERE amount > 500;

----------------------------------------------------
-- STEP 10 : Large Batch Processing Example
----------------------------------------------------

SELECT
    SUM(amount),
    AVG(amount),
    COUNT(*)
FROM sales;

----------------------------------------------------
-- STEP 11 : View Profiling Information
----------------------------------------------------

PRAGMA show_tables;
