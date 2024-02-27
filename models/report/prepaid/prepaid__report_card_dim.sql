{{ config(
    tags=["report","prepaid"],
    alias='card_dim',
    schema='prepaid'
    )
}}

select
    {{ dbt_utils.star(from=ref('prepaid__analyze_card_dim')) }}
from {{ ref('prepaid__analyze_card_dim') }}
