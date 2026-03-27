📊 Advanced SQL Data Analysis Project
-----------------------------------------------
📌 Overview

This project demonstrates advanced SQL techniques to analyse sales, customer behaviour, and product performance using a data warehouse schema.

The analysis is performed on a structured dataset containing:

Fact table: fact_sales
Dimension tables: dim_customers, dim_products

The goal is to extract meaningful business insights using:

Aggregations
Window functions
Common Table Expressions (CTEs)
Data segmentation
KPI calculations

🗂️ Database Structure
-----------------------------------------------
🔹 Fact Table
gold.fact_sales
Contains transactional sales data
Key fields: order_date, sales_amount, quantity, customer_key, product_key
🔹 Dimension Tables
gold.dim_customers
Customer details (name, birthdate, etc.)
gold.dim_products
Product details (name, category, cost)

📈 Key Analyses Performed
-----------------------------------------------
1. 📅 Sales Performance Over Time
   Monthly and yearly sales trends
   Metrics calculated:
   Total sales
   Total customers
   Total quantity sold
   Helps identify seasonality and growth trends.

2. 🔄 Cumulative Analysis
   Running total of sales over time
   Moving average of product prices

   Techniques Used:
   SUM() OVER()
   AVG() OVER()
   Window functions with ordering
   Useful for tracking growth momentum.

3. 📊 Product Performance Analysis
   Yearly sales comparison per product
   Compared against:
   Product’s average sales
   Previous year's sales

   Identifies top and underperforming products.

4. 🧩 Part-to-Whole Analysis
   Contribution of each product category to total sales
   Category-wise sales
   Percentage contribution

    Helps prioritise high-performing categories.

5. 🏷️ Product Segmentation
   Products grouped based on cost ranges
   Useful for pricing strategy and product distribution insights.

6. 👥 Customer Segmentation
   Customers are classified into:
   Helps in targeted marketing and retention strategies.

🧾 Customer Report View
-----------------------------------------------
📌 View Created:
gold.report_customers
🔍 Features:
Consolidated customer-level analytics
Includes:
Personal details (name, age, age group)
Purchase behaviour
Customer segmentation

📊 KPIs Calculated:
-----------------------------------------------
Total Orders
Total Sales
Total Quantity Purchased
Total Products Purchased
Customer Lifespan (months)
Recency (months since last order)
Average Order Value (AOV)
Average Monthly Spend
This view can be directly used for dashboards or BI tools.

🛠️ SQL Concepts Used
-----------------------------------------------
✅ Common Table Expressions (CTEs)
✅ Window Functions (OVER, LAG)
✅ Aggregate Functions (SUM, AVG, COUNT)
✅ Date Functions (DATEPART, DATEDIFF, DATETRUNC)
✅ Conditional Logic (CASE)
✅ Data Segmentation Techniques
✅ View Creation

🚀 How to Use
Clone the repository
Connect to your SQL Server
Run the script in order:
Schema selection
Analysis queries
View creation
Query the final view:
SELECT \* FROM gold.report_customers;

🎯 Business Value
-----------------------------------------------
This project helps:
Understand sales trends
Identify top-performing products
Segment high-value customers
Improve decision-making using data
