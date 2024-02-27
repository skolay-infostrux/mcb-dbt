{% macro generate_stg_compliant_customer(reference_source,reference_table,is_new_spec) %}
    {% if is_new_spec == 'y' %}
        --Compliant processor file
        with CUSTOMER as(      
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
        ,CUSTOMER_HEADER_TRAIL_REC  as(
            select             
                H.DATA_REC||'|'||T.DATA_REC as HEADER_TRAIL_REC,H.FILE_NAME
            from CUSTOMER  H 
            join (select DATA_REC,FILE_NAME from CUSTOMER where  FILE_ROW_NUMBER = MAX_ROW_NUMBER ) T on T.FILE_NAME = H.FILE_NAME
            where FILE_ROW_NUMBER = 1  
        )
        select 
            trim(split_part(DATA_REC, '|',  1))  as RECORD_TYPE
            ,trim(split_part(HEADER_TRAIL_REC, '|',  3))  as PAYMENT_PROCESSOR
            ,trim(split_part(DATA_REC, '|',  2))  as CUST_ACCOUNT_ID
            ,trim(split_part(DATA_REC, '|',  3))  as FIRST_NAME
            ,trim(split_part(DATA_REC, '|',  4))  as LAST_NAME
            ,trim(split_part(DATA_REC, '|',  5))  as ADDRESS_1
            ,trim(split_part(DATA_REC, '|',  6))  as ADDRESS_2
            ,trim(split_part(DATA_REC, '|',  7))  as CITY	
            ,trim(split_part(DATA_REC, '|',  8))  as STATE
            ,trim(split_part(DATA_REC, '|',  9))  as ZIP
            ,trim(split_part(DATA_REC, '|',  10)) as COUNTRY
            ,trim(split_part(DATA_REC, '|',  11)) as PRIMARY_PHONE_NUMBER
            ,trim(split_part(DATA_REC, '|',  12)) as SECONDARY_PHONE_NUMBER
            ,trim(split_part(DATA_REC, '|',  13)) as DATE_OF_BIRTH
            ,trim(split_part(DATA_REC, '|',  14)) as ID_TYPE
            ,trim(split_part(DATA_REC, '|',  15)) as ID_NUMBER
            ,trim(split_part(DATA_REC, '|',  16)) as ID_STATE
            ,trim(split_part(DATA_REC, '|',  17)) as ID_COUNTRY
            ,trim(split_part(DATA_REC, '|',  18)) as ID_ISSUED_DATE
            ,trim(split_part(DATA_REC, '|',  19)) as ID_EXPIRE_DATE
            ,trim(split_part(DATA_REC, '|',  20)) as ID_2
            ,trim(split_part(DATA_REC, '|',  21)) as ID_TYPE2
            ,trim(split_part(DATA_REC, '|',  22)) as SSN
            ,trim(split_part(DATA_REC, '|',  23)) as TIN_TYPE
            ,trim(split_part(DATA_REC, '|',  24)) as PROGRAM_ID
            ,trim(split_part(DATA_REC, '|',  25)) as CUST_STATUS
            ,trim(split_part(DATA_REC, '|',  26)) as CREATED_DATE
            ,trim(split_part(DATA_REC, '|',  27)) as LAST_UPDATED_DATE
            ,trim(split_part(DATA_REC, '|',  28)) as OTHER_INFO
            ,trim(split_part(DATA_REC, '|',  29)) as EMAIL
            ,trim(split_part(DATA_REC, '|',  30)) as PRN
            ,trim(split_part(DATA_REC, '|',  31)) as EXTERNAL_ACCOUNT_NUMBER
            ,trim(split_part(DATA_REC, '|',  32)) as BILL_CYCLE_DAY
            ,trim(split_part(DATA_REC, '|',  33)) as LOCATION_ID
            ,trim(split_part(DATA_REC, '|',  34)) as AGENT_USER_ID
            ,trim(split_part(DATA_REC, '|',  35)) as USER_DATA
            ,trim(split_part(DATA_REC, '|',  36)) as USER_DATA2
            ,trim(split_part(DATA_REC, '|',  37)) as SURROGATE_PROXY_TOKEN_UNIQUE_ID
            ,trim(split_part(DATA_REC, '|',  38)) as PRODUCT_ID
            ,trim(split_part(DATA_REC, '|',  39)) as ID_PASS
            ,trim(split_part(DATA_REC, '|',  40)) as ID_OVERRIDE
            ,trim(split_part(DATA_REC, '|',  41)) as COMPANY_NAME
            ,trim(split_part(DATA_REC, '|',  42)) AS EIN
            ,trim(split_part(DATA_REC, '|',  43)) as BUSINESS_ADDRESS_1
            ,trim(split_part(DATA_REC, '|',  44)) as BUSINESS_ADDRESS_2
            ,trim(split_part(DATA_REC, '|',  45)) as BUSINESS_ADDRESS_3
            ,trim(split_part(DATA_REC, '|',  46)) as BUSINESS_CITY
            ,trim(split_part(DATA_REC, '|',  47)) as BUSINESS_STATE
            ,trim(split_part(DATA_REC, '|',  48)) as BUSINESS_ZIP
            ,trim(split_part(DATA_REC, '|',  49)) as BUSINESS_COUNTRY
            ,trim(split_part(DATA_REC, '|',  50)) as CUST_ACCOUNT_TYPE
            ,trim(split_part(DATA_REC, '|',  51)) as COUNTRY_CITIZENSHIP    
            --Ingestion Control based on Compliant Files
            ,D.FILE_ROW_NUMBER
            ,split_part(D.FILE_NAME, '/',  -1) as FILE_NAME
            ,FILE_ROW_KEY
            ,FILE_INSERT_TS
            ,MAX_ROW_NUMBER
            ,H.HEADER_TRAIL_REC
        from CUSTOMER as D
        inner join CUSTOMER_HEADER_TRAIL_REC as H on D.FILE_NAME = H.FILE_NAME
        where left(DATA_REC, 1) = ( 'D' )
	{% else %}
        --Non Compliant processor        
        select 
            'D' as RECORD_TYPE                                                    
            ,PAYMENT_PROCESSOR
            ,CUST_ACCOUNT_ID
            ,FIRST_NAME
            ,LAST_NAME
            ,ADDRESS_1
            ,ADDRESS_2
            ,CITY	
            ,STATE
            ,ZIP
            ,COUNTRY
            ,PRIMARY_PHONE_NUMBER
            ,SECONDARY_PHONE_NUMBER
            ,DATE_OF_BIRTH
            ,ID_TYPE
            ,ID_NUMBER
            ,ID_STATE
            ,ID_COUNTRY
            ,ID_ISSUED_DATE
            ,ID_EXPIRE_DATE
            ,ID_2
            ,ID_TYPE2
            ,SSN
            ,TIN_TYPE
            ,PROGRAM_ID
            ,CUST_STATUS
            ,CREATED_DATE
            ,LAST_UPDATED_DATE
            ,OTHER_INFO
            ,EMAIL
            ,PRN
            ,EXTERNAL_ACCOUNT_NUMBER
            ,BILL_CYCLE_DAY
            ,LOCATION_ID
            ,AGENT_USER_ID
            ,USER_DATA
            ,USER_DATA2
            ,SURROGATE_PROXY_TOKEN_UNIQUE_ID
            ,PRODUCT_ID
            ,ID_PASS
            ,ID_OVERRIDE
            ,COMPANY_NAME
            ,EIN
            ,BUSINESS_ADDRESS_1
            ,BUSINESS_ADDRESS_2
            ,BUSINESS_ADDRESS_3
            ,BUSINESS_CITY
            ,BUSINESS_STATE
            ,BUSINESS_ZIP
            ,BUSINESS_COUNTRY
            ,CUST_ACCOUNT_TYPE
            ,COUNTRY_CITIZENSHIP                                  
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