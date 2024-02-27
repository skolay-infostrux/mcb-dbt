{{ config(
    tags=["report","log"],
    alias='dbt_run',
    schema='log'
    )
}}

select 
		drr.run_info:metadata:invocation_id::string as INVOCATION_ID
        , drr.run_info:metadata:project_name::string as PROJECT_NAME
        , drr.run_info:metadata:status::string as PROJECT_EXECUTION_STATUS 
		, drr.run_info:elapsed_time::float as ELAPSED_TIME
		, r.value:unique_id::string as MODEL_PATH
        , r.value:name::string as MODEL_NAME
        , r.value:database::string as DATABASE_NAME
        , r.value:schema::string  as SCHEMA_NAME
        , r.value:alias::string as TABLE_NAME                
        , r.value:status::string as STATUS
        , r.value:started_at::datetime as STARTED_AT
        , r.value:completed_at::datetime as COMPLETED_AT
        , r.value:execution_time::float as EXECUTION_TIME
		, r.value:rows_affected::int as ROWS_AFFECTED
		, r.value:thread_id::string as THREAD_NO
		, r.value:query_id::string as QUERY_ID
		, r.value:error_message::string as ERROR_MESSAGE
    from {{ var('project_database_prefix') }}_{{ target.name }}_log.{{ env_var('DBT_SNOWFLAKE_SCHEMA_PREFIX', '') }}dbt_run_results.run_results drr
        , lateral flatten(input => drr.run_info, path => 'results') as r