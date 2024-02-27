{% macro create_table_raw_compliant() %}
--COMPLIANT
    {% for processor_name in var('v_compliant_processors') %}
        {% set sql %}
            --create TRANSIENT table RAW_ACCOUNT
            CREATE TABLE IF NOT EXISTS
            {{ var('project_database_prefix') }}_{{ target.name }}_INGEST.{{ env_var('DBT_SNOWFLAKE_SCHEMA_PREFIX', '') }}{{ processor_name }}.RAW_ACCOUNT (
                DATA_REC VARCHAR(16777216),
                FILE_ROW_NUMBER NUMBER(18,0),
	            FILE_NAME VARCHAR(100),
	            FILE_ROW_KEY VARCHAR(50),
	            FILE_INSERT_TS TIMESTAMP_NTZ(9),
	            MAX_ROW_NUMBER NUMBER(18,0)
            );
        {% endset %}
        {% do run_query(sql) %}
        {% do log(processor_name ~ ": RAW_ACCOUNT Table creation statement executed", info=True) %}  

        {% set sql %}
            --create TRANSIENT table RAW_BALANCE
            CREATE TABLE IF NOT EXISTS
            {{ var('project_database_prefix') }}_{{ target.name }}_INGEST.{{ env_var('DBT_SNOWFLAKE_SCHEMA_PREFIX', '') }}{{ processor_name }}.RAW_BALANCE (
                DATA_REC VARCHAR(16777216),
                FILE_ROW_NUMBER NUMBER(18,0),
	            FILE_NAME VARCHAR(100),
	            FILE_ROW_KEY VARCHAR(50),
	            FILE_INSERT_TS TIMESTAMP_NTZ(9),
	            MAX_ROW_NUMBER NUMBER(18,0)
            );
        {% endset %}
        {% do run_query(sql) %}
        {% do log(processor_name ~ ": RAW_BALANCE Table creation statement executed", info=True) %}  

        {% set sql %}
            --create TRANSIENT table RAW_CUSTOMER
            CREATE TABLE IF NOT EXISTS
            {{ var('project_database_prefix') }}_{{ target.name }}_INGEST.{{ env_var('DBT_SNOWFLAKE_SCHEMA_PREFIX', '') }}{{ processor_name }}.RAW_CUSTOMER (
                DATA_REC VARCHAR(16777216),
                FILE_ROW_NUMBER NUMBER(18,0),
	            FILE_NAME VARCHAR(100),
	            FILE_ROW_KEY VARCHAR(50),
	            FILE_INSERT_TS TIMESTAMP_NTZ(9),
	            MAX_ROW_NUMBER NUMBER(18,0)
            );
        {% endset %}
        {% do run_query(sql) %}
        {% do log(processor_name ~ ": RAW_CUSTOMER Table creation statement executed", info=True) %}  

        {% set sql %}
            --create TRANSIENT table RAW_TRANSACTION
            CREATE TABLE IF NOT EXISTS
            {{ var('project_database_prefix') }}_{{ target.name }}_INGEST.{{ env_var('DBT_SNOWFLAKE_SCHEMA_PREFIX', '') }}{{ processor_name }}.RAW_TRANSACTION (
                DATA_REC VARCHAR(16777216),
                FILE_ROW_NUMBER NUMBER(18,0),
	            FILE_NAME VARCHAR(100),
	            FILE_ROW_KEY VARCHAR(50),
	            FILE_INSERT_TS TIMESTAMP_NTZ(9),
	            MAX_ROW_NUMBER NUMBER(18,0)
            );
        {% endset %}
        {% do run_query(sql) %}
        {% do log(processor_name ~ ": RAW_TRANSACTION Table creation statement executed", info=True) %} 

        {% set sql %}
            --create TRANSIENT table RAW_LOOKUP
            CREATE TABLE IF NOT EXISTS
            {{ var('project_database_prefix') }}_{{ target.name }}_INGEST.{{ env_var('DBT_SNOWFLAKE_SCHEMA_PREFIX', '') }}{{ processor_name }}.RAW_LOOKUP (
                DATA_REC VARCHAR(16777216),
                FILE_ROW_NUMBER NUMBER(18,0),
	            FILE_NAME VARCHAR(100),
	            FILE_ROW_KEY VARCHAR(50),
	            FILE_INSERT_TS TIMESTAMP_NTZ(9),
	            MAX_ROW_NUMBER NUMBER(18,0)
            );
        {% endset %}
        {% do run_query(sql) %}
        {% do log(processor_name ~ ": RAW_LOOKUP Table creation statement executed", info=True) %} 

        {% set sql %}
            --create TRANSIENT table RAW_RECON
            CREATE TABLE IF NOT EXISTS
            {{ var('project_database_prefix') }}_{{ target.name }}_INGEST.{{ env_var('DBT_SNOWFLAKE_SCHEMA_PREFIX', '') }}{{ processor_name }}.RAW_RECON (
                DATA_REC VARCHAR(16777216),
                FILE_ROW_NUMBER NUMBER(18,0),
	            FILE_NAME VARCHAR(100),
	            FILE_ROW_KEY VARCHAR(50),
	            FILE_INSERT_TS TIMESTAMP_NTZ(9),
	            MAX_ROW_NUMBER NUMBER(18,0)
            );
        {% endset %}
        {% do run_query(sql) %}
        {% do log(processor_name ~ ": RAW_RECON Table creation statement executed", info=True) %}    
    {% endfor %}
{% endmacro %}