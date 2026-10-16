{{
    config(
        materialized='table'
    )
}}
select
    *,
    case when order_amount < 100 then 'Low'
         when order_amount >= 100 and order_amount < 500 then 'Medium'
         else 'High'
    end as order_value_band
from demo_three.raw_orders