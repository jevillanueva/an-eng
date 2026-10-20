{{
    config(
        materialized='incremental',
        unique_key='month'
    )
}}
select
    date_trunc('month', order_date) as month,
    sum(order_amount) as total_revenue
from {{ref('stg_orders_basic')}}
group by 1

{% if is_incremental() %}
having date_trunc('month', order_date) > (select max(month) from {{ this }})
{% endif %}