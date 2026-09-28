-- Preppin' Data 2023 Week 05

-- Create the bank code by splitting out off the letters from the Transaction code, call this field 'Bank'
-- Change transaction date to the just be the month of the transaction
-- Total up the transaction values so you have one row for each bank and month combination
-- Rank each bank for their value of transactions each month against the other banks. 1st is the highest value of transactions, 3rd the lowest. 
-- Without losing all of the other data fields, find:
--     - The average rank a bank has across all of the months, call this field 'Avg Rank per Bank'
--     - The average transaction value per rank, call this field 'Avg Transaction Value per Rank'

with bank_rank as(
    select
        split_part(transaction_code,'-',1) Bank
        , to_char(to_date(transaction_date, 'DD/MM/YYYY HH24:MI:SS'),'MMMM') Transaction_Month
        , sum(value) value
        , rank() over (partition by transaction_month order by sum(value) desc) bank_rank_per_month
    from PD2023_WK01
    group by Bank, Transaction_Month
    )

select *
    , avg(value) over(partition by bank_rank_per_month) avg_value_per_rank
    , avg(bank_rank_per_month) over(partition by bank) avg_rank_per_bank
from bank_rank;
