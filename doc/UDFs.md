# Snowflake UDFs for Clean layer transformations #

The transformations to be implemented will be aligned with the design notes below:

## Design notes ##

- Each needed transformation is done from within a Snowflake UDF.


- The UDF is defined and created from within a DBT macro templating the target schema under `macros/udfs/phone_clean.sql` as example.


- The DBT macro is deployed via project hook `on-run-start`, so it’s available for any given model.


- A master macro named `macros/create_udfs.sql` is created to call each UDF macro.


- It needs to include a `create schema` statement since the target schema is created after the `on-run-start` hooks, for example:
```
{% macro create_udfs() %}

create schema if not exists {{target.schema}};

{{phone_number_udf()}};
{{another_udf_1()}};
{{another_udf_2()}}

{% endmacro %}
```
- An `on-run-start` hook is added to the project config yml file, where the *master* macro will be invoked.


- References to the UDF in the models template the target schema, for example:

```
SELECT {{target.schema}}.PHONE_CLEAN(phone_number)
FROM {{ ref(…)}}
```

- The hook is defined at project level, rather than model level.

- The UDF is invoked as part of a Clean Layer model’s transformation.

- The demo example cleans phone numbers from available sources.
