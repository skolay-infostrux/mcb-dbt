{{ config(
    tags=["normalize","prepaid"],
    alias='lookup',
    schema='prepaid'
    )
}}


{%- set fields = ["FILE_TYPE","FIELD_NAME","CODE","DESCRIPTION","PAYMENT_PROCESSOR"] -%}

select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}      
from {{ ref('buckzy__stg_generic_lookup') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('cascade__stg_generic_lookup') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('equals__stg_generic_lookup') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('ficentive__stg_generic_lookup') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('firstview__stg_generic_lookup') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('fisbambu__stg_generic_lookup') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('fiss__stg_generic_lookup') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('i2c__stg_generic_lookup') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('revolut__stg_generic_lookup') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('thunes__stg_generic_lookup') }}
union all
select     
    {%- for field in fields %}
    {{ field }} 
    {%- if not loop.last -%} , {%- endif -%}
    {% endfor %}
from {{ ref('b4b__stg_generic_lookup') }}