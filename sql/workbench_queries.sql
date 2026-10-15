
CREATE DATABASE ev_market_analysis;
USE ev_market_analysis;

SELECT COUNT(*) AS total_rows
FROM ev_market_analysis.ev_data_raw;


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

#Identify duplicate records
-- This helps me inspect repeated rows before deciding whether any cleaning is needed
SELECT region_country, category, parameter, mode, powertrain, year, unit, value, `Aggregate group`,
    COUNT(*) AS occurrences
FROM ev_market_analysis.ev_data_raw
GROUP BY region_country, category, parameter, mode, powertrain, year, unit, value, `Aggregate group`
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

#Count duplicate records by category
-- This helps me understand whether duplicates are concentrated in specific data categories
SELECT category, COUNT(*) AS duplicate_groups, SUM(occurrences - 1) AS extra_rows
FROM (SELECT category, COUNT(*) AS occurrences 
FROM ev_market_analysis.ev_data_raw 
GROUP BY region_country, category, parameter, mode, powertrain, year, unit, value, `Aggregate group` 
HAVING COUNT(*) > 1) AS duplicates
GROUP BY category
ORDER BY extra_rows DESC;

#Check which regions contain duplicate records
-- This helps me understand whether the duplicates come from a specific region
SELECT region_country, COUNT(*) AS duplicate_groups
FROM (SELECT region_country, category, parameter, mode, powertrain, year, unit, value, `Aggregate group`, COUNT(*) AS occurrences 
FROM ev_market_analysis.ev_data_raw 
GROUP BY region_country, category, parameter, mode, powertrain, year, unit, value, `Aggregate group` 
HAVING COUNT(*) > 1) AS duplicates
GROUP BY region_country
ORDER BY duplicate_groups DESC;

#Inspect duplicate records from the United Arab Emirates
-- This helps me check whether the repeated records have identical values
SELECT region_country, category, parameter, mode, powertrain, year, unit, value, `Aggregate group`
FROM ev_market_analysis.ev_data_raw
WHERE region_country = 'United Arab Emirates'
    AND category = 'Historical'
    AND parameter IN ('Electric LDVs per charging point', 'Average capacity per EV', 'Average capacity per EVSE')
ORDER BY parameter, year;

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


-- ----------------------
#Explore historical EV sales data
-- This helps me identify the sales categories and units before calculating totals
SELECT DISTINCT parameter, mode, powertrain, unit
FROM ev_market_analysis.ev_data_clean
WHERE parameter = 'EV sales'
    AND category = 'historical'
ORDER BY mode, powertrain, unit; -- 5 car modes and 4 distinct powertrain


#Inspect EV sales by powertrain
-- This helps me compare sales categories before calculating market totals
SELECT powertrain, SUM(value) AS total_sales
FROM ev_market_analysis.ev_data_clean
WHERE parameter = 'EV sales'
    AND category = 'historical'
    AND mode = 'Cars'
GROUP BY powertrain
ORDER BY total_sales DESC;   -- the totals do not match


#Compare EV and individual powertrain records
-- This helps me check whether EV is a separate total or overlaps with other categories
SELECT region_country, year, powertrain, value
FROM ev_market_analysis.ev_data_clean
WHERE parameter = 'EV sales'
    AND category = 'historical'
    AND mode = 'Cars'
    AND powertrain IN ('EV', 'BEV', 'PHEV', 'FCEV')
ORDER BY region_country, year, powertrain
LIMIT 20;      -- EV values do not consistently equal the sum of BEV, PHEV, and FCEV


#Inspect EV sales records by region and year
-- This helps me check whether EV values overlap with individual powertrain categories
SELECT region_country, year, value
FROM ev_market_analysis.ev_data_clean
WHERE parameter = 'EV sales'
    AND category = 'historical'
    AND mode = 'Cars'
    AND powertrain = 'EV'
ORDER BY region_country, year
LIMIT 20;       -- EV sales in this regional aggregate increased substantially over the period


#Analyse historical EV sales by year
-- This shows annual EV sales across all reported regions
SELECT year, SUM(value) AS total_ev_sales
FROM ev_market_analysis.ev_data_clean
WHERE parameter = 'EV sales'
    AND category = 'historical'
    AND mode = 'Cars'
    AND powertrain = 'EV'
GROUP BY year
ORDER BY year;

#Inspect the largest regional EV sales values
-- This helps me identify regional aggregates before calculating a global total
SELECT region_country, value
FROM ev_market_analysis.ev_data_clean
WHERE parameter = 'EV sales'
    AND category = 'historical'
    AND mode = 'Cars'
    AND powertrain = 'EV'
    AND year = 2025
ORDER BY value DESC
LIMIT 20;  -- overlapping geographic aggregates


#Analyse global EV sales by year
-- This uses World records only to avoid double-counting regions and countries
SELECT year, value AS global_ev_sales
FROM ev_market_analysis.ev_data_clean
WHERE parameter = 'EV sales'
    AND category = 'historical'
    AND mode = 'Cars'
    AND powertrain = 'EV'
    AND region_country = 'World'  -- using World records only to avoid double-counting
ORDER BY year;  


#Calculate annual global EV sales growth
-- This compares each year's sales with the previous year
SELECT year, value AS global_ev_sales,
    LAG(value) OVER (ORDER BY year) AS previous_year_sales,
    ROUND(
        (value - LAG(value) OVER (ORDER BY year))
        / LAG(value) OVER (ORDER BY year) * 100,
        2
    ) AS growth_percentage
FROM ev_market_analysis.ev_data_clean
WHERE parameter = 'EV sales'
    AND category = 'historical'
    AND mode = 'Cars'
    AND powertrain = 'EV'
    AND region_country = 'World'
ORDER BY year;


#Calculate annual changes in global EV sales
-- This shows how many additional vehicles were sold each year
SELECT year, value AS global_ev_sales,
    LAG(value) OVER (ORDER BY year) AS previous_year_sales,
    value - LAG(value) OVER (ORDER BY year) AS sales_increase
FROM ev_market_analysis.ev_data_clean
WHERE parameter = 'EV sales'
    AND category = 'historical'
    AND mode = 'Cars'
    AND powertrain = 'EV'
    AND region_country = 'World'
ORDER BY year;


#Inspect geographic groups in the dataset
-- This helps me identify the geographic levels available for market comparisons
SELECT DISTINCT region_country
FROM ev_market_analysis.ev_data_clean
ORDER BY region_country;  -- a missing value identified


#Check for missing geographic values
-- This checks whether region_country contains blank strings or NULL values
SELECT
    SUM(region_country IS NULL) AS null_regions,
    SUM(TRIM(region_country) = '') AS blank_regions
FROM ev_market_analysis.ev_data_clean;


#Inspect records with blank geographic values
-- This helps me understand which indicators are affected by missing region names
SELECT parameter, category, year, COUNT(*) AS record_count
FROM ev_market_analysis.ev_data_clean
WHERE TRIM(region_country) = ''
GROUP BY parameter, category, year
ORDER BY record_count DESC
LIMIT 20;

#Inspect units for price indicators with blank regions
-- This helps me interpret vehicle price statistics correctly
SELECT DISTINCT parameter, unit
FROM ev_market_analysis.ev_data_clean
WHERE TRIM(region_country) = ''
ORDER BY parameter, unit;


#Inspect vehicle price statistics
-- This helps me check whether the price values look plausible
SELECT parameter, year, value
FROM ev_market_analysis.ev_data_clean
WHERE TRIM(region_country) = ''
    AND parameter LIKE 'price_%'
ORDER BY year, parameter
LIMIT 20;


#Inspect all dimensions of vehicle price records
-- This helps me identify what distinguishes price records with blank regions
SELECT region_country, category, parameter, mode, powertrain, year, unit, value, `Aggregate group`
FROM ev_market_analysis.ev_data_clean
WHERE TRIM(region_country) = ''
    AND parameter = 'price_mean_2025USD'
    AND year = 2010
LIMIT 20;


#Explore vehicle segments in price data
-- This helps me identify the vehicle categories available for price comparisons
SELECT DISTINCT mode, powertrain
FROM ev_market_analysis.ev_data_clean
WHERE parameter = 'price_mean_2025USD'
ORDER BY mode, powertrain;


#Check available years in vehicle price data
-- This helps me identify the time period available for price trend analysis
SELECT MIN(year) AS first_year, MAX(year) AS last_year,
    COUNT(DISTINCT year) AS number_of_years
FROM ev_market_analysis.ev_data_clean
WHERE parameter = 'price_mean_2025USD';


#Find available years in vehicle price data
-- This identifies missing years before analysing price trends
SELECT DISTINCT year
FROM ev_market_analysis.ev_data_clean
WHERE parameter = 'price_mean_2025USD'
ORDER BY year;  -- 2020 is missing

#Compare BEV and ICEV price data
-- This checks whether comparable electric and combustion vehicle prices are available by year and segment
SELECT year, mode, powertrain, value
FROM ev_market_analysis.ev_data_clean
WHERE parameter = 'price_mean_2025USD'
    AND powertrain IN ('BEV', 'ICEV')
ORDER BY year, mode, powertrain;

#Inspect dimensions of vehicle price records
-- This identifies which columns distinguish multiple price values for the same year and powertrain
SELECT *
FROM ev_market_analysis.ev_data_clean
WHERE parameter = 'price_mean_2025USD'
    AND year = 2010
    AND mode = 'All cars'
    AND powertrain = 'BEV'
LIMIT 10;


#Compare country-level BEV and ICEV prices
-- This summarizes price observations by year and powertrain
SELECT year, powertrain,
    COUNT(*) AS record_count,
    COUNT(DISTINCT region_country) AS country_count,
    ROUND(AVG(value), 2) AS average_value
FROM ev_market_analysis.ev_data_clean
WHERE parameter = 'price_mean_2025USD'
    AND mode = 'All cars'
    AND powertrain IN ('BEV', 'ICEV')
GROUP BY year, powertrain
ORDER BY year, powertrain;


#Check comparable countries in 2025
-- This finds countries with price observations for both BEV and ICEV
SELECT region_country,
    COUNT(DISTINCT powertrain) AS powertrain_count
FROM ev_market_analysis.ev_data_clean
WHERE parameter = 'price_mean_2025USD'
    AND mode = 'All cars'
    AND year = 2025
    AND powertrain IN ('BEV', 'ICEV')
GROUP BY region_country
HAVING COUNT(DISTINCT powertrain) = 2
ORDER BY region_country;

#Compare BEV and ICEV prices by country in 2025
-- This places both powertrain price values side by side for each country
SELECT region_country,
    MAX(CASE WHEN powertrain = 'BEV' THEN value END) AS bev_price,
    MAX(CASE WHEN powertrain = 'ICEV' THEN value END) AS icev_price,
    ROUND(
        (MAX(CASE WHEN powertrain = 'BEV' THEN value END) /
        NULLIF(MAX(CASE WHEN powertrain = 'ICEV' THEN value END), 0) - 1) * 100,
        2
    ) AS bev_price_premium_pct
FROM ev_market_analysis.ev_data_clean
WHERE parameter = 'price_mean_2025USD'
    AND mode = 'All cars'
    AND year = 2025
    AND powertrain IN ('BEV', 'ICEV')
GROUP BY region_country
HAVING COUNT(DISTINCT powertrain) = 2
ORDER BY bev_price_premium_pct DESC;


#Check price record uniqueness by country
-- This verifies that each country has one price value per powertrain in 2025
SELECT region_country, powertrain,
    COUNT(*) AS record_count
FROM ev_market_analysis.ev_data_clean
WHERE parameter = 'price_mean_2025USD'
    AND mode = 'All cars'
    AND year = 2025
    AND powertrain IN ('BEV', 'ICEV')
GROUP BY region_country, powertrain
HAVING COUNT(*) > 1
ORDER BY region_country, powertrain;


#Check missing values in key price fields
-- This checks whether country, year, powertrain, or price values are missing
SELECT
    SUM(CASE WHEN region_country IS NULL OR TRIM(region_country) = '' THEN 1 ELSE 0 END) AS missing_country,
    SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS missing_year,
    SUM(CASE WHEN powertrain IS NULL OR TRIM(powertrain) = '' THEN 1 ELSE 0 END) AS missing_powertrain,
    SUM(CASE WHEN value IS NULL THEN 1 ELSE 0 END) AS missing_price
FROM ev_market_analysis.ev_data_clean
WHERE parameter = 'price_mean_2025USD'
    AND mode = 'All cars'
    AND powertrain IN ('BEV', 'ICEV');


#Compare BEV and PHEV sales by country in 2025
-- This retrieves country-level electric car sales for the latest historical year
SELECT region_country, powertrain, value
FROM ev_market_analysis.ev_data_clean
WHERE parameter = 'EV sales'
    AND category = 'Historical'
    AND mode = 'Cars'
    AND year = 2025
    AND powertrain IN ('BEV', 'PHEV')
ORDER BY region_country, powertrain;


#Rank countries by BEV sales in 2025
-- This identifies the leading individual country markets without summing overlapping regions
SELECT region_country, value AS bev_sales
FROM ev_market_analysis.ev_data_clean
WHERE parameter = 'EV sales'
    AND category = 'Historical'
    AND mode = 'Cars'
    AND year = 2025
    AND powertrain = 'BEV'
    AND region_country NOT IN (
        'World', 'Asia Pacific', 'Europe', 'European Union',
        'Africa', 'Latin America', 'Southeast Asia',
        'Advanced Economies', 'Developing Economies excl. China',
        'Middle East and Caspian'
    )
ORDER BY value DESC
LIMIT 10;


#Calculate BEV share of BEV and PHEV sales in 2025
-- This compares BEV and PHEV sales mix across the selected countries
SELECT region_country,
    SUM(CASE WHEN powertrain = 'BEV' THEN value ELSE 0 END) AS bev_sales,
    SUM(CASE WHEN powertrain = 'PHEV' THEN value ELSE 0 END) AS phev_sales,
    ROUND(
        SUM(CASE WHEN powertrain = 'BEV' THEN value ELSE 0 END) /
        NULLIF(SUM(value), 0) * 100,
        2
    ) AS bev_share_pct
FROM ev_market_analysis.ev_data_clean
WHERE parameter = 'EV sales'
    AND category = 'Historical'
    AND mode = 'Cars'
    AND year = 2025
    AND powertrain IN ('BEV', 'PHEV')
    AND region_country IN (
        'China', 'USA', 'Germany', 'United Kingdom', 'France',
        'Korea', 'Turkiye', 'Viet Nam', 'Norway', 'India'
    )
GROUP BY region_country
ORDER BY bev_share_pct DESC;


#Rank countries by PHEV share in 2025
-- This identifies markets where PHEVs represent a larger share of combined BEV and PHEV sales
SELECT region_country,
    SUM(CASE WHEN powertrain = 'BEV' THEN value ELSE 0 END) AS bev_sales,
    SUM(CASE WHEN powertrain = 'PHEV' THEN value ELSE 0 END) AS phev_sales,
    ROUND(
        SUM(CASE WHEN powertrain = 'PHEV' THEN value ELSE 0 END) /
        NULLIF(SUM(value), 0) * 100,
        2
    ) AS phev_share_pct
FROM ev_market_analysis.ev_data_clean
WHERE parameter = 'EV sales'
    AND category = 'Historical'
    AND mode = 'Cars'
    AND year = 2025
    AND powertrain IN ('BEV', 'PHEV')
    AND region_country NOT IN (
        'World', 'Asia Pacific', 'Europe', 'European Union',
        'Africa', 'Latin America', 'Southeast Asia',
        'Advanced Economies', 'Developing Economies excl. China',
        'Middle East and Caspian'
    )
    AND region_country IS NOT NULL
    AND TRIM(region_country) <> ''
GROUP BY region_country
HAVING SUM(value) > 0
ORDER BY phev_share_pct DESC
LIMIT 10;

#Inspect EV sales projection categories
-- This checks which projection categories and years are available for EV car sales
SELECT category, MIN(year) AS first_year,
    MAX(year) AS last_year,
    COUNT(DISTINCT year) AS number_of_years,
    COUNT(*) AS record_count
FROM ev_market_analysis.ev_data_clean
WHERE parameter = 'EV sales'
    AND mode = 'Cars'
GROUP BY category
ORDER BY category;


#Compare global EV sales projections for 2035
-- This compares World EV car sales under two projection scenarios
SELECT category, year, value, unit
FROM ev_market_analysis.ev_data_clean
WHERE region_country = 'World'
    AND parameter = 'EV sales'
    AND mode = 'Cars'
    AND powertrain = 'EV'
    AND year = 2035
ORDER BY category;

#Check country coverage for 2025 EV sales
-- This counts records and countries with reported EV car sales in 2025
SELECT
    COUNT(*) AS record_count,
    COUNT(DISTINCT region_country) AS distinct_regions_countries,
    SUM(CASE
        WHEN region_country IS NULL OR TRIM(region_country) = ''
        THEN 1 ELSE 0
    END) AS blank_region_records
FROM ev_market_analysis.ev_data_clean
WHERE parameter = 'EV sales'
    AND category = 'Historical'
    AND mode = 'Cars'
    AND year = 2025
    AND powertrain = 'EV';
    
    
#Review EV sales regions for 2025
-- This lists all geographic values to identify countries and regional aggregates
SELECT DISTINCT region_country
FROM ev_market_analysis.ev_data_clean
WHERE parameter = 'EV sales'
    AND category = 'Historical'
    AND mode = 'Cars'
    AND year = 2025
    AND powertrain = 'EV'
ORDER BY region_country;

#Review final analysis table structure
-- This checks the columns and data types in the cleaned dataset
DESCRIBE ev_market_analysis.ev_data_clean;

#Export cleaned dataset
-- This retrieves all rows from the cleaned analysis table
SELECT *
FROM ev_market_analysis.ev_data_clean;
    
SELECT COUNT(*)
FROM ev_market_analysis.ev_data_clean;

SELECT *
FROM ev_market_analysis.ev_data_clean;

SELECT COUNT(*)
FROM ev_market_analysis.ev_data_clean;

SELECT * FROM ev_market_analysis.ev_data_clean;