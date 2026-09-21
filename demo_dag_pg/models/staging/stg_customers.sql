{{
    config(
        materialized='view'
    )
}}

SELECT
    customer_id,
    customer_name,
    customer_country as country
FROM {{ source('demo_dag_sources', 'customers') }}