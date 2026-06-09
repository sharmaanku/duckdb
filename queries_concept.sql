Subquery



SELECT *

FROM employees

WHERE salary >

(

  SELECT AVG(salary)

  FROM employees

);





View:



CREATE VIEW high_salary_employees AS

SELECT *

FROM employees

WHERE salary > 60000;





CTE:

CREATE TABLE employees (

  emp_id INTEGER,

  emp_name VARCHAR,

  department VARCHAR,

  salary DOUBLE

);



INSERT INTO employees VALUES

(1,'John','IT',50000),

(2,'Mary','IT',70000),

(3,'David','HR',40000),

(4,'Lisa','HR',60000),

(5,'Robert','Finance',80000);



WITH high_salary_employees AS

(

  SELECT *

  FROM employees

  WHERE salary > 60000

)

SELECT *

FROM high_salary_employees;



WITH dept_salary AS

(

  SELECT

    department,

    AVG(salary) AS avg_salary

  FROM employees

  GROUP BY department

)

SELECT *

FROM dept_salary;



EXPLAIN

WITH high_salary_employees AS

(

  SELECT *

  FROM employees

  WHERE salary > 60000

)

SELECT *

FROM high_salary_employees;
