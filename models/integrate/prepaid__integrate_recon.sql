{{ config(
    tags=["integrate","prepaid"],
    alias='recon',
    schema='prepaid'
    )
}}

select    
    CUST_ACCOUNT_ID as CUSTOMER_ID        
    , ACCOUNT_NUMBER as ACCOUNT_ID
    , TRANSACTION_ID   
    , PAYMENT_PROCESSOR as PROCESSOR_NAME
from {{ ref('prepaid__normalize_recon') }}
