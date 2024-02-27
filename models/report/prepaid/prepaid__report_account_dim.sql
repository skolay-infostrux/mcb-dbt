{{ config(
    tags=["report","prepaid"],
    alias='account_dim',
    schema='prepaid'
    )
}}

select
    {{ dbt_utils.star(from=ref('prepaid__analyze_account_dim')) }}
from {{ ref('prepaid__analyze_account_dim') }}
