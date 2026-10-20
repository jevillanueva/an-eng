{{
    config(
        materialized='table'
    )
}}
with monthly_customers as (
    select
        date_trunc('month', order_date) as month,
        customer_id
    from {{ref('stg_orders_basic')}}
    group by 1, 2
),
curent_last as (
    select
        curr.month,
        count( DISTINCT curr.customer_id) as current_customers,
        count( DISTINCT last.customer_id) as retained_customers
        from monthly_customers curr
        left join monthly_customers last
        on last.customer_id = curr.customer_id
        and last.month = curr.month - interval '1 month'
        group by 1
)
select
    month,
    current_customers,
    retained_customers,
    case 
        when current_customers = 0 then 0
        else round(retained_customers::numeric / current_customers, 2)
    end as retention_rate
from curent_last
order by month