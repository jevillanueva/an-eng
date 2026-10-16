{{
    config(
        materialized='view'
    )
}}
select 
    order_id,
    order_date,
    customer_id,
    order_amount,
    status,
    case
        when order_amount >= 200 THEN 'HIGH'
        when order_amount >= 100 THEN 'MEDIUM'
        else 'LOW'
    end as order_value_band
from {{ ref('stg_orders_basic') }}
