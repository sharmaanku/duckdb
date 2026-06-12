------------------------------------------------
-- CPU BOTTLENECK DEMO
------------------------------------------------

DROP TABLE IF EXISTS cpu_demo;

CREATE TABLE cpu_demo AS
SELECT
    i AS id,
    RANDOM()*1000 AS amount
FROM range(5000000) t(i);

EXPLAIN ANALYZE
SELECT
    SUM(SQRT(amount) * LOG(amount+1))
FROM cpu_demo;
