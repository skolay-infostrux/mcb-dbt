{% macro cleanup_table() %}

{%- set source_list_query %}

    delete from {{this}}"

{%- endset %}

{%- set source_list_results = run_query(source_list_query) -%}

{% endmacro %}
