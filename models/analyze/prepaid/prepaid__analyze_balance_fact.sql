{{ config(
    tags=["analyze","prepaid"],
    alias='balance_snapshot_fact',
    schema='prepaid',
    materialized='incremental',
    incremental_strategy="append"

    )
}}

select
    {{ dbt_utils.star(from=ref('prepaid__integrate_balance')) }}
    , current_date() + {{ var('business_date_adjuster') }}  as BUSINESS_DATE
    , current_date() as LOAD_DATE
from {{ ref('prepaid__integrate_balance') }}
