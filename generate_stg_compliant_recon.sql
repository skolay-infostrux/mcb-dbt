{% macro generate_stg_compliant_recon(reference_source,reference_table) %}
    with RECON as(      
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
    ,RECON_HEADER_TRAIL_REC  as(
        select             
            H.DATA_REC||'|'||T.DATA_REC as HEADER_TRAIL_REC,H.FILE_NAME
        from RECON  H 
        join (select DATA_REC,FILE_NAME from RECON where  FILE_ROW_NUMBER = MAX_ROW_NUMBER ) T on T.FILE_NAME = H.FILE_NAME
        where FILE_ROW_NUMBER = 1  
    )
    select 
        trim(split_part(DATA_REC, '|',  1)) as RECORD_TYPE                           --Mandatory
        ,trim(split_part(H.HEADER_TRAIL_REC, '|',  3))    as PAYMENT_PROCESSOR       --Mandatory
        ,trim(split_part(DATA_REC, '|',  2))  as CUST_ACCOUNT_ID	                 --Mandatory
        ,trim(split_part(DATA_REC, '|',  3))  as ACCOUNT_NUMBER			             --Mandatory
        ,trim(split_part(DATA_REC, '|',  4))  as TRANSACTION_ID	    
        --Ingestion Control based on Compliant Files
        ,D.FILE_ROW_NUMBER
        ,split_part(D.FILE_NAME, '/',  -1) as FILE_NAME
        ,FILE_ROW_KEY
        ,FILE_INSERT_TS
        ,MAX_ROW_NUMBER
        ,H.HEADER_TRAIL_REC
    from RECON as D
    inner join RECON_HEADER_TRAIL_REC as H on D.FILE_NAME = H.FILE_NAME
    where left(DATA_REC, 1) = ( 'D' )
  
{% endmacro %}