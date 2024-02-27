{% macro generate_stg_compliant_transaction(reference_source,reference_table,is_new_spec) %}
    {% if is_new_spec == 'y' %}
    --Compliant processor file  
        with TRANSACTION as(      
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
        ,TRANSACTION_HEADER_TRAIL_REC as(
            select             
                H.DATA_REC||'|'||T.DATA_REC as HEADER_TRAIL_REC,H.FILE_NAME
            from TRANSACTION  H 
            join (select DATA_REC,FILE_NAME from TRANSACTION where  FILE_ROW_NUMBER = MAX_ROW_NUMBER ) T on T.FILE_NAME = H.FILE_NAME
            where FILE_ROW_NUMBER = 1  
        )
        select
            trim(split_part(DATA_REC, '|',  1)) as RECORD_TYPE
            ,trim(split_part(HEADER_TRAIL_REC, '|',  3))  as PAYMENT_PROCESSOR
            ,trim(split_part(DATA_REC, '|',  2)) as PROGRAM_ID
            ,trim(split_part(DATA_REC, '|',  3)) as ACCOUNT_NUMBER
            ,trim(split_part(DATA_REC, '|',  4)) as TRANSACTION_CODE
            ,trim(split_part(DATA_REC, '|',  5)) as TRANSACTION_AMOUNT
            ,trim(split_part(DATA_REC, '|',  6)) as TRANSACTION_CURRENCY
            ,trim(split_part(DATA_REC, '|',  7)) as TRANSACTION_DESCRIPTION
            ,trim(split_part(DATA_REC, '|',  8)) as TRANSACTION_TYPE
            ,trim(split_part(DATA_REC, '|',  9)) as TRANSACTION_STATUS
            ,trim(split_part(DATA_REC, '|',  10)) as RESPONSE_CODE
            ,trim(split_part(DATA_REC, '|',  11)) as AUTHORIZATION_CODE
            ,trim(split_part(DATA_REC, '|',  12)) as POST_DATE
            ,trim(split_part(DATA_REC, '|',  13)) as NETWORK_CODE
            ,trim(split_part(DATA_REC, '|',  14)) as MERCHANT_NUMBER
            ,trim(split_part(DATA_REC, '|',  15)) as MERCHANT_NAME
            ,trim(split_part(DATA_REC, '|',  16)) as MERCHANT_CITY
            ,trim(split_part(DATA_REC, '|',  17)) as MERCHANT_STATE
            ,trim(split_part(DATA_REC, '|',  18)) as MERCHANT_ZIP
            ,trim(split_part(DATA_REC, '|',  19)) as MERCHANT_CATEGORY
            ,trim(split_part(DATA_REC, '|',  20)) as MERCHANT_COUNTRY
            ,trim(split_part(DATA_REC, '|',  21)) as INTERCHANGE_FEE
            ,trim(split_part(DATA_REC, '|',  22)) as TRANSACTION_ID
            ,trim(split_part(DATA_REC, '|',  23)) as PSEUDO_DDA
            ,trim(split_part(DATA_REC, '|',  24)) as CARD_ID
            ,trim(split_part(DATA_REC, '|',  25)) as OTHER_DATA1
            ,trim(split_part(DATA_REC, '|',  26)) as OTHER_DATA2
            ,trim(split_part(DATA_REC, '|',  27)) as FOREIGN_TERMINAL
            ,trim(split_part(DATA_REC, '|',  28)) as SETTLED_DATE
            ,trim(split_part(DATA_REC, '|',  29)) as POS_INDICATOR
            ,trim(split_part(DATA_REC, '|',  30)) as CREATED_DATE
            ,trim(split_part(DATA_REC, '|',  31)) as LAST_UPDATED_DATE
            ,trim(split_part(DATA_REC, '|',  32)) as TRANSACTION_DATE
            --,trim(split_part(DATA_REC, '|',  33)) as TRANSACTION_ID_UNIQUE
            , case
                when trim(split_part(DATA_REC, '|',  33)) is null or trim(split_part(DATA_REC, '|',  33)) ='' 
                    then MD5(coalesce(TRANSACTION_ID,'') || FILE_INSERT_TS || split_part(D.FILE_NAME, '/',  -1) || D.FILE_ROW_NUMBER)
                else trim(split_part(DATA_REC, '|',  33))
            end as TRANSACTION_ID_UNIQUE
            ,trim(split_part(DATA_REC, '|',  34)) as SURROGATE_PROXY_TOKEN_UNIQUE_ID
            ,trim(split_part(DATA_REC, '|',  35)) as PRODUCT_ID
            ,trim(split_part(DATA_REC, '|',  36))  as DEBIT_PARTY_TYPE
            ,trim(split_part(DATA_REC, '|',  37))  as DEBIT_PARTY_ACCOUNT_NUMBER
            ,trim(split_part(DATA_REC, '|',  38))  as DEBIT_PARTY_NAME
            ,trim(split_part(DATA_REC, '|',  39))  as DEBIT_PARTY_ADDR_1
            ,trim(split_part(DATA_REC, '|',  40))  as DEBIT_PARTY_ADDR_2
            ,trim(split_part(DATA_REC, '|',  41))  as DEBIT_PARTY_ADDR_3
            ,trim(split_part(DATA_REC, '|',  42))  as DEBIT_VALUE_DATE
            ,trim(split_part(DATA_REC, '|',  43))  as DEBIT_PARTY_COUNTRY
            ,trim(split_part(DATA_REC, '|',  44))  as CREDIT_PARTY_TYPE
            ,trim(split_part(DATA_REC, '|',  45))  as CREDIT_PARTY_ACCOUNT_NUMBER
            ,trim(split_part(DATA_REC, '|',  46))  as CREDIT_PARTY_NAME
            ,trim(split_part(DATA_REC, '|',  47))  as CREDIT_PARTY_ADDR_1
            ,trim(split_part(DATA_REC, '|',  48))  as CREDIT_PARTY_ADDR_2
            ,trim(split_part(DATA_REC, '|',  49))  as CREDIT_PARTY_ADDR_3
            ,trim(split_part(DATA_REC, '|',  50))  as CREDIT_VALUE_DATE
            ,trim(SPLIT_PART(DATA_REC, '|',  51))  as CREDIT_PARTY_COUNTRY
            ,trim(SPLIT_PART(DATA_REC, '|',  52))  as INTERMEDIARY_3RD_PARTY_TYPE
            ,trim(SPLIT_PART(DATA_REC, '|',  53))  as INTERMEDIARY_ACCOUNT_3RD_PARTY_ID
            ,trim(SPLIT_PART(DATA_REC, '|',  54))  as INTERMEDIARY_3RD_PARTY_NAME
            ,trim(SPLIT_PART(DATA_REC, '|',  55))  as INTERMEDIARY_3RD_PARTY_ADDR_1
            ,trim(SPLIT_PART(DATA_REC, '|',  56))  as INTERMEDIARY_3RD_PARTY_ADDR_2
            ,trim(SPLIT_PART(DATA_REC, '|',  57))  as INTERMEDIARY_3RD_PARTY_ADDR_3
            ,trim(SPLIT_PART(DATA_REC, '|',  58))  as INSTRUCTING_PARTY_NAME
            ,trim(SPLIT_PART(DATA_REC, '|',  59))  as INSTRUCTING_PARTY_ADDR_1
            ,trim(SPLIT_PART(DATA_REC, '|',  60))  as INSTRUCTING_PARTY_ADDR_2
            ,trim(SPLIT_PART(DATA_REC, '|',  61))  as INSTRUCTING_PARTY_ADDR_3
            ,trim(SPLIT_PART(DATA_REC, '|',  62))  as BENEFICIARY_4TH_PARTY_TYPE
            ,trim(SPLIT_PART(DATA_REC, '|',  63))  as BENEFICIARY_BANK_ID_4TH_PARTY_ID
            ,trim(SPLIT_PART(DATA_REC, '|',  64))  as BENEFICIARY_BANK_ROUTING_4TH_PARTY_NAME
            ,trim(SPLIT_PART(DATA_REC, '|',  65))  as BENEFICIARY_BANK_4TH_PARTY_ADDR_1
            ,trim(SPLIT_PART(DATA_REC, '|',  66))  as BENEFICIARY_BANK_4TH_PARTY_ADDR_2
            ,trim(SPLIT_PART(DATA_REC, '|',  67))  as BENEFICIARY_BANK_4TH_PARTY_ADDR_3
            ,trim(SPLIT_PART(DATA_REC, '|',  68))  as BENEFICIARY_5TH_PARTY_TYPE
            ,trim(SPLIT_PART(DATA_REC, '|',  69))  as BENEFICIARY_ID_5TH_PARTY_ID
            ,trim(SPLIT_PART(DATA_REC, '|',  70))  as BENEFICIARY_NAME_5TH_PARTY_NAME
            ,trim(SPLIT_PART(DATA_REC, '|',  71))  as BENEFICIARY_5TH_PARTY_ADDR_1
            ,trim(SPLIT_PART(DATA_REC, '|',  72))  as BENEFICIARY_5TH_PARTY_ADDR_2
            ,trim(SPLIT_PART(DATA_REC, '|',  73))  as BENEFICIARY_5TH_PARTY_ADDR_3
            ,trim(split_part(DATA_REC, '|',  74))  as TRANSACTION_NOTE
            ,trim(split_part(DATA_REC, '|',  75))  as ORIGINAL_TRANSACTION_AMOUNT
            ,trim(split_part(DATA_REC, '|',  76))  as TRANSACTION_AMOUNT_LOCAL
            ,trim(split_part(DATA_REC, '|',  77))  as TRANSACTION_CURRENCY_LOCAL_CODE 
            --Ingestion Control based on Compliant Files              
            ,D.FILE_ROW_NUMBER
            ,split_part(D.FILE_NAME, '/',  -1) as FILE_NAME
            ,FILE_ROW_KEY
            ,FILE_INSERT_TS
            ,MAX_ROW_NUMBER
            ,H.HEADER_TRAIL_REC
        from TRANSACTION as D
        inner join TRANSACTION_HEADER_TRAIL_REC as H on D.FILE_NAME = H.FILE_NAME
        where left(DATA_REC, 1) = ( 'D' )
	{% else %}
        --Non Compliant processor        
        select 
            'D' as RECORD_TYPE                                                    
            , PAYMENT_PROCESSOR
            , PROGRAM_ID
            , ACCOUNT_NUMBER
            , TRANSACTION_CODE
            , TRANSACTION_AMOUNT
            , TRANSACTION_CURRENCY
            , TRANSACTION_DESCRIPTION
            , TRANSACTION_TYPE
            , TRANSACTION_STATUS
            , RESPONSE_CODE
            , AUTHORIZATION_CODE
            , POST_DATE
            , NETWORK_CODE
            , MERCHANT_NUMBER
            , MERCHANT_NAME
            , MERCHANT_CITY
            , MERCHANT_STATE
            , MERCHANT_ZIP
            , MERCHANT_CATEGORY
            , MERCHANT_COUNTRY
            , INTERCHANGE_FEE
            , TRANSACTION_ID
            , PSEUDO_DDA
            , CARD_ID
            , OTHER_DATA1
            , OTHER_DATA2
            , FOREIGN_TERMINAL
            , SETTLED_DATE
            , POS_INDICATOR
            , CREATED_DATE
            , LAST_UPDATED_DATE
            , TRANSACTION_DATE
            --, TRANSACTION_ID_UNIQUE
            , case
                when TRANSACTION_ID_UNIQUE is null or TRANSACTION_ID_UNIQUE ='' 
                    then MD5(coalesce(TRANSACTION_ID,'') || FILE_INSERT_TS || split_part(FILE_NAME, '/',  -1)  || FILE_ROW_NUMBER)                    
                else TRANSACTION_ID_UNIQUE
            end as TRANSACTION_ID_UNIQUE
            , SURROGATE_PROXY_TOKEN_UNIQUE_ID
            , PRODUCT_ID
            , DEBIT_PARTY_TYPE
            , DEBIT_PARTY_ACCOUNT_NUMBER
            , DEBIT_PARTY_NAME
            , DEBIT_PARTY_ADDR_1
            , DEBIT_PARTY_ADDR_2
            , DEBIT_PARTY_ADDR_3
            , DEBIT_VALUE_DATE
            , DEBIT_PARTY_COUNTRY
            , CREDIT_PARTY_TYPE
            , CREDIT_PARTY_ACCOUNT_NUMBER
            , CREDIT_PARTY_NAME
            , CREDIT_PARTY_ADDR_1
            , CREDIT_PARTY_ADDR_2
            , CREDIT_PARTY_ADDR_3
            , CREDIT_VALUE_DATE
            , CREDIT_PARTY_COUNTRY
            , INTERMEDIARY_3RD_PARTY_TYPE
            , INTERMEDIARY_ACCOUNT_3RD_PARTY_ID
            , INTERMEDIARY_3RD_PARTY_NAME
            , INTERMEDIARY_3RD_PARTY_ADDR_1
            , INTERMEDIARY_3RD_PARTY_ADDR_2
            , INTERMEDIARY_3RD_PARTY_ADDR_3
            , INSTRUCTING_PARTY_NAME
            , INSTRUCTING_PARTY_ADDR_1
            , INSTRUCTING_PARTY_ADDR_2
            , INSTRUCTING_PARTY_ADDR_3
            , BENEFICIARY_4TH_PARTY_TYPE
            , BENEFICIARY_BANK_ID_4TH_PARTY_ID
            , BENEFICIARY_BANK_ROUTING_4TH_PARTY_NAME
            , BENEFICIARY_BANK_4TH_PARTY_ADDR_1
            , BENEFICIARY_BANK_4TH_PARTY_ADDR_2
            , BENEFICIARY_BANK_4TH_PARTY_ADDR_3
            , BENEFICIARY_5TH_PARTY_TYPE
            , BENEFICIARY_ID_5TH_PARTY_ID
            , BENEFICIARY_NAME_5TH_PARTY_NAME
            , BENEFICIARY_5TH_PARTY_ADDR_1
            , BENEFICIARY_5TH_PARTY_ADDR_2
            , BENEFICIARY_5TH_PARTY_ADDR_3
            , TRANSACTION_NOTE
            , ORIGINAL_TRANSACTION_AMOUNT
            , TRANSACTION_AMOUNT_LOCAL
            , TRANSACTION_CURRENCY_LOCAL_CODE                                
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