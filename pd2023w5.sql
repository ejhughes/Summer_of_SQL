-- Preppin' Data 2023 Week 05

-- Create the bank code by splitting out off the letters from the Transaction code, call this field 'Bank'
-- Change transaction date to the just be the month of the transaction
-- Total up the transaction values so you have one row for each bank and month combination
-- Rank each bank for their value of transactions each month against the other banks. 1st is the highest value of transactions, 3rd the lowest. 
-- Without losing all of the other data fields, find:
--     - The average rank a bank has across all of the months, call this field 'Avg Rank per Bank'
--     - The average transaction value per rank, call this field 'Avg Transaction Value per Rank'

-- my solution: one main cte for rank of bank transactions each month, then window calcs for average transaction value per rank & average rank per bank

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

-------------------------------------------------------------------------------------------------------------------------
-- Will's solution, three separate ctes where averages are calculated in distinct ctes, later brought together with joins

WITH CTE AS (
SELECT 
SPLIT_PART(transaction_code,'-',1) as bank,
DATENAME('month',DATE(transaction_date,'dd/MM/yyyy hh24:mi:ss')) as month,
SUM(value) as total_transaction_values,
RANK() OVER(PARTITION BY MONTHNAME(DATE(transaction_date,'dd/MM/yyyy hh24:mi:ss')) ORDER BY SUM(value) DESC) as rnk
FROM pd2023_wk01
GROUP BY SPLIT_PART(transaction_code,'-',1),
MONTHNAME(DATE(transaction_date,'dd/MM/yyyy hh24:mi:ss'))
)
,AVG_RANK AS (
SELECT 
bank,
AVG(rnk) as average_rank_across_all_months
FROM CTE
GROUP BY bank
)
,AVG_RNK_VALUE AS (
SELECT 
rnk,
AVG(total_transaction_values) as avg_transaction_per_rank
FROM CTE
GROUP BY rnk
)
SELECT 
CTE.*,
average_rank_across_all_months as avg_rank_per_bank,
avg_transaction_per_rank as avg_transaction_value_per_rank
FROM CTE
INNER JOIN AVG_RANK as AR ON AR.bank = CTE.bank
INNER JOIN AVG_RNK_VALUE as AV ON AV.rnk = CTE.rnk
