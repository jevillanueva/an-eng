{{
    config(
        materialized='view'
    )
}}
SELECT
    customer_id,
    -- Apply Macro
    {{ clean_customer_name('customer_name') }} as customer_name,
    -- simple email normalization
    lower(trim(email)) as email,
    -- normalize country
    {{ clean_customer_name('country') }} as country
FROM demo_three.customers_raw