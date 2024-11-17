-- SQL Retail Sales Analysis - P1

-- Creates a NEW DATABASE NAME p1_retail_db in PostgreSQL:
CREATE DATABASE p1_retail_db;


-- Create Table
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales (
		transactions_id	INT PRIMARY KEY,
		sale_date DATE,
		sale_time TIME,
		customer_id	INT,
		gender	VARCHAR(15),
		age	INT,
		category VARCHAR(15),
		quantity	INT,
		price_per_unit	FLOAT,
		cogs	FLOAT,
		total_sale	FLOAT 
	);


-- To retrieve all rows and columns from the retail_sales table 
SELECT * FROM retail_sales;		-- 11 columns


-- To retrieve the first 10 rows from the retail_sales table,
SELECT * FROM retail_sales LIMIT 10;


-- To get the total number of rows in the retail_sales table
SELECT COUNT(*) FROM retail_sales;		-- 2000 rows


-- To retrieve all rows from the retail_sales table, by the transactions_id column in ascending order:
SELECT * FROM public.retail_sales
ORDER BY transactions_id ASC 




-- Data Cleaning
SELECT * FROM retail_sales 
WHERE transactions_id IS Null;

SELECT * FROM retail_sales 
WHERE sale_date IS Null;

SELECT * FROM retail_sales
WHERE sale_time IS NULL;

-- Checks each specified column for NULL values and returns rows where at least one column is NULL.
SELECT * FROM retail_sales 
	WHERE 
	transactions_id IS Null
	OR
	sale_date IS Null
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	age IS NULL
	OR
	category IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;
-- Note: In the above SELECT Query I have taken all 11 columns and i found that AGE COLUMN is mot mandatory 
-- for Retail Sales table as other columns like category, quantity, price_per_unit, cogs and total_sale. 

-- Update Code
SELECT * FROM retail_sales 
	WHERE 
	transactions_id IS Null
	OR
	sale_date IS Null
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	category IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;

----------------------------------------------------------------
	
 -- Remove all rows from the retail_sales table where any of the specified columns contain NULL values
BEGIN;		-- Statement starts a transaction
DELETE FROM retail_sales 
	WHERE 
	transactions_id IS Null
	OR
	sale_date IS Null
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	category IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;
COMMIT; -- Or ROLLBACK if you want to cancel
	



-- Data Exploration

SELECT * FROM retail_sales;

-- How many sales do we have?
SELECT COUNT(*) as total_sales FROM retail_sales;	-- 1997

SELECT DISTINCT(COUNT(*)) FROM retail_sales;	-- 1997

-- How many unique transactions do we have?
SELECT COUNT(DISTINCT transactions_id )FROM retail_sales; -- 1997

-- How many unique customers do we have?
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;	-- 155

-- How many categories do we have?
SELECT COUNT(DISTINCT category) no_of_categories FROM retail_sales;	-- 3

SELECT DISTINCT(category) name_of_categories FROM retail_sales;




-- Data Analysis & Business Key Problems & Answers

-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'.
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022.
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year.
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales. 
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17).


-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'.
SELECT * 
FROM retail_sales
WHERE sale_date = '2022-11-05';


-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and 
-- the quantity sold is more than 4 in the month of Nov-2022
SELECT * 
FROM retail_sales
WHERE category = 'Clothing' 
    AND quantity >= 4
    AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11';


-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
SELECT category, 
	SUM(total_sale) AS net_sale 
FROM retail_sales
GROUP BY 1;

SELECT category, 
	SUM(total_sale) AS net_sale,
	COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category;


-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
SELECT 
	ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';


-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
SELECT *
FROM retail_sales
WHERE total_sale > 1000;


-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
SELECT category, gender, COUNT(transactions_id)
FROM retail_sales
GROUP BY category, gender
ORDER BY category;


-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year.
SELECT 
	year, month, avg_sale
FROM
(
	SELECT 
		EXTRACT (YEAR FROM sale_date) AS year,
		EXTRACT (MONTH FROM sale_date) AS month,
		AVG(total_sale) AS avg_sale,
		RANK() OVER(PARTITION BY EXTRACT (YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS rank
	FROM retail_sales
	GROUP BY year, month
) AS t1
WHERE rank = 1;
-- ORDER BY year, 3 DESC;


-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales. 
SELECT 
	customer_id,
	SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC 
LIMIT 5;


-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
SELECT 
	category,
	COUNT(DISTINCT customer_id) AS cnt_unique_cust
from retail_sales
GROUP BY category;


-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning < 12, 
-- Afternoon Between 12 & 17, Evening >17).

WITH Hourly_sale
AS
(
	SELECT * ,
		CASE
			WHEN EXTRACT (HOUR FROM sale_time) < 12 THEN 'Morning'
			WHEN EXTRACT (HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
			ELSE 'Evening'
		END AS shift
	FROM retail_sales
)
SELECT shift, COUNT(*) AS total_orders
FROM Hourly_sale
GROUP BY shift;

-- End of Project

-- SELECT EXTRACT (HOUR FROM CURRENT_TIME);






