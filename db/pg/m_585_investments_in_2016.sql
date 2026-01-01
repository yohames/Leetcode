/*
Table: Insurance

+-------------+-------+
| Column Name | Type  |
+-------------+-------+
| pid         | int   |
| tiv_2015    | float |
| tiv_2016    | float |
| lat         | float |
| lon         | float |
+-------------+-------+
pid is the primary key (column with unique values) for this table.
Each row of this table contains information about one policy where:
pid is the policyholder's policy ID.
tiv_2015 is the total investment value in 2015 and tiv_2016 is the total investment value in 2016.
lat is the latitude of the policy holder's city. It's guaranteed that lat is not NULL.
lon is the longitude of the policy holder's city. It's guaranteed that lon is not NULL.
 

Write a solution to report the sum of all total investment values in 2016 tiv_2016, for all policyholders who:

have the same tiv_2015 value as one or more other policyholders, and
are not located in the same city as any other policyholder (i.e., the (lat, lon) attribute pairs must be unique).
Round tiv_2016 to two decimal places.

The result format is in the following example.

 

Example 1:

Input: 
Insurance table:
+-----+----------+----------+-----+-----+
| pid | tiv_2015 | tiv_2016 | lat | lon |
+-----+----------+----------+-----+-----+
| 1   | 10       | 5        | 10  | 10  |
| 2   | 20       | 20       | 20  | 20  |
| 3   | 10       | 30       | 20  | 20  |
| 4   | 10       | 40       | 40  | 40  |
+-----+----------+----------+-----+-----+
Output: 
+----------+
| tiv_2016 |
+----------+
| 45.00    |
+----------+
Explanation: 
The first record in the table, like the last record, meets both of the two criteria.
The tiv_2015 value 10 is the same as the third and fourth records, and its location is unique.

The second record does not meet any of the two criteria. Its tiv_2015 is not like any other policyholders and its location is the same as the third record, which makes the third record fail, too.
So, the result is the sum of tiv_2016 of the first and last record, which is 45.
 */
-- Table Schema
-- Create Table If Not Exists Insurance (pid int, tiv_2015 float, tiv_2016 float, lat float, lon float)
-- Truncate table Insurance
-- insert into Insurance (pid, tiv_2015, tiv_2016, lat, lon) values ('1', '10', '5', '10', '10')
-- ,('2', '20', '20', '20', '20')
-- ,('3', '10', '30', '20', '20')
-- ,('4', '10', '40', '40', '40')
-- Second testcase
-- INSERT INTO Insurance (pid, tiv_2015, tiv_2016, lat, lon) VALUES
-- (1, 224.17, 952.73, 32.4, 20.2),
-- (2, 224.17, 900.66, 52.4, 32.7),
-- (3, 824.61, 645.13, 72.4, 45.2),
-- (4, 424.32, 323.66, 12.4, 7.7),
-- (5, 424.32, 282.9, 12.4, 7.7),
-- (6, 625.05, 243.53, 52.5, 32.8),
-- (7, 424.32, 968.94, 72.5, 45.3),
-- (8, 624.46, 714.13, 12.5, 7.8),
-- (9, 425.49, 463.85, 32.5, 20.3),
-- (10, 624.46, 776.85, 12.4, 7.7),
-- (11, 624.46, 692.71, 72.5, 45.3),
-- (12, 225.93, 933, 12.5, 7.8),
-- (13, 824.61, 786.86, 32.6, 20.3),
-- (14, 824.61, 935.34, 52.6, 32.8);
-- select DISTINCT concat(lat, ',', lon)  from Insurance;


WITH dup AS (
    SELECT
        *,
        count(concat(lat, ',', lon)) OVER (PARTITION BY concat(lat, ',', lon)) AS loc_count,
        count(tiv_2015) OVER (PARTITION BY tiv_2015) as tiv_count
    FROM
        insurance
)
SELECT
    sum(tiv_2016) as tiv_2016
FROM
    dup
WHERE
    loc_count < 2 and
    tiv_count > 1;

