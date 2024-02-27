{#  PURPOSE: use this macro to enhance the [info] logging in dbt.log 
        USAGE EXAMPLE:
            {{ log_custom('My log message...', info=True) }}

            OUTPUT (console):
                22:18:49  [2023-08-03] My log message...
            
            OUTPUT (dbt.log):
                15:18:49.880902 [info ] [MainThread]: [2023-08-03] My log message...

    ALTERNATIVE: another option could be to override the dbt core implementation (thank you dbt for being open source!!!)
        like so:
        Modify the default implementation in 'dbt\events\format.py'
        def timestamp_to_datetime_string(ts):
            timestamp_dt = datetime.fromtimestamp(ts.seconds + ts.nanos / 1e9)
            # return timestamp_dt.strftime("%H:%M:%S.%f")
            return timestamp_dt.strftime("%Y-%m-%d %H:%M:%S.%f")
        USAGE EXAMPLE:
            {{ log('My log message...', info=True) }}
        
            OUTPUT (console):
                22:18:49  My log message...

            OUTPUT (dbt.log):
                2023-08-03 15:18:49.880902 [info ] [MainThread]: [2023-08-03] My log message...       
#}

{% macro log_custom(message, info=False) -%}
    {# UTC time, milliseconds [2023-10-19 06:33:42] #}
    {# {{ log('[' ~ modules.datetime.datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S') ~ '] ' ~  message, info) }} #}

    {# local time, microseconds [2023-10-19 09:33:42.127142] #}
    {# {{ log('[' ~ modules.datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f') ~ '] ' ~  message, info) }} #}

    {# local time, milliseconds [2023-10-19 09:33:42.127] #}
    {# {{ log('[' ~ modules.datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')[:23] ~ '] ' ~  message, info) }} #}

    {# local time, milliseconds with timezone offset from UTC [2023-10-19 09:33:42.127-04:00] #}
    {{ log('[' ~ modules.datetime.datetime.now().astimezone().isoformat(sep=' ', timespec='milliseconds') ~ '] ' ~  message, info) }}
{% endmacro %}

