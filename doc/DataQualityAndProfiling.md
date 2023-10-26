# Data Quality folders structure

```
├── dbt_project.yml
└── data
    ├── profiling
    |   └── chicago_empleoyess.csv (sample data)
    |   └── us_census_adult.csv (sample data)
└── macros
    └── generate_profile_report.sql
└── scripts
    └── quality
        └── profiling
            ├── data_profiler_local.py
            ├── data_profiler_remote_deserialize.py
            ├── data_profiler_remote.sh
        └── anomalies
            ├── data_observer_report.sh
        └── expectations
            └── (future use)
└── quality
    └── profiling
        └── output
            ├── Profile_Report_DATABASE.SCHEMA.TABLE_YYYYMMDD_HHmmss.html
            ├── Profile_Report_DATABASE.SCHEMA.TABLE_YYYYMMDD_HHmmss.html
    └── anomalies
        └── output
            ├── elementary_report.html
            ├── elementary_output.json
            ├── edr.log
        └── expectations
            └── (future use)
```

# Ingest CSV for Data Profiling

## Steps to follow

1. Prepare your CSV file
    1.1 Add Headers with columns names
    1.2 Uppercase column names could help if you have errors

2. Move CSV files to "data/profiling" folder

3. Run the following dbt seed command to create snowflake table from CSV file
    3.1 To process all CSV files inside data folder
        dbt seed
    3.2 To process only a specific CSV file (e.g. to process the file us_census_adult.csv)
        dbt seed --select us_census_adult

Note: This method is is not performant neither recommded for large files.


## Technical details: dbt configuration (dbt_project.yml)

Current default seeds configuration will read files from  "data" folder and ingest to ,<PREFIX>_STARTER_<ENV>_INGEST database presupposing clean files (without invalid characters in headers). The additional profiling configuration will apply to every file in the subfolder "profiling" and will ingest in the same database but into "DATA_PROFILING" schema instead of the $DBT_SNOWFLAKE_SCHEMA. Besides column names will be quoted to avoid invalid characters issues. When full_refresh is set to true, dbt recreates the corresponding table each time when the dbt seed command runs.


```
seeds:
  dbt_cloud_starter:
    +database: "ingest"
    +full_refresh: true
    profiling:
      +schema: "data_profiling"
      +quote_columns: true
      +full_refresh: true
```

# Generate Data Profiling Report

## Steps to follow

1. Activate Anaconda Packages from Snowsight
    https://docs.snowflake.com/en/developer-guide/udf/python/udf-python-packages#getting-started

2. Run the following dbt macro to create a Snowpark Python UDP (user-defined procedure) and be ready to perform data profiling:
    `dbt run-operation create_procedure_profile_table`

3. Run the data profiler script to generate the Profile Report
    3.1 To compute the whole process in Snowflake and download the final report (snowsql is required for this):
        `source scripts/quality/profiling/data_profiler_remote.sh <DATABASE>.<SCHEMA>.<TABLE>`
    3.2 To download data and compute locally the final report:
        `python scripts/quality/profiling/data_profiler_local.py <DATABASE>.<SCHEMA>.<TABLE>`

4. Open your report
```
└── quality
    └── profiling
        └── output
            ├── Profile_Report_DATABASE.SCHEMA.TABLE_YYYYMMDD_HHmmss.html
```

## Technical details: target databases and schemas

CSV Files uploaded for data profiling through dbt seeds will use:
>
    DATABASE:   <PREFIX>_STARTER_<ENV>_INGEST
    SCHEMA:     DATA_PROFILING
    TABLE:      The name of the csv file

Snowpark Python UDP
>
    DATABASE:   $DBT_SNOWFLAKE_DATABASE
    SCHEMA:     DATA_PROFILING
    PROCEDURE:  PROFILE_TABLE

Tables to be Profiled
>
    ARGS TABLE_NAME: <DATABASE>.<SCHEMA>.<TABLE>

## Technical details: profiling scripts
data_profiler_remote.sh:
>
    Path: scripts/quality/profiling/data_profiler_remote.sh

    Description:
    Calls the PROFILE_TABLE stored procedure against a specified table and dumps the results locally as an HTML report (quality/profiling/output). The stored procedure itself is created by a dbt macro (macros/create_procedure_profile_table.sql). Note that this procedure does exactly what data_profiler_local.py does, except that execution is performed by a Snowflake virtual warehosue (specified by the DBT_SNOWFLAKE_WAREHOUSE env var).

    snowsql is required to use this script.

data_profiler_remote_deserialize.py
>
    Path: scripts/quality/profiling/data_profiler_remote_deserialize.py

    Description:
    Helper script used by data_profiler_remote.sh to process remote profiling results into a readable format.

data_profiler_local.py
>
    Path: scripts/quality/profiling/data_profiler_local.py

    Description:
    Uses the ydata-profiling Python library to perform profiling against a specified table locally. The script retrieves the contents of the table as a dataframe and processes it using classes from the ydata-profiling library. The profiling results are dumped as a HTML report (quality/profiling/output).

    The data_profiler_remote.sh script and the stored procedure that it calls (PROFILE_TABLE) does exactly this as well, but code execution is handled by a Snowflake virtual warehouse.


# Generate Anomalies Observability Report

## Steps to follow

1. Configure table and columns anomalies in your model at some stage layer that is ready for observability

2. Set the new database env var DBT_SNOWFLAKE_ELEMENTARY_DATABASE pointing to <PREFIX>_STARTER_<ENV>_LOG

3. Run dbt command to run transformations populating stage layers Snowflake tables:

   `dbt run --select <model>`

   If you already have data populated in Snowflake and you only want to populate anomalies data metrics:

    `dbt run --select elementary`

4.Run the caller script to generate Anomalies Observability Report
```
source scripts/quality/anomalies/data_observer_report.sh
```

5. Open your report
```
└── quality
    └── anomalies
        └── output
            ├── elementary_report.html
```


## Technical details: Anomalies model configuration

You need to specify at model level each anomaly to be detected, tested and reported.

```
models:
  - name: customer__clean__demo_crm
    tests:
      - elementary.table_anomalies:
          table_anomalies:
            - row_count
            - freshness
          #optional - use tags to run elementary tests on a dedicated run
          tags: ['elementary']
          config:
          #optional - change severity
            severity: warn
    columns:
      - name: NAME
        tests:
          - elementary.column_anomalies:
              column_anomalies:
                 - null_count
                 - null_percent
                 - min_length
                 - max_length
                 - average_length
                 - missing_count
                 - missing_percent
              tags: ['elementary']
```

More information: https://docs.elementary-data.com/guides/add-elementary-tests

## Technical details: profile configuration (profile.yml)

In current dbt starter version, elementary has his own parameters because it has a fixed schema called "ELEMENTARY" so it doesn't use the env var $DBT_SNOWFLAKE_SCHEMA. Additionaly, in this version I separate also the database creating a new env var $DBT_SNOWFLAKE_ELEMENTARY_DATABASE that must be included in the ~/.dbt/profile_var.sh. It could be useful to update later setup_environment_variables.sh.

```
elementary:
  target: dev
  outputs:
    dev:
      type: snowflake
      threads: 8
      account: "{{ env_var('DBT_SNOWFLAKE_ACCOUNT') }}"
      user: "{{ env_var('DBT_SNOWFLAKE_USER') }}"
      private_key_path: "{{ env_var('DBT_SNOWFLAKE_PRIVATE_KEY_PATH') }}"
      private_key_passphrase: "{{ env_var('DBT_SNOWFLAKE_PRIVATE_KEY_PASSPHRASE') }}"
      role: "{{ env_var('DBT_SNOWFLAKE_ROLE') }}"
      database: "{{ env_var('DBT_SNOWFLAKE_ELEMENTARY_DATABASE') }}"
      warehouse: "{{ env_var('DBT_SNOWFLAKE_WAREHOUSE') }}"
      schema: "ELEMENTARY"
```

# Generate Expectations Report and Tests

[Placeholder for future use]
