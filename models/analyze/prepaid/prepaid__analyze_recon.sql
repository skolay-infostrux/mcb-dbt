{{ config(
    tags=["analyze","prepaid"],
    alias='recon',
    schema='prepaid',
    materialized='incremental',
    incremental_strategy="append"
    )
}}
with linked_records as
(
    select 
        DISTINCT a.CUSTOMER_ID
        , b.ACCOUNT_ID
        , c.TRANSACTION_ID
        , a.PROCESSOR_NAME
    from {{ ref('prepaid__integrate_customer') }} a
    inner join  {{ ref('prepaid__integrate_account') }} b 
        on trim(a.CUSTOMER_ID) = trim(b.CUSTOMER_ID) and trim(a.PROCESSOR_NAME) = trim(b.PROCESSOR_NAME)

    inner join  {{ ref('prepaid__integrate_transaction') }} c 
        on trim(b.ACCOUNT_ID) = trim(c.ACCOUNT_ID) and trim(b.PROCESSOR_NAME) = trim(c.PROCESSOR_NAME)
)
select
    main.CUSTOMER_ID
    , main.ACCOUNT_ID
    , main.TRANSACTION_ID
    , main.PROCESSOR_NAME
    , (case when (lr.CUSTOMER_ID is null or lr.ACCOUNT_ID is null or lr.TRANSACTION_ID is null)
                then 'INCOMPLETE'
            else 'COMPLETE'
        end)  as RECON_STATUS
    , (case when (lr.CUSTOMER_ID is null)
                then 'CUSTOMER ID is not present in the Customer Table'
            when (lr.ACCOUNT_ID is null)
                then 'ACCOUNT ID is not present in Account Table'
            when (lr.TRANSACTION_ID is null)
                then 'TRANSACTION ID is not present in the Transaction Table'
            else 'Transaction is linked to both Customer and Account Tables'        
        end) as RECON_RESULTS
    , current_date() + {{ var('business_date_adjuster') }} as BUSINESS_DATE
    , current_date() as LOAD_DATE
from {{ ref('prepaid__integrate_recon') }} main
left join  linked_records lr 
    on trim(main.CUSTOMER_ID) = trim(lr.CUSTOMER_ID) 
        and trim(main.ACCOUNT_ID) = trim(lr.ACCOUNT_ID)
        and trim(main.TRANSACTION_ID) = trim(lr.TRANSACTION_ID) 
        and trim(main.PROCESSOR_NAME) = trim(lr.PROCESSOR_NAME)
