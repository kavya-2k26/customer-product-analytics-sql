/* ============================================================
   File: customer_analytics.sql
   Purpose:
   Build a customer-level analytics report using transactional
   data to calculate KPIs such as recency, lifespan, AOV, and
   monthly spend, and to segment customers into groups.
   ============================================================ */

-- Creating a reusable reporting view
-- CREATE VIEW report_customers AS

/* ------------------------------------------------------------
   1) Base Query: Join fact and customer dimension
------------------------------------------------------------ */
WITH base_query AS (
    SELECT
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        DATEDIFF(year, c.birthdate, GETDATE()) AS age
    FROM fact_sales f
    LEFT JOIN dim_customers c
        ON c.customer_key = f.customer_key
    WHERE f.order_date IS NOT NULL
),

/* ------------------------------------------------------------
   2) Customer Aggregation: roll up to customer level
------------------------------------------------------------ */
customer_aggregation AS (
    SELECT
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order_date,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan_months
    FROM base_query
    GROUP BY
        customer_key,
        customer_number,
        customer_name,
        age
)

/* ------------------------------------------------------------
   3) Final Report: Segments + KPIs
------------------------------------------------------------ */
SELECT
    customer_key,
    customer_number,
    customer_name,
    age,

    -- Age Group
    CASE
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50+'
    END AS age_group,

    -- Customer Segment
    CASE
        WHEN lifespan_months >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan_months >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,

    last_order_date,
    DATEDIFF(month, last_order_date, GETDATE()) AS recency_months,

    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan_months,

    -- Average Order Value (AOV)
    CASE
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_value,

    -- Average Monthly Spend
    CASE
        WHEN lifespan_months = 0 THEN total_sales
        ELSE total_sales / lifespan_months
    END AS avg_monthly_spend

FROM customer_aggregation
ORDER BY total_sales DESC;
