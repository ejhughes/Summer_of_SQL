-- Data with Danny's 8-week SQL challenge
-- Week 3
-- Case Study: Foodie Fi 

-- section A. Customer Journey
-- Describing customer's onboarding journeys

-- my summary: all customers start on a trial plan, 54.6% then convert to basic monthly, 32.5% convert to pro monthly, only 3.7% convert to pro annual and 9.2% churn
with cte AS(
    SELECT
        customer_id
        , plan_name
        , price
        , start_date
        , CASE WHEN row_number() OVER(PARTITION BY customer_id ORDER BY start_date)=1 THEN 'first_plan' WHEN row_number() OVER(PARTITION BY customer_id ORDER BY start_date)=2 THEN 'second_plan' END plan_num
    FROM subscriptions s
    JOIN plans p
        ON s.plan_id=p.plan_id
),

cte_first_plans AS(
    SELECT 
        customer_id
        , plan_name
        , plan_num
    FROM cte
    WHERE plan_num IS NOT NULL
),

cte_pivot AS(
    SELECT 
        customer_id
        , "'first_plan'" first_plan
        , "'second_plan'" second_plan
    FROM cte_first_plans
        PIVOT(MIN(plan_name) for plan_num in ('first_plan', 'second_plan'))
),

min_plan_date AS(
    SELECT 
        customer_id
        , MIN(start_date) start_date
        , DATEDIFF('day', MIN(start_date), MAX(start_date)) days_until_plan_change
    FROM cte
    GROUP BY 1
)
SELECT 
    first_plan
    , second_plan
    , COUNT(customer_id)
    , (COUNT(customer_id) / SUM(COUNT(customer_id)) OVER())*100 percent
FROM (
    SELECT cte.customer_id
        , first_plan
        , second_plan
        , d.start_date
        , days_until_plan_change
        , MIN(price) first_payment
        , MAX(price) second_payment
    FROM cte
        JOIN cte_pivot p
            ON cte.customer_id=p.customer_id
        JOIN min_plan_date d
            ON cte.customer_id=d.customer_id
    WHERE plan_num IS NOT NULL
    GROUP BY 1, 2 ,3, 4, 5
)
GROUP BY 1,2 
;

----------------------------------------------------------------------------------------------------------

-- section B. Data Analyst Questions

-- 1. How many customers has Foodie-Fi ever had?
-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
-- 6. What is the number and percentage of customer plans after their initial free trial?
-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
-- 8. How many customers have upgraded to an annual plan in 2020?
  -- Any customer going to annual plan
-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
