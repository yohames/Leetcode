/*
Table: Logs

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| id          | int     |
| num         | varchar |
+-------------+---------+
In SQL, id is the primary key for this table.
id is an autoincrement column starting from 1.
 

Find all numbers that appear at least three times consecutively.

Return the result table in any order.

The result format is in the following example.

 

Example 1:

Input: 
Logs table:
+----+-----+
| id | num |
+----+-----+
| 1  | 1   |
| 2  | 1   |
| 3  | 1   |
| 4  | 2   |
| 5  | 1   |
| 6  | 2   |
| 7  | 2   |
+----+-----+
Output: 
+-----------------+
| ConsecutiveNums |
+-----------------+
| 1               |
+-----------------+
Explanation: 1 is the only number that appears consecutively for at least three times.
*/

-- Create table If Not Exists Logs (id int, num int)
-- Truncate table Logs
-- 
-- insert into Logs (id, num) values ('1', '1'),
-- ('2', '1'),
-- ('3', '1'),
-- ('4', '2'),
-- ('5', '1'),
-- ('6', '2'),
-- ('7', '2')
-- 


select num as ConsecutiveNums from
(
select
num,
LEAD(num, 1) OVER (ORDER BY id) AS num_2,
LEAD(num, 2) OVER(ORDER BY id ) AS num_3
from Logs) as consequetive_nums
where num = num_2 and num = num_3;