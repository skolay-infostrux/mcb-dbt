{# Returns a an extended `dict` object richer than the standard dbt `run_results.json` file
  detailing the results of a given `dbt run`
  Can only be called from `on-run-end` hook where `results` object is available 
  Advantages over `run_results.json` file:
    - will produce results even if a dbt execution error 
    - is accessible programaticaly from `on-run-end` hook 
    - outputs the result to the console in both JSON and YAML formats
      for the benefit the of external orchestrators like Airflow that can capture the `stdout`

  RECOMMENDATION: The returned `dict` should be saved to a database table for further performance analysis        
#}
{% macro get_run_info_dict(results) -%}

{% set project_info_dict = get_project_info_dict() %}
{% set metadata_dict = project_info_dict.metadata %}
{% set run_info_dict = {'metadata': metadata_dict} %}

 {% if execute -%}
  {% set backslash %}\{% endset %}

  {% set success_count = [] %}
  {% set warning_count = [] %}
  {% set error_count = [] %}
  {% set skipped_count = [] %}

  {% set results_list = [] %}

  {% for item in results -%}
    {% set item_dict = {} %}

    {% if item.thread_id == 'main' and item.timing == [] %}
      {% do item_dict.update({'unique_id': 'on-run-start'}) %}

    {% elif item.node %}
      {% do item_dict.update({'unique_id': item.node.unique_id }) %}
      {% do item_dict.update({'database': item.node.database }) %}
      {% do item_dict.update({'schema': item.node.schema }) %}
      {% do item_dict.update({'name': item.node.name }) %}
      {% do item_dict.update({'alias': item.node.alias }) %}

      {% set models = graph.nodes.values() %}
      {% set model_list = (models | selectattr('unique_id', 'equalto', item.node.unique_id) | list) %}
      {% if (model_list | length) > 0 %}
          {% set model = model_list.pop() %}
          {% if model.config and model.config.materialized == 'incremental'%}
            {% set cf_dict = model.config %}
            {% set _dict = {} %}
            
            {% if cf_dict.materialized %}{% do _dict.update({'materialized': cf_dict.materialized}) %}{% endif %}
            {% if cf_dict.incremental_strategy %}{% do _dict.update({'incremental_strategy': cf_dict.incremental_strategy}) %}{% endif %}
            {% if cf_dict.unique_key and cf_dict.unique_key|list|length > 1 %}
              {% do _dict.update({'unique_key': cf_dict.unique_key | list }) %}
            {% endif %}

            {% if cf_dict.materialized == 'incremental'%}
              {% do item_dict.update({'config': _dict }) %}
            {% endif %}
          {% endif %}          
      {% endif %}
    {% endif %}

    {% do item_dict.update({'status': item.status.value }) %}
    {% if item.status == 'error' %}
      {% set __ = error_count.append(1) %}
      {% do item_dict.update({'error_message': item.message|replace('\n',' ')|replace('   ',' ')|replace(backslash,'/') }) %}
    {% elif item.status == 'skipped' %}
      {% set __ = skipped_count.append(1) %}
    {% else %}  
      {% set __ = success_count.append(1) %}

      {% if item.adapter_response and item.adapter_response.query_id|length > 0 %}
        {% if item.adapter_response %} {% do item_dict.update({'query_id': item.adapter_response.query_id }) %} {% endif %}
        {% if item.adapter_response %} {% do item_dict.update({'rows_affected': item.adapter_response.rows_affected }) %} {% endif %}
      {% endif %}
      
      {% if item.execution_time %} {% do item_dict.update({'execution_time': item.execution_time|round(3) }) %} {% endif %}
      {% if item.thread_id %} {% do item_dict.update({'thread_id': item.thread_id }) %} {% endif %}
      
      {% if (item.timing|length) > 0 and item.timing[0].started_at %} {% do item_dict.update({'started_at': item.timing[0].started_at|string }) %} {%endif %}
      {% if (item.timing|length) > 1 and item.timing[1].completed_at %} {% do item_dict.update({'completed_at': item.timing[1].completed_at|string }) %} {%endif %}
    {% endif %}
    
    {% do results_list.append(item_dict) %}
  {% endfor %}  

  {% set done_dict = {}%}
  {% do done_dict.update({'PASS': success_count|length}) %}
  {% do done_dict.update({'WARN': warning_count|length}) %}
  {% do done_dict.update({'ERROR': error_count|length}) %}
  {% do done_dict.update({'SKIP': skipped_count|length}) %}
  {% do done_dict.update({'TOTAL': success_count|length + warning_count|length + error_count|length + skipped_count|length}) %}
  {% do metadata_dict.update({'completion': done_dict}) %}

  {% do metadata_dict.update({'status': 'SUCCESS'}) %}
  {% if error_count|length > 0 %}
    {% do metadata_dict.update({'status': 'FAIL'}) %}
  {% endif %}

  {% do run_info_dict.update({'args': {
      'invocation_command': invocation_args_dict.invocation_command|string,
      'which': invocation_args_dict.which|string,
      'fail_fast': invocation_args_dict.fail_fast|string,
      'select': invocation_args_dict.select,
      'exclude': invocation_args_dict.exclude,
      'vars': invocation_args_dict.vars,
      }
    }) %}

  {% do run_info_dict.update({'run_started_at': run_started_at|string }) %}
  {% do run_info_dict.update({'run_completed_at': modules.datetime.datetime.now().astimezone(modules.pytz.utc)|string }) %}
  {% set run_completed_at = modules.datetime.datetime.now().astimezone(modules.pytz.utc) %}
  {% set elapsed_time = (run_completed_at - run_started_at).total_seconds() %}
  {% do run_info_dict.update({'run_completed_at': run_completed_at|string }) %}
  {% do run_info_dict.update({'elapsed_time': elapsed_time|round(3)|string }) %}
  
  {% do run_info_dict.update({'results': results_list}) %}
 {%- endif -%}
 {{ return(run_info_dict) }} 
{%- endmacro %}
