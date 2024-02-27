{{ config(
    tags=["integrate","prepaid"],
    alias='customer_dim',
    schema='prepaid'
    )
}}

select 
    CUST_ACCOUNT_ID as CUSTOMER_ID 
    , CUST_STATUS as CUSTOMER_STATUS 
    , CUST_ACCOUNT_TYPE as CUSTOMER_TYPE 
    , FIRST_NAME 
    , LAST_NAME 
    , DATE_OF_BIRTH
    , ADDRESS_1 
    , ADDRESS_2 
    , CITY 
    , STATE 
    , COUNTRY 
    , ZIP 
    , PRIMARY_PHONE_NUMBER 
    , SECONDARY_PHONE_NUMBER 
    , EMAIL 
    , ID_TYPE as ID_TYPE_1 
    , ID_NUMBER as ID_NUMBER_1 
    , ID_STATE as ID_STATE_1 
    , ID_COUNTRY as ID_COUNTRY_1 
    , ID_ISSUED_DATE as ID_ISSUED_DATE_1 
    , ID_EXPIRE_DATE as ID_EXPIRY_DATE_1
    , ID_TYPE2 as ID_TYPE_2 
    , ID_2 as ID_NUMBER_2 
    , COUNTRY_CITIZENSHIP 
    , TIN_TYPE 
    , SSN 
    , EIN 
    , COMPANY_NAME 
    , BUSINESS_ADDRESS_1 
    , BUSINESS_ADDRESS_2 
    , BUSINESS_ADDRESS_3 
    , BUSINESS_CITY 
    , BUSINESS_STATE 
    , BUSINESS_COUNTRY 
    , BUSINESS_ZIP 
    , LOCATION_ID 
    , AGENT_USER_ID 
    , USER_DATA as USER_DATA_1 
    , USER_DATA2 as USER_DATA_2 
    , ID_PASS as ID_VERIFICATION_RESULTS
    , ID_OVERRIDE as ID_VERIFICATION_RESULTS_OVERRIDE
    , OTHER_INFO 
    , CREATED_DATE
    , LAST_UPDATED_DATE
    , PAYMENT_PROCESSOR as PROCESSOR_NAME
from {{ ref('prepaid__normalize_customer') }}