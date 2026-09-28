-- Preppin' Data 2023 Week 06

-- Reshape the data so we have 5 rows for each customer, with responses for the Mobile App and Online Interface being in separate fields on the same row
-- Clean the question categories so they don't have the platform in from of them
--     - e.g. Mobile App - Ease of Use should be simply Ease of Use
-- Exclude the Overall Ratings, these were incorrectly calculated by the system
-- Calculate the Average Ratings for each platform for each customer 
-- Calculate the difference in Average Rating between Mobile App and Online Interface for each customer
-- Catergorise customers as being:
--     - Mobile App Superfans if the difference is greater than or equal to 2 in the Mobile App's favour
--     - Mobile App Fans if difference >= 1
--     - Online Interface Fan
--     - Online Interface Superfan
--     - Neutral if difference is between 0 and 1
-- Calculate the Percent of Total customers in each category, rounded to 1 decimal place


--- my solution, via ctes: 
--- 1) Unpivot all the survey categories fields
--- 2) Split to separate interface from survey category
--- 3) Pivot to two columns (one for each interface)
--- 4) Calculate the average ratings for each interface per customer
--- 5) Define customer categories of interface preference
--- 6) Calculate % of total customers that fall within each preference category

with unpivot_table as(
    select *
    from pd2023_wk06_dsb_customer_survey
    unpivot (
        rating for category in (
        MOBILE_APP___EASE_OF_USE, 
        MOBILE_APP___EASE_OF_ACCESS,
        MOBILE_APP___NAVIGATION,
        MOBILE_APP___LIKELIHOOD_TO_RECOMMEND,
        ONLINE_INTERFACE___EASE_OF_USE,
        ONLINE_INTERFACE___EASE_OF_ACCESS,
        ONLINE_INTERFACE___NAVIGATION,
        ONLINE_INTERFACE___LIKELIHOOD_TO_RECOMMEND
        ))
    ),

split_table as(
    select 
        customer_id
        , split_part(category, '___', 1) interface
        , split_part(category, '___', 2) q_category
        , rating
    from unpivot_table
    ),

pivot_table as(
    select *
    from split_table
    pivot(min(rating) for INTERFACE in ('MOBILE_APP' as mobile, 'ONLINE_INTERFACE' as online))
    ),

avg_ratings as(
    select 
        customer_id
        , avg(mobile) as movile_avg
        , avg(online) as online_avg
        , avg(mobile) - avg(online) as difference
    from pivot_table
    group by customer_id
),

cust_categories as(
    select 
        customer_id
        , difference
        , CASE 
            WHEN difference >= 2 THEN 'Mobile App Superfan'
            WHEN difference >=1 THEN 'Mobile App Fan'
            WHEN difference >-1 THEN 'Neutral'
            WHEN difference >-2 THEN 'Online Interface Fan'
            ELSE 'Online Interface Superfan'
        END as preference
    from avg_ratings
),

preference as(
    select 
        preference
        , ROUND(COUNT(*)/(select COUNT(*) from cust_categories)*100,1) percent_of_total
    from cust_categories
    group by preference
)

select *
from preference;
