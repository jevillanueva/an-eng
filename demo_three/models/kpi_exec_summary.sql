{{
    config(
        materialized='table'
    )
}}
with base as(
    select
    coalesce(r.month, a.month, t.month) as month,
    r.total_revenue,
    a.average_order_value,
    t.retention_rate
    from {{ref('kpi_revenue')}} r
    full join {{ref('kpi_aov')}} a
    on r.month = a.month
    full join {{ref('kpi_retention')}} t
    on t.month = coalesce(r.month, a.month)
)
select *
from base
order by month