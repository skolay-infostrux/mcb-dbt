{% macro generate_stg_compliant_lookup(reference_source,reference_table) %}

    with LOOKUP as(      
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
    ,LOOKUP_HEADER_TRAIL_REC  as(
        select             
            H.DATA_REC||'|'||T.DATA_REC as HEADER_TRAIL_REC,H.FILE_NAME
        from LOOKUP  H 
        join (select DATA_REC,FILE_NAME from LOOKUP where  FILE_ROW_NUMBER = MAX_ROW_NUMBER ) T on T.FILE_NAME = H.FILE_NAME
        where FILE_ROW_NUMBER = 1  
    )
    select
        split_part(DATA_REC, '|',  1)                 as RECORD_TYPE        --Mandatory
        ,trim(split_part(HEADER_TRAIL_REC, '|',  3))  as PAYMENT_PROCESSOR  --Mandatory
        ,trim(split_part(DATA_REC, '|',  2))          as FILE_TYPE          --Mandatory
        ,trim(split_part(DATA_REC, '|',  3))          as FIELD_NAME         --Mandatory
        ,trim(split_part(DATA_REC, '|',  4))          as CODE	            --Mandatory
        ,trim(split_part(DATA_REC, '|',  5))          as DESCRIPTION        --Mandatory
        --Ingestion Control based on Compliant Files
        ,D.FILE_ROW_NUMBER
        ,split_part(D.FILE_NAME, '/',  -1) as FILE_NAME
        ,FILE_ROW_KEY
        ,FILE_INSERT_TS
        ,MAX_ROW_NUMBER
        ,H.HEADER_TRAIL_REC
    from LOOKUP as D
    inner join LOOKUP_HEADER_TRAIL_REC as H on D.FILE_NAME = H.FILE_NAME
    where left(DATA_REC, 1) = ( 'D' )  
     
{% endmacro %}