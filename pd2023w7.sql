-- Preppin' Data 2023 Week 07

-- For the Transaction Path table:
--     - Make sure field naming convention matches the other tables
--         - i.e. instead of Account_From it should be Account From
-- For the Account Information table:
--     - Make sure there are no null values in the Account Holder ID
--     - Ensure there is one row per Account Holder ID
--         - Joint accounts will have 2 Account Holders, we want a row for each of them
-- For the Account Holders table:
--     - Make sure the phone numbers start with 07
-- Bring the tables together
-- Filter out cancelled transactions 
-- Filter to transactions greater than £1,000 in value 
-- Filter out Platinum accounts



-- my solution: ctes for pivots & cleaning tables, then join & filter

with account_id_split as(
    select account_number
        , account_type
        , balance_date
        , balance
        ,split_part(account_holder_id, ', ',1) account_id_1
        ,split_part(account_holder_id, ', ',2) account_id_2
    from pd2023_wk07_account_information
),

account_id_pivot as(
    select account_number
        , account_type
        , balance_date
        , balance
        , account_holder_id
    from account_id_split
        unpivot(
        account_holder_id for account_id in (
            account_id_1,
            account_id_2)
    )
),

account_information_pivot as(
    select *
    from account_id_pivot
    where account_holder_id != ''
),

account_holders as(
    select lpad(account_holder_id, 8, '0') account_holder_id
        , name
        , date_of_birth
        , concat('0',to_char(contact_number)) contact_number
        , first_line_of_address
    from pd2023_wk07_account_holders
)


select tp.transaction_id
    , tp.account_to
    , td.transaction_date
    , td.value
    , ai.account_number
    , ai.account_type
    , ai.balance_date
    , ai.balance
    , ah.name
    , ah.date_of_birth
    , ah.contact_number
    , ah.first_line_of_address
from pd2023_wk07_transaction_path as tp
join pd2023_wk07_transaction_detail as td
    on tp.transaction_id = td.transaction_id
join account_information_pivot ai
    on account_from = account_number
left join account_holders ah
  on ai.account_holder_id = ah.account_holder_id
where cancelled_='N' and value > 1000 and account_type!='Platinum';


-- will's solution

WITH ACC as (
SELECT 
ACCOUNT_NUMBER, 
ACCOUNT_TYPE, 
value as ACCOUNT_HOLDER_ID, 
BALANCE_DATE, 
BALANCE
FROM pd2023_wk07_account_information, LATERAL SPLIT_TO_TABLE(account_holder_id,', ') -- uses LATERAL split_to_table for the unpivot
WHERE account_holder_id IS NOT NULL
)
SELECT 
D.transaction_id,
account_to,
transaction_date,
value,
account_number,
account_type,
balance_date,
balance,
name,
date_of_birth,
'0' || contact_number::varchar(20) as contact_number, -- concatenates using the || functionality and ::varchar to cast the numerical field to a string with max 20 characters
first_line_of_address
FROM pd2023_wk07_transaction_detail as D
INNER JOIN pd2023_wk07_transaction_path as P ON D.transaction_id = P.transaction_id
INNER JOIN ACC on ACC.account_number = P.account_from
INNER JOIN pd2023_wk07_account_holders as H ON H.account_holder_id = ACC.account_holder_id
WHERE cancelled_ = 'N'
AND value > 1000
AND account_type <> 'Platinum'
