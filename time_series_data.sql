--------------------------------------------------------
-- TIME SERIES ANALYTICS
--------------------------------------------------------

CREATE TABLE sales_time_series AS
SELECT
    DATE '2025-01-01' + CAST(i AS INTEGER) AS sales_date,
    ROUND(RANDOM()*1000,2) AS sales_amount
FROM range(30) t(i);

--------------------------------------------------------
-- View Data
--------------------------------------------------------

SELECT *
FROM sales_time_series
ORDER BY sales_date;

--------------------------------------------------------
-- Daily Sales
--------------------------------------------------------

SELECT
    sales_date,
    sales_amount
FROM sales_time_series
ORDER BY sales_date;

--------------------------------------------------------
-- Running Total
--------------------------------------------------------

SELECT
    sales_date,
    sales_amount,
    SUM(sales_amount)
    OVER(
        ORDER BY sales_date
    ) AS running_total
FROM sales_time_series;

--------------------------------------------------------
-- 3-Day Moving Average
--------------------------------------------------------

SELECT
    sales_date,
    sales_amount,
    AVG(sales_amount)
    OVER(
        ORDER BY sales_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_average
FROM sales_time_series;

--------------------------------------------------------
-- Highest Sale Day
--------------------------------------------------------

SELECT *
FROM sales_time_series
ORDER BY sales_amount DESC
LIMIT 1;

--------------------------------------------------------
-- Monthly Aggregation
--------------------------------------------------------

SELECT
    strftime(sales_date,'%Y-%m') AS month,
    SUM(sales_amount) AS total_sales
FROM sales_time_series
GROUP BY month;
