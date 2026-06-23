-- ==========================================================
-- DUCKDB QUERY OPTIMIZATION MASTER SCRIPT
-- Covers:
-- 1. Predicate Pushdown
-- 2. Projection Pushdown
-- 3. Hash Join
-- 4. Merge Join
-- 5. Nested Loop Join
-- 6. Aggregation Optimization
-- 7. CTE Optimization
-- 8. Materialized / Non-Materialized CTE
-- 9. Window Function Optimization
-- 10. Subquery Rewriting
-- 11. Vectorized Execution Optimization
-- 12. Filter Pushdown Before Join
-- 13. Aggregation Before Join
-- ==========================================================

DROP SCHEMA IF EXISTS optimization_demo CASCADE;

CREATE SCHEMA optimization_demo;

SET schema='optimization_demo';

-- ==========================================================
-- TABLE CREATION
-- ==========================================================

CREATE TABLE customers
(
    customer_id INTEGER,
    customer_name VARCHAR,
    city VARCHAR,
    country VARCHAR,
    signup_date DATE
);

CREATE TABLE products
(
    product_id INTEGER,
    product_name VARCHAR,
    category VARCHAR,
    price DECIMAL(10,2)
);

CREATE TABLE orders
(
    order_id INTEGER,
    customer_id INTEGER,
    order_date DATE,
    order_status VARCHAR
);

CREATE TABLE order_items
(
    order_item_id INTEGER,
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    sales_amount DECIMAL(12,2)
);

-- ==========================================================
-- SAMPLE DATA
-- ==========================================================

INSERT INTO customers VALUES
(1,'John','New York','USA','2023-01-01'),
(2,'Mary','Chicago','USA','2023-02-10'),
(3,'David','Toronto','Canada','2023-03-15'),
(4,'Steve','London','UK','2023-04-01'),
(5,'Robert','Delhi','India','2023-05-01'),
(6,'James','Boston','USA','2023-06-01'),
(7,'Emily','Dallas','USA','2023-07-01');

INSERT INTO products VALUES
(101,'Laptop','Electronics',1200),
(102,'Phone','Electronics',800),
(103,'Keyboard','Accessories',50),
(104,'Mouse','Accessories',25),
(105,'Monitor','Electronics',400),
(106,'Tablet','Electronics',600);

INSERT INTO orders VALUES
(1001,1,'2024-01-01','Completed'),
(1002,2,'2024-01-02','Completed'),
(1003,3,'2024-01-03','Pending'),
(1004,4,'2024-01-04','Completed'),
(1005,5,'2024-01-05','Cancelled'),
(1006,6,'2024-01-06','Completed'),
(1007,7,'2024-01-07','Completed');

INSERT INTO order_items VALUES
(1,1001,101,2,2400),
(2,1001,103,3,150),
(3,1002,102,1,800),
(4,1002,104,2,50),
(5,1003,105,1,400),
(6,1004,101,1,1200),
(7,1004,104,5,125),
(8,1005,103,10,500),
(9,1006,106,2,1200),
(10,1007,102,2,1600);

-- ==========================================================
-- PREDICATE PUSHDOWN
-- ==========================================================

EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE order_status='Completed';

-- ==========================================================
-- PROJECTION PUSHDOWN
-- ==========================================================

EXPLAIN ANALYZE
SELECT
    customer_id,
    customer_name
FROM customers
WHERE country='USA';

-- ==========================================================
-- HASH JOIN OPTIMIZATION
-- ==========================================================

EXPLAIN ANALYZE
SELECT
    o.order_id,
    c.customer_name,
    o.order_status
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id;

-- ==========================================================
-- HASH JOIN FACT-DIMENSION PATTERN
-- ==========================================================

EXPLAIN ANALYZE
SELECT
    oi.order_id,
    p.product_name,
    oi.sales_amount
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id;

-- ==========================================================
-- MERGE JOIN DEMONSTRATION
-- ==========================================================

EXPLAIN ANALYZE
SELECT
    o.order_id,
    c.customer_name
FROM
(
    SELECT *
    FROM orders
    ORDER BY customer_id
) o
JOIN
(
    SELECT *
    FROM customers
    ORDER BY customer_id
) c
ON o.customer_id = c.customer_id;

-- ==========================================================
-- NESTED LOOP JOIN
-- NON-EQUI JOIN
-- ==========================================================

EXPLAIN ANALYZE
SELECT
    p1.product_name,
    p2.product_name,
    p1.price,
    p2.price
FROM products p1
JOIN products p2
ON p1.price > p2.price;

-- ==========================================================
-- AGGREGATION OPTIMIZATION
-- ==========================================================

EXPLAIN ANALYZE
SELECT
    product_id,
    SUM(sales_amount) total_sales,
    AVG(sales_amount) avg_sales,
    COUNT(*) transaction_count
FROM order_items
GROUP BY product_id;

-- ==========================================================
-- GROUP BY CATEGORY
-- ==========================================================

EXPLAIN ANALYZE
SELECT
    p.category,
    SUM(oi.sales_amount) revenue,
    COUNT(*) total_transactions
FROM order_items oi
JOIN products p
ON oi.product_id=p.product_id
GROUP BY p.category;

-- ==========================================================
-- CONDITIONAL AGGREGATION
-- ==========================================================

EXPLAIN ANALYZE
SELECT
    SUM(
        CASE
            WHEN sales_amount > 1000
            THEN sales_amount
            ELSE 0
        END
    ) high_value_sales
FROM order_items;

-- ==========================================================
-- CTE OPTIMIZATION (INLINE)
-- ==========================================================

EXPLAIN ANALYZE
WITH completed_orders AS
(
    SELECT *
    FROM orders
    WHERE order_status='Completed'
)
SELECT *
FROM completed_orders;

-- ==========================================================
-- CTE REFERENCED MULTIPLE TIMES
-- ==========================================================

EXPLAIN ANALYZE
WITH completed_orders AS
(
    SELECT *
    FROM orders
    WHERE order_status='Completed'
)
SELECT COUNT(*) AS order_count
FROM completed_orders

UNION ALL

SELECT SUM(order_id)
FROM completed_orders;

-- ==========================================================
-- MATERIALIZED CTE
-- ==========================================================

EXPLAIN ANALYZE
WITH sales_cte AS MATERIALIZED
(
    SELECT *
    FROM order_items
)
SELECT
    SUM(sales_amount)
FROM sales_cte;

-- ==========================================================
-- NOT MATERIALIZED CTE
-- ==========================================================

EXPLAIN ANALYZE
WITH sales_cte AS NOT MATERIALIZED
(
    SELECT *
    FROM order_items
)
SELECT
    SUM(sales_amount)
FROM sales_cte;

-- ==========================================================
-- WINDOW FUNCTION OPTIMIZATION
-- ==========================================================

EXPLAIN ANALYZE
SELECT
    order_id,
    sales_amount,
    SUM(sales_amount)
    OVER(
        ORDER BY order_id
    ) running_total
FROM order_items;

-- ==========================================================
-- RANK WINDOW FUNCTION
-- ==========================================================

EXPLAIN ANALYZE
SELECT
    product_id,
    sales_amount,
    RANK()
    OVER(
        PARTITION BY product_id
        ORDER BY sales_amount DESC
    ) ranking
FROM order_items;

-- ==========================================================
-- ROW_NUMBER
-- ==========================================================

EXPLAIN ANALYZE
SELECT
    product_id,
    sales_amount,
    ROW_NUMBER()
    OVER(
        PARTITION BY product_id
        ORDER BY sales_amount DESC
    ) rn
FROM order_items;

-- ==========================================================
-- CORRELATED SUBQUERY
-- ==========================================================

EXPLAIN ANALYZE
SELECT
    customer_id,
    customer_name
FROM customers c
WHERE EXISTS
(
    SELECT 1
    FROM orders o
    WHERE o.customer_id=c.customer_id
);

-- ==========================================================
-- REWRITTEN JOIN VERSION
-- ==========================================================

EXPLAIN ANALYZE
SELECT DISTINCT
    c.customer_id,
    c.customer_name
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id;

-- ==========================================================
-- SCALAR SUBQUERY
-- ==========================================================

EXPLAIN ANALYZE
SELECT
    order_id,
    sales_amount
FROM order_items
WHERE sales_amount >
(
    SELECT AVG(sales_amount)
    FROM order_items
);

-- ==========================================================
-- SUBQUERY REWRITE USING CTE
-- ==========================================================

EXPLAIN ANALYZE
WITH avg_sales AS
(
    SELECT AVG(sales_amount) avg_value
    FROM order_items
)
SELECT
    oi.order_id,
    oi.sales_amount
FROM order_items oi
CROSS JOIN avg_sales a
WHERE oi.sales_amount > a.avg_value;

-- ==========================================================
-- FILTER BEFORE JOIN
-- ==========================================================

EXPLAIN ANALYZE
SELECT
    o.order_id,
    c.customer_name
FROM orders o
JOIN
(
    SELECT *
    FROM customers
    WHERE country='USA'
) c
ON o.customer_id=c.customer_id;

-- ==========================================================
-- AGGREGATION BEFORE JOIN
-- ==========================================================

EXPLAIN ANALYZE
WITH sales_summary AS
(
    SELECT
        product_id,
        SUM(sales_amount) total_sales
    FROM order_items
    GROUP BY product_id
)
SELECT
    p.category,
    SUM(s.total_sales) category_sales
FROM sales_summary s
JOIN products p
ON s.product_id=p.product_id
GROUP BY p.category;

-- ==========================================================
-- VECTORIZED EXECUTION FRIENDLY QUERY
-- ==========================================================

EXPLAIN ANALYZE
SELECT
    order_item_id,
    quantity,
    sales_amount,
    quantity * sales_amount AS total_value,
    quantity * sales_amount * 0.18 AS tax_amount,
    (quantity * sales_amount) +
    (quantity * sales_amount * 0.18) AS final_amount
FROM order_items;

-- ==========================================================
-- COMPLETE OPTIMIZED ANALYTICAL QUERY
-- Demonstrates:
-- Predicate Pushdown
-- Projection Pushdown
-- Hash Join
-- Aggregation
-- Vectorized Execution
-- ==========================================================

EXPLAIN ANALYZE
SELECT
    c.country,
    p.category,
    COUNT(*) total_orders,
    SUM(oi.sales_amount) revenue,
    AVG(oi.sales_amount) avg_revenue,
    MAX(oi.sales_amount) max_revenue
FROM order_items oi
JOIN orders o
ON oi.order_id=o.order_id
JOIN customers c
ON o.customer_id=c.customer_id
JOIN products p
ON oi.product_id=p.product_id
WHERE o.order_status='Completed'
AND c.country='USA'
GROUP BY
    c.country,
    p.category
ORDER BY revenue DESC;

-- ==========================================================
-- VIEW EXECUTION PLAN ONLY
-- ==========================================================

EXPLAIN
SELECT
    c.country,
    SUM(oi.sales_amount)
FROM order_items oi
JOIN orders o
ON oi.order_id=o.order_id
JOIN customers c
ON o.customer_id=c.customer_id
GROUP BY c.country;
