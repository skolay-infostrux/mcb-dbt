{{ config(
    tags=["normalize","prepaid"],
    alias='account',
    schema='prepaid'
    )
}}

{%- set fields = ["CUST_ACCOUNT_ID","ACCOUNT_NUMBER","ACCOUNT_EXPIRATION_DATE"
    ,"ACCOUNT_STATUS","ACCOUNT_CREATED_DATE","LAST_UPDATED_DATE","PRN","PSEUDO_DDA"
    ,"GROUP_ID","PRODUCT_ID","PROGRAM_ID","RELOADABLE_INDICATOR","TYPE_OF_ACCOUNT"
    ,"SURROGATE_PROXY_TOKEN_UNIQUE_ID","CARD_ID","TYPE_OF_CARD","LAST_TRANSACTION_DATE","PAYMENT_PROCESSOR"] -%}

select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}      
from {{ ref('buckzy__stg_generic_account') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('cascade__stg_generic_account') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('equals__stg_generic_account') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('ficentive__stg_generic_account') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('firstview__stg_generic_account') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('fisbambu__stg_generic_account') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('fiss__stg_generic_account') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('i2c__stg_generic_account') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('revolut__stg_generic_account') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('thunes__stg_generic_account') }}
union all

select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('b4b__stg_generic_account') }}
union all

select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('galileo__stg_generic_account') }}
union all

select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('corecard__stg_generic_account') }}


