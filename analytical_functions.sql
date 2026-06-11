--------------------------------------------------------
-- ADVANCED ANALYTICAL SQL CAPABILITIES IN DUCKDB
--------------------------------------------------------

--------------------------------------------------------
-- Cleanup
--------------------------------------------------------
DROP TABLE IF EXISTS sales;

--------------------------------------------------------
-- Create Sample Sales Table
--------------------------------------------------------
CREATE TABLE sales (
    sale_id INTEGER,
    sale_date DATE,
    region VARCHAR,
    salesperson VARCHAR,
    amount DOUBLE
);

--------------------------------------------------------
-- Insert Sample Data
--------------------------------------------------------
INSERT INTO sales VALUES
(1,'2025-01-01','North','John',1000),
(2,'2025-01-02','North','John',1500),
(3,'2025-01-03','North','John',1800),
(4,'2025-01-04','North','John',1200),

(5,'2025-01-01','North','Mary',1400),
(6,'2025-01-02','North','Mary',1700),
(7,'2025-01-03','North','Mary',2200),
(8,'2025-01-04','North','Mary',2000),

(9,'2025-01-01','South','David',900),
(10,'2025-01-02','South','David',1300),
(11,'2025-01-03','South','David',1600),
(12,'2025-01-04','South','David',1900),

(13,'2025-01-01','South','Lisa',1100),
(14,'2025-01-02','South','Lisa',1400),
(15,'2025-01-03','South','Lisa',1800),
(16,'2025-01-04','South','Lisa',2100);

--------------------------------------------------------
-- View Data
--------------------------------------------------------
SELECT * FROM sales
ORDER BY region, salesperson, sale_date;

--------------------------------------------------------
-- 1. Running Total
--------------------------------------------------------
SELECT
    salesperson,
    sale_date,
    amount,
    SUM(amount) OVER(
        PARTITION BY salesperson
        ORDER BY sale_date
    ) AS running_total
FROM sales
ORDER BY salesperson, sale_date;

--------------------------------------------------------
-- 2. Row Number
--------------------------------------------------------
SELECT
    salesperson,
    sale_date,
    amount,
    ROW_NUMBER() OVER(
        PARTITION BY salesperson
        ORDER BY amount DESC
    ) AS row_num
FROM sales
ORDER BY salesperson;

--------------------------------------------------------
-- 3. Rank
--------------------------------------------------------
SELECT
    salesperson,
    sale_date,
    amount,
    RANK() OVER(
        PARTITION BY salesperson
        ORDER BY amount DESC
    ) AS sales_rank
FROM sales
ORDER BY salesperson;

--------------------------------------------------------
-- 4. Dense Rank
--------------------------------------------------------
SELECT
    salesperson,
    sale_date,
    amount,
    DENSE_RANK() OVER(
        PARTITION BY salesperson
        ORDER BY amount DESC
    ) AS dense_rank
FROM sales
ORDER BY salesperson;

--------------------------------------------------------
-- 5. Moving Average (3-Day Window)
--------------------------------------------------------
SELECT
    salesperson,
    sale_date,
    amount,
    AVG(amount) OVER(
        PARTITION BY salesperson
        ORDER BY sale_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg
FROM sales
ORDER BY salesperson, sale_date;

--------------------------------------------------------
-- 6. Previous Day Sales (LAG)
--------------------------------------------------------
SELECT
    salesperson,
    sale_date,
    amount,
    LAG(amount,1) OVER(
        PARTITION BY salesperson
        ORDER BY sale_date
    ) AS previous_sale
FROM sales
ORDER BY salesperson, sale_date;

--------------------------------------------------------
-- 7. Next Day Sales (LEAD)
--------------------------------------------------------
SELECT
    salesperson,
    sale_date,
    amount,
    LEAD(amount,1) OVER(
        PARTITION BY salesperson
        ORDER BY sale_date
    ) AS next_sale
FROM sales
ORDER BY salesperson, sale_date;

--------------------------------------------------------
-- 8. Day-over-Day Growth
--------------------------------------------------------
SELECT
    salesperson,
    sale_date,
    amount,
    amount -
    LAG(amount) OVER(
        PARTITION BY salesperson
        ORDER BY sale_date
    ) AS growth
FROM sales
ORDER BY salesperson, sale_date;

--------------------------------------------------------
-- 9. Percentile Analysis
--------------------------------------------------------
SELECT
    region,
    quantile_cont(amount,0.25) AS p25,
    quantile_cont(amount,0.50) AS median,
    quantile_cont(amount,0.75) AS p75
FROM sales
GROUP BY region;

--------------------------------------------------------
-- 10. Top Performer Per Region
--------------------------------------------------------
WITH regional_sales AS
(
    SELECT
        region,
        salesperson,
        SUM(amount) AS total_sales
    FROM sales
    GROUP BY region, salesperson
)
SELECT *
FROM
(
    SELECT
        *,
        ROW_NUMBER() OVER(
            PARTITION BY region
            ORDER BY total_sales DESC
        ) AS rn
    FROM regional_sales
)
WHERE rn = 1;

--------------------------------------------------------
-- 11. Sales Contribution Percentage
--------------------------------------------------------
SELECT
    salesperson,
    SUM(amount) AS total_sales,
    ROUND(
        100.0 * SUM(amount)
        / SUM(SUM(amount)) OVER(),
        2
    ) AS contribution_percent
FROM sales
GROUP BY salesperson
ORDER BY contribution_percent DESC;

--------------------------------------------------------
-- 12. Region-wise Analytics Dashboard
--------------------------------------------------------
SELECT
    region,
    COUNT(*) AS transactions,
    SUM(amount) AS total_sales,
    AVG(amount) AS avg_sales,
    MIN(amount) AS min_sale,
    MAX(amount) AS max_sale
FROM sales
GROUP BY region
ORDER BY total_sales DESC;
