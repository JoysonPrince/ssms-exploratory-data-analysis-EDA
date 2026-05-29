-- ====================
-- Ranking analysis:
-- ====================

-- Which 5 products generate the highest revenue ???

SELECT TOP 5 * FROM gold.fact_sales;

SELECT TOP 5 dp.product_name, SUM(fs.sales_amount) revenue
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp
ON fs.product_key = dp.product_key
GROUP BY dp.product_name
ORDER BY revenue DESC; -- this will ensure TOP 5 returns a deterministic result

-- How to solve the above task using Window functions ???:

--> Ranking with GROUP BY & without partitioning: 
	--> If the query has GROUP BY clause, then it is most likely you will not need PARTITION BY

SELECT TOP 5 dp.product_name, SUM(fs.sales_amount) revenue, DENSE_RANK () OVER (ORDER BY SUM(fs.sales_amount) DESC) ProductRank
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp
ON fs.product_key = dp.product_key
GROUP BY dp.product_name
ORDER BY revenue DESC; -- ORDER BY revenue makes the TOP 5 deterministic -- given the same input, you always get the same output

-- If ORDER BY in the outer query is not used, the results may vary based on internal engine execution, server load, etc.
-- So it is better to use a subquery & filter for top 5 OR use it like mentioned above.
-- The ORDER BY within Window function has no influence over the outer query. This ORDER BY is used to sort in DESC only for ranking.
-- The outer ORDER BY ensures the TOP 5 result set is deterministic.

-- Using subquery:
SELECT * 
FROM
(SELECT TOP 5 dp.product_name, SUM(fs.sales_amount) revenue, DENSE_RANK () OVER (ORDER BY SUM(fs.sales_amount) DESC) ProductRank
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp
ON fs.product_key = dp.product_key
GROUP BY dp.product_name) z1
WHERE z1.ProductRank <= 5;

/*
--> To get top-5 results using window functions --> use subquery & filter using WHERE outside the subquery
--> To get top-5 results using window functions but not using WHERE filter outside the subquery:
	-- Sort the aggr col using ORDER BY & then use TOP 5 to get deterministic results.
*/

/*
--> Ranking without GROUP BY & with partitioning:
SELECT TOP 5 dp.product_name, SUM(fs.sales_amount) revenue,
	         DENSE_RANK () OVER (PARTITION BY dp.product_name ORDER BY SUM(fs.sales_amount) DESC) ProductRank
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp
ON fs.product_key = dp.product_key;
*/

/* 
Why the above query will fail ???
--> When you write SUM(fs.sales_amount) without a GROUP BY, SQL treats the entire result as one big unaggregated set. 
-->	The engine sees SUM(fs.sales_amount) in the SELECT clause alongside dp.product_name (a non-aggregated column) and throws an error because:
--> " You're mixing an aggregate function with a non-aggregated column, and I have no GROUP BY to tell me how to group them "

--> PARTITION BY lives inside the window function — it only tells DENSE_RANK() how to partition its ranking calculation. 
--> It has zero influence on how rows are grouped or aggregated in the rest of the query.
--> The SQL engine processes GROUP BY before window functions, so the aggregation must already be resolved before any window function runs.
*/

-- What are the 5 worst-performing products in terms of sales ???

SELECT TOP 5 dp.product_name, SUM(fs.sales_amount) revenue
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp
ON fs.product_key = dp.product_key
GROUP BY dp.product_name
ORDER BY revenue ASC;

-- Which 5 product sub-categories generate the highest revenue ???

SELECT TOP 5 dp.subcategory, SUM(fs.sales_amount) revenue
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp
ON fs.product_key = dp.product_key
GROUP BY dp.subcategory
ORDER BY revenue DESC;

-- What are the 5 worst-performing product sub-categories in terms of sales ???

SELECT TOP 5 dp.subcategory, SUM(fs.sales_amount) revenue
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp
ON fs.product_key = dp.product_key
GROUP BY dp.subcategory
ORDER BY revenue ASC;

-- Find the top-10 customers who have generated the highest revenue 

SELECT TOP 10 dc.customer_key, dc.first_name, SUM(fs.sales_amount) AS revenue
			  --DENSE_RANK () OVER (ORDER BY SUM(fs.sales_amount) DESC) rank_customers
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
ON fs.customer_key = dc.customer_key
GROUP BY dc.customer_key, dc.first_name
ORDER BY revenue DESC;

-- Find the top-3 customers with the fewest orders placed.

SELECT TOP 3 dc.customer_key, dc.first_name, dc.last_name,
			 COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
ON fs.customer_key = dc.customer_key
GROUP BY dc.customer_key, dc.first_name, dc.last_name
ORDER BY total_orders ASC;  -- customers with fewest orders is needed, not highest, so use ASC.

--> There are 18484 customers in the DWH, all of them have ordered at least once.
--> i.e, 18484 customers have at least 1 order placed.
--> Thus, when TOP 3 is used, the SQL engine will arbitrarily choose the top-3 rows from the 18484 rows of customers with only 1 order
--	and silently ignore the other 18481 customers.

-- In this tied case scenario, use subquery with dense rank and then filter

SELECT *
FROM
(SELECT dc.customer_key, dc.first_name, dc.last_name,
			 COUNT(DISTINCT order_number) AS total_orders,
			 DENSE_RANK () OVER (ORDER BY COUNT(DISTINCT order_number) ASC) ranked_customers
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
ON fs.customer_key = dc.customer_key
GROUP BY dc.customer_key, dc.first_name, dc.last_name
) z1
WHERE z1.ranked_customers <= 3;

-------------------------------| Edge case: |------------------------------------- 
-- Find the top-3 customers with the HIGHEST orders placed.
SELECT TOP 3 dc.customer_key, dc.first_name, dc.last_name,
			 COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
ON fs.customer_key = dc.customer_key
GROUP BY dc.customer_key, dc.first_name, dc.last_name
ORDER BY total_orders DESC;

-- Solving the same using WF:
SELECT TOP 3 dc.customer_key, dc.first_name, dc.last_name,
			 COUNT(DISTINCT order_number) AS total_orders,
			 DENSE_RANK () OVER (ORDER BY COUNT(DISTINCT order_number) DESC) Top3Customers
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
ON fs.customer_key = dc.customer_key
GROUP BY dc.customer_key, dc.first_name, dc.last_name
ORDER BY total_orders DESC;

-- FROM/JOIN --> WHERE -> GROUP BY --> HAVING --> SELECT --> TOP --> DISTINCT --> ORDER BY
