create database Sales_Delivery;

select * from cust_dimen;
select* from market_fact;

#Q1: Find the top 3 customers who have the maximum number of orders

SELECT m.cust_id,c.Customer_Name,count(m.Order_Quantity)max_number
from cust_dimen c
JOIN
market_fact m ON m.Cust_id = c.Cust_id
GROUP BY c.cust_id,Ord_id,c.Customer_Name
order by max_number desc
limit 3;

#Q2: Create a new column DaysTakenForDelivery that contains the date difference between Order_Date and Ship_Date.

ALTER TABLE Orders_Dimen
ADD DaysTakenForDelivery INT;

UPDATE orders_dimen od
JOIN shipping_dimen sd ON od.Order_ID = sd.Order_ID
SET od.DaysTakenForDelivery = DATEDIFF(STR_TO_DATE(sd.Ship_Date, '%d-%m-%Y'), STR_TO_DATE(od.Order_Date, '%d-%m-%Y'));
select * from orders_dimen;

#Question 3: Find the customer whose order took the maximum time to get delivered.

SELECT m.cust_id,c.Customer_Name,max(DaysTakenForDelivery) AS max_delivery_time 
FROM market_fact m
join 
orders_dimen o
on m.Ord_id=o.Ord_id
join
shipping_dimen s 
on s.Ship_id=m.Ship_id
join cust_dimen c
on c.cust_id=m.Cust_id
GROUP BY m.cust_id,c.Customer_Name
ORDER BY max_delivery_time DESC
LIMIT 1;


#Question 4: Retrieve total sales made by each product from the data (use Windows function)

SELECT p.Prod_id, SUM(Sales) OVER (PARTITION BY Prod_id ) AS TotalSales
FROM Market_Fact m
JOIN Prod_Dimen p ON M.Prod_id = P.Prod_id
order by totalsales desc; 

#Question 5: Retrieve the total profit made from each product from the data (use windows function)
  
SELECT p.Prod_id, Product_Category, SUM(Profit) OVER (PARTITION BY Prod_id)AS TotalProfit
FROM Market_Fact m
JOIN Prod_Dimen p ON M.Prod_id = P.Prod_id
order by totalprofit desc;

#Question 6: Count the total number of unique customers in January and how many of 
#them came back every month over the entire year in 2011

WITH JanuaryCustomers AS 
(SELECT DISTINCT c.Cust_id
  FROM market_fact m
  JOIN cust_dimen c ON c.Cust_id = m.Cust_id
  JOIN orders_dimen o ON o.Ord_id = m.Ord_id
  WHERE YEAR(STR_TO_DATE(o.Order_Date, '%d-%m-%Y')) = 2011
  AND MONTH(STR_TO_DATE(o.Order_Date, '%d-%m-%Y')) = 1
),

ReturningCustomers AS 
(SELECT m.Cust_id,o.Order_ID
FROM orders_dimen o
JOIN market_fact m ON m.Ord_id = o.Ord_id
WHERE YEAR(STR_TO_DATE(o.Order_Date, '%d-%m-%Y')) = 2011
GROUP BY m.Cust_id,o.Order_ID
HAVING COUNT(distinct MONTH(STR_TO_DATE(o.Order_Date, '%d-%m-%Y')))= 12
)

SELECT COUNT(*) AS UniqueCustomersInJanuary, COUNT(ReturningCustomers.Cust_id) AS ReturningCustomersIn2011
FROM JanuaryCustomers
left JOIN ReturningCustomers ON JanuaryCustomers.cust_id = ReturningCustomers.cust_id;



---------------------------------------------------------------------------------------------------------------------------

