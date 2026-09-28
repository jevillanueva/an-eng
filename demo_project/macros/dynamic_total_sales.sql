{% macro dynamic_total_sales(column_name='1', alias='total_sales') %}
    SUM({{ column_name }}) AS {{ alias }}
{% endmacro %}
