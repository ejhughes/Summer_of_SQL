-- Preppin' Data 2023 Week 02
-- https://preppindata.blogspot.com/2023/01/2023-week-2-international-bank-account.html

-- In the Transactions table, there is a Sort Code field which contains dashes. We need to remove these so just have a 6 digit string
-- Use the SWIFT Bank Code lookup table to bring in additional information about the SWIFT code and Check Digits of the receiving bank account
-- Add a field for the Country Code
      -- Hint: all these transactions take place in the UK so the Country Code should be GB
-- Create the IBAN as above
      -- Hint: watch out for trying to combine string fields with numeric fields - check data types
-- Remove unnecessary fields

SELECT
    transaction_id
    , CONCAT('GB', check_digits, swift_code, REPLACE(sort_code,'-',''), account_number) IBAN
FROM PD2023_WK02_TRANSACTIONS t
JOIN PD2023_WK02_SWIFT_CODES s
     ON t.bank=s.bank

/* Alternative concatenation method: 'GB' || check_digits || swift_code || REPLACE(sort_code,'-','') || account_number */
