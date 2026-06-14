DROP DATABASE IF EXISTS Ecommerce_Analytics;
CREATE DATABASE Ecommerce_Analytics;
USE Ecommerce_Analytics;

CREATE TABLE customers_dataset (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

CREATE TABLE sellers_dataset (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);

CREATE TABLE products_dataset (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

CREATE TABLE orders_dataset (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
    order_purchase_timestamp DATETIME NULL,
    order_approved_at DATETIME NULL,
    order_delivered_carrier_date DATETIME NULL,
    order_delivered_customer_date DATETIME NULL,
    order_estimated_delivery_date DATETIME NULL,

    FOREIGN KEY (customer_id)
    REFERENCES customers_dataset(customer_id)
);

CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),

    PRIMARY KEY (order_id, order_item_id),

    FOREIGN KEY (order_id) REFERENCES orders_dataset(order_id),
    FOREIGN KEY (product_id) REFERENCES products_dataset(product_id),
    FOREIGN KEY (seller_id) REFERENCES sellers_dataset(seller_id)
);

CREATE TABLE order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(20),
    payment_installments INT,
    payment_value DECIMAL(10,2),

    PRIMARY KEY (order_id, payment_sequential),

    FOREIGN KEY (order_id)
    REFERENCES orders_dataset(order_id)
);

CREATE TABLE order_reviews (
    review_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title VARCHAR(255),
    review_comment_message TEXT,
    review_creation_date DATETIME NULL,
    review_answer_timestamp DATETIME NULL,

    FOREIGN KEY (order_id)
    REFERENCES orders_dataset(order_id)
);

CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat DECIMAL(20,15),
    geolocation_lng DECIMAL(20,15),
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(10)
);

CREATE TABLE product_names (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(50)
);

CREATE TABLE product_category_name_transl (
    product_category_name VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100)
);

SET GLOBAL local_infile = 1;
SHOW GLOBAL VARIABLES LIKE 'local_infile';

LOAD DATA LOCAL INFILE "C:/Users/LENOVO/Desktop/Ecommerce/DATASET/product_names.csv"
INTO TABLE product_names
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE "C:/Users/LENOVO/Desktop/Ecommerce/DATASET/Geolocation.csv"
INTO TABLE geolocation
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE "C:/Users/LENOVO/Desktop/Ecommerce/DATASET/product_category_name_transl.csv"
INTO TABLE product_category_name_transl
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE "C:/Users/LENOVO/Desktop/Ecommerce/DATASET/products_dataset.csv"
INTO TABLE products_dataset
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(product_id,
 product_category_name,
 @name_len,
 @desc_len,
 @photos,
 @weight,
 @length,
 @height,
 @width)
SET
product_name_lenght = NULLIF(@name_len,''),
product_description_lenght = NULLIF(@desc_len,''),
product_photos_qty = NULLIF(@photos,''),
product_weight_g = NULLIF(@weight,''),
product_length_cm = NULLIF(@length,''),
product_height_cm = NULLIF(@height,''),
product_width_cm = NULLIF(@width,'');

LOAD DATA LOCAL INFILE 'C:/Users/LENOVO/Desktop/Ecommerce/DATASET/sellers_dataset.csv'
INTO TABLE sellers_dataset
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE "C:/Users/LENOVO/Desktop/Ecommerce/DATASET/Customers_dataset.csv"
INTO TABLE customers_dataset
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE "C:/Users/LENOVO/Desktop/Ecommerce/DATASET/orders_dataset.csv"
INTO TABLE orders_dataset
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(order_id,
 customer_id,
 order_status,
 @purchase,
 @approved,
 @carrier,
 @delivered,
 @estimated)

SET
order_purchase_timestamp =
STR_TO_DATE(NULLIF(@purchase,''),'%d-%m-%Y %H.%i'),

order_approved_at =
STR_TO_DATE(NULLIF(@approved,''),'%d-%m-%Y %H.%i'),

order_delivered_carrier_date =
STR_TO_DATE(NULLIF(@carrier,''),'%d-%m-%Y %H.%i'),

order_delivered_customer_date =
STR_TO_DATE(NULLIF(@delivered,''),'%d-%m-%Y %H.%i'),

order_estimated_delivery_date =
STR_TO_DATE(NULLIF(@estimated,''),'%d-%m-%Y %H.%i');

LOAD DATA LOCAL INFILE 'C:/Users/LENOVO/Desktop/Ecommerce/DATASET/order_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id, order_item_id, product_id, seller_id, @shipping_limit_date, price, freight_value)

SET shipping_limit_date =
STR_TO_DATE(@shipping_limit_date,'%Y-%m-%d %H:%i:%s');

LOAD DATA LOCAL INFILE 'C:/Users/LENOVO/Desktop/Ecommerce/DATASET/order_payments.csv'
INTO TABLE order_payments
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Users/LENOVO/Desktop/Ecommerce/DATASET/order_reviews.csv'
INTO TABLE order_reviews
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(review_id,
 order_id,
 review_score,
 review_comment_title,
 review_comment_message,
 @creation,
 @answer)

SET
review_creation_date =
STR_TO_DATE(@creation,'%Y-%m-%d %H:%i:%s'),

review_answer_timestamp =
STR_TO_DATE(@answer,'%Y-%m-%d %H:%i:%s');

-- 1 Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics
SELECT 
CASE 
WHEN DAYOFWEEK(order_purchase_timestamp) IN (1,7)
THEN 'Weekend'
ELSE 'Weekday'
END AS Day_Type,

COUNT(DISTINCT o.order_id) AS Total_Orders,
CONCAT(ROUND(COUNT(DISTINCT o.order_id) * 100.0 /
    SUM(COUNT(DISTINCT o.order_id)) OVER(), 
2),"%") AS Orders_Percentage,
SUM(p.payment_value) AS Total_Payment,
ROUND(AVG(p.payment_value),2) AS Avg_Payment

FROM orders_dataset o
JOIN order_payments p
ON o.order_id = p.order_id

GROUP BY Day_Type;

-- 2 Number of Orders with review score 5 and payment type as credit card.
SELECT 
COUNT(DISTINCT o.order_id) AS Total_Orders
FROM orders_dataset o
JOIN order_reviews r 
ON o.order_id = r.order_id
JOIN order_payments p 
ON o.order_id = p.order_id
WHERE r.review_score = 5
AND p.payment_type = 'credit_card';

-- 3 Average number of days taken for order_delivered_customer_date for pet_shop
SELECT 
ROUND(AVG(DATEDIFF(o.order_delivered_customer_date,
o.order_purchase_timestamp))) AS Avg_Delivery_Days

FROM orders_dataset o
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN products_dataset p
ON oi.product_id = p.product_id

WHERE p.product_category_name = 'pet_shop';

-- 4 Average price and payment values from customers of sao paulo city
SELECT 
ROUND(AVG(oi.price),2) AS Avg_Product_Price,
ROUND(AVG(op.payment_value),2) AS Avg_Payment_Value
FROM customers_dataset c
JOIN orders_dataset o 
ON c.customer_id = o.customer_id
JOIN order_items oi 
ON o.order_id = oi.order_id
JOIN order_payments op 
ON o.order_id = op.order_id
WHERE LOWER(c.customer_city) = 'sao paulo'
AND oi.price IS NOT NULL
AND op.payment_value IS NOT NULL;

-- 5 Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores..
SELECT 
r.review_score,

round(AVG(
DATEDIFF(o.order_delivered_customer_date,
o.order_purchase_timestamp)
)) AS Avg_Shipping_Days,

COUNT(o.order_id) AS Total_Orders

FROM orders_dataset o
JOIN order_reviews r
ON o.order_id = r.order_id

WHERE o.order_delivered_customer_date IS NOT NULL

GROUP BY r.review_score
ORDER BY r.review_score;

-- 6 Top 10 Expensive Product Categories (Price wise)
SELECT 
p.product_category_name,
ROUND(sum(oi.price),2) AS Total_Price
FROM order_items oi
JOIN products_dataset p
ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY Total_Price DESC
LIMIT 10;

-- 7 Top 10 Cities by Number of Orders
SELECT 
c.customer_city,
COUNT(o.order_id) AS Total_Orders
FROM customers_dataset c
JOIN orders_dataset o
ON c.customer_id = o.customer_id
GROUP BY c.customer_city
ORDER BY Total_Orders DESC
LIMIT 10;

-- 8 Sales Trend Over Time

SELECT Month_Name,Total_Sales from(
SELECT
MONTH(o.order_purchase_timestamp) as Month_No,
MONTHNAME(o.order_purchase_timestamp) AS Month_Name,
ROUND(SUM(p.payment_value),2) AS Total_Sales
FROM orders_dataset o
JOIN order_payments p
ON o.order_id = p.order_id
GROUP BY Month_Name,Month_No
ORDER BY Month_no)a;

-- 9 Sales by Product Category
SELECT 
p.product_category_name,
ROUND(SUM(oi.price),2) AS Total_Sales
FROM order_items oi
JOIN products_dataset p
ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY Total_Sales DESC
LIMIT 10;

-- 10 Orders by Order Status
SELECT 
order_status,
COUNT(order_id) AS Total_Orders
FROM orders_dataset
GROUP BY order_status
ORDER BY Total_Orders DESC;

-- 11 Sales by Customer State
SELECT 
c.customer_state,
COUNT(op.payment_value) AS Total_Sales
FROM customers_dataset c
JOIN orders_dataset o
ON c.customer_id = o.customer_id
JOIN order_payments op
ON o.order_id = op.order_id
GROUP BY c.customer_state
ORDER BY Total_Sales DESC;

-- 12 Top Sellers by Revenue
SELECT 
oi.seller_id,
ROUND(SUM(oi.price),2) AS Revenue
FROM order_items oi
GROUP BY oi.seller_id
ORDER BY Revenue DESC
LIMIT 5;

-- 13 Payment Installments Analysis
SELECT 
payment_installments,
COUNT(order_id) AS Total_Orders
FROM order_payments
GROUP BY payment_installments
ORDER BY payment_installments;
