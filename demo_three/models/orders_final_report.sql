{{
    config(
        materialized='view'
    )
}}
select
    order_value_band,
    count(*) as order_count,
    sum(order_amount) as total_amount
from {{ref('orders_enriched')}}
GROUP BY order_value_band
order by order_value_band