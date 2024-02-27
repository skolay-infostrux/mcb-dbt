{{ config(
    tags=["integrate","prepaid"],
    alias='balance_fact',
    schema='prepaid'
    )
}}
with latest_balance_date as
(
    select 
        ACCOUNT_NUMBER
        , CUST_ACCOUNT_ID
        , PAYMENT_PROCESSOR
        , max(CURRENT_BALANCE_DATE) as MAX_BALANCE_DATE
    from {{ ref('prepaid__normalize_balance') }}
    group by ACCOUNT_NUMBER, CUST_ACCOUNT_ID, PAYMENT_PROCESSOR
)
select 
    c.ACCOUNT_SK
    , a.ACCOUNT_NUMBER as ACCOUNT_ID
    , a.CUST_ACCOUNT_ID as CUSTOMER_ID
    , a.CURRENT_BALANCE
    , a.CURRENT_BALANCE_DATE
    , a.AVAILABLE_BALANCE
    , a.NEGATIVE_BALANCE_DATE
    , a.NEGATIVE_BALANCE_FEE
    , a.CURRENCY as CURRENCY_CODE
    , (case a.CURRENCY
        when 'USD' then 1
        else null
      end)  as FX_RATE
    , a.PAYMENT_PROCESSOR as PROCESSOR_NAME   
from {{ ref('prepaid__normalize_balance') }} a
    inner join latest_balance_date b
        on trim(a.ACCOUNT_NUMBER) = trim(b.ACCOUNT_NUMBER) 
            and trim(a.CUST_ACCOUNT_ID) = trim(b.CUST_ACCOUNT_ID)
            and trim(a.PAYMENT_PROCESSOR) = trim(b.PAYMENT_PROCESSOR)
            and a.CURRENT_BALANCE_DATE = b.MAX_BALANCE_DATE

    left join {{ ref('prepaid__integrate_account') }} c
        on trim(a.ACCOUNT_NUMBER) = trim(c.ACCOUNT_ID) 
            and trim(a.PAYMENT_PROCESSOR) = trim(c.PROCESSOR_NAME)
