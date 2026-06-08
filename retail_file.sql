-- =====================================================
-- RETAIL DATABASE SETUP SCRIPT
-- =====================================================

CREATE SCHEMA IF NOT EXISTS retail;

-- =====================================================
-- CUSTOMERS
-- =====================================================

CREATE TABLE retail.customers (
    customer_id INTEGER,
    customer_name VARCHAR,
    gender VARCHAR,
    city VARCHAR,
    state VARCHAR,
    registration_date DATE
);

INSERT INTO retail.customers VALUES
(1001,'Rahul Sharma','Male','Delhi','Delhi','2023-01-10'),
(1002,'Priya Verma','Female','Mumbai','Maharashtra','2023-02-15'),
(1003,'Amit Singh','Male','Bangalore','Karnataka','2023-03-20'),
(1004,'Sneha Gupta','Female','Chennai','Tamil Nadu','2023-04-12'),
(1005,'Rohit Mehta','Male','Pune','Maharashtra','2023-05-01'),
(1006,'Karan Malhotra','Male','Hyderabad','Telangana','2023-06-18'),
(1007,'Anjali Kapoor','Female','Kolkata','West Bengal','2023-07-25'),
(1008,'Vikas Jain','Male','Ahmedabad','Gujarat','2023-08-14'),
(1009,'Neha Agarwal','Female','Jaipur','Rajasthan','2023-09-05'),
(1010,'Arjun Verma','Male','Lucknow','Uttar Pradesh','2023-10-11');

-- =====================================================
-- PRODUCTS
-- =====================================================

CREATE TABLE retail.products (
    product_id INTEGER,
    product_name VARCHAR,
    category VARCHAR,
    brand VARCHAR,
    unit_price DECIMAL(10,2)
);

INSERT INTO retail.products VALUES
(101,'Laptop','Electronics','Dell',55000),
(102,'Mobile Phone','Electronics','Samsung',25000),
(103,'Television','Electronics','Sony',45000),
(104,'Washing Machine','Home Appliances','LG',30000),
(105,'Refrigerator','Home Appliances','Whirlpool',40000),
(106,'Air Conditioner','Home Appliances','Daikin',50000),
(107,'Headphones','Electronics','Boat',2500),
(108,'Microwave Oven','Home Appliances','IFB',15000),
(109,'Smart Watch','Electronics','Apple',35000),
(110,'Tablet','Electronics','Lenovo',28000);

-- =====================================================
-- STORES
-- =====================================================

CREATE TABLE retail.stores (
    store_id INTEGER,
    store_name VARCHAR,
    city VARCHAR,
    state VARCHAR
);

INSERT INTO retail.stores VALUES
(1,'Delhi Mega Store','Delhi','Delhi'),
(2,'Mumbai Central Store','Mumbai','Maharashtra'),
(3,'Bangalore Retail Hub','Bangalore','Karnataka'),
(4,'Chennai Super Store','Chennai','Tamil Nadu'),
(5,'Hyderabad City Store','Hyderabad','Telangana');

-- =====================================================
-- SALES FACT TABLE
-- =====================================================

CREATE TABLE retail.sales (
    sale_id BIGINT,
    sale_date DATE,
    customer_id INTEGER,
    product_id INTEGER,
    store_id INTEGER,
    quantity INTEGER,
    sales_amount DECIMAL(12,2)
);

INSERT INTO retail.sales VALUES
(1,'2025-01-01',1001,101,1,1,55000),
(2,'2025-01-02',1002,102,2,2,50000),
(3,'2025-01-02',1003,103,3,1,45000),
(4,'2025-01-03',1004,104,4,1,30000),
(5,'2025-01-03',1005,105,2,1,40000),
(6,'2025-01-04',1001,102,1,1,25000),
(7,'2025-01-05',1002,101,2,1,55000),
(8,'2025-01-05',1003,104,3,2,60000),
(9,'2025-01-06',1006,106,5,1,50000),
(10,'2025-01-06',1007,107,4,3,7500),
(11,'2025-01-07',1008,108,5,1,15000),
(12,'2025-01-08',1009,109,1,1,35000),
(13,'2025-01-08',1010,110,2,2,56000),
(14,'2025-01-09',1001,107,1,2,5000),
(15,'2025-01-10',1004,109,4,1,35000),
(16,'2025-01-10',1007,101,5,1,55000),
(17,'2025-01-11',1005,103,2,1,45000),
(18,'2025-01-12',1003,106,3,1,50000),
(19,'2025-01-12',1009,108,1,2,30000),
(20,'2025-01-13',1010,102,2,1,25000);

-- =====================================================
-- VERIFY OBJECTS
-- =====================================================

SELECT 'Customers' AS table_name, COUNT(*) AS record_count
FROM retail.customers

UNION ALL

SELECT 'Products', COUNT(*)
FROM retail.products

UNION ALL

SELECT 'Stores', COUNT(*)
FROM retail.stores

UNION ALL

SELECT 'Sales', COUNT(*)
FROM retail.sales;

-- =====================================================
-- SAMPLE ANALYTICS QUERIES
-- =====================================================

-- Total Revenue
SELECT SUM(sales_amount) AS total_revenue
FROM retail.sales;

-- Top Products
SELECT
    p.product_name,
    SUM(s.sales_amount) AS revenue
FROM retail.sales s
JOIN retail.products p
ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC;

-- Store Performance
SELECT
    st.store_name,
    SUM(s.sales_amount) AS revenue
FROM retail.sales s
JOIN retail.stores st
ON s.store_id = st.store_id
GROUP BY st.store_name
ORDER BY revenue DESC;

-- Customer Spend
SELECT
    c.customer_name,
    SUM(s.sales_amount) AS total_spend
FROM retail.sales s
JOIN retail.customers c
ON s.customer_id = c.customer_id
GROUP BY c.customer_name
ORDER BY total_spend DESC;
