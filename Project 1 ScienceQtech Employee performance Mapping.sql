-- Project 1 ScienceQtech Employee performance Mapping

#1. Create a database named employee, then import data_science_team.csv proj_table.csv and emp_record_table.csv into the employee database from the given resources.

 CREATE database employees;
 
 USE employees;
 
 desc data_science_team;
 
 Alter table data_science_team
 rename column ï»¿EMP_ID
 to emp_id;

desc emp_record_table;
SELECT *
FROM EMP_RECORD_TABLE;

DROP TABLE EMP_RECORD_TABLE;

Alter table emp_record_table
 rename column ï»¿EMP_ID
 to EMP_ID;
 
 desc proj_table;
 
 Alter table proj_table
 rename column ï»¿PROJ_ID
 to PROJ_ID;
 
 SELECT *
 FROM EMP_RECORD_TABLE;
 
 #2. Create an ER diagram for the given employee database.


#3. Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, and DEPARTMENT from the employee record table, and make a list of employees and details of their department.

 SELECT emp_id, FIRST_NAME, LAST_NAME, GENDER, DEPT
 FROM emp_record_table
 ORDER BY DEPT;

/*4. Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPARTMENT, and EMP_RATING if the EMP_RATING is: 
less than two
greater than four 
between two and four*/

# Emp_Rating is Less than 2
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT,EMP_RATING
FROM emp_record_table
WHERE EMP_RATING <2
ORDER BY DEPT, EMP_RATING DESC;

# Emp_Rating is greater than 4
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT,EMP_RATING
FROM emp_record_table
WHERE EMP_RATING >4
ORDER BY DEPT, EMP_RATING DESC;

# Emp_Rating is between 2 and 4
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT,EMP_RATING
FROM emp_record_table
WHERE  EMP_RATING BETWEEN 2 AND 4
ORDER BY DEPT, EMP_RATING DESC;

#5. Write a query to concatenate the FIRST_NAME and the LAST_NAME of employees in the Finance department from the employee table and then give the resultant column alias as NAME.

 SELECT concat(FIRST_NAME, " ", LAST_NAME) AS NAME
 FROM emp_record_table
 WHERE DEPT = 'FINANCE';

#6. Write a query to list only those employees who have someone reporting to them. Also, show the number of reporters (including the President).

--- correct option # 1
SELECT 
mang.emp_id,
    mang.first_name,
    mang.last_name,
    count(rep.emp_id) AS number_of_employees
FROM emp_record_table rep
JOIN emp_record_table mang
ON rep.manager_id = mang.emp_id
GROUP BY mang.emp_id, mang.first_name, mang.last_name
order by number_of_employees desc;

-- Correct Option #2
SELECT
    mgr.emp_id,
    mgr.first_name,
    mgr.last_name,
    mgr.role,
    rep.emp_count
FROM
    emp_record_table mgr,
    (
        SELECT
            manager_id,
            COUNT(*) emp_count
        FROM
            emp_record_table
        GROUP BY
            manager_id
    ) rep
WHERE
    mgr.emp_id = rep.manager_id
    order by emp_count desc;

#7. Write a query to list down all the employees from the healthcare and finance departments using union. Take data from the employee record table.

SELECT *
FROM emp_record_table
WHERE dept = 'healthcare'
UNION
SELECT *
FROM emp_record_table
WHERE dept = 'finance';
 

#8. Write a query to list down employee details such as EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPARTMENT, and EMP_RATING grouped by dept. 
# Also include the respective employee rating along with the max emp rating for the department.

SELECT EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT, EMP_RATING, max(emp_rating) over (partition by dept) AS max_salary_by_dept
FROM emp_record_table;
 
#9. Write a query to calculate the minimum and the maximum salary of the employees in each role. Take data from the employee record table.

 SELECT emp_id, first_name, last_name, role, salary, min(salary) over (partition by role) AS min_salary_by_role, max(salary) over (partition by role) AS max_salary_by_role
 FROM emp_record_table;

#10. Write a query to assign ranks to each employee based on their experience. Take data from the employee record table.

SELECT *, rank() over (order by exp DESC) AS EMP_RANK
FROM emp_record_table;

#11. Write a query to create a view that displays employees in various countries whose salary is more than six thousand. Take data from the employee record table.

CREATE VIEW emp_countries AS
SELECT emp_id, first_name, LAST_NAME, Country
FROM emp_record_table
WHERE salary > 6000
ORDER BY COUNTRY ASC;

SELECT *
FROM emp_countries;

#12. Write a nested query to find employees with experience of more than ten years. Take data from the employee record table.

SELECT emp_id, first_name, last_name, exp, role, dept, country
FROM (SELECT * FROM emp_record_table WHERE exp >10  ORDER BY exp DESC) AS exp_more_than_10;

#13. Write a query to create a stored procedure to retrieve the details of the employees whose experience is more than three years. Take data from the employee record table.

DELIMITER &&
CREATE PROCEDURE emp_exp_over_3yrs()
BEGIN
SELECT *
FROM emp_record_table
WHERE EXP > 3;
END &&

CALL emp_exp_over_3yrs();


/*14. Write a query using stored functions in the project table to check whether the job profile assigned to each employee in the data science team matches the organization’s set standard.

 The standard being:
For an employee with experience less than or equal to 2 years assign 'JUNIOR DATA SCIENTIST',
For an employee with the experience of 2 to 5 years assign 'ASSOCIATE DATA SCIENTIST',
For an employee with the experience of 5 to 10 years assign 'SENIOR DATA SCIENTIST',
For an employee with the experience of 10 to 12 years assign 'LEAD DATA SCIENTIST',
For an employee with the experience of 12 to 16 years assign 'MANAGER'.
*/
 
DELIMITER $$
CREATE FUNCTION emp_job_profile(experience INT) 
RETURNS VARCHAR(40) DETERMINISTIC
BEGIN
    DECLARE job_profile VARCHAR(40);

    IF experience <= 2 THEN
        SET job_profile = 'JUNIOR DATA SCIENTIST';
    ELSEIF experience > 2 AND experience <= 5 THEN
        SET job_profile = 'ASSOCIATE DATA SCIENTIST';
    ELSEIF experience > 5 AND experience <= 10 THEN
        SET job_profile = 'SENIOR DATA SCIENTIST';
    ELSEIF experience > 10 AND experience <= 12 THEN
        SET job_profile = 'LEAD DATA SCIENTIST';
    ELSEIF experience > 12 AND experience <= 16 THEN
        SET job_profile = 'MANAGER';
    ELSE
        SET job_profile = 'UNKNOWN';
    END IF;

    RETURN job_profile;
END $$
DELIMITER ;


SELECT exp, role, emp_job_profile(exp)
FROM data_science_team
ORDER BY exp;

#15. Create an index to improve the cost and performance of the query to find the employee whose FIRST_NAME is ‘Eric’ in the employee table after checking the execution plan.
 
CREATE Index first_name_idx
 ON emp_record_table(FIRST_NAME(100));
 
SHOW indexes FROM emp_record_table;

Alter table emp_record_table
drop index first_name_idx;

explain format = json
SELECT *
FROM emp_record_table
WHERE first_name = 'Eric';

#16. Write a query to calculate the bonus for all the employees, based on their ratings and salaries (Use the formula: 5% of salary * employee rating).

 SELECT *, (0.05*salary*emp_rating) AS Bonus
 FROM emp_record_table 
 ORDER BY Bonus DESC;
 
#17. Write a query to calculate the average salary distribution based on the continent and country. Take data from the employee record table.

SELECT *, avg(salary) over (partition by continent, country) AS Avg_salary_by_continent_country
FROM emp_record_table
ORDER BY continent, country;