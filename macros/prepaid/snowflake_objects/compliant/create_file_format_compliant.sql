{% macro create_file_format_compliant() %}
    {% for processor_name in var('v_compliant_processors') %}
        {% set sql %}
            --create File Format
            CREATE FILE FORMAT IF NOT EXISTS
            {{ var('project_database_prefix') }}_{{ target.name }}_INGEST.{{ env_var('DBT_SNOWFLAKE_SCHEMA_PREFIX', '') }}{{ processor_name }}.FF_COMPLIANT_{{ processor_name }} 
                FIELD_DELIMITER = 'NONE'
	            TRIM_SPACE = TRUE
                COMMENT='COMPLIANT PREPAID FILE FORMAT'
                ;
        {% endset %}
        {% do run_query(sql) %}
        {% do log("FF_COMPLIANT_" ~ processor_name ~ ": File Format creation statement executed", info=True) %}  
    {% endfor %}   
{% endmacro %}