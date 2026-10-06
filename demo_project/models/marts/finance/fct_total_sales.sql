{{
    dynamic_total_sales_2(
        source_relation=ref('stg_orders'),
        amount_column='order_amount'
    )
}}