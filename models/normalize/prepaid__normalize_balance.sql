{{ config(
    tags=["normalize","prepaid"],
    alias='balance',
    schema='prepaid'
    )
}}
{%- set fields = ["CUST_ACCOUNT_ID","ACCOUNT_NUMBER","CURRENT_BALANCE","CURRENT_BALANCE_DATE","AVAILABLE_BALANCE"  
    , "NEGATIVE_BALANCE_DATE","NEGATIVE_BALANCE_FEE","CURRENCY","PAYMENT_PROCESSOR"] -%}

select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}      
from {{ ref('buckzy__stg_generic_balance') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('cascade__stg_generic_balance') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('equals__stg_generic_balance') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('ficentive__stg_generic_balance') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('firstview__stg_generic_balance') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('fisbambu__stg_generic_balance') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('fiss__stg_generic_balance') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('i2c__stg_generic_balance') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('revolut__stg_generic_balance') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('thunes__stg_generic_balance') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('b4b__stg_generic_balance') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('galileo__stg_generic_balance') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('corecard__stg_generic_balance') }}