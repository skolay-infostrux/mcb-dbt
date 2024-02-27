{{ config(
    tags=["normalize","prepaid"],
    alias='customer',
    schema='prepaid'
    )
}}


{%- set fields = ["CUST_ACCOUNT_ID","FIRST_NAME","LAST_NAME","ADDRESS_1","ADDRESS_2","CITY","STATE","ZIP","COUNTRY","PRIMARY_PHONE_NUMBER","SECONDARY_PHONE_NUMBER","DATE_OF_BIRTH"
    ,"ID_TYPE","ID_NUMBER","ID_STATE","ID_COUNTRY","ID_ISSUED_DATE","ID_EXPIRE_DATE","ID_2","ID_TYPE2","SSN","TIN_TYPE","PROGRAM_ID","CUST_STATUS","CREATED_DATE","LAST_UPDATED_DATE"
    ,"OTHER_INFO","EMAIL","PRN","EXTERNAL_ACCOUNT_NUMBER","BILL_CYCLE_DAY","LOCATION_ID","AGENT_USER_ID","USER_DATA","USER_DATA2","SURROGATE_PROXY_TOKEN_UNIQUE_ID","PRODUCT_ID"
    ,"ID_PASS","ID_OVERRIDE","COMPANY_NAME","EIN","BUSINESS_ADDRESS_1","BUSINESS_ADDRESS_2","BUSINESS_ADDRESS_3","BUSINESS_CITY","BUSINESS_STATE","BUSINESS_ZIP","BUSINESS_COUNTRY"
    ,"CUST_ACCOUNT_TYPE","COUNTRY_CITIZENSHIP","PAYMENT_PROCESSOR"] -%}

select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}      
from {{ ref('buckzy__stg_generic_customer') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('cascade__stg_generic_customer') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('equals__stg_generic_customer') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('ficentive__stg_generic_customer') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('firstview__stg_generic_customer') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('fisbambu__stg_generic_customer') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('fiss__stg_generic_customer') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('i2c__stg_generic_customer') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('revolut__stg_generic_customer') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('thunes__stg_generic_customer') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('b4b__stg_generic_customer') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('galileo__stg_generic_customer') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('corecard__stg_generic_customer') }}