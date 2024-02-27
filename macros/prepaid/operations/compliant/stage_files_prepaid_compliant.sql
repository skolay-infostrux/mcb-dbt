{% macro stage_files_prepaid_compliant() %}
{% for processor_name in var('v_compliant_processors') %}
    {% set sql %}
        put {{ var('file_path_compliant_prepaid') }}/{{processor_name}}/* '@{{ var('project_database_prefix') }}_{{ target.name }}_INGEST.{{ env_var('DBT_SNOWFLAKE_SCHEMA_PREFIX', '') }}{{ processor_name }}.STG_PREPAID/COMPLIANT/' 
        ;
    {% endset %}
    {% do run_query(sql) %}
    {% do log(processor_name ~ ": Compliant prepaid files are staged", info=True) %}
{% endfor %}
{% endmacro %}