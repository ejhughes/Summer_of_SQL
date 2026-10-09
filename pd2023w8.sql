-- Preppin' Data 2023 Week 08

-- Create a 'file date' using the month found in the file name
--     - The Null value should be replaced as 1
-- Clean the Market Cap value to ensure it is the true value as 'Market Capitalisation'
--     - Remove any rows with 'n/a'
-- Categorise the Purchase Price into groupings
    -- 0 to 24,999.99 as 'Low'
    -- 25,000 to 49,999.99 as 'Medium'
    -- 50,000 to 74,999.99 as 'High'
    -- 75,000 to 100,000 as 'Very High'
-- Categorise the Market Cap into groupings
    -- Below $100M as 'Small'
    -- Between $100M and below $1B as 'Medium'
    -- Between $1B and below $100B as 'Large' 
    -- $100B and above as 'Huge'
-- Rank the highest 5 purchases per combination of: file date, Purchase Price Categorisation and Market Capitalisation Categorisation.
-- Output only records with a rank of 1 to 5

-- my solution: union tables from every month, clean up market_cap field, categorise market_cap & purchase_price, rank by purchase price and filter to top 5

with annual_trades as(
    select *, 1 month from pd2023_wk08_01
    UNION ALL
    select *, 2 month from pd2023_wk08_02
    UNION ALL
    select *, 3 month from pd2023_wk08_03
    UNION ALL
    select *, 4 month from pd2023_wk08_04
    UNION ALL
    select *, 5 month from pd2023_wk08_05
    UNION ALL
    select *, 6 month from pd2023_wk08_06
    UNION ALL
    select *, 7 month from pd2023_wk08_07
    UNION ALL
    select *, 8 month from pd2023_wk08_08
    UNION ALL
    select *, 9 month from pd2023_wk08_09
    UNION ALL
    select *, 10 month from pd2023_wk08_10
    UNION ALL
    select *, 11 month from pd2023_wk08_11
    UNION ALL
    select *, 12 month from pd2023_wk08_12
),

annual_trades_to_num as(
select *
    , date_from_parts(2023, month, 1) file_date
    , LTRIM(purchase_price, '$')::FLOAT purchase_price_num
    , CASE 
        WHEN CONTAINS(LTRIM(market_cap,'$'), 'M') THEN RTRIM(LTRIM(market_cap,'$'),'M')::FLOAT * POW(10,6)
        WHEN CONTAINS(LTRIM(market_cap,'$'), 'B') THEN RTRIM(LTRIM(market_cap,'$'),'B')::FLOAT * POW(10,9)
        ELSE LTRIM(market_cap,'$')::FLOAT
    END Market_Capitalisation
from annual_trades
where market_cap <> 'n/a'
),

annual_trades_clean as(
select
    CASE 
        WHEN Market_Capitalisation <POW(10,8) THEN 'Small'
        WHEN Market_Capitalisation <POW(10,9) THEN 'Medium'
        WHEN Market_Capitalisation <POW(10,11) THEN 'Large'
        ELSE 'Huge'
    END market_capitalisation_category
    , CASE
        WHEN purchase_price_num <25000 THEN 'Small'
        WHEN purchase_price_num <50000 THEN 'Medium'
        WHEN purchase_price_num <75000 THEN 'Large'
        ELSE 'Very High'
    END purchase_price_category
    , file_date
    , ticker
    , sector
    , market
    , stock_name
    , Market_Capitalisation
    , purchase_price
from annual_trades_to_num
),

annual_trades_ranked as(
select 
    RANK() OVER(partition by file_date, purchase_price_category, market_capitalisation_category order by purchase_price desc) rank
    , *
from annual_trades_clean
),

RANKED AS (
SELECT 
RANK() OVER(PARTITION BY file_date, market_capitalisation_category, purchase_price_category ORDER BY (SUBSTR(purchase_price,2,LENGTH(purchase_price)))::float DESC) as rnk,
*
FROM annual_trades_clean
)

select *
from annual_trades_ranked
where rank <= 5;
