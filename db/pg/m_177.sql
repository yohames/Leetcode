/*
Table: Employee

+-------------+------+
| Column Name | Type |
+-------------+------+
| id          | int  |
| salary      | int  |
+-------------+------+
id is the primary key (column with unique values) for this table.
Each row of this table contains information about the salary of an employee.
 

Write a solution to find the nth highest distinct salary from the Employee table. If there are less than n distinct salaries, return null.

The result format is in the following example.

 

Example 1:

Input: 
Employee table:
+----+--------+
| id | salary |
+----+--------+
| 1  | 100    |
| 2  | 200    |
| 3  | 300    |
+----+--------+
n = 2
Output: 
+------------------------+
| getNthHighestSalary(2) |
+------------------------+
| 200                    |
+------------------------+
Example 2:

Input: 
Employee table:
+----+--------+
| id | salary |
+----+--------+
| 1  | 100    |
+----+--------+
n = 2
Output: 
+------------------------+
| getNthHighestSalary(2) |
+------------------------+
| null                   |
+------------------------+
*/

-- Create table If Not Exists Employee (Id int, Salary int)
-- Truncate table Employee
-- insert into Employee (id, salary) values ('4', '100')
-- insert into Employee (id, salary) values ('2', '200')
-- insert into Employee (id, salary) values ('3', '300')


CREATE OR REPLACE FUNCTION NthHighestSalary(N INT) 
RETURNS TABLE (salary INT) 
AS $$
BEGIN
    RETURN QUERY
    SELECT (SELECT DISTINCT e.salary
    FROM Employee AS e
    ORDER BY e.salary DESC
    
    -- If N is invalid, LIMIT is 0 (returns empty set).
    LIMIT CASE 
            WHEN N IS NULL OR N < 1 THEN 0 
            ELSE 1
          END
          
    OFFSET GREATEST(COALESCE(N, 1) - 1, 0)); 
END;
$$ LANGUAGE plpgsql;


SELECT NthHighestSalary(-1);
