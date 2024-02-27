{% macro get_project_info_dict() %}
 {% if execute or 'run-operation' in invocation_args_dict.invocation_command %}
  {% set metadata_dict = {} %}
  {% do metadata_dict.update({'generated_at': modules.datetime.datetime.now().astimezone(modules.pytz.utc)|string }) %}
  {% if ddbt_schema_version %}{% do metadata_dict.update({'dbt_schema_version': dbt_schema_version|string }) %}{% endif %}
  {% do metadata_dict.update({'dbt_version': dbt_version|string }) %}
  {% do metadata_dict.update({'dbt_command': invocation_args_dict.which }) %}
    {% if invocation_args_dict.macro %}{% do metadata_dict.update({'invocation_macro': invocation_args_dict.macro }) %}{% endif %}
    {% if invocation_args_dict.args %}{% do metadata_dict.update({'invocation_args': invocation_args_dict.args }) %}{% endif %}
    {% if invocation_args_dict.vars %}{% do metadata_dict.update({'invocation_vars': invocation_args_dict.vars }) %}{% endif %}
  {% do metadata_dict.update({'invocation_id': invocation_id }) %}

  {% do metadata_dict.update({'project_name': (project_name|string ~ ' ')|trim }) %} {# !? toyaml() doesnt render without it #}
  
  {% set dbt_target = {'target': target.profile_name|string}  %}
  {% do dbt_target.update({'target_name': target.target_name|string }) %}
  {% do dbt_target.update({'account': target.account|string }) %}
  {% do dbt_target.update({'user': target.user|string }) %}
  {% do dbt_target.update({'role': target.role|string }) %}
  {% do dbt_target.update({'warehouse': target.warehouse|string }) %}
  {% do dbt_target.update({'database': target.database|string }) %}
  {% do metadata_dict.update({'target': dbt_target }) %}

  {% set host_environment = {'OSTYPE': ''}  %}
  {% if env_var('COMPUTERNAME','')|length > 0 %}
    {% do host_environment.update({'OSTYPE': 'Windows'}) %}
    {% do host_environment.update({'COMPUTERNAME': env_var('COMPUTERNAME','')}) %}
    {% do host_environment.update({'USERDOMAIN': env_var('USERDOMAIN', '') }) %}
    {% do host_environment.update({'USERNAME': env_var('USERNAME', '') }) %}
  {% else %}
    {% do host_environment.update({'OSTYPE': env_var('OSTYPE','linux')}) %}
    {% do host_environment.update({'HOSTNAME': env_var('HOSTNAME',env_var('NAME',''))}) %}

    {% set MACHTYPE = env_var('MACHTYPE','') %}
    {% if MACHTYPE|length %}{% do host_environment.update({'MACHTYPE': MACHTYPE}) %}{% endif %}

    {% set USER = env_var('USER','') %}
    {% if USER|length %}{% do host_environment.update({'USER': USER }) %}{% endif %}
  {% endif %}
  {% do metadata_dict.update({'host_environment': host_environment }) %}
 
  {% set project_info_dict = {'metadata': metadata_dict} %}

  {{ return(project_info_dict) }}
 {% endif %}

{% endmacro %}
