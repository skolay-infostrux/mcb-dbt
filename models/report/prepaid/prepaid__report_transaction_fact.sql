{{ config(
    tags=["report","prepaid"],
    alias='transaction_fact',
    schema='prepaid'
    )
}}

select
    {{ dbt_utils.star(from=ref('prepaid__analyze_transaction_fact')) }}
from {{ ref('prepaid__analyze_transaction_fact') }}
