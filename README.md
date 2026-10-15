# EV Market Analysis

**A data analytics project using SQL, Python and Tableau**

## Project Overview

This project analyses electric vehicle market data from the International Energy Agency's Global EV Outlook 2026 dataset. The goal is to understand global EV sales trends, compare country markets, investigate vehicle prices and prepare the results for interactive visualisation.

## Tools & Methods

MySQL Workbench was used for data cleaning, validation and exploratory analysis. Python, pandas and Matplotlib were used to calculate growth metrics, analyse country-level sales and create charts. Tableau Public was used to build an interactive dashboard.

## SQL Analysis: Process and Key Findings

### Data Cleaning and Quality Checks

I began by exploring the dataset's structure, record count, available years, indicators, vehicle categories, powertrain types and geographic coverage.
I checked for missing values and exact duplicate rows. The original dataset contained 49,375 records, including 15 exact duplicates. I used `SELECT DISTINCT` to create a separate clean table containing 49,360 unique records, preserving the raw table for reference.
I also investigated blank geographic labels and missing measurement units. Rather than automatically deleting these records, I examined which indicators they belonged to and whether the missing fields affected their interpretation.

### Investigating EV Powertrain Categories

One issue emerged when the total recorded under `EV` did not match the combined total of `BEV`, `PHEV` and `FCEV`. I compared these categories for passenger cars in Advanced Economies and found that their values could not be treated as directly interchangeable.
My conclusion was to investigate the source definitions before combining powertrain categories or calculating market totals.

### Analysing Global Sales Trends

I filtered the dataset to historical passenger-car EV sales and used the `World` geographic aggregate to avoid double-counting countries and regions. I then used SQL aggregation and the `LAG()` window function to compare sales with the previous year.
The selected series increased from 7,400 vehicles in 2010 to 21 million in 2025. Sales grew by 23.53% in 2025, while the year-over-year growth rate varied substantially over the period.
This analysis showed why both absolute sales changes and percentage growth rates are needed to understand market development.

### Comparing Countries and Vehicle Prices

For the 2025 market comparison, I excluded known regional and global aggregates before ranking country-level EV sales. China recorded 13 million sales in the selected `EV` series, compared with 1.5 million in the USA.
I also investigated vehicle price records, examined the dimensions distinguishing multiple observations, checked data coverage and compared BEV and ICEV prices across 10 countries with observations for both powertrains in 2025.
The recorded BEV average price was higher in nine of the ten countries. In the UK, the recorded values were $61,000 for BEVs and $47,000 for ICEVs. These are descriptive country-level comparisons and do not establish the causes of price differences.

## Python Analysis

After cleaning the data in MySQL, I loaded the exported CSV into Python using pandas. I inspected the dataset's structure, data types, missing values and time coverage.
I used `diff()` to calculate absolute annual sales changes and `pct_change()` to calculate year-over-year growth. Matplotlib was used to visualise global sales trends, annual growth and the top ten country markets. The analytical outputs were exported to CSV for reuse in Tableau.

## Tableau Dashboard

The interactive dashboard presents global EV sales trends from 2010 to 2025, annual growth and the top ten EV markets in 2025. It includes filters to explore the data.

**[View the Global EV Market Analysis Dashboard](https://public.tableau.com/app/profile/yelena.ginosyan/viz/GlobalEVMarketAnalysis20102025/GlobalElectricVehicleMarketAnalysis20102025?publish=yes)))**

## Conclusion

This project demonstrates a structured workflow from raw data inspection and SQL-based cleaning to Python analysis and interactive visualisation. A key part of the work was identifying limitations in the source data, including overlapping geographic aggregates, inconsistent powertrain totals and incomplete price metadata.

The project reinforced the importance of validating definitions and choosing appropriate filters before interpreting market trends or comparing countries.

