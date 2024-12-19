-- Preppin' Data 2023 Week 04

-- We want to stack the tables on top of one another, since they have the same fields in each sheet. We can do this one of 2 ways:
    -- Drag each table into the canvas and use a union step to stack them on top of one another
    -- Use a wildcard union in the input step of one of the tables
-- Some of the fields aren't matching up as we'd expect, due to differences in spelling. Merge these fields together
-- Make a Joining Date field based on the Joining Day, Table Names and the year 2023
-- Now we want to reshape our data so we have a field for each demographic, for each new customer (help)
-- Make sure all the data types are correct for each field
-- Remove duplicates (help)
    -- If a customer appears multiple times take their earliest joining date

-- My solution without ctes (below). Will's solution with ctes: https://github.com/wjsutton/preppin-data/blob/main/2023/SQL/2023_week_04.sql

SELECT
    ID
    , 'Account Type'
    , 'Date of Birth'
    , 'Ethnicity'
    , MIN(TO_DATE(CONCAT(joining_day, ' ' , tablename, ' ' , 2023), 'DD MMMM YYYY')) joining_date
FROM
(
SELECT *
    , 'January' tablename
FROM PD2023_WK04_JANUARY
    UNION
SELECT *
    , 'February' tablename
FROM PD2023_WK04_FEBRUARY
    UNION
SELECT *
    , 'March' tablename
FROM PD2023_WK04_MARCH
    UNION
SELECT *
    , 'April' tablename
FROM PD2023_WK04_APRIL
    UNION
SELECT *
    , 'May' tablename
FROM PD2023_WK04_MAY
    UNION
SELECT *
    , 'June' tablename
FROM PD2023_WK04_JUNE
    UNION
SELECT *
    , 'July' tablename
FROM PD2023_WK04_JULY
    UNION
SELECT *
    , 'August' tablename
FROM PD2023_WK04_AUGUST
    UNION
SELECT *
    , 'September' tablename
FROM PD2023_WK04_SEPTEMBER
    UNION
SELECT *
    , 'October' tablename
FROM PD2023_WK04_OCTOBER
    UNION
SELECT *
    , 'November' tablename
FROM PD2023_WK04_NOVEMBER
    UNION
SELECT *
    , 'December' tablename
FROM PD2023_WK04_DECEMBER
)
PIVOT(MIN(value) for demographic IN (ANY))
GROUP BY 1
