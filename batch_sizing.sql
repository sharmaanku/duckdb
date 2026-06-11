-- Create sample table

CREATE TABLE sales AS
SELECT
    i AS sale_id,
    RANDOM() * 1000 AS amount
FROM range(1000000) t(i);

-- Enable profiling
PRAGMA enable_profiling;

-- Query 1: Scan and aggregate 1 million rows
SELECT
    COUNT(*),
    SUM(amount),
    AVG(amount)
FROM sales;

-- Query 2: Apply filter and aggregation
SELECT
    COUNT(*),
    SUM(amount)
FROM sales
WHERE amount > 500;

-- View execution plan
EXPLAIN ANALYZE
SELECT
    COUNT(*),
    SUM(amount)
FROM sales
WHERE amount > 500;
