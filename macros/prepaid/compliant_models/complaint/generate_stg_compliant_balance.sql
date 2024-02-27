{% macro generate_stg_compliant_balance(reference_source,reference_table,is_new_spec) %}
    {% if is_new_spec == 'y' %}
        --Compliant processor file
        with BALANCE as(
            select 
                DATA_REC
                ,FILE_ROW_NUMBER
                ,FILE_NAME
                ,FILE_ROW_KEY
                ,FILE_INSERT_TS
                ,MAX_ROW_NUMBER
            from (
                select 
                    DATA_REC
                    ,FILE_ROW_NUMBER
                    ,FILE_NAME
                    ,FILE_ROW_KEY
                    ,FILE_INSERT_TS
                    ,MAX_ROW_NUMBER
                    ,dense_rank() over (order by FILE_INSERT_TS desc) as drk
                from {{ source(reference_source, reference_table) }} RAW
                order by FILE_NAME,FILE_ROW_NUMBER
            )
            where drk=1
        )
        ,BALANCE_HEADER_TRAIL_REC AS(
            select             
                H.DATA_REC||'|'||T.DATA_REC as HEADER_TRAIL_REC,H.FILE_NAME
            from BALANCE  H 
            join (select DATA_REC,FILE_NAME from BALANCE where  FILE_ROW_NUMBER = MAX_ROW_NUMBER ) T on T.FILE_NAME = H.FILE_NAME
            where FILE_ROW_NUMBER = 1  
        )
        select 
            trim(split_part(DATA_REC, '|',  1)) as RECORD_TYPE                          
            ,trim(split_part(HEADER_TRAIL_REC, '|',  3))  as PAYMENT_PROCESSOR          
            ,trim(split_part(DATA_REC, '|',  2)) as CUST_ACCOUNT_ID                     
            ,trim(split_part(DATA_REC, '|',  3)) as ACCOUNT_NUMBER                      
            ,trim(split_part(DATA_REC, '|',  4)) as CURRENT_BALANCE                     
            ,trim(split_part(DATA_REC, '|',  5)) as CURRENT_BALANCE_DATE  
            ,trim(split_part(DATA_REC, '|',  6)) as AVAILABLE_BALANCE                   
            ,trim(split_part(DATA_REC, '|',  7)) as NEGATIVE_BALANCE_DATE
            ,trim(split_part(DATA_REC, '|',  8)) as NEGATIVE_BALANCE_FEE
            ,trim(split_part(DATA_REC, '|',  9)) as CURRENCY                            
            --Ingestion Control based on Compliant Files
            ,D.FILE_ROW_NUMBER
            ,split_part(D.FILE_NAME, '/',  -1) as FILE_NAME
            ,FILE_ROW_KEY
            ,FILE_INSERT_TS
            ,MAX_ROW_NUMBER
            ,H.HEADER_TRAIL_REC
        from BALANCE as D
        inner join  BALANCE_HEADER_TRAIL_REC as H on D.FILE_NAME = H.FILE_NAME
        where left(DATA_REC, 1) = ( 'D' ) 
	{% else %}
        --Non Compliant processor        
        select 
            'D' as RECORD_TYPE                                                    
            ,PAYMENT_PROCESSOR                    
            ,CUST_ACCOUNT_ID                
            ,ACCOUNT_NUMBER                  
            ,CURRENT_BALANCE      
            ,CURRENT_BALANCE_DATE                   
            ,AVAILABLE_BALANCE                                 
            ,NEGATIVE_BALANCE_DATE                                                    
            ,NEGATIVE_BALANCE_FEE                                            
            ,CURRENCY                                   
            --Ingestion Control based on Compliant Files
            ,FILE_ROW_NUMBER
            ,split_part(FILE_NAME, '/',  -1) as FILE_NAME
            ,NULL::VARCHAR(50) AS FILE_ROW_KEY
            ,FILE_INSERT_TS
            ,NULL::NUMBER(18,0) as MAX_ROW_NUMBER
            ,NULL::VARCHAR(200) as HEADER_TRAIL_REC
        from {{ ref(reference_table) }}

	{% endif %}
      
{% endmacro %}