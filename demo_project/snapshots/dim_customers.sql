{% snapshot dim_customers %}
{{
    config(
        target_schema='demo_project',
        unique_key='customer_id',
        strategy='timestamp',
        updated_at='updated_at'
        )
}}

select
    customer_id,
    customer_name,
    city,
    updated_at
from public.raw_customers

{% endsnapshot %}
