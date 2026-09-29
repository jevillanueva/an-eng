{{
    dynamic_total_sales_2(
        source_relation=ref('orders_model'),
        amount_column='order_amount',
        where_clause="order_date >= date '2024-01-01' and order_date < date '2024-02-01'"
    )
}}