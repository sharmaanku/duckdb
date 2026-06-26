------------------------------------------------------------
-- RELIANCE RETAIL DUCKDB END-TO-END MOCK PROJECT
-- Working with CSV, JSON, Parquet and Arrow
------------------------------------------------------------

------------------------------------------------------------
-- INSTALL EXTENSIONS
------------------------------------------------------------

INSTALL json;
LOAD json;

INSTALL parquet;
LOAD parquet;

------------------------------------------------------------
-- CREATE TABLES
------------------------------------------------------------

CREATE TABLE stores
(
    store_id INTEGER,
    store_name VARCHAR,
    city VARCHAR,
    state VARCHAR
);

INSERT INTO stores VALUES
(101,'Mumbai Central','Mumbai','Maharashtra'),
(102,'Delhi Mall','Delhi','Delhi'),
(103,'Bangalore One','Bangalore','Karnataka');

------------------------------------------------------------

CREATE TABLE products
(
    product_id INTEGER,
    product_name VARCHAR,
    category VARCHAR,
    brand VARCHAR,
    price DECIMAL(10,2)
);

INSERT INTO products VALUES
(1001,'Laptop','Electronics','Lenovo',65000),
(1002,'Television','Electronics','Samsung',45000),
(1003,'Rice Bag','Grocery','Fortune',1200),
(1004,'Milk','Grocery','Amul',60),
(1005,'Mobile','Electronics','Apple',85000);

------------------------------------------------------------

CREATE TABLE customers
(
    customer_id INTEGER,
    customer_name VARCHAR,
    city VARCHAR,
    loyalty VARCHAR
);

INSERT INTO customers VALUES
(1,'Rahul','Mumbai','Gold'),
(2,'Priya','Delhi','Silver'),
(3,'Ankit','Bangalore','Gold'),
(4,'Neha','Mumbai','Bronze');

------------------------------------------------------------

CREATE TABLE employees
(
    employee_id INTEGER,
    employee_name VARCHAR,
    department VARCHAR,
    salary DECIMAL(10,2)
);

INSERT INTO employees VALUES
(201,'Amit','Sales',55000),
(202,'Karan','HR',65000),
(203,'Sneha','Finance',75000),
(204,'Ritu','Sales',50000);

------------------------------------------------------------

CREATE TABLE sales
(
    sale_id INTEGER,
    sale_date DATE,
    store_id INTEGER,
    customer_id INTEGER,
    product_id INTEGER,
    quantity INTEGER
);

INSERT INTO sales VALUES
(1,'2026-01-01',101,1,1001,1),
(2,'2026-01-02',102,2,1002,2),
(3,'2026-01-03',103,3,1003,5),
(4,'2026-01-04',101,4,1004,10),
(5,'2026-01-05',102,1,1005,1);

------------------------------------------------------------
-- BASIC SELECTS
------------------------------------------------------------

SELECT * FROM stores;

SELECT * FROM products;

SELECT * FROM customers;

SELECT * FROM employees;

SELECT * FROM sales;

------------------------------------------------------------
-- EXPORT CSV
------------------------------------------------------------

COPY stores TO 'stores.csv' (HEADER, DELIMITER ',');

COPY products TO 'products.csv' (HEADER);

COPY customers TO 'customers.csv' (HEADER);

COPY sales TO 'sales.csv' (HEADER);

------------------------------------------------------------
-- EXPORT JSON
------------------------------------------------------------

COPY customers TO 'customers.json';

------------------------------------------------------------
-- EXPORT PARQUET
------------------------------------------------------------

COPY sales TO 'sales.parquet' (FORMAT PARQUET);

COPY products TO 'products.parquet' (FORMAT PARQUET);

COPY employees TO 'employees.parquet' (FORMAT PARQUET);

------------------------------------------------------------
-- READ CSV
------------------------------------------------------------

SELECT *
FROM read_csv_auto('sales.csv');

------------------------------------------------------------
-- READ JSON
------------------------------------------------------------

SELECT *
FROM read_json_auto('customers.json');

------------------------------------------------------------
-- READ PARQUET
------------------------------------------------------------

SELECT *
FROM read_parquet('sales.parquet');

------------------------------------------------------------
-- CREATE VIEW
------------------------------------------------------------

CREATE VIEW sales_summary AS

SELECT
sale_id,
sale_date,
store_name,
customer_name,
product_name,
quantity,
price,
quantity*price AS total_amount

FROM sales s

JOIN stores st
ON s.store_id=st.store_id

JOIN customers c
ON s.customer_id=c.customer_id

JOIN products p
ON s.product_id=p.product_id;

------------------------------------------------------------

SELECT * FROM sales_summary;

------------------------------------------------------------
-- AGGREGATION
------------------------------------------------------------

SELECT

store_name,

SUM(total_amount) TotalSales

FROM sales_summary

GROUP BY store_name;

------------------------------------------------------------
-- TOP PRODUCTS
------------------------------------------------------------

SELECT

product_name,

SUM(quantity) QuantitySold

FROM sales_summary

GROUP BY product_name

ORDER BY QuantitySold DESC;

------------------------------------------------------------
-- WINDOW FUNCTION
------------------------------------------------------------

SELECT

customer_name,

SUM(total_amount) TotalPurchase,

RANK() OVER(ORDER BY SUM(total_amount) DESC) Ranking

FROM sales_summary

GROUP BY customer_name;

------------------------------------------------------------
-- DATE FUNCTIONS
------------------------------------------------------------

SELECT

sale_date,

YEAR(sale_date) SalesYear,

MONTH(sale_date) SalesMonth,

DAY(sale_date) SalesDay

FROM sales;

------------------------------------------------------------
-- STRING FUNCTIONS
------------------------------------------------------------

SELECT

UPPER(product_name),

LOWER(category),

LENGTH(product_name)

FROM products;

------------------------------------------------------------
-- CASE STATEMENT
------------------------------------------------------------

SELECT

customer_name,

loyalty,

CASE

WHEN loyalty='Gold'

THEN 'Premium'

WHEN loyalty='Silver'

THEN 'Preferred'

ELSE 'Regular'

END CustomerType

FROM customers;

------------------------------------------------------------
-- CTE
------------------------------------------------------------

WITH SalesCTE AS

(

SELECT

store_id,

SUM(quantity) Qty

FROM sales

GROUP BY store_id

)

SELECT *

FROM SalesCTE;

------------------------------------------------------------
-- TEMP TABLE
------------------------------------------------------------

CREATE TEMP TABLE top_sales AS

SELECT *

FROM sales_summary

WHERE total_amount>50000;

SELECT * FROM top_sales;

------------------------------------------------------------
-- NULL HANDLING
------------------------------------------------------------

SELECT

COALESCE(city,'UNKNOWN')

FROM customers;

------------------------------------------------------------
-- DUPLICATE CHECK
------------------------------------------------------------

SELECT

customer_id,

COUNT(*)

FROM customers

GROUP BY customer_id

HAVING COUNT(*)>1;

------------------------------------------------------------
-- JOIN DIFFERENT FILE FORMATS
------------------------------------------------------------

SELECT

s.sale_id,

c.customer_name,

p.product_name,

quantity

FROM read_parquet('sales.parquet') s

JOIN read_json_auto('customers.json') c

ON s.customer_id=c.customer_id

JOIN read_csv_auto('products.csv') p

ON s.product_id=p.product_id;

------------------------------------------------------------
-- EXPORT CLEAN DATA
------------------------------------------------------------

COPY

(

SELECT *

FROM sales_summary

)

TO 'sales_summary.parquet'

(FORMAT PARQUET);

------------------------------------------------------------
-- PARTITION PARQUET
------------------------------------------------------------

COPY

(

SELECT

department,

employee_name,

salary

FROM employees

)

TO 'EmployeePartition'

(FORMAT PARQUET,

PARTITION_BY(department));

------------------------------------------------------------
-- READ PARTITIONED DATA
------------------------------------------------------------

SELECT *

FROM read_parquet('EmployeePartition/*/*.parquet');

------------------------------------------------------------
-- ANALYTICAL REPORT
------------------------------------------------------------

SELECT

category,

SUM(total_amount) Revenue,

AVG(total_amount) AvgRevenue,

MIN(total_amount) MinSale,

MAX(total_amount) MaxSale

FROM sales_summary

GROUP BY category;

------------------------------------------------------------
-- PERFORMANCE TEST
------------------------------------------------------------

EXPLAIN

SELECT *

FROM read_csv_auto('sales.csv');

EXPLAIN

SELECT *

FROM read_parquet('sales.parquet');

------------------------------------------------------------
-- EXPORT FINAL REPORT
------------------------------------------------------------

COPY

(

SELECT *

FROM sales_summary

)

TO 'RelianceRetailReport.csv'

(HEADER);

COPY

(

SELECT *

FROM sales_summary

)

TO 'RelianceRetailReport.parquet'

(FORMAT PARQUET);

------------------------------------------------------------
-- END OF PROJECT
------------------------------------------------------------
