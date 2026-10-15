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