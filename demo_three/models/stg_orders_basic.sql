{{
    config(
        materialized='ephemeral'
    )
}}
select 
    order_id,
    order_date,
    customer_id,
    order_amount,
    upper(status) as status
from demo_three.raw_orders