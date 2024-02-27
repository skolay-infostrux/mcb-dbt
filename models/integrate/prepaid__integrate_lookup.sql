{{ config(
    tags=["integrate","prepaid"],
    alias='lookup',
    schema='prepaid'
    )
}}

select
    (case when (FILE_TYPE = 'C')
            then 'CUSTOMER'
          when (FILE_TYPE = 'A')
            then 'ACCOUNT'
          when (FILE_TYPE = 'P')
            then 'TRANSACTION'
          else FILE_TYPE
    end) as ENTITY_NAME
    , FIELD_NAME
    , CODE
    , DESCRIPTION
    , '' as OTHER_INFO
    , PAYMENT_PROCESSOR as PROCESSOR_NAME
from {{ ref('prepaid__normalize_lookup') }}
