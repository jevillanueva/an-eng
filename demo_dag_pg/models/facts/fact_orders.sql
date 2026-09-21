{{
    config(
        materialized='incremental',
        unique_key='order_id'
    )
}}

SELECT
    order_id,
    customer_id,
    product_name,
    product_category,
    quantity,
    price,
    quantity * price AS total_amount
FROM {{ source('demo_dag_sources', 'orders_seed') }}

{% if is_incremental() %}
    WHERE order_id > (SELECT MAX(order_id) FROM {{ this }})
{% endif %}