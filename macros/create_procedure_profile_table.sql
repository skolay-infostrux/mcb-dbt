{% macro create_procedure_profile_table() %}

    {% set sql %}
        create schema if not exists DATA_PROFILING;

        CREATE OR REPLACE PROCEDURE DATA_PROFILING.profile_table(tableName VARCHAR)
        returns variant
        LANGUAGE PYTHON
        RUNTIME_VERSION = '3.8'
        PACKAGES = ('snowflake-snowpark-python','pandas','ydata-profiling')
        HANDLER = 'profile_by_table'
        AS
        $$

from snowflake.snowpark.functions import col
import pandas as pd
from ydata_profiling import ProfileReport
def profile_by_table(session, table_name):
    df = session.table(table_name)
    df_pd = df.to_pandas()
    profile = ProfileReport(
        df_pd, title="Data Profiling Report",
        explorative=True, minimal=False, pool_size=8
        )
    return profile.to_html()

        $$;
    {% endset %}
    {% do run_query(sql) %}
    {% do log("procedure profile_table created", info=True) %}
{% endmacro %}
