
#EV Market Analysis
# Load cleaned data exported from MySQL

import pandas as pd

df = pd.read_csv("data/processed/ev_data_clean.csv")

print("Dataset loaded successfully!")
print("Rows and columns:", df.shape)
print(df.head())

print("Total records:", len(df))

print("\nColumn names:")
print(df.columns.tolist())

# Check the number of missing values in each column
print("\nMissing values per column:")
print(df.isnull().sum())

# Check data types and memory usage for each column
print("\nData types and memory usage:")
df.info()

# Check the year range covered by the dataset
print("\nYear range:")
print("Earliest year:", df["year"].min())
print("Latest year:", df["year"].max())

# Count records for each year
print("\nRecords per year:")
print(df["year"].value_counts().sort_index())

# Check the categories of data available in the dataset
print("\nData categories:")
print(df["category"].value_counts())

# Check the parameters measured in the dataset
print("\nAvailable parameters:")
print(df["parameter"].value_counts().head(15))


# Filter historical global EV car sales
# Exclude projections and keep only the World total
global_ev_sales = df[
    (df["category"] == "Historical") &
    (df["parameter"] == "EV sales") &
    (df["mode"] == "Cars") &
    (df["powertrain"] == "EV") &
    (df["region_country"] == "World")
].copy()

# Keep the historical period from 2010 to 2025
global_ev_sales = global_ev_sales[
    global_ev_sales["year"].between(2010, 2025)
]

# Display the selected records
print("\nGlobal historical EV car sales:")
print(global_ev_sales[["year", "value", "unit"]].sort_values("year").to_string(index=False))

# Check that there is only one record per year
print("\nNumber of selected records:", len(global_ev_sales))

# Sort records chronologically before calculating growth
global_ev_sales = global_ev_sales.sort_values("year").copy()

# Calculate the absolute change in sales compared with the previous year
global_ev_sales["sales_change"] = global_ev_sales["value"].diff()

# Calculate year-over-year sales growth as a percentage
global_ev_sales["sales_growth_pct"] = (
    global_ev_sales["value"].pct_change() * 100
)

# Display sales and growth metrics
print("\nGlobal EV sales growth analysis:")
print(
    global_ev_sales[
        ["year", "value", "sales_change", "sales_growth_pct"]
    ].round(2).to_string(index=False)
)


# Import matplotlib for data visualization
import matplotlib.pyplot as plt

# 1) Create a line chart of global EV sales over time
plt.figure(figsize=(10, 6))
plt.plot(
    global_ev_sales["year"],
    global_ev_sales["value"],
    marker="o"
)

# Add chart title and axis labels
plt.title("Global Electric Vehicle Sales (2010–2025)")
plt.xlabel("Year")
plt.ylabel("EV Sales (Vehicles)")

# Improve readability
plt.grid(True, alpha=0.3)
plt.ticklabel_format(axis="y", style="plain")
plt.tight_layout()

# Save the global EV sales chart for the project portfolio
plt.savefig("analysis/global_ev_sales.png", dpi=300, bbox_inches="tight")

# Display the chart
plt.show()


# 2) Create a bar chart of year-over-year EV sales growth
growth_data = global_ev_sales.dropna(subset=["sales_growth_pct"])

plt.figure(figsize=(10, 6))
plt.bar(
    growth_data["year"],
    growth_data["sales_growth_pct"]
)

# Add chart title and axis labels
plt.title("Year-over-Year Growth in Global EV Sales (2011–2025)")
plt.xlabel("Year")
plt.ylabel("Sales Growth (%)")

# Improve chart readability
plt.axhline(y=0, linewidth=1)
plt.grid(axis="y", alpha=0.3)
plt.tight_layout()

# Save the year-over-year EV sales growth chart for the project portfolio
plt.savefig("analysis/ev_sales_growth.png", dpi=300, bbox_inches="tight")

# Display the chart
plt.show()

# Export global EV sales and growth metrics for further analysis
# Round the growth percentage to two decimal places for readability
global_ev_sales_export = global_ev_sales[
    ["year", "value", "sales_change", "sales_growth_pct"]
].copy()

global_ev_sales_export["sales_growth_pct"] = (
    global_ev_sales_export["sales_growth_pct"].round(2)
)

global_ev_sales_export.to_csv(
    "data/processed/global_ev_sales_analysis.csv",
    index=False
)

print("\nGlobal EV sales analysis exported successfully.")


# Analyse EV sales by country in 2025


# Filter historical EV car sales for 2025
# Exclude regional and economic aggregates from the country comparison
country_ev_sales_2025 = df[
    (df["category"] == "Historical") &
    (df["parameter"] == "EV sales") &
    (df["mode"] == "Cars") &
    (df["powertrain"] == "EV") &
    (df["year"] == 2025) &
    (~df["region_country"].isin([
        "World",
        "Asia Pacific",
        "Advanced Economies",
        "Europe",
        "European Union",
        "Southeast Asia",
        "Latin America",
        "Developing Economies excl. China",
        "Middle East and Caspian",
        "Africa"
    ]))
].copy()


# Sort countries by sales, from highest to lowest
country_ev_sales_2025 = country_ev_sales_2025.sort_values(
    "value", ascending=False
)

# Display the top 10 countries
print("\nTop 10 EV markets in 2025:")
print(
    country_ev_sales_2025[
        ["region_country", "value", "unit"]
    ].head(10).to_string(index=False)
)


# List all geographic names in the 2025 EV sales data
print("\nAll geographic entries for EV car sales in 2025:")
print(
    sorted(country_ev_sales_2025["region_country"].unique())
)


# Export the top 10 country EV markets for Tableau
top_10_ev_markets = country_ev_sales_2025.head(10).copy()

top_10_ev_markets.to_csv(
    "data/processed/top_10_ev_markets_2025.csv",
    index=False
)

print("\nTop 10 EV markets exported successfully.")



# Create a bar chart of the top 10 EV markets in 2025

# Sort markets from lowest to highest for horizontal bars
top_10_ev_markets_chart = top_10_ev_markets.sort_values(
    "value", ascending=True
)

plt.figure(figsize=(10, 6))

plt.barh(
    top_10_ev_markets_chart["region_country"],
    top_10_ev_markets_chart["value"]
)

# Add chart title and axis labels
plt.title("Top 10 EV Markets by Sales (2025)")
plt.xlabel("EV Sales (Vehicles)")
plt.ylabel("Country")

# Improve chart readability
plt.ticklabel_format(axis="x", style="plain")
plt.grid(axis="x", alpha=0.3)
plt.tight_layout()

# Save the chart for the project portfolio
plt.savefig("analysis/top_10_ev_markets_2025.png", dpi=300, bbox_inches="tight")

# Display the chart
plt.show()
