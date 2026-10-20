{{
    config(
        materialized='table'
    )
}}
select
    date_trunc('month', order_date) as month,
    avg(order_amount) as average_order_value
from {{ref('stg_orders_basic')}}
group by 1
order by 1
