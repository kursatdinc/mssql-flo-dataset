/*
FLO OBJECTIVES
*/

--QUESTION 1 Create a database named Customers and a table named FLO that will contain the variables in the given data set.
CREATE DATABASE CUSTOMERS

CREATE TABLE FLO (
	master_id							VARCHAR(50),
	order_channel						VARCHAR(50),
	last_order_channel					VARCHAR(50),
	first_order_date					DATE,
	last_order_date						DATE,
	last_order_date_online				DATE,
	last_order_date_offline				DATE,
	order_num_total_ever_online			INT,
	order_num_total_ever_offline		INT,
	customer_value_total_ever_offline	FLOAT,
	customer_value_total_ever_online	FLOAT,
	interested_in_categories_12			VARCHAR(50),
	store_type							VARCHAR(10)
);


--QUESTION 2: Write the query that will show how many different customers shopped.
SELECT COUNT(DISTINCT(master_id)) AS DISTINCT_PEOPLE_NUMBER FROM FLO;


--QUESTION 3: Write the query that will return the total number of purchases and turnover.
SELECT 
	SUM(order_num_total_ever_offline + order_num_total_ever_online) AS TOTAL_ORDER_COUNT,
	ROUND(SUM(customer_value_total_ever_offline + customer_value_total_ever_online), 2) AS TOTAL_REVENUE
FROM FLO;


--QUESTION 4:  Write the query that will return the average turnover per purchase.
SELECT  
--SUM(order_num_total_ever_online+order_num_total_ever_offline) TOTAL_ORDER_COUNT
	ROUND((SUM(customer_value_total_ever_offline + customer_value_total_ever_online) / 
	SUM(order_num_total_ever_online+order_num_total_ever_offline) 
	), 2) AS ORDER_AVG_REVENUE 
 FROM FLO


--QUESTION 5: Write the query that will return the total turnover and number of purchases made through the last shopping channel (last_order_channel).
SELECT  last_order_channel LAST_ORDER_CHANNEL,
SUM(customer_value_total_ever_offline + customer_value_total_ever_online) TOTAL_REVENUE,
SUM(order_num_total_ever_online+order_num_total_ever_offline) TOTAL_ORDER_COUNT
FROM FLO
GROUP BY  last_order_channel


--QUESTION 6: Write the query that returns the total turnover obtained in the store type breakdown.
SELECT store_type STORE_TYPE, 
       ROUND(SUM(customer_value_total_ever_offline + customer_value_total_ever_online), 2) TOTAL_REVENUE 
FROM FLO 
GROUP BY store_type;

--BONUS - > Parsed version of the data in the store type.
SELECT Value,SUM(TOTAL_REVENUE/COUNT_) FROM
(
SELECT store_type STORE_TYPE,(SELECT COUNT(VALUE) FROM  string_split(store_type,',') ) COUNT_,
       ROUND(SUM(customer_value_total_ever_offline + customer_value_total_ever_online), 2) TOTAL_REVENUE 
FROM FLO 
GROUP BY store_type) T
CROSS APPLY (SELECT  VALUE  FROM  string_split(T.STORE_TYPE,',') ) D
GROUP BY Value
 

--QUESTION 7: Write the query that will return the number of purchases by year (Base the year on the customers first purchase date (first_order_date)).
SELECT 
YEAR(first_order_date) YEAR,  SUM(order_num_total_ever_offline + order_num_total_ever_online) ORDER_COUNT
FROM  FLO
GROUP BY YEAR(first_order_date)


--QUESTION 8: Write the query that will calculate the average turnover per purchase in the channel breakdown where the last purchase was made.
SELECT last_order_channel, 
       ROUND(SUM(customer_value_total_ever_offline + customer_value_total_ever_online),2) TOTAL_REVENUE,
	   SUM(order_num_total_ever_offline + order_num_total_ever_online) TOTAL_ORDER_COUNT,
       ROUND(SUM(customer_value_total_ever_offline + customer_value_total_ever_online) / SUM(order_num_total_ever_offline + order_num_total_ever_online),2) AS TURNOVER
FROM FLO
GROUP BY last_order_channel;


--QUESTION 9: Write the query that returns the most popular category in the last 12 months.
SELECT interested_in_categories_12, 
       COUNT(*) FREQUENCY 
FROM FLO
GROUP BY interested_in_categories_12
ORDER BY 2 DESC;

--BONUS - >
SELECT K.VALUE,SUM(T.FREQUECNY/T.COUNT) FROM 
(
SELECT 
(SELECT COUNT(VALUE) FROM string_split(interested_in_categories_12,',')) COUNT,
REPLACE(REPLACE(interested_in_categories_12,']',''),'[','') CATEGORY, 
COUNT(*) FREQUENCY 
FROM FLO
GROUP BY interested_in_categories_12
) T 
CROSS APPLY (SELECT * FROM string_split(CATEGORY,',')) K
GROUP BY K.value


--QUESTION 10: Write the query that returns the most preferred store_type information.
SELECT TOP 1   
	store_type, 
    COUNT(*) FREQUENCY 
FROM FLO 
GROUP BY store_type 
ORDER BY 2 DESC;

--BONUS - >
SELECT * FROM
(
SELECT    
ROW_NUMBER() OVER(  ORDER BY COUNT(*) DESC) ROWNR,
	store_type, 
    COUNT(*) FREQUENCY 
FROM FLO 
GROUP BY store_type 
)T 
WHERE ROWNR=1


--QUESTION 11: Based on the last shopping channel (last_order_channel), write the query that returns the most popular category and how much shopping was done from this category.
SELECT DISTINCT last_order_channel,
(
	SELECT top 1 interested_in_categories_12
	FROM FLO  WHERE last_order_channel=f.last_order_channel
	group by interested_in_categories_12
	order by 
	SUM(order_num_total_ever_online+order_num_total_ever_offline) desc 
),
(
	SELECT top 1 SUM(order_num_total_ever_online+order_num_total_ever_offline)
	FROM FLO  WHERE last_order_channel=f.last_order_channel
	group by interested_in_categories_12
	order by 
	SUM(order_num_total_ever_online+order_num_total_ever_offline) desc 
)
FROM FLO F


--BONUS - >
SELECT DISTINCT last_order_channel,D.interested_in_categories_12,D.TOTAL_ORDER
FROM FLO  F
CROSS APPLY 
(
	SELECT top 1 interested_in_categories_12,SUM(order_num_total_ever_online+order_num_total_ever_offline) TOTAL_ORDER
	FROM FLO   WHERE last_order_channel=f.last_order_channel
	group by interested_in_categories_12
	order by 
	SUM(order_num_total_ever_online+order_num_total_ever_offline) desc 
) D


--QUESTION 12: Write the query that returns the ID of the person who makes the most purchases.
 SELECT TOP 1 master_id   		    
	FROM FLO 
	GROUP BY master_id 
ORDER BY  SUM(customer_value_total_ever_offline + customer_value_total_ever_online)    DESC 

--BONUS
SELECT D.master_id
FROM 
	(SELECT master_id, 
		   ROW_NUMBER() OVER(ORDER BY SUM(customer_value_total_ever_offline + customer_value_total_ever_online) DESC) RN
	FROM FLO 
	GROUP BY master_id) AS D
WHERE RN = 1;


--QUESTION 13: Write the query that returns the average turnover per purchase of the person who shops the most and the average shopping day (shopping frequency).
SELECT D.master_id,ROUND((D.TOTAL_REVENUE / D.TOTAL_ORDER_COUNT),2) REV_BY_ORDER,
ROUND((DATEDIFF(DAY, first_order_date, last_order_date)/D.TOPLAM_SIPARIS_SAYISI ),1) AVG_SHOP_DAY
FROM
(
SELECT TOP 1 master_id, first_order_date, last_order_date,
		   SUM(customer_value_total_ever_offline + customer_value_total_ever_online) TOTAL_REVENUE,
		   SUM(order_num_total_ever_offline + order_num_total_ever_online) TOTAL_ORDER_COUNT
	FROM FLO 
	GROUP BY master_id,first_order_date, last_order_date
ORDER BY TOTAL_REVENUE DESC
) D


--QUESTION 14: Write the query that returns the average shopping day (shopping frequency) of the top 100 people who shop the most (on a turnover basis).
SELECT  
D.master_id,
       D.TOTAL_REVENUE,
	   D.TOTAL_ORDER_COUNT,
       ROUND((D.TOPLAM_CIRO / D.TOPLAM_SIPARIS_SAYISI),2) REV_BY_ORDER,
	   DATEDIFF(DAY, first_order_date, last_order_date) SHOP_DAY_DIFF,
	  ROUND((DATEDIFF(DAY, first_order_date, last_order_date)/D.TOPLAM_SIPARIS_SAYISI ),1) AVG_SHOP_DAY	 
  FROM
(
SELECT TOP 100 master_id, first_order_date, last_order_date,
		   SUM(customer_value_total_ever_offline + customer_value_total_ever_online) TOTAL_REVENUE,
		   SUM(order_num_total_ever_offline + order_num_total_ever_online) TOTAL_ORDER_COUNT
	FROM FLO 
	GROUP BY master_id,first_order_date, last_order_date
ORDER BY TOTAL_REVENUE DESC
) D


--QUESTION 15: Write the query that returns the customers who shopped the most in the last_order_channel breakdown.
SELECT DISTINCT last_order_channel,
(
	SELECT top 1 master_id
	FROM FLO  WHERE last_order_channel=f.last_order_channel
	group by master_id
	order by 
	SUM(customer_value_total_ever_offline+customer_value_total_ever_online) desc 
) TOP_SHOPPING_CUSTOMER,
(
	SELECT top 1 SUM(customer_value_total_ever_offline+customer_value_total_ever_online)
	FROM FLO  WHERE last_order_channel=f.last_order_channel
	group by master_id
	order by 
	SUM(customer_value_total_ever_offline+customer_value_total_ever_online) desc 
) REVENUE
FROM FLO F


--QUESTION 16: Write the query that returns the ID of the last person who shopped. (There is more than one shopping ID on the maximum deadline. Bring them too.)
SELECT master_id,last_order_date FROM FLO
WHERE last_order_date=(SELECT MAX(last_order_date) FROM FLO)