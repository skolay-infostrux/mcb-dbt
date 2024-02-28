{{ config(
    tags=["clean","b4b","compliant"],
    schema='b4b',
    pre_hook="

        copy into {{ var('project_database_prefix') }}_{{ target.name }}_INGEST.{{ env_var('DBT_SNOWFLAKE_SCHEMA_PREFIX', '') }}B4B.RAW_ACCOUNT(DATA_REC,FILE_ROW_NUMBER,FILE_NAME,FILE_ROW_KEY,FILE_INSERT_TS,MAX_ROW_NUMBER) 
            from (
                select 
                    $1  as DATA_REC
                    ,metadata$file_row_number as FILE_ROW_NUMBER
                    ,metadata$filename as FILE_NAME
                    ,CAST( MD5( NVL(CAST(DATA_REC as varchar),'null') ) as varchar ) as FILE_ROW_KEY
                    ,current_timestamp as FILE_INSERT_TS
                    ,max(metadata$file_row_number) OVER (PARTITION BY metadata$filename ) as MAX_ROW_NUMBER
                from '@{{ var('project_database_prefix') }}_{{ target.name }}_INGEST.{{ env_var('DBT_SNOWFLAKE_SCHEMA_PREFIX', '') }}B4B.EXT_STG_PREPAID/COMPLIANT/'
            ) 
        FILE_FORMAT = (FORMAT_NAME={{ var('project_database_prefix') }}_{{ target.name }}_INGEST.{{ env_var('DBT_SNOWFLAKE_SCHEMA_PREFIX', '') }}B4B.FF_COMPLIANT_B4B)
        PATTERN = '.*/B4_ACCT_.*.TXT.*';
        "  
    )
}}

{{ generate_stg_compliant_account('raw_data_b4b','raw_account','y') }}