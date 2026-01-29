# Customer & Product Analytics using SQL

## Overview
This project demonstrates SQL-based analytics to transform transactional data into reporting-ready insights.
It includes time-series analysis, customer-level reporting, product-level reporting, and performance analysis
using aggregations, segmentation logic, and window functions.

## Learning Note
This project was developed as part of a guided learning exercise based on online SQL tutorials,
with additional restructuring, documentation, and file organization for portfolio presentation.

## Data Model
The project uses a simple star-schema style structure:
- fact_sales (transactions)
- dim_customers (customer attributes)
- dim_products (product attributes)

## What’s Included

### 1) Time Series Analysis
File: `sql/time_series_analysis.sql`
- Yearly and monthly sales trends
- Running total (cumulative) sales
- Moving average analysis

### 2) Customer Analytics Report
File: `sql/customer_analytics.sql`
- Customer-level rollups (orders, sales, quantity, products)
- Customer segmentation logic
- KPIs: recency, lifespan, average order value, average monthly spend

### 3) Product Analytics Report
File: `sql/product_analytics.sql`
- Product-level rollups (orders, sales, quantity, customers)
- Product performance segmentation
- KPIs: recency, lifespan, average order revenue, average monthly revenue

### 4) Performance Analysis
File: `sql/performance_analysis.sql`
- Product performance vs average
- Year-over-year (YoY) comparison using LAG
- Part-to-whole contribution by category
- Segmentation summaries (cost ranges, customer segments)

## SQL Concepts Demonstrated
- JOINs (fact and dimension tables)
- CTEs (WITH statements)
- Aggregations (SUM, COUNT, AVG)
- CASE statements for segmentation
- Date functions (lifespan, recency)
- Window functions (SUM OVER, AVG OVER, LAG)

## Tools
- SQL (analytics-style queries)
- Structured for BI reporting and dashboard use cases

## How to Use
1. Load or connect tables: `fact_sales`, `dim_customers`, `dim_products`
2. Run scripts from the `sql/` folder in this order:
   - `time_series_analysis.sql`
   - `customer_analytics.sql`
   - `product_analytics.sql`
   - `performance_analysis.sql`

## Acknowledgment
Inspired by SQL learning content from online tutorials by Baraa.
