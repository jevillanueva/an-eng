CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS mart;

-- RAW SCHEMA

DROP TABLE IF EXISTS raw.raw_orders;

CREATE TABLE IF NOT EXISTS raw.raw_orders (
    order_id TEXT,
    order_date TEXT,
    customer_name TEXT,
    product_name TEXT,
    quantity TEXT,
    total_amount TEXT
);

-- unclean raw orders data
INSERT INTO raw.raw_orders VALUES
('001', '2025-01-01', 'alice johnson', 'Running Shoes ', '2', '240'),
('002', '2025/01/02', 'bob smith', 'formal shirt', '1', '50'),
('003', '01-02-2025', 'carol white', 'jeans', '3', '150'),
('004', '', 'david brown', 'sneakers', '1', '120 '),
('005', '2025-01-05', 'emma davis', 't-shirt', '2', '40'),
('006', '2025-01-06', 'frank miller', 'hoodie', '1', '60'),
('007', '2025-01-07', 'grace lee', 'socks', '5', '25.00');

-- STAGING SCHEMA

DROP TABLE IF EXISTS staging.stg_orders;

CREATE TABLE IF NOT EXISTS staging.stg_orders (
    order_id INT,
    order_date DATE,
    customer_name VARCHAR(100),
    product_name VARCHAR(100),
    quantity INT,
    total_amount NUMERIC(10, 2)
);

-- Transform and load raw orders data into staging table
INSERT INTO staging.stg_orders
SELECT
    order_id::INT,
    CASE
        WHEN order_date IS NULL or order_date = '' THEN NULL
        WHEN order_date ~ '^\d{4}/\d{2}/\d{2}$' THEN TO_DATE(order_date, 'YYYY/MM/DD')
        WHEN order_date ~ '^\d{4}-\d{2}-\d{2}$' THEN TO_DATE(order_date, 'YYYY-MM-DD')
        WHEN order_date ~ '^\d{2}-\d{2}-\d{4}$' THEN TO_DATE(order_date, 'DD-MM-YYYY')
        ELSE NULL
    END as order_date,
    INITCAP(TRIM(customer_name)) as customer_name,
    INITCAP(TRIM(product_name)) as product_name,
    COALESCE(NULLIF(quantity, ''), '0')::INT as quantity,
    TRIM(total_amount)::NUMERIC as total_amount
FROM raw.raw_orders;



DROP TABLE IF EXISTS mart.dim_product;
DROP TABLE IF EXISTS mart.dim_customer;
DROP TABLE IF EXISTS mart.dim_date;

CREATE TABLE IF NOT EXISTS mart.dim_product (
    product_key SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    brand VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS mart.dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_name VARCHAR(100),
    region VARCHAR(50),
    city VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS mart.dim_date (
    date_key DATE PRIMARY KEY,
    year INT,
    month INT,
    day INT,
    weekday VARCHAR(15)
);

-- MART SCHEMA
DROP TABLE IF EXISTS mart.fct_orders;

CREATE TABLE IF NOT EXISTS mart.fct_orders (
    order_id INT PRIMARY KEY,
    date_key DATE REFERENCES mart.dim_date(date_key),
    customer_key INT REFERENCES mart.dim_customer(customer_key),
    product_key INT REFERENCES mart.dim_product(product_key),
    quantity INT,
    total_amount NUMERIC(10, 2)
);



INSERT INTO mart.dim_product(product_name, category, brand)
SELECT DISTINCT
    s.product_name,
    CASE
        WHEN s.product_name ILIKE '%shoe%' THEN 'Footwear'
        WHEN s.product_name ILIKE '%shirt%' THEN 'Apparel'
        WHEN s.product_name ILIKE '%jeans%' THEN 'Apparel'
        WHEN s.product_name ILIKE '%sneakers%' THEN 'Footwear'
        WHEN s.product_name ILIKE '%t-shirt%' THEN 'Apparel'
        WHEN s.product_name ILIKE '%hoodie%' THEN 'Apparel'
        WHEN s.product_name ILIKE '%socks%' THEN 'Apparel'
        ELSE 'Other'
    END as category,
    'Generic' as brand
FROM staging.stg_orders s
LEFT JOIN mart.dim_product p
ON s.product_name = p.product_name
WHERE p.product_key IS NULL;

INSERT INTO dim_customer(customer_name, region, city)
SELECT DISTINCT
    s.customer_name,
    'Unknown Region' as region,
    'Unknown City' as city
FROM staging.stg_orders s
LEFT JOIN mart.dim_customer c
ON s.customer_name = c.customer_name
WHERE c.customer_key IS NULL;

INSERT INTO mart.dim_date(date_key, year, month, day, weekday)
SELECT DISTINCT
    s.order_date as date_key,
    EXTRACT(YEAR FROM s.order_date)::INT as year,
    EXTRACT(MONTH FROM s.order_date)::INT as month,
    EXTRACT(DAY FROM s.order_date)::INT as day,
    TO_CHAR(s.order_date, 'Day') as weekday
FROM staging.stg_orders s
LEFT JOIN mart.dim_date d
ON s.order_date = d.date_key
WHERE d.date_key IS NULL AND s.order_date IS NOT NULL;

-- INSERT DATA INTO FACT TABLE
INSERT INTO mart.fct_orders (
    order_id,
    date_key,
    customer_key,
    product_key,
    quantity,
    total_amount
)
SELECT
    s.order_id,
    s.order_date as date_key,
    c.customer_key,
    p.product_key,
    s.quantity,
    s.total_amount
FROM staging.stg_orders s
LEFT JOIN mart.dim_customer c
ON LOWER(TRIM(s.customer_name)) = LOWER(TRIM(c.customer_name))
LEFT JOIN mart.dim_product p
ON LOWER(TRIM(s.product_name)) = LOWER(TRIM(p.product_name));

-- TEST
SELECT
f.order_id,
s.order_date,
s.customer_name,
s.product_name,
f.customer_key,
f.product_key
FROM mart.fct_orders f
JOIN staging.stg_orders s
ON f.order_id = s.order_id
WHERE f.customer_key IS NULL OR f.product_key IS NULL;

-- Total revenue and AOV (Average Order Value)

SELECT
    p.category,
    SUM(f.total_amount) AS total_revenue
FROM mart.fct_orders f
JOIN mart.dim_product p ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;

SELECT
    c.region,
    SUM(f.total_amount) AS total_revenue
FROM mart.fct_orders f
JOIN mart.dim_customer c ON f.customer_key = c.customer_key
GROUP BY c.region
ORDER BY total_revenue DESC;

SELECT
    ROUND(SUM(total_amount)/COUNT(order_id),2) AS avg_order_value
FROM mart.fct_orders;

SELECT
    p.category,
    SUM(f.total_amount) AS total_revenue,
    ROUND(SUM(f.total_amount)/COUNT(f.order_id),2) AS avg_order_value
FROM mart.fct_orders f
JOIN mart.dim_product p ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;
