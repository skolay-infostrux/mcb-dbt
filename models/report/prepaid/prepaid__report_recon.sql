{{ config(
    tags=["report","prepaid"],
    alias='recon',
    schema='prepaid'
    )
}}

select
    {{ dbt_utils.star(from=ref('prepaid__analyze_recon')) }}
from {{ ref('prepaid__analyze_recon') }}
