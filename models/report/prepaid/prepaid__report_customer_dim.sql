{{ config(
    tags=["report","prepaid"],
    alias='customer_dim',
    schema='prepaid'
    )
}}

select
    {{ dbt_utils.star(from=ref('prepaid__analyze_customer_dim')) }}
from {{ ref('prepaid__analyze_customer_dim') }}
