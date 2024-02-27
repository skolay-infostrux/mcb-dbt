{% macro create_log_objects() %}
    --create SCHEMA
    {% set sql %}
        CREATE SCHEMA IF NOT EXISTS {{ var('project_database_prefix') }}_{{ target.name }}_LOG.{{ env_var('DBT_SNOWFLAKE_SCHEMA_PREFIX', '') }}DBT_RUN_RESULTS;
    {% endset %}
    {% do run_query(sql) %}

    --create TABLE
    {% set sql %}
        CREATE TABLE IF NOT EXISTS 
        {{ var('project_database_prefix') }}_{{ target.name }}_LOG.{{ env_var('DBT_SNOWFLAKE_SCHEMA_PREFIX', '') }}DBT_RUN_RESULTS.RUN_RESULTS(
            run_info variant
            );
    {% endset %}
    {% do run_query(sql) %}

    {% do log("Object creation statement in Log DB executed", info=True) %}

{% endmacro %}

