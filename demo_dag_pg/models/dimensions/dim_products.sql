{{
    config(
        materialized='table'
    )
}}
SELECT
    product_name,
    category
FROM {{ ref('stg_orders') }}