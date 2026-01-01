/*
Table: Orders

+-----------------+----------+
| Column Name     | Type     |
+-----------------+----------+
| order_number    | int      |
| customer_number | int      |
+-----------------+----------+
order_number is the primary key (column with unique values) for this table.
This table contains information about the order ID and the customer ID.
 

Write a solution to find the customer_number for the customer who has placed the largest number of orders.

The test cases are generated so that exactly one customer will have placed more orders than any other customer.

The result format is in the following example.

 

Example 1:

Input: 
Orders table:
+--------------+-----------------+
| order_number | customer_number |
+--------------+-----------------+
| 1            | 1               |
| 2            | 2               |
| 3            | 3               |
| 4            | 3               |
+--------------+-----------------+
Output: 
+-----------------+
| customer_number |
+-----------------+
| 3               |
+-----------------+
Explanation: 
The customer with number 3 has two orders, which is greater than either customer 1 or 2 because each of them only has one order. 
So the result is customer_number 3.
 

Follow up: What if more than one customer has the largest number of orders, can you find all the customer_number in this case?
*/
-- Table Schema
-- Create table If Not Exists orders (order_number int, customer_number int)
-- Truncate table orders
insert into orders (order_number, customer_number) values ('1', '1')
,('2', '2')
,('3', '3')
,('4', '3')

select customer_number from
(select max(count(customer_number) over(partition by customer_number)) from orders) as cnt;


insert into orders (order_number, customer_number) values(3 , 5),
(5 , 1),
(6 , 5),
(7 , 4),
(8 , 6),
(9 , 2),
(10, 4),
(11,16),
(12, 3),
(13, 5),
(14, 3),
(15,16)


select *, rank() over (order by max_customer desc)  from (select customer_number, count(order_number) as max_customer 
from orders
group by customer_number) as max_seller



select customer_number, max(count(order_number)) from orders group by customer_number;

select customer_number from (select customer_number, RANK() OVER (ORDER BY COUNT(order_number) DESC) as rnk
from orders
GROUP BY customer_number) as top_customer
where rnk = 1