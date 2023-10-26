{% macro clone_database(source_database_name, target_database_name) %}

   {% set sql %}

        CREATE OR REPLACE DATABASE {{target_database_name}} CLONE {{source_database_name}};

   {% endset %}

   {% do run_query(sql) %}


{% endmacro %}
