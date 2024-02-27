{{ config(
    tags=["report","prepaid"],
    alias='balance_snapshot_fact',
    schema='prepaid'
    )
}}

select
    {{ dbt_utils.star(from=ref('prepaid__analyze_balance_fact')) }}
from {{ ref('prepaid__analyze_balance_fact') }}
