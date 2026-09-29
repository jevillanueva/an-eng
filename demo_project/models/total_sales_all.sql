{{
    dynamic_total_sales_2(
        source_relation=ref('orders_model'),
        amount_column='order_amount'
    )
}}