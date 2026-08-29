-- Databricks notebook source
--To check if the table exists/data loaded correctly
 SELECT *
 FROM bright_coffee.default.bright_coffee_dataset

 --To check total number of records
 SELECT COUNT(*) AS total_records
 FROM bright_coffee.default.bright_coffee_dataset;
 
--Checking Product Type
 SELECT DISTINCT product_type
 FROM bright_coffee.default.bright_coffee_dataset

--Checking for the NULL values
SELECT
    COUNT(*) AS total_records,
    COUNT(transaction_id) AS transaction_id_count,
    COUNT(transaction_date) AS transaction_date_count,
    COUNT(transaction_time) AS transaction_time_count,
    COUNT(transaction_qty) AS transaction_qty_count,
    COUNT(unit_price) AS unit_price_count,
    COUNT(product_category) AS product_category_count,
    COUNT(product_type) AS product_type_count
FROM bright_coffee.default.bright_coffee_dataset;

--Checking Transaction Date
SELECT DISTINCT transaction_date
FROM bright_coffee.default.bright_coffee_dataset;

SELECT DISTINCT DATE_FORMAT(transaction_date, 'MMMM') AS Month_name
FROM bright_coffee.default.bright_coffee_dataset

--Checking Transaction Time
SELECT DISTINCT transaction_time
FROM bright_coffee.default.bright_coffee_dataset;

SELECT DISTINCT DATE_FORMAT(transaction_time, 'HH:mm:ss') AS time
FROM bright_coffee.default.bright_coffee_dataset

-- Checking for Duplicate Transactions
SELECT *,
    COUNT(*) AS duplicates_count
FROM bright_coffee.default.bright_coffee_dataset
GROUP BY ALL
HAVING COUNT(*) >1;

SELECT 
    transaction_id,
    COUNT(*) AS duplicates_count
FROM bright_coffee.default.bright_coffee_dataset
GROUP BY transaction_id
HAVING COUNT(*) >1


--Calculating Total Amount (this is one of the calculations specifically required for the assignment)
SELECT
    transaction_id,
    transaction_date,
    transaction_time,
    product_category,
    product_type,
    product_detail,
    transaction_qty,
    unit_price,
    transaction_qty * unit_price AS total_amount
FROM bright_coffee.default.bright_coffee_dataset;

 SELECT 
     *,
     unit_price * transaction_qty AS total_amount
 FROM bright_coffee.default.bright_coffee_dataset;

 --Total Revenue
 SELECT
     SUM(unit_price * transaction_qty) AS total_revenue
 FROM bright_coffee.default.bright_coffee_dataset;

 --Total Units Sold
 SELECT 
     SUM(transaction_qty) AS total_units_sold
 FROM bright_coffee.default.bright_coffee_dataset;

 --Number of Transactions
 SELECT 
     COUNT(DISTINCT transaction_id) AS total_transactions
 FROM bright_coffee.default.bright_coffee_dataset;

 --Average Transaction Value
 SELECT
     ROUND(
         SUM(transaction_qty * unit_price)
         / COUNT(DISTINCT transaction_id),
         2    
     ) AS average_transaction_value
     FROM bright_coffee.default.bright_coffee_dataset;

--Revenue by Product Category(checking which products generates most revenue)
SELECT
    product_category,
ROUND(SUM(unit_price * transaction_qty), 2) AS total_revenue
FROM bright_coffee.default.bright_coffee_dataset
GROUP BY product_category
ORDER BY total_revenue DESC;

--Revenue by Product Type
SELECT
    product_type,
ROUND(SUM(unit_price * transaction_qty), 2) AS total_revenue
FROM bright_coffee.default.bright_coffee_dataset
GROUP BY product_type
ORDER BY total_revenue DESC;

--Revenue by Product Detail
SELECT
    product_detail,
ROUND(SUM(unit_price * transaction_qty), 2) AS total_revenue
FROM bright_coffee.default.bright_coffee_dataset
GROUP BY product_detail
ORDER BY total_revenue DESC;


--Units sold by Product Type
SELECT
    product_type,
SUM(transaction_qty) AS total_units_sold
FROM bright_coffee.default.bright_coffee_dataset
GROUP BY product_type
ORDER BY total_units_sold DESC;

--Top 10 Products by Revenue
SELECT
    product_type,
    ROUND(SUM(transaction_qty * unit_price), 2) AS total_revenue
FROM bright_coffee.default.bright_coffee_dataset
GROUP BY product_type
ORDER BY total_revenue DESC
LIMIT 10;

--Bottom 10 Products by Revenue
SELECT 
    product_type,
    ROUND(SUM(transaction_qty * unit_price), 2) AS total_revenue
FROM bright_coffee.default.bright_coffee_dataset
GROUP BY product_type
ORDER BY total_revenue ASC
LIMIT 10;

--Sales by Date
SELECT
    transaction_date,
    SUM(transaction_qty) AS total_units_sold,
    ROUND(SUM(transaction_qty * unit_price), 2) AS total_revenue
FROM bright_coffee.default.bright_coffee_dataset
GROUP BY transaction_date
ORDER BY transaction_date;

--Sales by Month
SELECT
    DATE_FORMAT(transaction_date, 'yyyy-MM') AS month,
    SUM(transaction_qty) AS total_units_sold,
    ROUND(SUM(transaction_qty * unit_price), 2) AS total_revenue
FROM bright_coffee.default.bright_coffee_dataset
GROUP BY DATE_FORMAT(transaction_date, 'yyyy-MM')
ORDER BY month;

--Sales by Day of Week
SELECT
    DATE_FORMAT(transaction_date, 'E') AS day_of_week,
    SUM(transaction_qty) AS total_units_sold,
    ROUND(SUM(transaction_qty * unit_price), 2) AS total_revenue
FROM bright_coffee.default.bright_coffee_dataset
GROUP BY DATE_FORMAT(transaction_date, 'E')
ORDER BY total_revenue DESC;

--Creating a 30 Minute Time Bucket


    
        
SELECT
    transaction_time,
    CONCAT(
       LPAD(
          CAST(HOUR(transaction_time) AS STRING),
          2,
          '0'
       ),
       ':',
       LPAD(
          CAST(MINUTE(transaction_time) AS STRING),
          2,
          '0'
        ),
        ':',
        CASE
           WHEN MINUTE(transaction_time) < 30 THEN '00'
           ELSE '30'
        END 
    ) AS time_bucket
 FROM bright_coffee.default.bright_coffee_dataset; 

--Sales by 30 Minute Time Interval
SELECT
    CONCAT(
        LPAD(CAST(HOUR(transaction_time) AS STRING), 2, '0'),
        ':',
        CASE
           WHEN MINUTE(transaction_time) < 30 THEN '00'
           ELSE '30'
        END
    ) AS time_bucket,
    SUM(transaction_qty) AS total_units_sold,

    ROUND(
        SUM(transaction_qty * unit_price),
        2
        ) AS total_revenue
FROM bright_coffee.default.bright_coffee_dataset
GROUP BY 
   CONCAT(
        LPAD(CAST(HOUR(transaction_time) AS STRING), 2, '0'),
        ':',
        CASE
           WHEN MINUTE(transaction_time) < 30 THEN '00'
           ELSE '30'
        END
    )
ORDER BY time_bucket;     

--Best time of Day for store performance
SELECT
    CASE
        WHEN HOUR(transaction_time) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN HOUR(transaction_time) BETWEEN 12 AND 16 THEN 'Afternoon'
        WHEN HOUR(transaction_time) BETWEEN 17 AND 20 THEN 'Evening'
        ELSE 'Night'
    END AS time_of_day,
    SUM(transaction_qty) AS total_units_sold,
    ROUND(
        SUM(transaction_qty * unit_price), 
        2
    ) AS total_revenue
FROM bright_coffee.default.bright_coffee_dataset
GROUP BY 
    CASE
        WHEN HOUR(transaction_time) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN HOUR(transaction_time) BETWEEN 12 AND 16 THEN 'Afternoon'
        WHEN HOUR(transaction_time) BETWEEN 17 AND 20 THEN 'Evening'
        ELSE 'Night'
    END
ORDER BY total_revenue DESC;

--Best Hour of the Day
SELECT
    HOUR(transaction_time) AS hour_of_day,
    SUM(transaction_qty) AS total_units_sold,
    ROUND(
        SUM(transaction_qty * unit_price),
        2
    ) AS total_revenue
FROM bright_coffee.default.bright_coffee_dataset
GROUP BY HOUR(transaction_time)
ORDER BY total_revenue DESC;

--High Performing and Low Performing Products
WITH product_sales AS (
    SELECT
         product_type,
         SUM(transaction_qty) AS total_units_sold,
         ROUND
            (SUM(transaction_qty * unit_price), 
            2)
         AS total_revenue
    FROM bright_coffee.default.bright_coffee_dataset
    GROUP BY product_type
)
SELECT
    product_type,
    total_units_sold,
    total_revenue,
    CASE
        WHEN total_revenue >=
        (SELECT AVG(total_revenue) 
        FROM product_sales) THEN 'High Performing'
        ELSE 'Low Performing'
    END AS product_performance
FROM product_sales
ORDER BY total_revenue DESC;

--Daily Sales Trend
SELECT 
    transaction_date,
    ROUND(
        SUM(transaction_qty * unit_price),
        2
    ) AS daily_revenue,
    SUM(transaction_qty) AS daily_units_solds,
    COUNT(DISTINCT transaction_id) AS daily_transactions
FROM bright_coffee.default.bright_coffee_dataset
GROUP BY transaction_date
ORDER BY transaction_date;    

--Monthly Sales Trend
SELECT
    DATE_FORMAT(transaction_date, 'yyyy-MM') AS month,
    ROUND(
        SUM(transaction_qty * unit_price),
        2
    ) AS monthly_revenue,
    SUM(transaction_qty) AS monthly_units_sold,
    COUNT(DISTINCT transaction_id) AS monthly_transactions
FROM bright_coffee.default.bright_coffee_dataset
GROUP BY DATE_FORMAT(transaction_date, 'yyyy-MM')
ORDER BY month;

--Checking Product Category
 SELECT distinct product_category
 FROM bright_coffee.default.bright_coffee_dataset
 
--Cleaning Product Category
SELECT DISTINCT
     product_category,
     CASE 
         WHEN product_category IS NULL THEN 'Unknown'
         WHEN product_category = ' ' THEN 'Unknown'
         ELSE product_category
     END AS product_cat
     FROM bright_coffee.default.bright_coffee_dataset;

 --Inspecting Product Type
 SELECT DISTINCT product_type
 FROM bright_coffee.default.bright_coffee_dataset;

 
--Cleaning Product Type
SELECT DISTINCT
     product_type,
     CASE 
         WHEN product_type IS NULL THEN 'Unknown'
         WHEN product_type = ' ' THEN 'Unknown'
         ELSE product_type
     END AS product_typ
     FROM bright_coffee.default.bright_coffee_dataset;

-- Creating the Revenue Column
SELECT transaction_qty*unit_price AS revenue
FROM bright_coffee.default.bright_coffee_dataset



DESCRIBE bright_coffee.default.bright_coffee_dataset

 --To check total number of unique products
 SELECT COUNT(DISTINCT product_id) AS total_products
 FROM bright_coffee.default.bright_coffee_dataset;

 --Data Transformations Transaction time bucket column (Converting times into buckets)

 SELECT 
     *,
     CONCAT (
         LPAD(CAST(HOUR(transaction_time) AS STRING), 2, '0'),
         ':',
         LPAD(CAST(FLOOR(MINUTE(transaction_time) / 30) * 30 AS STRING), 2, '0')
     ) AS transaction_time_bucket
 FROM bright_coffee.default.bright_coffee_dataset;

 --Create price unit correctley

 SELECT 
     unit_price,
     CAST(unit_price AS DECIMAL(10,2)) AS unit_price_corrected
 FROM bright_coffee.default.bright_coffee_dataset
 LIMIT 20

SELECT transaction_qty, ROUND(SUM (CAST(transaction_qty AS DOUBLE) * CAST (REPLACE(unit_price, ',', '.') AS DOUBLE)),0) AS total_amount
FROM bright_coffee.default.bright_coffee_dataset
GROUP BY transaction_qty;


 --Creating a new table with all the transformations

 CREATE OR REPLACE TABLE bright_coffee.default.bright_coffee_dataset_processed
 SELECT
     transaction_id,
     transaction_date,
     transaction_time,
     transaction_qty,
     store_id,
     store_location,
     product_id,
     CAST(unit_price AS DECIMAL(10,2)) AS unit_price,
     product_category,
     product_type,
     product_detail,

     CONCAT(
         LPAD(CAST(HOUR(transaction_time) AS STRING), 2, '0'),
         ':',
         LPAD(CAST(FLOOR(MINUTE(transaction_time) / 30) * 30 AS STRING), 2, '0')
     ) AS transaction_time_bucket,
     
     CAST(unit_price AS DECIMAL(10,2)) * transaction_qty AS total_amount
 FROM bright_coffee.default.bright_coffee_dataset;

--A new table was created with all the transformations

SELECT *
 FROM bright_coffee.default.bright_coffee_dataset_processed
 

SHOW TABLES IN bright_coffee.default;

 SELECT 
     product_type,

     CONCAT(
         LPAD(CAST(HOUR(transaction_time) AS STRING), 2, '0'),
         ':',
         LPAD(
          CAST(FLOOR(MINUTE(transaction_time) / 30) * 30 AS STRING),
           2, 
           '0')
         ) AS transaction_time_bucket,
     SUM (transaction_qty) AS total_quantity,

     SUM(
         CAST(unit_price AS DECIMAL(10,2)) * transaction_qty
     ) AS total_sales

 FROM bright_coffee.default.bright_coffee_dataset

 GROUP BY 
     product_type,
     CONCAT(
         LPAD(CAST(HOUR(transaction_time) AS STRING), 2, '0'),
         ':',
         LPAD(
          CAST(FLOOR(MINUTE(transaction_time) / 30) * 30 AS STRING), 
          2,
         '0'
        )    
     )

     ORDER BY
        product_type,
        transaction_time_bucket;

   WITH cleaned_data AS (

    SELECT
        transaction_id,

        CAST(transaction_date AS DATE) AS transaction_date,

        DAYOFWEEK(
            CAST(transaction_date AS DATE)
        ) AS day_number,

        DATE_FORMAT(
            CAST(transaction_date AS DATE),
            'MMMM'
        ) AS month_name,

        MONTH(
            CAST(transaction_date AS DATE)
        ) AS month_number,

        YEAR(
            CAST(transaction_date AS DATE)
        ) AS year,

        HOUR(transaction_time) AS transaction_hour,

        transaction_qty,
        store_id,
        store_location,
        product_id,
        product_category,
        product_type,
        product_detail,
        CAST(
            REPLACE(
                CAST(unit_price AS STRING),
                ',',
                '.'
            ) AS DECIMAL(10,2)
        ) AS unit_price
    FROM bright_coffee.default.bright_coffee_dataset
),
final_data AS (

    SELECT
        transaction_id,
        transaction_date,
        CASE
            WHEN day_number = 1 THEN 'Sunday'
            WHEN day_number = 2 THEN 'Monday'
            WHEN day_number = 3 THEN 'Tuesday'
            WHEN day_number = 4 THEN 'Wednesday'
            WHEN day_number = 5 THEN 'Thursday'
            WHEN day_number = 6 THEN 'Friday'
            WHEN day_number = 7 THEN 'Saturday'
        END AS day_name,
        day_number,
        month_name,
        month_number,
        year,
        CASE
            WHEN transaction_hour BETWEEN 6 AND 8 THEN '06:00-09:00'
            WHEN transaction_hour BETWEEN 9 AND 11 THEN '09:00-12:00'
            WHEN transaction_hour BETWEEN 12 AND 14 THEN '12:00-15:00'
            WHEN transaction_hour BETWEEN 15 AND 17 THEN '15:00-18:00'
            WHEN transaction_hour BETWEEN 18 AND 20 THEN '18:00-21:00'
            ELSE 'Other'
        END AS time_of_day,

        CASE
            WHEN transaction_hour BETWEEN 6 AND 8 THEN 'Morning'
            WHEN transaction_hour BETWEEN 9 AND 11 THEN 'Late Morning'
            WHEN transaction_hour BETWEEN 12 AND 14 THEN 'Afternoon'
            WHEN transaction_hour BETWEEN 15 AND 17 THEN 'Late Afternoon'
            WHEN transaction_hour BETWEEN 18 AND 20 THEN 'Closing Hours' 
            ELSE 'Other'
        END AS time_bucket,
        transaction_qty,
        unit_price,

        CAST(
            transaction_qty * unit_price
            AS DECIMAL(10,2)
        ) AS total_amount,

        store_id,
        store_location,
        product_id,
        product_category,
        product_type,
        product_detail
    FROM cleaned_data
)

SELECT *
FROM final_data;     


