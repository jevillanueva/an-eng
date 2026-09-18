CREATE TABLE dim_product (
  product_key SERIAL PRIMARY KEY,
  product_name VARCHAR(100),
  category VARCHAR(50),
  subcategory VARCHAR(50)
);

CREATE TABLE dim_customer (
  customer_key SERIAL PRIMARY KEY,
  customer_name VARCHAR(100),
  region VARCHAR(50),
  city VARCHAR(50)
);

CREATE TABLE dim_date (
  date_key DATE PRIMARY KEY,
  year INT,
  month INT,
  day INT,
  weekday VARCHAR(15)
);

INSERT INTO dim_product(product_name,category,subcategory) VALUES 
('Running Shoes', 'Footwear', 'Sport'),
('Casual Tshirt', 'Apparel', 'Men'),
('LED TV', 'Electronics', 'Home Enternainment');


INSERT INTO dim_customer(customer_name,region,city) VALUES 
('Alice', 'East', 'New York'),
('Bob', 'West', 'San francisco'),
('Catherine', 'North', 'Chicago');

INSERT INTO dim_date VALUES
('2025-01-01', 2025, 1, 1, 'Wednesday'),
('2025-01-02', 2025, 1, 2, 'Thursday'),
('2025-01-03', 2025, 1, 3, 'Friday');

CREATE TABLE fact_orders(
  order_id SERIAL PRIMARY KEY,
  date_key DATE REFERENCES dim_date(date_key),
  product_key INT REFERENCES dim_product(product_key),
  customer_key INT REFERENCES dim_customer(customer_key),
  quantity INT,
  total_amount NUMERIC (10,2)
);

INSERT INTO fact_orders(date_key,product_key, customer_key,quantity, total_amount) VALUES
('2025-01-01', 1,1,2,240.00),
('2025-01-01', 2,2,1,45.00),
('2025-01-02', 3,3,1,90.00),
('2025-01-03', 1,2,1,120.00),
('2025-01-03', 2,1,3,135.00);

SELECT
  d.date_key,
  c.customer_name,
  p.product_name,
  p.category,
  f.quantity,
  f.total_amount
FROM fact_orders f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_customer c ON f.customer_key = c.customer_key
order by d.date_key;



SELECT
  c.region,
  p.category,
  SUM(f.total_amount) AS total_revenue,
  ROUND(SUM(f.total_amount) / COUNT(DISTINCT f.order_id),2) AS avg_order_value
FROM fact_orders f
JOIN dim_customer c ON f.customer_key = c.customer_key
JOIN dim_product p ON f.product_key = p.product_key
GROUP BY c.region, p.category
ORDER BY total_revenue DESC;


select
  d.year,
  d.month,
  SUM(f.total_amount) as total_revenue
FROM
  fact_orders f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.year, d.month
ORDER BY d.year, d.month;

SELECT SUM(total_revenue)
FROM (
  select
    c.region, SUM(f.total_amount) AS total_revenue
  FROM fact_orders f
  JOIN dim_customer c ON f.customer_key = c.customer_key
  GROUP BY c.region
) AS subquery;
