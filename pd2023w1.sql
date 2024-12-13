-- Preppin' Data 2023 Week 01
-- https://preppindata.blogspot.com/2023/01/2023-week-1-data-source-bank.html

-- Split the Transaction Code to extract the letters at the start of the transaction code. These identify the bank who processes the transaction 
    -- Rename the new field with the Bank code 'Bank'. 
-- Rename the values in the Online or In-person field, Online of the 1 values and In-Person for the 2 values. 
-- Change the date to be the day of the week
-- Different levels of detail are required in the outputs. You will need to sum up the values of the transactions in three ways:
    -- 1. Total Values of Transactions by each bank
    -- 2. Total Values by Bank, Day of the Week and Type of Transaction (Online or In-Person)
    -- 3. Total Values by Bank and Customer Code

-- 1. Total Values of Transactions by each bank
SELECT
    SPLIT_PART(transaction_code,'-',1) AS BANK
    , SUM(value) VALUE
FROM PD2023_WK01
GROUP BY 1
;

-- 2. Total Values by Bank, Day of the Week and Type of Transaction (Online or In-Person)
SELECT
    SPLIT_PART(transaction_code,'-',1) AS BANK
    , CASE online_or_in_person
        WHEN 1 THEN 'Online'
        WHEN 2 THEN 'In Person'
        END
    AS ONLINE_OR_IN_PERSON
    , dayname(
        to_date(
            concat(
                split_part(split_part(transaction_date,' ',1),'/',3)
                , '-'
                , split_part(transaction_date,'/',2)
                , '-'
                , split_part(transaction_date,'/',1)
                ))) AS DAY_OF_WEEK
    /*Simpler date conversion by using DAYNAME(DATE(transaction_date,'dd/MM/yyyy hh24:mi:ss')) as day_of_week*/
    , SUM(value) VALUE
FROM PD2023_WK01
GROUP BY 1,2,3
;

-- 3. Total Values by Bank and Customer Code
SELECT
    SPLIT_PART(transaction_code,'-',1) AS BANK
    , customer_code
    , SUM(value) VALUE
FROM PD2023_WK01
GROUP BY 1,2
;



