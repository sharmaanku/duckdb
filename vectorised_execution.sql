------------------------------------------------------------
-- STEP 1 : Create Sample Table
------------------------------------------------------------

CREATE TABLE sales (
    order_id INTEGER,
    customer_name VARCHAR,
    region VARCHAR,
    amount DOUBLE
);

------------------------------------------------------------
-- STEP 2 : Insert Sample Data
------------------------------------------------------------

INSERT INTO sales VALUES
(1,'John','North',1000),
(2,'Mary','South',2000),
(3,'David','North',3000),
(4,'Emma','East',1500),
(5,'Chris','West',2500),
(6,'Sophia','North',4000),
(7,'James','South',1200),
(8,'Olivia','North',3500);

------------------------------------------------------------
-- STEP 3 : Simple Query
------------------------------------------------------------

SELECT *
FROM sales
WHERE region='North'
AND amount > 2000;

------------------------------------------------------------
-- STEP 4 : View Optimized Query Plan
------------------------------------------------------------

EXPLAIN
SELECT *
FROM sales
WHERE region='North'
AND amount > 2000;

------------------------------------------------------------
-- STEP 5 : Aggregation Query
------------------------------------------------------------

SELECT region,
       SUM(amount) AS total_sales
FROM sales
WHERE amount > 1000
GROUP BY region;

------------------------------------------------------------
-- STEP 6 : View Optimized Plan
------------------------------------------------------------

EXPLAIN
SELECT region,
       SUM(amount) AS total_sales
FROM sales
WHERE amount > 1000
GROUP BY region;

------------------------------------------------------------
-- STEP 7 : More Complex Query
------------------------------------------------------------

SELECT *
FROM sales
WHERE amount > 1000
AND region='North'
AND customer_name IS NOT NULL;

------------------------------------------------------------
-- STEP 8 : Observe Query Rewriting
------------------------------------------------------------

EXPLAIN
SELECT *
FROM sales
WHERE amount > 1000
AND region='North'
AND customer_name IS NOT NULL;
