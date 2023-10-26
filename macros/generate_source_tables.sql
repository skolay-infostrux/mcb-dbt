{% macro generate_source_tables(database,schema,table_name) %}

{%- set source_list_query %}

    SELECT table_name,table_schema
      FROM {{database}}.information_schema.tables
     WHERE table_type='BASE TABLE'
    {%- if schema -%}
    AND table_schema= '{{schema}}'
    {%- endif -%}
    {% if table_name  %}
    AND table_name= '{{table_name}}'
    {%- endif -%}

{%- endset %}
{%- set source_list_results = run_query(source_list_query) -%}
{{ return (source_list_results) }}

{% endmacro %}
