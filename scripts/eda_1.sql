/*
-- How to decide between a DIMENSION & a MEASURE ???
-- If the column data type = NUMBER ???
	--> If NO, THEN, it is a DIMENSION.
	--> If YES, THEN, Does it make sense to aggregate it ?? If YES, THEN it is a MEASURE.
	--> If NO, THEN, it is a DIMENSION.
-- Understand it with some examples:
*/

-- Category: DIMENSION OR MEASURE ???
SELECT DISTINCT category
FROM gold.dim_products;	--> This is a DIMENSION

-- sales_amount: DIMENSION OR MEASURE ???
SELECT DISTINCT sales_amount
FROM gold.fact_sales;	--> This makes sense to aggregate, thus, it is a MEASURE.

-- birthdate: DIMENSION OR MEASURE ???
SELECT DISTINCT birthdate, DATEDIFF(year, birthdate, GETDATE()) AS Age
FROM gold.dim_customers;
--> DATE type column, although a DIMENSION, could be a MEASURE if 'Age' is derived from it.

-- Customer average age:
SELECT DISTINCT AVG(DATEDIFF(year, birthdate, GETDATE())) AS AvgCustomer_Age
FROM gold.dim_customers;	--> This is a MEASURE, derived from birthdate DIMENSION.

-- customer_id: DIMENSION OR MEASURE ???
SELECT DISTINCT customer_id
FROM gold.dim_customers;	--> IDs are unique to every customer, no sense in aggregating it. Thus, it is a DIMENSION.

------------------------------------------------------------------------------------------

/* Dimensions exploration:
--> Identify the unique values or categories in each dimension
--> Recognizing how data might be grouped or segmented will be useful for analysis.

*/

-- Explore all the countries customers come from
SELECT DISTINCT country FROM gold.dim_customers;

-- Explore all the categories "major divisions"
SELECT DISTINCT category, subcategory, product_name FROM gold.dim_products
ORDER BY 1,2,3;

---------------------------------------------------------------------------------------------------
/*
-- DATE exploration:

-- Identifying the earliest & latest dates gives us the DATE boundaries and timespan of the data.
*/

-- Find the dates of the first and the last order
-- How many years of sales data is available in the system ???

SELECT MIN(order_date) first_order_date, MAX(order_date) last_order_date,
	   DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) order_range_years,
	   DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) order_range_months
FROM gold.fact_sales;

-- Find the youngest and the oldest customer
SELECT MIN(birthdate) oldest_birthdate, MAX(birthdate) youngest_birthdate,
	   DATEDIFF(YEAR, MIN(birthdate), GETDATE()) oldest_age,
	   DATEDIFF(YEAR, MAX(birthdate), GETDATE()) youngest_age
FROM gold.dim_customers;

----------------------------------------------------------------------------------

-- =======================
-- Measure exploration:
-- =======================

SELECT TOP 10 * FROM gold.fact_sales;

-- 1. Find the total sales
SELECT SUM(sales_amount) total_sales FROM gold.fact_sales;

-- 2. Find how many items are sold
SELECT SUM(quantity) total_items_sold FROM gold.fact_sales;

-- 3. Find the average selling price
SELECT AVG(price) avg_price FROM gold.fact_sales;

-- 4. Find the total number of orders
SELECT COUNT(order_number) total_orders FROM gold.fact_sales; -- 60398 orders
SELECT COUNT(DISTINCT order_number) total_orders2 FROM gold.fact_sales; -- 27659 UNIQUE orders
-- It depends on what is asked, total orders irrespective of the repeats or without repeat orders.

SELECT * FROM gold.fact_sales WHERE order_number = 'SO54496'; -- there is order repitition

-- 5. Find the total number of products
SELECT TOP 5 * FROM gold.dim_products;

SELECT COUNT(product_name) total_products FROM gold.dim_products; -- 295 products
SELECT COUNT(DISTINCT product_name) total_products FROM gold.dim_products; -- 295 products, i.e, there are no duplicate products


-- 6. Find the total number of customers
SELECT TOP 5 * FROM gold.dim_customers;

SELECT COUNT(customer_key) total_customers FROM gold.dim_customers; -- 18484 customers
-- DISTINCT will ensure unique customers are fetched


-- 7. Find the total number of customers that have placed an order
--SELECT TOP 7 * FROM gold.fact_sales;

SELECT COUNT(DISTINCT customer_key) total_customers FROM gold.fact_sales;
-- all 18484 customers have placed at least an order.


/* Note:- 
--> To find the # of products --> COUNT the 'products' in 'dim_products'
--> To find the # of customers --> COUNT the 'customer_key' (because every customer key is UNIQUE) in 'dim_customers'
--> To find the customers who have placed an order --> need to COUNT the UNIQUE 'customer_key' in 'fact_sales', because orders data is found in it.
*/


-- Generate a report that shows all the key metrics of the business

SELECT 'Total Sales' AS measure_name, SUM(sales_amount) total_sales FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity sold', SUM(quantity) total_items_sold FROM gold.fact_sales
UNION ALL
SELECT 'Average Selling Price', AVG(price) avg_price FROM gold.fact_sales
UNION ALL
SELECT 'Total no. of orders', COUNT(DISTINCT order_number) total_orders FROM gold.fact_sales
UNION ALL
SELECT 'Total no. of products', COUNT(product_name) total_products FROM gold.dim_products
UNION ALL
SELECT 'Total no. of customers', COUNT(customer_key) total_customers FROM gold.dim_customers;
--> The result set inherits column aliases from the first query only. Aliases in subsequent SELECTs are ignored.

---------------------------------------------------------------------------------------------------------------------------
