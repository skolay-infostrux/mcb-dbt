{{ config(
    tags=["report","common_dim"],
    alias='date_dim',
    schema='common_dim'
    )
}}

select
    DATE_ID
    , DATE_VAL
    , YEAR
    , DOW
    , MOY
    , DOM
    , QOY
    , DAY_NAME
    , MONTH_NAME
    , QUARTER_NAME
    , WEEKEND
    , FIRST_DOM
    , LAST_DOM
    , MONTH_END
    , QUARTER_END
    , YEAR_END
from {{ var('project_database_prefix') }}_{{ target.name }}_analyze.{{ env_var('DBT_SNOWFLAKE_SCHEMA_PREFIX', '') }}common_dim.date_dim
