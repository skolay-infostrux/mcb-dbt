{{ config(
    tags=["normalize","prepaid"],
    alias='transaction',
    schema='prepaid'
    )
}}



{%- set fields = ["PROGRAM_ID","ACCOUNT_NUMBER","TRANSACTION_CODE","TRANSACTION_AMOUNT","TRANSACTION_CURRENCY","TRANSACTION_DESCRIPTION","TRANSACTION_TYPE","TRANSACTION_STATUS",'RESPONSE_CODE',"AUTHORIZATION_CODE","POST_DATE"
    ,"NETWORK_CODE","MERCHANT_NUMBER","MERCHANT_NAME","MERCHANT_CITY","MERCHANT_STATE","MERCHANT_ZIP","MERCHANT_CATEGORY","MERCHANT_COUNTRY","INTERCHANGE_FEE","TRANSACTION_ID","PSEUDO_DDA","CARD_ID","OTHER_DATA1","OTHER_DATA2"
    ,"FOREIGN_TERMINAL","SETTLED_DATE","POS_INDICATOR","CREATED_DATE","LAST_UPDATED_DATE","TRANSACTION_DATE","TRANSACTION_ID_UNIQUE","SURROGATE_PROXY_TOKEN_UNIQUE_ID","PRODUCT_ID","DEBIT_PARTY_TYPE","DEBIT_PARTY_ACCOUNT_NUMBER"
    ,"DEBIT_PARTY_NAME","DEBIT_PARTY_ADDR_1","DEBIT_PARTY_ADDR_2","DEBIT_PARTY_ADDR_3","DEBIT_VALUE_DATE","DEBIT_PARTY_COUNTRY","CREDIT_PARTY_TYPE","CREDIT_PARTY_ACCOUNT_NUMBER","CREDIT_PARTY_NAME","CREDIT_PARTY_ADDR_1"
    ,"CREDIT_PARTY_ADDR_2","CREDIT_PARTY_ADDR_3","CREDIT_VALUE_DATE","CREDIT_PARTY_COUNTRY","INTERMEDIARY_3RD_PARTY_TYPE","INTERMEDIARY_ACCOUNT_3RD_PARTY_ID","INTERMEDIARY_3RD_PARTY_NAME","INTERMEDIARY_3RD_PARTY_ADDR_1"
    ,"INTERMEDIARY_3RD_PARTY_ADDR_2","INTERMEDIARY_3RD_PARTY_ADDR_3","INSTRUCTING_PARTY_NAME","INSTRUCTING_PARTY_ADDR_1","INSTRUCTING_PARTY_ADDR_2","INSTRUCTING_PARTY_ADDR_3","BENEFICIARY_4TH_PARTY_TYPE"
    ,"BENEFICIARY_BANK_ID_4TH_PARTY_ID","BENEFICIARY_BANK_ROUTING_4TH_PARTY_NAME","BENEFICIARY_BANK_4TH_PARTY_ADDR_1","BENEFICIARY_BANK_4TH_PARTY_ADDR_2","BENEFICIARY_BANK_4TH_PARTY_ADDR_3","BENEFICIARY_5TH_PARTY_TYPE"
    ,"BENEFICIARY_ID_5TH_PARTY_ID","BENEFICIARY_NAME_5TH_PARTY_NAME","BENEFICIARY_5TH_PARTY_ADDR_1","BENEFICIARY_5TH_PARTY_ADDR_2","BENEFICIARY_5TH_PARTY_ADDR_3","TRANSACTION_NOTE","ORIGINAL_TRANSACTION_AMOUNT"
    ,"TRANSACTION_AMOUNT_LOCAL","TRANSACTION_CURRENCY_LOCAL_CODE","PAYMENT_PROCESSOR"] -%}

select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}      
from {{ ref('buckzy__stg_generic_transaction') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('cascade__stg_generic_transaction') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('equals__stg_generic_transaction') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('ficentive__stg_generic_transaction') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('firstview__stg_generic_transaction') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('fisbambu__stg_generic_transaction') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('fiss__stg_generic_transaction') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('i2c__stg_generic_transaction') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('revolut__stg_generic_transaction') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('thunes__stg_generic_transaction') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('b4b__stg_generic_transaction') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('galileo__stg_generic_transaction') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('corecard__stg_generic_transaction') }}