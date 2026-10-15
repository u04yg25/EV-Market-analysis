# Check the imported data to make sure the CSV was loaded correctly
-- I'm starting with a small sample before doing any analysis
SELECT *
FROM ev_market_analysis.ev_data_raw
LIMIT 27;


# Explore the different indicators available in the dataset
-- This helps me understand what I can analyse before choosing my main research questions
SELECT DISTINCT parameter
FROM ev_market_analysis.ev_data_raw
ORDER BY parameter;


#Check the year range covered by the dataset
-- This helps me understand the time period available for the market analysis
SELECT
    MIN(year) AS first_year,
    MAX(year) AS last_year,
    COUNT(DISTINCT year) AS number_of_years
FROM ev_market_analysis.ev_data_raw;


#List all available years in the dataset
-- I want to identify any missing years before analysing market trends
SELECT DISTINCT year
FROM ev_market_analysis.ev_data_raw
ORDER BY year;

#Count the different countries and regions in the dataset
-- This helps me understand the geographical coverage of the EV market analysis
SELECT
    COUNT(DISTINCT region_country) AS number_of_regions
FROM ev_market_analysis.ev_data_raw;

#Explore the different categories in the dataset
-- This helps me understand which types of vehicles are included
SELECT DISTINCT category
FROM ev_market_analysis.ev_data_raw
ORDER BY category;

#Explore the different powertrain types in the dataset
-- This helps me identify which vehicle technologies I can compare
SELECT DISTINCT powertrain
FROM ev_market_analysis.ev_data_raw
ORDER BY powertrain;

#Check which units are used to measure the data
-- This helps me interpret the values correctly before comparing them
SELECT DISTINCT unit
FROM ev_market_analysis.ev_data_raw
ORDER BY unit;

#Check which units are used for each indicator
-- This helps me understand how the different indicators are measured
SELECT DISTINCT
    parameter,
    unit
FROM ev_market_analysis.ev_data_raw
ORDER BY parameter, unit;

#Check for missing values in the main columns
-- This helps me identify data quality issues before the analysis
SELECT
    SUM(region_country IS NULL) AS missing_regions,
    SUM(parameter IS NULL) AS missing_parameters,
    SUM(year IS NULL) AS missing_years,
    SUM(value IS NULL) AS missing_values
FROM ev_market_analysis.ev_data_raw;

#Explore the different transport modes in the dataset
-- This helps me understand which transport modes are included in the analysis
SELECT DISTINCT mode
FROM ev_market_analysis.ev_data_raw
ORDER BY mode;

-- ----------------
#Check historical EV sales by year
-- This helps me see how electric vehicle sales have changed over time
SELECT year, SUM(value) AS total_ev_sales
FROM ev_market_analysis.ev_data_raw
WHERE parameter = 'EV sales'
    AND category = 'historical'
GROUP BY year
ORDER BY year;

#Check for duplicate records
-- This helps me identify identical rows that could affect the analysis
SELECT
    COUNT(*) - COUNT(DISTINCT CONCAT_WS('|',
        region_country, category, parameter, mode, powertrain, year, unit, value, `Aggregate group`
    )) AS duplicate_rows
FROM ev_market_analysis.ev_data_raw;



#Record the original row count
-- This gives me a baseline to compare the dataset before and after cleaning
SELECT COUNT(*) AS original_rows
FROM ev_market_analysis.ev_data_raw; -- 49375


-- --------------
#Create a working copy of the raw data
-- This lets me clean and analyse the data without changing the original table
CREATE TABLE ev_market_analysis.ev_data_work AS
SELECT *
FROM ev_market_analysis.ev_data_raw;


#Compare row counts before cleaning
-- This helps me confirm that the working copy matches the original dataset
SELECT 'raw' AS table_name, COUNT(*) AS total_rows
FROM ev_market_analysis.ev_data_raw
UNION ALL
SELECT 'work' AS table_name, COUNT(*) AS total_rows
FROM ev_market_analysis.ev_data_work;   -- the same number of rows


#Count unique records in the working copy
-- This helps me estimate how many rows would remain after removing exact duplicates
SELECT COUNT(*) AS unique_rows
FROM (
    SELECT DISTINCT *
    FROM ev_market_analysis.ev_data_work
) AS unique_records;  -- 49360


#Create a clean table without exact duplicates
-- This keeps one copy of each unique record while preserving the original data
CREATE TABLE ev_market_analysis.ev_data_clean AS
SELECT DISTINCT *
FROM ev_market_analysis.ev_data_work;

#Verify the cleaned dataset
-- This helps me confirm that the clean table contains the expected number of rows
SELECT COUNT(*) AS clean_rows
FROM ev_market_analysis.ev_data_clean; -- 49360 as expected

#Check for remaining exact duplicates
-- This confirms that the clean table contains no fully duplicated records
SELECT COUNT(*) AS duplicate_groups
FROM (
    SELECT region_country, category, parameter, mode, powertrain, year, unit, value, `Aggregate group`
    FROM ev_market_analysis.ev_data_clean
    GROUP BY region_country, category, parameter, mode, powertrain, year, unit, value, `Aggregate group`
    HAVING COUNT(*) > 1
) AS duplicates;  -- 0 duplicates