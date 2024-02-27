{{ config(
    tags=["integrate","prepaid"],
    alias='account_dim',
    schema='prepaid'
    )
}}

select 
    DISTINCT a.SURROGATE_PROXY_TOKEN_UNIQUE_ID as ACCOUNT_SK
    , a.ACCOUNT_NUMBER as ACCOUNT_ID
    , b.EXTERNAL_ACCOUNT_NUMBER as EXTERNAL_ACCOUNT_ID 
    , a.CUST_ACCOUNT_ID as CUSTOMER_ID
    , a.ACCOUNT_CREATED_DATE as ACCOUNT_CREATED_DATE
    , a.ACCOUNT_EXPIRATION_DATE
    , a.ACCOUNT_STATUS
    , a.CARD_ID
    , c.PROGRAM_ID
    , c.PROGRAM_DESCRIPTION
    , d.PRODUCT_ID
    , d.PRODUCT_DESCRIPTION
    , a.PRN
    , b.BILL_CYCLE_DAY
    , a.LAST_TRANSACTION_DATE
    , a.PSEUDO_DDA
    , '' OTHER_INFO
    , a.ACCOUNT_CREATED_DATE as CREATED_DATE
	, a.LAST_UPDATED_DATE
    , a.PAYMENT_PROCESSOR as PROCESSOR_NAME
from {{ ref('prepaid__normalize_account') }} a
    left join  {{ ref('prepaid__normalize_customer') }} b 
        on trim(a.CUST_ACCOUNT_ID) = trim(b.CUST_ACCOUNT_ID) and trim(a.PAYMENT_PROCESSOR) = trim(b.PAYMENT_PROCESSOR)

    left join {{ var('project_database_prefix') }}_{{ target.name }}_analyze.{{ env_var('DBT_SNOWFLAKE_SCHEMA_PREFIX', '') }}common_dim.program_dim c 
		on to_varchar(a.PROGRAM_ID) = c.PROGRAM_ID

    left join {{ var('project_database_prefix') }}_{{ target.name }}_analyze.{{ env_var('DBT_SNOWFLAKE_SCHEMA_PREFIX', '') }}common_dim.product_dim d 
		on to_varchar(a.PRODUCT_ID) = d.PRODUCT_ID

