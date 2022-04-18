/*

In this project I explored a Sales Dataset (from Kaggle) and analysed insights from customers past purchase behavior.
I started from analyzing sales revenue to continue with creating a customer segmentation analysis using the RFM method.

For that I used: 
- Basic SQL queries
- Aggregate Functions
- Window Functions
- Subqueries
- Common Table Expressions (CTEs)
- XML Path Function

*/



-- Inspecting Data from SalesDataSample table

SELECT *
FROM [SalesPoject].[dbo].[SalesDataSample]



-- Checking unique values from different columns

SELECT DISTINCT status
FROM [SalesPoject].[dbo].[SalesDataSample]

SELECT DISTINCT year_id 
FROM [SalesPoject].[dbo].[SalesDataSample]

SELECT DISTINCT productline
FROM [SalesPoject].[dbo].[SalesDataSample]

SELECT DISTINCT country
FROM [SalesPoject].[dbo].[SalesDataSample]

SELECT DISTINCT dealsize
FROM [SalesPoject].[dbo].[SalesDataSample]

SELECT DISTINCT territory
FROM [SalesPoject].[dbo].[SalesDataSample]




-- Analysis

-- Starting by grouping sales by productline

SELECT productline, SUM(sales) AS revenue
FROM [dbo].[SalesDataSample]
GROUP BY productline
ORDER BY 2 DESC 


-- Checking sales across the years

SELECT year_id, SUM(sales) AS revenue
FROM [dbo].[SalesDataSample]
GROUP BY year_id
ORDER BY 2 DESC


-- Checking the number of months per year

SELECT DISTINCT month_id
FROM [dbo].[SalesDataSample]
WHERE year_id = 2005 -- change year to see the rest


-- Checking sales throught the dealsize

SELECT dealsize, SUM(sales) AS revenue
FROM [dbo].[SalesDataSample]
GROUP BY dealsize
ORDER BY 2 DESC


-- Show city which has the highest number of sales in a specific country

SELECT city, SUM(sales) AS revenue
FROM [dbo].[SalesDataSample]
WHERE country = 'France' -- change country to see the rest
GROUP BY city
ORDER BY 2 DESC


-- What is the best product in France?

SELECT country, year_id, productline, SUM(sales) AS revenue
FROM [dbo].[SalesDataSample]
WHERE country = 'France'
GROUP BY country, year_id, productline
ORDER BY 4 DESC


-- What is the best month for sales in a specific year? How much was earned that month?

SELECT month_id, SUM(sales) AS revenue, COUNT(ordernumber) AS frequency
FROM [dbo].[SalesDataSample]
WHERE year_id = 2003 -- change year to see the rest
GROUP BY month_id
ORDER BY 2 DESC


-- November is the best month, but which product did they sell in November?

SELECT month_id, productline, SUM(sales) AS revenue, COUNT(ordernumber) AS frequency
FROM [dbo].[SalesDataSample]
WHERE year_id = 2003 AND month_id = 11 -- change year to see the rest
GROUP BY month_id, productline
ORDER BY 3 DESC




-- Who is the best customer (RFM analysis)?

DROP TABLE IF EXISTS #rfm
;WITH rfm AS 
(
    SELECT customername, 
	       SUM(sales) AS monetary_value,
		   AVG(sales) AS avg_monetary_value,
		   COUNT(ordernumber) AS frequency,
		   MAX(orderdate) AS last_order_date,
		   (SELECT MAX(orderdate) FROM [dbo].[SalesDataSample]) AS max_order_date,
		   DATEDIFF(DD, MAX(orderdate), (SELECT MAX(orderdate) FROM [dbo].[SalesDataSample])) AS recency
	FROM [dbo].[SalesDataSample]
	GROUP BY customername
),
rfm_calc AS
(
	SELECT r.*,
		   NTILE(4) OVER (ORDER BY recency DESC) AS rfm_recency,
		   NTILE(4) OVER (ORDER BY frequency) AS rfm_frequency,
		   NTILE(4) OVER (ORDER BY monetary_value) AS rfm_monetary
	FROM rfm r
)

SELECT c.*, rfm_recency + rfm_frequency + rfm_monetary AS rfm_cell,
	   CAST(rfm_recency AS VARCHAR) + CAST(rfm_frequency AS VARCHAR) + CAST(rfm_monetary AS VARCHAR) AS rfm_cell_string
INTO #rfm
FROM rfm_calc AS c


-- Customer segmentation

SELECT customername, rfm_recency, rfm_frequency, rfm_monetary,
CASE WHEN rfm_cell_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) THEN 'lost_customers'  -- Lost customers
     WHEN rfm_cell_string in (133, 134, 143, 244, 334, 343, 344, 144) THEN 'slipping_away_customers' -- Slipping away customers (Big spenders who haven’t made purchase lately) 
     WHEN rfm_cell_string in (311, 411, 331) THEN 'new_customers'
     WHEN rfm_cell_string in (222, 223, 233, 322) THEN 'potential_churners'
     WHEN rfm_cell_string in (323, 333,321, 422, 332, 432) THEN 'active_customers' -- (Customers who buy often and who have made purchase recently, but at low price points)
	 WHEN rfm_cell_string in (433, 434, 443, 444) THEN 'loyal_customers'
END rfm_segment
FROM #rfm


-- What products are most often sold together?

SELECT DISTINCT ordernumber, STUFF(

   (SELECT ',' + productcode
	FROM [dbo].[SalesDataSample] AS p
	WHERE ordernumber IN 
	   (
		 SELECT ordernumber
		 FROM (
				SELECT ordernumber, COUNT(*) AS rn
				FROM [dbo].[SalesDataSample]
				WHERE status = 'Shipped'
				GROUP BY ordernumber
	           ) AS m
		 WHERE rn = 2
		)
		AND p.ordernumber = s.ordernumber
		FOR XML PATH (''))
		
		, 1, 1, '') AS ProductCodes

FROM [dbo].[SalesDataSample] AS s
ORDER BY 2 DESC


