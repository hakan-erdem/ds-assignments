

--DAwSQL Session -8 

--E-Commerce Project Solution



--1. Join all the tables and create a new table called combined_table. (market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)


select a.*, e.Order_ID,
b.Customer_Name, b.Customer_Segment, b.Province, b.Region,
c.Order_Date, c.Order_Priority,
d.Product_Category, d.Product_Sub_Category,
e.Ship_Date, e.Ship_Mode into combined_table
from market_fact a, cust_dimen b, orders_dimen c, prod_dimen d, shipping_dimen e
where a.Cust_id = b.Cust_id
and a.Ord_id = c.Ord_id
and a.Prod_id = d.Prod_id
and a.Ship_id = e.Ship_id



--///////////////////////


--2. Find the top 3 customers who have the maximum count of orders.

select top 3 Cust_id ,Customer_Name, COUNT(Order_ID) as order_counts
from combined_table
group by  Cust_id ,Customer_Name
order by 3 desc



--/////////////////////////////////



--3.Create a new column at combined_table as DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.
--Use "ALTER TABLE", "UPDATE" etc.

alter table combined_table
add DaysTakenForDelivery int;

update combined_table
set DaysTakenForDelivery = DATEDIFF(day, Order_Date, Ship_Date)

select Order_Date, Ship_Date, DaysTakenForDelivery
from combined_table



--////////////////////////////////////


--4. Find the customer whose order took the maximum time to get delivered.
--Use "MAX" or "TOP"

select top 1 Cust_id, Customer_Name, DaysTakenForDelivery day_to_deliver
from combined_table
order by DaysTakenForDelivery desc



--////////////////////////////////



--5. Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011
--You can use such date functions and subqueries

select count(distinct Cust_id) as num_of_customers
from combined_table
where year(Order_Date) = 2011
and MONTH(Order_Date) = 1

-- ****** --

select month(order_date), count(distinct cust_id) monthly_num_of_cust
from combined_table a
where exists
(
select Cust_id
from combined_table b
where year(Order_Date) = 2011
and MONTH(Order_Date) = 1
and a.Cust_id = b.Cust_id
)
and year(Order_Date) = 2011
group by month(order_date)




--////////////////////////////////////////////


--6. write a query to return for each user the time elapsed between the first purchasing and the third purchasing, 
--in ascending order by Customer ID
--Use "MIN" with Window Functions


SELECT DISTINCT
		cust_id,
		order_date,
		dense_number,
		FIRST_ORDER_DATE,
		DATEDIFF(day, FIRST_ORDER_DATE, order_date) DAYS_ELAPSED
FROM	
		(
		SELECT	Cust_id, ord_id, order_DATE,
				MIN (Order_Date) OVER (PARTITION BY cust_id) FIRST_ORDER_DATE,
				DENSE_RANK () OVER (PARTITION BY cust_id ORDER BY Order_date) dense_number
		FROM	combined_table
		) A
WHERE	dense_number = 3


--//////////////////////////////////////

--7. Write a query that returns customers who purchased both product 11 and product 14, 
--as well as the ratio of these products to the total number of products purchased by the customer.
--Use CASE Expression, CTE, CAST AND such Aggregate Functions

with table_1 as
(
select cust_id,
sum(case when Prod_id = 'Prod_11' then Order_Quantity else 0 end) p_11,
sum(case when Prod_id = 'Prod_14' then Order_Quantity else 0 end) p_14,
sum(convert(int, Order_Quantity)) total_order
from combined_table
group by Cust_id
having sum(case when Prod_id = 'Prod_11' then Order_Quantity else 0 end) >= 1
and sum(case when Prod_id = 'Prod_14' then Order_Quantity else 0 end) >= 1
)
SELECT	Cust_id, p_11, p_14, total_order,
		CAST (1.0*p_11/total_order AS NUMERIC (3,2)) AS RATIO_P11,
		CAST (1.0*p_14/total_order AS NUMERIC (3,2)) AS RATIO_P14
FROM table_1



--/////////////////



--CUSTOMER RETENTION ANALYSIS



--1. Create a view that keeps visit logs of customers on a monthly basis. (For each log, three field is kept: Cust_id, Year, Month)
--Use such date functions. Don't forget to call up columns you might need later.

create view monthly_cust_logs as
select Cust_id, YEAR(Order_Date) year, MONTH(Order_Date) month
from combined_table



--//////////////////////////////////


--2. Create a view that keeps the number of monthly visits by users. (Separately for all months from the business beginning)
--Don't forget to call up columns you might need later.

create view num_of_visits_monthly as
select Cust_id, YEAR(Order_Date) year, MONTH(Order_Date) month, count(Cust_id) customer_visits
from combined_table
group by Cust_id, YEAR(Order_Date), MONTH(Order_Date)



--//////////////////////////////////


--3. For each visit of customers, create the next month of the visit as a separate column.
--You can number the months with "DENSE_RANK" function.
--then create a new column for each month showing the next month using the numbering you have made. (use "LEAD" function.)
--Don't forget to call up columns you might need later.


create view next_visit as
select *,
lead(a.current_month, 1) over(partition by a.cust_id order by a.current_month) next_visit_month
from
(
select *,
DENSE_RANK() over(order by year, month) current_month
from num_of_visits_monthly
) a



--/////////////////////////////////



--4. Calculate the monthly time gap between two consecutive visits by each customer.
--Don't forget to call up columns you might need later.

create view time_gaps as
select *, next_visit_month - current_month time_gap
from next_visit




--/////////////////////////////////////////


--5.Categorise customers using average time gaps. Choose the most fitted labeling model for you.
--  For example: 
--	Labeled as churn if the customer hasn't made another purchase in the months since they made their first purchase.
--	Labeled as regular if the customer has made a purchase every month.
--  Etc.


select Cust_id, avg(time_gap) avg_time_gap,
case 
	when avg(time_gap) = 1 then 'retained'
	when avg(time_gap) > 1 then 'irregular'
	when avg(time_gap) is NULL then 'churn'
	else 'unknown'
end cust_label
from time_gaps
group by cust_id



--/////////////////////////////////////




--MONTH-WÝSE RETENTÝON RATE


--Find month-by-month customer retention rate  since the start of the business.


--1. Find the number of customers retained month-wise. (You can use time gaps)
--Use Time Gaps


select distinct Cust_id, year, month, current_month, next_visit_month, time_gap,
		count(Cust_id) over (partition by next_visit_month) retetion_month_wise
from time_gaps
where time_gap = 1
order by Cust_id, next_visit_month


--//////////////////////


--2. Calculate the month-wise retention rate.

--Basic formula: o	Month-Wise Retention Rate = 1.0 * Number of Customers Retained in The Next Nonth / Total Number of Customers in The Previous Month

--It is easier to divide the operations into parts rather than in a single ad-hoc query. It is recommended to use View. 
--You can also use CTE or Subquery if you want.

--You should pay attention to the join type and join columns between your views or tables.

create view current_num_of_cust as
select distinct Cust_id, year, month, current_month,
		count(Cust_id) over (partition by current_month) retetion_month_wise
from time_gaps


--- hocanin cozumu 

CREATE VIEW CURRENT_NUM_OF_CUST AS
SELECT	DISTINCT cust_id, [YEAR],
		[MONTH],
		CURRENT_MONTH,
		COUNT (cust_id)	OVER (PARTITION BY CURRENT_MONTH) RETENTITON_MONTH_WISE
FROM	time_gaps
SELECT *
FROM	CURRENT_NUM_OF_CUST
---
DROP VIEW NEXT_NUM_OF_CUST
CREATE VIEW NEXT_NUM_OF_CUST AS
SELECT	DISTINCT cust_id, [YEAR],
		[MONTH],
		CURRENT_MONTH,
		NEXT_VISIT_MONTH,
		COUNT (cust_id)	OVER (PARTITION BY NEXT_VISIT_MONTH) RETENTITON_MONTH_WISE
FROM	time_gaps
WHERE	time_gaps = 1
AND		CURRENT_MONTH > 1
SELECT DISTINCT
		B.[YEAR],
		B.[MONTH],
		B.CURRENT_MONTH,
		B.NEXT_VISIT_MONTH,
		1.0 * B.RETENTITON_MONTH_WISE / A.RETENTITON_MONTH_WISE RETENTION_RATE
FROM	CURRENT_NUM_OF_CUST A LEFT JOIN NEXT_NUM_OF_CUST B
ON		A.CURRENT_MONTH + 1 = B.NEXT_VISIT_MONTH

select *
from current_num_of_cust

---






---///////////////////////////////////
--Good luck!