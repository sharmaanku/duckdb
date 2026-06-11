CREATE OR REPLACE TABLE employee_data AS
SELECT
    i AS employee_id,
    'Employee_' || i AS employee_name,
    CASE
        WHEN i % 3 = 0 THEN 'IT'
        WHEN i % 3 = 1 THEN 'HR'
        ELSE 'Finance'
    END AS department,
    30000 + (i % 50000) AS salary,
    DATE '2024-01-01' + (i % 365) AS joining_date,
    'Address_' || i AS address,
    'City_' || (i % 100) AS city,
    'Country_' || (i % 10) AS country
FROM range(1000000) t(i);
