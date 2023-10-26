
-- If custom database names are not provided, conventional names are applied
-- Model names should have the following naming standard - [TableName__DatabaseName__SchemaName | TableName__DatabaseName]
--   !!! The '__SchemaName' may be optional for some customer projects
-- The list of acceptable database names is provided in dbt_project.yml file via the database_list varaiable
-- Directory names and the corresponding database names should match
-- Apply only if (node.resource_type == 'model') or (node.resource_type == 'seed')

{% macro generate_database_name(custom_database_name, node) %}
     {% set project_database_prefix = var('project_database_prefix') %}
     {% set environment_name = target.name %} {#from profiles.yaml#}
     {% set output_database_name = target.database %} {#from profiles.yaml#}
     {% set model_name = node.name|trim %}
     {% set model_folder_name = node.fqn[1] | trim %}

     {# Apply conventional database name - database name should be generated from the node name.
     Node name has the form: [TableName__DatabaseName__SchemaName | TableName__DatabaseName]
     For example, if node name is 'customer__clean__demo_crm', database name resolves to 'clean' #}
     {% set conventional_database_name_from_model_name = model_name.split('__')[1] | trim %}
     {% set conventional_database_name_from_directory_name = model_folder_name %}
     {% set is_valid_model = node.resource_type is in ['model','seed']%}

     {% if is_valid_model and custom_database_name is not none %}
         {% set my_database_rule_message = "Custom DATABASE" %}

         {% set output_database_name = project_database_prefix ~ '_' ~ environment_name ~ '_' ~ custom_database_name|trim %}

     {% elif is_valid_model and conventional_database_name_from_model_name is not none and conventional_database_name_from_model_name  != '' %}
          {% set my_database_rule_message = "Conventional DATABASE" %}
          {% if conventional_database_name_from_model_name not in var("database_list")  %}
               {{ log("Unconventional database name: "~ conventional_database_name_from_model_name, info=True ) }}
               {{ exceptions.raise_compiler_error("ERROR unconventional database name: " ~ conventional_database_name_from_model_name ~ ". To fix, provide the database name part of the model name (tableName__databaseName__schemaName) from the predefined list of the acceptable database names described in the database_list variable of the the dbt_project.yml file - ['ingest', 'clean', 'normalize', 'integrate', 'analyze', 'egest', 'report']") }}
          {% elif conventional_database_name_from_directory_name not in var("database_list") and 'sources' != conventional_database_name_from_directory_name %}
               {{ log("Unconventional directory name: "~ conventional_database_name_from_directory_name, info=True ) }}
               {{ exceptions.raise_compiler_error("ERROR unconventional directory name: " ~ conventional_database_name_from_directory_name ~ ". To fix, choose the parent directory name of the model's directory from the predefined list of the acceptable database names described in the database_list variable of the the dbt_project.yml file - ['ingest', 'clean', 'normalize', 'integrate', 'analyze', 'egest', 'report']") }}
          {% elif conventional_database_name_from_model_name != conventional_database_name_from_directory_name %}
               {{ log("Directory and database names do not match: " ~ conventional_database_name_from_directory_name ~ " "~ conventional_database_name_from_model_name, info=True ) }}
               {{ exceptions.raise_compiler_error("ERROR directory and database names do not match: " ~ conventional_database_name_from_directory_name ~ " "~ conventional_database_name_from_model_name ~ ". To fix, provide the same name for the database name part of the model name (tableName__databaseName__schemaName) as the parent directory name of the model's directory ") }}
          {% endif %}

          {% set output_database_name = project_database_prefix ~ '_' ~ environment_name ~ '_' ~ conventional_database_name_from_model_name|trim %}
     {% else %}
          {% set my_database_rule_message = "Default DATABASE" %}

          {% set output_database_name = target.database %} {#from profiles.yaml#}
     {% endif %}

     {# Log to the log file only, not the console! >>  log("my message", info=False)  #}
     {% if is_valid_model %}
          {{ log(my_database_rule_message ~ ": '" ~ output_database_name ~ '", node: "'~node.name~'", file: "'~node.original_file_path~'"', info=False ) }}
          {# Verbose logging #}
          {# {{ log(' , macro call generate_database_name("' ~ custom_database_name ~ '", ...)\n'
               ~ ' , target.schema: "' ~ target.schema ~ '"\n'
               ~ ' , target.role: "' ~ target.role ~ '"\n'
               ~ ' , node.resource_type: "' ~ node.resource_type ~ '"\n'
               ~ ' , node.name": "' ~ node.name ~ '"\n'
               ~ ' , node.fqn": "' ~ node.fqn ~ '"\n'
               ~ ' ,   node.package_name": "' ~ node.package_name ~ '"\n'
               ~ ' ,   node.path": "' ~ node.path ~ '"\n'
               ~ ' ,   node.original_file_path": "' ~ node.original_file_path ~ '"\n'
               ~ '\n'
            , info=True) }} #}
     {% endif %}

     {{ output_database_name }}

{% endmacro %}
