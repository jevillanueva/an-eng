{{
    config(
        materialized='table'
    )
}}
select
    date_trunc('month', order_date) as month,
    sum(order_amount) as total_revenue
from {{ref('stg_orders_basic')}}
group by 1
order by 1