-- If custom schema names are not provided, conventional names are applied
-- Model names should have the following naming standard - TableName__DatabaseName__SchemaName
-- Directory names and the corresponding schema names should match

{% macro generate_schema_name(custom_schema_name, node) %}

    {% set conventional_schema_name_from_model_name = node.name.split('__')[2] | trim  %}
    {% set conventional_schema_name_from_directory_name = node.fqn[2] | trim %}

    {% if custom_schema_name is not none %}

        {# Use custom_schema_name. Should be provided in dbt_project.yml file or in models' configs #}
        {{ custom_schema_name | trim }}
        {% set my_database_rule_message = "Custom SCHEMA: '" ~ custom_schema_name ~ '"' %}

    {% elif conventional_schema_name_from_model_name is not none and ( conventional_schema_name_from_model_name ) != '' %}

        {% if  conventional_schema_name_from_model_name != conventional_schema_name_from_directory_name %}
               {{ log("Directory and schema names do not match  - " ~ conventional_schema_name_from_directory_name ~ " "~ conventional_schema_name_from_model_name, info=True ) }}
               {{ exceptions.raise_compiler_error("ERROR directory and schema names do not match: " ~ conventional_schema_name_from_directory_name ~ " "~ conventional_schema_name_from_model_name ~ ". To fix, provide the same name for the schema name part of the model name (tableName__databaseName__schemaName) as the subdirectory name of the model ") }}
        {% endif %}

        {# Apply conventional schema name - schema name should be generated from the node name. For example, if node name is customer__clean__demo_crm, schema name should be demo_crm #}
        {{ conventional_schema_name_from_model_name }}
        {% set my_database_rule_message = "Conventional SCHEMA: '" ~ conventional_schema_name_from_model_name ~ '"' %}

    {% else %}

        {% set default_schema = target.schema %}
        {{ default_schema }}
        {% set my_database_rule_message = "Default SCHEMA: '" ~ default_schema ~ '"' %}

    {% endif %}

    {# Log to the log file only, not the console! >>  log("my message", info=False)  #}
    {{ log(my_database_rule_message ~ ', node: "'~node.name~'", file: "'~node.original_file_path~'"', info=False ) }}


{% endmacro %}
