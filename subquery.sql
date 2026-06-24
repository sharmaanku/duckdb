---------------------------------------------------------
-- CLEANUP
---------------------------------------------------------

DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS employees;

---------------------------------------------------------
-- CUSTOMERS
---------------------------------------------------------

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

---------------------------------------------------------
-- PRODUCTS
---------------------------------------------------------

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

---------------------------------------------------------
-- SALES
---------------------------------------------------------

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

---------------------------------------------------------
-- EMPLOYEES
---------------------------------------------------------

CREATE TABLE employees
(
    emp_id INTEGER,
    emp_name VARCHAR,
    salary DOUBLE,
    department VARCHAR
);

INSERT INTO employees VALUES
(1,'John',80000,'IT'),
(2,'Alice',90000,'IT'),
(3,'Bob',70000,'HR'),
(4,'David',65000,'HR'),
(5,'Emma',120000,'Finance'),
(6,'Mike',95000,'Finance');

---------------------------------------------------------
-- 1. SCALAR SUBQUERY
---------------------------------------------------------

SELECT *
FROM employees
WHERE salary >
(
    SELECT AVG(salary)
    FROM employees
);

---------------------------------------------------------
-- 2. SUBQUERY IN SELECT
---------------------------------------------------------

SELECT
    emp_name,
    salary,
    (
        SELECT AVG(salary)
        FROM employees
    ) AS company_avg_salary
FROM employees;

---------------------------------------------------------
-- 3. SUBQUERY IN FROM
---------------------------------------------------------

SELECT *
FROM
(
    SELECT
        department,
        AVG(salary) avg_salary
    FROM employees
    GROUP BY department
) x;

---------------------------------------------------------
-- 4. SINGLE ROW SUBQUERY
---------------------------------------------------------

SELECT *
FROM employees
WHERE salary =
(
    SELECT MAX(salary)
    FROM employees
);

---------------------------------------------------------
-- 5. MULTI ROW SUBQUERY (IN)
---------------------------------------------------------

SELECT *
FROM customers
WHERE customer_id IN
(
    SELECT customer_id
    FROM sales
);

---------------------------------------------------------
-- 6. NOT IN SUBQUERY
---------------------------------------------------------

SELECT *
FROM customers
WHERE customer_id NOT IN
(
    SELECT customer_id
    FROM sales
);

---------------------------------------------------------
-- 7. CORRELATED SUBQUERY
---------------------------------------------------------

SELECT
    e1.emp_name,
    e1.salary,
    e1.department
FROM employees e1
WHERE salary >
(
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e1.department = e2.department
);

---------------------------------------------------------
-- 8. EXISTS
---------------------------------------------------------

SELECT *
FROM customers c
WHERE EXISTS
(
    SELECT 1
    FROM sales s
    WHERE c.customer_id = s.customer_id
);

---------------------------------------------------------
-- 9. NOT EXISTS
---------------------------------------------------------

SELECT *
FROM customers c
WHERE NOT EXISTS
(
    SELECT 1
    FROM sales s
    WHERE c.customer_id = s.customer_id
);

---------------------------------------------------------
-- 10. ANY
---------------------------------------------------------

SELECT *
FROM employees
WHERE salary >
ANY
(
    SELECT salary
    FROM employees
    WHERE department='HR'
);

---------------------------------------------------------
-- 11. ALL
---------------------------------------------------------

SELECT *
FROM employees
WHERE salary >
ALL
(
    SELECT salary
    FROM employees
    WHERE department='HR'
);

---------------------------------------------------------
-- 12. NESTED SUBQUERY
---------------------------------------------------------

SELECT *
FROM employees
WHERE salary >
(
    SELECT AVG(avg_sal)
    FROM
    (
        SELECT department,
               AVG(salary) avg_sal
        FROM employees
        GROUP BY department
    ) x
);

---------------------------------------------------------
-- 13. SUBQUERY WITH AGGREGATION
---------------------------------------------------------

SELECT department,
       AVG(salary)
FROM employees
GROUP BY department
HAVING AVG(salary) >
(
    SELECT AVG(salary)
    FROM employees
);

---------------------------------------------------------
-- 14. TOP EARNER PER DEPARTMENT
---------------------------------------------------------

SELECT *
FROM employees e1
WHERE salary =
(
    SELECT MAX(e2.salary)
    FROM employees e2
    WHERE e1.department=e2.department
);

---------------------------------------------------------
-- 15. SECOND HIGHEST SALARY
---------------------------------------------------------

SELECT MAX(salary)
FROM employees
WHERE salary <
(
    SELECT MAX(salary)
    FROM employees
);

---------------------------------------------------------
-- 16. THIRD HIGHEST SALARY
---------------------------------------------------------

SELECT MAX(salary)
FROM employees
WHERE salary <
(
    SELECT MAX(salary)
    FROM employees
    WHERE salary <
    (
        SELECT MAX(salary)
        FROM employees
    )
);

---------------------------------------------------------
-- 17. SUBQUERY IN UPDATE
---------------------------------------------------------

UPDATE employees
SET salary = salary * 1.10
WHERE salary <
(
    SELECT AVG(salary)
    FROM employees
);

SELECT * FROM employees;

---------------------------------------------------------
-- 18. SUBQUERY IN DELETE
---------------------------------------------------------

DELETE FROM employees
WHERE emp_id IN
(
    SELECT emp_id
    FROM employees
    WHERE salary < 70000
);

---------------------------------------------------------
-- 19. SALES ABOVE AVERAGE SALES
---------------------------------------------------------

SELECT *
FROM sales
WHERE quantity >
(
    SELECT AVG(quantity)
    FROM sales
);

---------------------------------------------------------
-- 20. MOST EXPENSIVE PRODUCT IN CATEGORY
---------------------------------------------------------

SELECT *
FROM products p1
WHERE price =
(
    SELECT MAX(price)
    FROM products p2
    WHERE p1.category = p2.category
);

---------------------------------------------------------
-- 21. CUSTOMER WITH HIGHEST PURCHASE VALUE
---------------------------------------------------------

SELECT *
FROM customers
WHERE customer_id =
(
    SELECT customer_id
    FROM
    (
        SELECT
            s.customer_id,
            SUM(p.price*s.quantity) revenue
        FROM sales s
        JOIN products p
            ON s.product_id=p.product_id
        GROUP BY s.customer_id
        ORDER BY revenue DESC
        LIMIT 1
    ) x
);

---------------------------------------------------------
-- 22. SUBQUERY IN CASE STATEMENT
---------------------------------------------------------

SELECT
    emp_name,
    salary,
    CASE
       WHEN salary >
       (
          SELECT AVG(salary)
          FROM employees
       )
       THEN 'ABOVE AVG'
       ELSE 'BELOW AVG'
    END status
FROM employees;

---------------------------------------------------------
-- 23. SUBQUERY RETURNING MULTIPLE COLUMNS
---------------------------------------------------------

SELECT *
FROM
(
    SELECT
        department,
        COUNT(*) emp_count,
        AVG(salary) avg_salary
    FROM employees
    GROUP BY department
) x;

---------------------------------------------------------
-- 24. WINDOW FUNCTION INSIDE SUBQUERY
---------------------------------------------------------

SELECT *
FROM
(
    SELECT
        emp_name,
        salary,
        DENSE_RANK() OVER
        (
            ORDER BY salary DESC
        ) rnk
    FROM employees
) x
WHERE rnk <= 3;

---------------------------------------------------------
-- 25. TOP 3 CUSTOMERS BY REVENUE
---------------------------------------------------------

SELECT *
FROM
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
) x
ORDER BY revenue DESC
LIMIT 3;

---------------------------------------------------------
-- 26. MULTI LEVEL NESTED SUBQUERY
---------------------------------------------------------

SELECT *
FROM employees
WHERE salary >
(
    SELECT AVG(avg_salary)
    FROM
    (
        SELECT department,
               AVG(salary) avg_salary
        FROM
        (
            SELECT *
            FROM employees
        ) x
        GROUP BY department
    ) y
);

---------------------------------------------------------
-- 27. SUBQUERY VS JOIN EXAMPLE
---------------------------------------------------------

SELECT *
FROM employees
WHERE department IN
(
    SELECT department
    FROM employees
    GROUP BY department
    HAVING AVG(salary) > 80000
);

---------------------------------------------------------
-- 28. CORRELATED AGGREGATE SUBQUERY
---------------------------------------------------------

SELECT
    c.customer_name,
    (
        SELECT SUM(quantity)
        FROM sales s
        WHERE s.customer_id=c.customer_id
    ) total_quantity
FROM customers c;

---------------------------------------------------------
-- 29. PERFORMANCE PLAN
---------------------------------------------------------

EXPLAIN
SELECT *
FROM employees
WHERE salary >
(
    SELECT AVG(salary)
    FROM employees
);

---------------------------------------------------------
-- 30. PERFORMANCE ANALYSIS
---------------------------------------------------------

EXPLAIN ANALYZE
SELECT *
FROM employees
WHERE salary >
(
    SELECT AVG(salary)
    FROM employees
);

---------------------------------------------------------
-- 31. EDGE CASE - EMPTY RESULT
---------------------------------------------------------

SELECT *
FROM employees
WHERE salary >
(
    SELECT 9999999
);

---------------------------------------------------------
-- 32. EDGE CASE - NULL HANDLING
---------------------------------------------------------

SELECT *
FROM employees
WHERE salary >
(
    SELECT AVG(NULLIF(salary, salary))
    FROM employees
);

---------------------------------------------------------
-- 33. EDGE CASE - NOT EXISTS SAFE NULL CHECK
---------------------------------------------------------

SELECT *
FROM customers c
WHERE NOT EXISTS
(
    SELECT 1
    FROM sales s
    WHERE s.customer_id=c.customer_id
);

---------------------------------------------------------
-- 34. EDGE CASE - NOT IN NULL PROBLEM
---------------------------------------------------------

SELECT *
FROM customers
WHERE customer_id NOT IN
(
    SELECT NULL
);

---------------------------------------------------------
-- 35. ADVANCED ANALYTICAL SUBQUERY
---------------------------------------------------------

SELECT *
FROM
(
    SELECT
        customer_id,
        product_id,
        quantity,
        AVG(quantity) OVER
        (
            PARTITION BY customer_id
        ) avg_qty
    FROM sales
) x
WHERE quantity > avg_qty;
