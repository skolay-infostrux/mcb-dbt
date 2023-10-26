# DBT best practices

> This document describes DBT project development best practices recommended by Infostrux. Best practices that are not currently implemented in the Infostrux projects are also covered. In addition, some solutions recommended by DBT but implemented differently in our projects are also discussed.



## Project structure

There are 7 data data staging layers according to our reference architecture - INGEST, CLEAN, NORMALIZE, INTEGRATE, ANALYZE, REPORT, EGEST:

https://infostrux.atlassian.net/wiki/spaces/ENG/pages/666632197/Datastores

Models for deploying each data processing layer are organized in separate subfolders under the models directory. Thus, there are 7 subdirectories under the models directory, representing the corresponding layer-ingest, clean, normalize, integrate, analyze, report, and egest.INGEST, CLEAN, and NORMALIZE are organized by the data sources. Thus, based on different sources, these layers can contain separate subfolders for the corresponding sources. INTEGRATE, ANALYZE and report are organized by business area, and can be divided into subfolders accordingly. EGEST is organized by the data target. Therefore, this layer can have a separate subfolder for each data target.


## Model configs

We recommend to define model configs in the dbt_project.yml file (not in each model header or a .yml file under models' subdirectories, if there is no special reason for that):
```
models:
  dbt_cloud_starter:
    egest:
      database: "EGEST"
    analyze:
      database: "ANALYZE"
    report:
      database: "REPORT"
    integrate:
      database: "INTEGRATE"
    normalize:
      database: "NORMALIZE"
    clean:
      database: "CLEAN"
    ingest:
      database: "INGEST"
```
These configs apply to all models under the subdirectory. As compared to providing model configs in model headers or in .yml files under models’ subdirectories, this solution helps to avoid code redundancy. In addition, in case of changing configs, we have only one file to update unlike to other two solutions where each model config should be updated separately. If we need to provide special configs for specific models in the directory, we can provide them in models’ headers which will override the configs in the dbt_project.yml file:

```sql
 {{ config(alias='phone', database='analyze', schema='customer') }}

select
    phone.id,
    phone.phone_number,
    phone.phone_type,
    customer.id as customer_id,
    customer.name as customer_name,
    -- book keeping
    greatest(customer._loaded_ts_utc, phone._loaded_ts_utc) as _loaded_ts_utc,
    -- sources
    customer._source_demo_crm_customer_id,
    customer.source_demo_erp_cust_id,
    phone.source_demo_crm_phone_id,
    phone.source_demo_erp_phon_id
from {{ ref ('customer__integrate__customer') }} customer
inner join {{ ref ('phone__integrate__customer') }} phone
on customer.id = phone.customer_id
```

We recommend having one .yml file (model_name.yml) per dbt model in that model's directory. The .yml file should have a brief model-level description that describes the purpose and usage of the model. This description should also contain the grain of the table. Each column in a dbt model should also have a brief description that gives consumer information on the column. The description should also describe any transformations that occur in the column:


```
version: 2

models:
  - name: customer__clean__demo_crm
    description: Customers table from CRM, at the customer grain
    tests:
      - elementary.table_anomalies:
          table_anomalies:
            - row_count
            - freshness
          # optional - use tags to run elementary tests on a dedicated run
          tags: ['elementary']
          config:
          # optional - change severity
            severity: warn
    columns:
      - name: id
		description: '{{ doc("customer_id") }}'
		tests:
		  - unique
		  - not_null
	  - name: name
		description: '{{ doc("customer_name") }}'
        tests:
          - elementary.column_anomalies:
              column_anomalies:
                - zero_count
              tags: ['elementary']
	  - name: updated_timestamp
		description: '{{ doc("updated_timestamp") }}'
```

### Docs Blocks

Docs blocks (https://docs.getdbt.com/docs/collaborate/documentation#using-docs-blocks) should be leveraged to ensure consistent column-level descriptions across the dbt project. There should be one docs blocks `.md` file at the root of the dbt project, these docs blocks should besorted alphabetically and would contain all shared column descriptions across the project. For columns which will be encountered only in individual models, the column description can be included in the model's `.yml` file.

```
{% docs customer_id %}
Unique identifier for customers from the CRM

{% enddocs %}

{% docs customer_name %}
Name of the customer from the CRM
{% enddocs %}

{% docs updated_timestamp %}
Timestamp of when the row was last updated
{% enddocs %}
```

## Seed configs

If the structure of a seed CSV changes, after it has been previously loaded, the next dbt seed command will fail as it will try to use the existing table that has a different structure. For example, if you have already loaded the data from a seed fine and then jjust rename a column in th CSV file and run dbt seed, the command will fail. To avoid this issue, it can be reasonable to set full_refresh to true in the seeds config node in the dbt_project.yml file, if future structural changes are possible in seed CSV files:
```
seeds:
  database: "INGEST"
  full_refresh: true
```
When full_refresh is set to true, dbt recreates the corresponding table each time when the dbt seed command runs instead of refreshing it.



## Sources

Only the INGEST layer should contain information about sources (sources' descriptions in .yml files). Different subcategories of sources should be stored separately. Therefore,  different subfolders under the ingest folder should be created for different sources. We recommend creating a separate .yml file per source table (source_table_name.yml) under the corresponding directory.


## Style guide

Code is read many more times than it is written, so it is imperative that it is easy to read and understand at a glance. Time spent unraveling poorly written code is time taken away from productive work - building new features and improving existing ones. As such, poorly written code is nothing other than technical debt as it increases implementation time and costs.

> Infostrux proposes custom SQL Style Guide - https://github.com/Infostrux-Solutions/dbt-starter-project/blob/main/doc/SQLStyleGuide.md, to develop models. This guide has been adapted from the dbt Style Guide and a few others with the goal of maximizing code maintainability.


## Automation

Automating checks for adherence to code style guides is probably the only sane way to enforce them. Linters exist for exactly that purpose. They should be part of any project's CI pipeline to ensure code merged to all repos follows the same standard.
Of particular interest is SQLFluff (https://github.com/sqlfluff/sqlfluff) and the SQLFluff extension to Visual Studio Code (https://marketplace.visualstudio.com/items?itemName=dorzey.vscode-sqlfluff) which helps developers ensure code is style-conformant before they submit it to the CI pipeline.


## DBT tests

DBT tests are used if it is required to check data transformations and the values of the source data.



## Source Freshness

Data providers can fail to deliver a source file. Automated ingestion of source data files can fail as well. Both scenarios can result in stale/inaccurate data. It is advisable to setup source data freshness checks to ensure dbt models are working with the current data. dbt provides source freshness check functionality right out of the box.



## Version Control

All dbt projects should be managed in a version control system such as git. For all the code versioning we follow a feature branch strategy as opposed to trunk-based development.


## CI/CD for dbt

CI/CD is a method to frequently deliver apps to customers by introducing automation into the stages of app development. The main concepts attributed to CI/CD are continuous integration, continuous delivery and continuous deployment.

To ensure code and implementation quality, CI/CD tools should include linting and unit tests prior to any branch being allowed to be merged into develop to enforce coding standards as well as validate the integrity of the implementation.


## Environments

For production and development purposes we use separate environments - PROD and DEV. In the DEV environment, we support all six layers of our data staging model. Environments are defined by providing only one-env_name variable, instead of using dbt standard approach (such as target.name, target.database internal variables). This makes the configuration more flexible when we switch environments or add a new environment.

### Environment variables

When generating database object names, providing environment-related variables as dbt variables and not referring to dbt internal environment variables (such as target.name, target.database, etc) sometimes can be a more effective solution. For instance, in the sample project below database names are being generated using the env_name variable and are fully independent dbt environment settings:

In dbt_project.yml file:
```
#Define variables here

#DEV or PROD. It is used to generate the environment name for the source database.

#DEV by default. If it is not provided-then DEV_<DB_NAME> (DEV_INGEST for example), if provided- <env_name>_<DB_NAME> (PROD_INGEST).

vars:
  env_name: 'DEV'
```
Database name generation macro:
```
-- e.g. dev_clean or prod_ingest, where clean and ingest are the 'stage_name'
--#> MACRO
{% macro generate_database_name(stage_name, node) %}

   {% set default_database = target.database %}
   {% if stage_name is none %}
        {{ default_database }}
   {% else %}
        {{ var("env_name") }}_{{ stage_name | trim }}
   {% endif %}

{% endmacro %}
--#< MACRO
```


The variable is provided to the dbt command if we need to use other values than the default. For example:
```
dbt run --vars 'env_name: "PROD"'
```
And no need to provide anything for the DEV as it uses the default value:
```
dbt run
```
In the case of switching between different environments, this solution can be helpful as there is no need to update environment settings.



## Data load

Data from the sources is loaded only into the PROD_INGEST database. All layers above are being deployed by DBT models. Moreover, models of each layer refer only to models from previous layers or the same layer.

To deploy the DEV environment, the DEV_INGEST database is cloned from the PROD_INGEST database (unless there is a requirement to move DEV data separately) and all preceding layers of the DEV environment are created by DBT models. Seeds can be loaded in different layers depending on their usage.


### Generating DEV environment by cloning ingest layer of the PROD environment

It is recommended to have all six layers of Infostrux architecture in DEV environment as well. This can be achieved by creating the **ingest** layer for DEV (all other layers will be created by dbt models using the ingest layer) by cloning the **ingest** layer of the prod environment. The cloning can be defined in a macro (a simple cloning macro below):
```
{% macro clone_database(source_database_name, target_database_name) %}

   {% set sql %}

        CREATE OR REPLACE DATABASE {{target_database_name}} CLONE {{source_database_name}};

   {% endset %}

   {% do run_query(sql) %}

{% endmacro %}
```


Then, cloning can be run as a dbt operation by a job:
```
dbt run-operation clone_database --args '{source_database_name: PROD_INGEST, target_database_name: DEV_INGEST}'
```
Please note that the user running the job should have OWNERSHIP permission to the target database as the job replaces the existing database.

## Best practices recommended by DBT that are not used by Infostrux

There are some DBT design and development aspects that we approach in different ways than recommended by DBT. We provide our own solutions to these challenges, and based on our experience, we find them quite flexible and optimal. Therefore, in our projects, we recommend these approaches as best practices.

### Providing Environment Variables

We use only one variable to provide environment names instead of referring to DBT's internal environment variables. By default, it is set to 'DEV' which means if we do not provide the parameter, dbt commands will run on the DEV environment. The variable is described in the dbt_project.yml file:

    # Define variables here
    # DEV or PROD. It is used to generate the environment name for the source database.
    # DEV by default. If it is not provided-then DEV_<DB_NAME> (DEV_INGEST for example), if provided- <env_name>_<DB_NAME ##(PROD_INGEST).
    vars:
      env_name: 'DEV'

With this approach, it is not necessary to use dbt environment variables in the code. Object names will be generated by the corresponding macros that use our env_name variable. For example, in dbt_project.yml file, we just provide the database names without environment prefixes. These prefixes are generated by the generate_database_name macro based on the environment provided:

```
  dbt_cloud_starter:
    # Applies to all files under models/example/
    egest:
      materialized: "view"
      database: "EGEST"
    analyze:
      materialized: "view"
      database: "ANALYZE"
    integrate:
      materialized: "view"
      database: "INTEGRATE"
    normalize:
      materialized: "view"
      database: "NORMALIZE"
    clean:
      materialized: "view"
      database: "CLEAN"
    ingest:
      materialized: "view"
      database: "INGEST"

seeds:
  database: "INGEST"
  full_refresh: true
```

generate_database_name macro:

```
{% macro generate_database_name(stage_name, node) %}

   {% set default_database = target.database %}
   {% if stage_name is none %}
        {{ default_database }}
   {% else %}
        {{ var("env_name") }}_{{ stage_name | trim }}
   {% endif %}

{% endmacro %}
```

In each environment, we pass the corresponding value to the variable in jobs. For example, a sample job for the PROD environment will use the following command:

```
dbt build --vars 'env_name: "PROD"'
```

This makes it easier to switch between environments and add new environments as there is less dependency on dbt internal configurations.

### Structuring DBT project

We use more data transformation layers than is recommended by DBT. Instead of the minimum of three distinct checkpoints recommended by DBT (https://discourse.getdbt.com/t/how-we-structure-our-dbt-projects/355#data-transformation-101-1), we have six. Hence, we have the following data transformation layers, as mentioned above in this article:

INGEST, CLEAN, NORMALIZE, INTEGRATE, ANALYZE, EGEST

We find this approach more robust and flexible in terms of data processing, code modularity, and delivery. For more information about our data transformation layers, please follow Infostrux's development reference architecture document:

https://infostrux.atlassian.net/wiki/spaces/ENG/pages/666632197/Datastores

https://infostrux.atlassian.net/wiki/spaces/ENG/pages/666304656/Data+Structures

### Referring to the source models

We define sources in INGEST layer. There is a subdirectory for each source subcategory in that layer. Each source table is provided by a separate .yml file under the corresponding subfolder. There are no models in the first-INGEST layer. Sources are referred to by the SOURCE keyword in models:

```
SELECT
    id,
    name,
    updated_timestamp
FROM
    {{ source('demo_crm','customer') }}
```

While Infostrux's and DBT's approaches (https://docs.getdbt.com/guides/legacy/best-practices#rename-and-recast-fields-once) are the same in renaming and recasting fields only once and referring to only modified data in upper layers, we have a bit different approach in referring to the source models. According to the best practices recommended by DBT,  every source matches exactly one model. This model just uses CTE to refer to the corresponding source and perform some simple data transformations:

https://discourse.getdbt.com/t/how-we-structure-our-dbt-projects/355#but-what-about-base-models-3

These basic data transformations are done in our CLEAN layer. So, models from the CLEAN layer refer to the sources using the SOURCE keyword.  We do not find it mandatory to use CTEs just to rename sources in our code. Also, we do not use specific "base" models and "base" subdirectories. As it is mentioned above, we have only one .yml file per source table, which is in the INGEST layer. We do not have models in the INGEST layer but only sources. We find this approach simpler, more convenient in terms of code modularity, and less redundant.

### References

* https://docs.getdbt.com/guides/legacy/best-practices

* https://github.com/dbt-labs/corp/blob/main/dbt_style_guide.md

* https://discourse.getdbt.com/t/how-we-structure-our-dbt-projects/355

* https://docs.getdbt.com/guides/best-practices/how-we-structure/1-guide-overview

* https://github.com/dbt-labs/corp/blob/main/dbt_style_guide.md

* https://docs.sqlfluff.com/en/stable/rules.html

* https://handbook.meltano.com/data-team/sql-style-guide

* https://github.com/ingydotnet/git-subrepo#readme
