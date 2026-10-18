{%
    macro clean_customer_name(column_name)
%}
    nullif(upper(trim({{ column_name }})), '')
{% endmacro %}