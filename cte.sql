-----------------------------------------------------------
-- CLEANUP
-----------------------------------------------------------

DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS employees;

-----------------------------------------------------------
-- SAMPLE TABLES
-----------------------------------------------------------

CREATE TABLE customers
(
    customer_id INTEGER,
    customer_name VARCHAR,
    city VARCHAR
);

INSERT INTO customers VALUES
(1,'John','New York'),
(2,'Alice','Chicago'),
(3,'Bob','Dallas'),
(4,'David','Chicago'),
(5,'Emma','New York');

-----------------------------------------------------------

CREATE TABLE products
(
    product_id INTEGER,
    product_name VARCHAR,
    category VARCHAR,
    price DOUBLE
);

INSERT INTO products VALUES
(101,'Laptop','Electronics',1200),
(102,'Phone','Electronics',800),
(103,'Tablet','Electronics',500),
(104,'Chair','Furniture',150),
(105,'Desk','Furniture',300);

-----------------------------------------------------------

CREATE TABLE sales
(
    sale_id INTEGER,
    customer_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    sale_date DATE
);

INSERT INTO sales VALUES
(1,1,101,1,'2025-01-01'),
(2,1,102,2,'2025-01-02'),
(3,2,101,1,'2025-01-03'),
(4,3,103,4,'2025-01-04'),
(5,4,104,3,'2025-01-05'),
(6,5,105,2,'2025-01-06'),
(7,2,102,1,'2025-01-07'),
(8,3,104,5,'2025-01-08'),
(9,4,105,2,'2025-01-09'),
(10,5,101,1,'2025-01-10');

-----------------------------------------------------------
-- EMPLOYEE HIERARCHY TABLE
-----------------------------------------------------------

CREATE TABLE employees
(
    emp_id INTEGER,
    emp_name VARCHAR,
    manager_id INTEGER
);

INSERT INTO employees VALUES
(1,'CEO',NULL),
(2,'VP_Sales',1),
(3,'VP_IT',1),
(4,'Manager_A',2),
(5,'Manager_B',2),
(6,'Lead_A',4),
(7,'Developer_A',6);

-----------------------------------------------------------
-- 1. BASIC CTE
-----------------------------------------------------------

WITH electronics_products AS
(
    SELECT *
    FROM products
    WHERE category='Electronics'
)
SELECT *
FROM electronics_products;

-----------------------------------------------------------
-- 2. MULTIPLE CTEs
-----------------------------------------------------------

WITH electronics AS
(
    SELECT *
    FROM products
    WHERE category='Electronics'
),
furniture AS
(
    SELECT *
    FROM products
    WHERE category='Furniture'
)
SELECT *
FROM electronics
UNION ALL
SELECT *
FROM furniture;

-----------------------------------------------------------
-- 3. CTE WITH JOIN
-----------------------------------------------------------

WITH sales_details AS
(
    SELECT
        s.sale_id,
        c.customer_name,
        p.product_name,
        p.price,
        s.quantity,
        p.price * s.quantity AS sales_amount
    FROM sales s
    JOIN customers c
        ON s.customer_id = c.customer_id
    JOIN products p
        ON s.product_id = p.product_id
)
SELECT *
FROM sales_details;

-----------------------------------------------------------
-- 4. CHAINED CTEs
-----------------------------------------------------------

WITH sales_details AS
(
    SELECT
        c.customer_name,
        p.price * s.quantity AS sales_amount
    FROM sales s
    JOIN customers c
        ON s.customer_id = c.customer_id
    JOIN products p
        ON s.product_id = p.product_id
),
customer_sales AS
(
    SELECT
        customer_name,
        SUM(sales_amount) AS total_sales
    FROM sales_details
    GROUP BY customer_name
),
top_customers AS
(
    SELECT *
    FROM customer_sales
    WHERE total_sales > 1500
)
SELECT *
FROM top_customers;

-----------------------------------------------------------
-- 5. AGGREGATION USING CTE
-----------------------------------------------------------

WITH category_sales AS
(
    SELECT
        p.category,
        SUM(p.price*s.quantity) AS revenue
    FROM sales s
    JOIN products p
        ON s.product_id=p.product_id
    GROUP BY p.category
)
SELECT *
FROM category_sales;

-----------------------------------------------------------
-- 6. WINDOW FUNCTION CTE
-----------------------------------------------------------

WITH customer_revenue AS
(
    SELECT
        c.customer_name,
        SUM(p.price*s.quantity) AS revenue
    FROM sales s
    JOIN customers c
        ON s.customer_id=c.customer_id
    JOIN products p
        ON s.product_id=p.product_id
    GROUP BY c.customer_name
)
SELECT
    customer_name,
    revenue,
    RANK() OVER(ORDER BY revenue DESC) AS rank_no
FROM customer_revenue;

-----------------------------------------------------------
-- 7. TOP N PERFORMERS
-----------------------------------------------------------

WITH customer_revenue AS
(
    SELECT
        c.customer_name,
        SUM(p.price*s.quantity) revenue
    FROM sales s
    JOIN customers c
        ON c.customer_id=s.customer_id
    JOIN products p
        ON p.product_id=s.product_id
    GROUP BY c.customer_name
),
ranking AS
(
    SELECT *,
           ROW_NUMBER() OVER
           (ORDER BY revenue DESC) rn
    FROM customer_revenue
)
SELECT *
FROM ranking
WHERE rn <= 3;

-----------------------------------------------------------
-- 8. RUNNING TOTAL USING CTE
-----------------------------------------------------------

WITH daily_sales AS
(
    SELECT
        sale_date,
        SUM(p.price*s.quantity) revenue
    FROM sales s
    JOIN products p
        ON s.product_id=p.product_id
    GROUP BY sale_date
)
SELECT
    sale_date,
    revenue,
    SUM(revenue)
    OVER(
        ORDER BY sale_date
    ) AS running_total
FROM daily_sales;

-----------------------------------------------------------
-- 9. DATA CLEANSING USING CTE
-----------------------------------------------------------

WITH cleaned_products AS
(
    SELECT
        product_id,
        TRIM(product_name) product_name,
        category,
        COALESCE(price,0) price
    FROM products
)
SELECT *
FROM cleaned_products;

-----------------------------------------------------------
-- 10. CTE REUSE
-----------------------------------------------------------

WITH customer_revenue AS
(
    SELECT
        c.customer_name,
        SUM(p.price*s.quantity) revenue
    FROM sales s
    JOIN customers c
        ON c.customer_id=s.customer_id
    JOIN products p
        ON p.product_id=s.product_id
    GROUP BY c.customer_name
)
SELECT
    MAX(revenue) AS highest_revenue,
    MIN(revenue) AS lowest_revenue,
    AVG(revenue) AS avg_revenue
FROM customer_revenue;

-----------------------------------------------------------
-- 11. RECURSIVE CTE - NUMBER GENERATOR
-----------------------------------------------------------

WITH RECURSIVE numbers AS
(
    SELECT 1 AS n

    UNION ALL

    SELECT n + 1
    FROM numbers
    WHERE n < 10
)
SELECT *
FROM numbers;

-----------------------------------------------------------
-- 12. RECURSIVE CTE - EMPLOYEE HIERARCHY
-----------------------------------------------------------

WITH RECURSIVE employee_tree AS
(
    SELECT
        emp_id,
        emp_name,
        manager_id,
        1 AS level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT
        e.emp_id,
        e.emp_name,
        e.manager_id,
        et.level + 1
    FROM employees e
    JOIN employee_tree et
        ON e.manager_id = et.emp_id
)
SELECT *
FROM employee_tree
ORDER BY level;

-----------------------------------------------------------
-- 13. NESTED CTE
-----------------------------------------------------------

WITH first_layer AS
(
    SELECT *
    FROM sales
),
second_layer AS
(
    SELECT
        customer_id,
        SUM(quantity) total_qty
    FROM first_layer
    GROUP BY customer_id
)
SELECT *
FROM second_layer;

-----------------------------------------------------------
-- 14. CTE FOR PERCENTAGE CONTRIBUTION
-----------------------------------------------------------

WITH customer_sales AS
(
    SELECT
        c.customer_name,
        SUM(p.price*s.quantity) revenue
    FROM sales s
    JOIN customers c
        ON c.customer_id=s.customer_id
    JOIN products p
        ON p.product_id=s.product_id
    GROUP BY c.customer_name
),
grand_total AS
(
    SELECT SUM(revenue) total_revenue
    FROM customer_sales
)
SELECT
    cs.customer_name,
    cs.revenue,
    ROUND(
        (cs.revenue * 100.0) /
        gt.total_revenue,
        2
    ) AS contribution_pct
FROM customer_sales cs
CROSS JOIN grand_total gt;

-----------------------------------------------------------
-- 15. CTE FOR MOVING AVERAGE
-----------------------------------------------------------

WITH daily_sales AS
(
    SELECT
        sale_date,
        SUM(p.price*s.quantity) revenue
    FROM sales s
    JOIN products p
        ON s.product_id=p.product_id
    GROUP BY sale_date
)
SELECT
    sale_date,
    revenue,
    AVG(revenue)
    OVER(
        ORDER BY sale_date
        ROWS BETWEEN 2 PRECEDING
        AND CURRENT ROW
    ) AS moving_avg
FROM daily_sales;

-----------------------------------------------------------
-- 16. COMPLEX ANALYTICAL PIPELINE
-----------------------------------------------------------

WITH sales_detail AS
(
    SELECT
        c.customer_name,
        c.city,
        p.category,
        p.price*s.quantity AS sales_amount
    FROM sales s
    JOIN customers c
        ON c.customer_id=s.customer_id
    JOIN products p
        ON p.product_id=s.product_id
),

city_sales AS
(
    SELECT
        city,
        SUM(sales_amount) city_revenue
    FROM sales_detail
    GROUP BY city
),

customer_sales AS
(
    SELECT
        customer_name,
        city,
        SUM(sales_amount) customer_revenue
    FROM sales_detail
    GROUP BY customer_name, city
),

ranked_customers AS
(
    SELECT
        *,
        DENSE_RANK()
        OVER(
            PARTITION BY city
            ORDER BY customer_revenue DESC
        ) city_rank
    FROM customer_sales
)

SELECT
    rc.customer_name,
    rc.city,
    rc.customer_revenue,
    cs.city_revenue,
    ROUND(
      rc.customer_revenue * 100.0
      / cs.city_revenue,
      2
    ) contribution_pct,
    rc.city_rank
FROM ranked_customers rc
JOIN city_sales cs
    ON rc.city=cs.city
ORDER BY city, city_rank;

-----------------------------------------------------------
-- 17. EXPLAIN CTE OPTIMIZATION
-----------------------------------------------------------

EXPLAIN
WITH customer_sales AS
(
    SELECT
        customer_id,
        SUM(quantity) total_qty
    FROM sales
    GROUP BY customer_id
)
SELECT *
FROM customer_sales
WHERE total_qty > 2;

-----------------------------------------------------------
-- 18. EXPLAIN CTE MATERIALIZATION
-----------------------------------------------------------

EXPLAIN ANALYZE
WITH customer_sales AS
(
    SELECT
        customer_id,
        SUM(quantity) total_qty
    FROM sales
    GROUP BY customer_id
)
SELECT *
FROM customer_sales;
