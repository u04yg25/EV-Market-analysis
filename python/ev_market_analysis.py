
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
global_ev_sales[
    ["year", "value", "sales_change", "sales_growth_pct"]
].to_csv(
    "data/processed/global_ev_sales_analysis.csv",
    index=False
)

print("\nGlobal EV sales analysis exported successfully.")