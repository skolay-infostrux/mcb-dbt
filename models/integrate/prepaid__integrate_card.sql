{{ config(
    tags=["integrate","prepaid"],
    alias='card_dim',
    schema='prepaid'
    )
}}

select 
    a.CARD_ID
    , a.TYPE_OF_CARD as CARD_TYPE
    , a.ACCOUNT_CREATED_DATE as CARD_VALIDITY_DATE
    , a.ACCOUNT_EXPIRATION_DATE as CARD_EXPIRATION_DATE
    , a.ACCOUNT_STATUS as CARD_STATUS
    , a.RELOADABLE_INDICATOR
    , b.PROGRAM_ID
    , b.PROGRAM_DESCRIPTION
    , c.PRODUCT_ID
    , c.PRODUCT_DESCRIPTION
    , a.GROUP_ID
    , '' as OTHER_INFO
    , a.ACCOUNT_CREATED_DATE as CREATED_DATE
    , a.LAST_UPDATED_DATE
    , a.PAYMENT_PROCESSOR as PROCESSOR_NAME
from {{ ref('prepaid__normalize_account') }} a
    left join {{ var('project_database_prefix') }}_{{ target.name }}_analyze.{{ env_var('DBT_SNOWFLAKE_SCHEMA_PREFIX', '') }}common_dim.program_dim b 
		on to_varchar(a.PROGRAM_ID) = b.PROGRAM_ID

    left join {{ var('project_database_prefix') }}_{{ target.name }}_analyze.{{ env_var('DBT_SNOWFLAKE_SCHEMA_PREFIX', '') }}common_dim.product_dim c 
		on to_varchar(a.PRODUCT_ID) = c.PRODUCT_ID
