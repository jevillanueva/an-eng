{% macro dynamic_total_sales_2(source_relation, amount_column, where_clause=None) %}
    SELECT SUM({{ amount_column }}) AS total_sales
    FROM {{ source_relation }}
    {% if where_clause is not none %}
    WHERE {{ where_clause }}
    {% endif %}
{% endmacro %}