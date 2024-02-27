{{ config(
    tags=["analyze","prepaid"],
    alias='account_dim',
    schema='prepaid',
    materialized='incremental',
    incremental_strategy="append"
    )
}}

select
    {{ dbt_utils.star(from=ref('prepaid__integrate_account')) }}
    , current_date() + {{ var('business_date_adjuster') }} as BUSINESS_DATE
    , current_date() as LOAD_DATE
from {{ ref('prepaid__integrate_account') }}
