{{
    config(
        materialized='view'
    )
}}
 
SELECT
    order_id,
    customer_id,
    product_name,
    product_category as category,
    quantity,
    price,
    quantity * price as total_amount
FROM {{ source('demo_dag_sources', 'orders') }}
