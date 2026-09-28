SELECT
{{ dynamic_total_sales('order_amount', 'order_amount') }}
FROM {{ref('orders_model')}}