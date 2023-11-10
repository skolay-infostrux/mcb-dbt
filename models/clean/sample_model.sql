{{ config(
    alias='sample_model',
    schema='public',
    materialized='table'
	)
}}

  {% set get_date_statement %}
      SELECT CURRENT_TIMESTAMP();
{% endset %}

  {%- set get_date_result = dbt_utils.get_single_value(get_date_statement, default="'1900-01-01'") -%}
SELECT
'{{get_date_result}}' AS EXECUTED_TIMESTAMP,
'To Test macros' AS LOG_MESSAGE
