{{
    config(
        materialized='table'
    )
}}

SELECT
    customer_id,
    customer_name,
    country
FROM {{ ref('stg_customers') }}