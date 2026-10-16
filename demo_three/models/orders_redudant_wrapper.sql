{{
    config(
        materialized='view'
    )
}}
-- This model is intetionally redudant
-- it just select * from another model without changes
select *
from {{ ref('orders_enriched') }}