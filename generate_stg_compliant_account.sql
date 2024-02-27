{% macro generate_stg_compliant_account(reference_source,reference_table,is_new_spec) %}
    {% if is_new_spec == 'y' %}
        --Compliant processor file
        with account as(      
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
        ,ACCOUNT_HEADER_TRAIL_REC AS(
            select             
                H.DATA_REC||'|'||T.DATA_REC as HEADER_TRAIL_REC,H.FILE_NAME
            from Account  H 
            join (select DATA_REC,FILE_NAME from Account where  FILE_ROW_NUMBER = MAX_ROW_NUMBER ) T on T.FILE_NAME = H.FILE_NAME
            where FILE_ROW_NUMBER = 1  
        )
        select 
            trim(split_part(DATA_REC, '|',  1)) as RECORD_TYPE                                          
            ,trim(split_part(H.HEADER_TRAIL_REC, '|',  3))    as PAYMENT_PROCESSOR                      
            ,trim(split_part(DATA_REC, '|',  2))  as CUST_ACCOUNT_ID	                                
            ,trim(split_part(DATA_REC, '|',  3))  as ACCOUNT_NUMBER	                                    
            ,trim(split_part(DATA_REC, '|',  4))  as ACCOUNT_EXPIRATION_DATE   
            ,trim(split_part(DATA_REC, '|',  5))  as ACCOUNT_STATUS	                                    
            ,trim(split_part(DATA_REC, '|',  6))  as ACCOUNT_CREATED_DATE      
            ,trim(split_part(DATA_REC, '|',  7))  as LAST_UPDATED_DATE         
            ,trim(split_part(DATA_REC, '|',  8))  as PRN                                
            ,trim(split_part(DATA_REC, '|',  9))  as PSEUDO_DDA                         
            ,trim(split_part(DATA_REC, '|',  10)) as GROUP_ID                                           
            ,trim(split_part(DATA_REC, '|',  11)) as PRODUCT_ID                         
            ,trim(split_part(DATA_REC, '|',  12)) as PROGRAM_ID                         
            ,trim(split_part(DATA_REC, '|',  13)) as RELOADABLE_INDICATOR               
            ,trim(split_part(DATA_REC, '|',  14)) as TYPE_OF_ACCOUNT                                    
            ,trim(split_part(DATA_REC, '|',  15)) as SURROGATE_PROXY_TOKEN_UNIQUE_ID                    
            ,trim(split_part(DATA_REC, '|',  16)) as CARD_ID                                            
            ,trim(split_part(DATA_REC, '|',  17)) as TYPE_OF_CARD                                       
            ,trim(split_part(DATA_REC, '|',  18)) as LAST_TRANSACTION_DATE     
            --Ingestion Control based on Compliant Files
            ,D.FILE_ROW_NUMBER
            ,split_part(D.FILE_NAME, '/',  -1) as FILE_NAME
            ,FILE_ROW_KEY
            ,FILE_INSERT_TS
            ,MAX_ROW_NUMBER
            ,H.HEADER_TRAIL_REC
        from account AS D
        inner join ACCOUNT_HEADER_TRAIL_REC as H on D.FILE_NAME = H.FILE_NAME
        where left(DATA_REC, 1) = ( 'D' )
	{% else %}
        --Non Compliant processor        
        select 
            'D' as RECORD_TYPE                                                    
            ,PAYMENT_PROCESSOR                    
            ,CUST_ACCOUNT_ID                
            ,ACCOUNT_NUMBER                  
            ,ACCOUNT_EXPIRATION_DATE      
            ,ACCOUNT_STATUS                   
            ,ACCOUNT_CREATED_DATE                                 
            ,LAST_UPDATED_DATE                                                    
            ,PRN                                            
            ,PSEUDO_DDA                                 
            ,GROUP_ID                              
            ,PRODUCT_ID                          
            ,PROGRAM_ID                          
            ,RELOADABLE_INDICATOR                    
            ,TYPE_OF_ACCOUNT                              
            ,SURROGATE_PROXY_TOKEN_UNIQUE_ID
            ,CARD_ID                                
            ,TYPE_OF_CARD                        
            ,LAST_TRANSACTION_DATE                                  
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