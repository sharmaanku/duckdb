-- ==========================================
-- JOIN OPTIMIZATION DEMO IN DUCKDB
-- ==========================================

-- Cleanup
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS table_a;
DROP TABLE IF EXISTS table_b;

-- ==========================================
-- CREATE CUSTOMERS TABLE
-- ==========================================

CREATE TABLE customers (
    customer_id INTEGER,
    customer_name VARCHAR
);

INSERT INTO customers VALUES
(1, 'Ankur'),
(2, 'Rahul'),
(3, 'Priya');

-- ==========================================
-- CREATE ORDERS TABLE
-- ==========================================

CREATE TABLE orders (
    order_id INTEGER,
    customer_id INTEGER,
    amount INTEGER
);

INSERT INTO orders VALUES
(101, 1, 1000),
(102, 2, 2000),
(103, 1, 1500),
(104, 3, 3000);

-- ==========================================
-- VIEW DATA
-- ==========================================

SELECT * FROM customers;

SELECT * FROM orders;

-- ==========================================
-- HASH JOIN DEMO
-- Equality Join
-- ==========================================

EXPLAIN
SELECT
    o.order_id,
    o.amount,
    c.customer_name
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id;

SELECT
    o.order_id,
    o.amount,
    c.customer_name
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id;

-- ==========================================
-- CREATE SORTED TABLES
-- FOR MERGE JOIN DEMO
-- ==========================================

CREATE TABLE table_a (
    id INTEGER,
    name VARCHAR
);

INSERT INTO table_a VALUES
(1,'A'),
(2,'B'),
(3,'C'),
(4,'D'),
(5,'E');

CREATE TABLE table_b (
    id INTEGER,
    dept VARCHAR
);

INSERT INTO table_b VALUES
(2,'IT'),
(3,'HR'),
(4,'Finance'),
(5,'Sales');

-- ==========================================
-- MERGE JOIN DEMO
-- Sorted Data
-- ==========================================

EXPLAIN
SELECT
    a.id,
    a.name,
    b.dept
FROM table_a a
JOIN table_b b
ON a.id = b.id
ORDER BY a.id;

SELECT
    a.id,
    a.name,
    b.dept
FROM table_a a
JOIN table_b b
ON a.id = b.id
ORDER BY a.id;

-- ==========================================
-- NESTED LOOP JOIN DEMO
-- Non Equality Join
-- ==========================================

EXPLAIN
SELECT
    o.order_id,
    o.amount,
    c.customer_name
FROM orders o
JOIN customers c
ON o.amount > c.customer_id * 1000;

SELECT
    o.order_id,
    o.amount,
    c.customer_name
FROM orders o
JOIN customers c
ON o.amount > c.customer_id * 1000;

-- ==========================================
-- END OF DEMO
-- ==========================================
