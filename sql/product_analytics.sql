/* ============================================================
   File: product_analytics.sql
   Purpose:
   Build a product-level analytics report using transactional
   data to calculate KPIs such as recency, lifespan, average
   order revenue, and monthly revenue, and to segment products
   by performance tiers.
   ============================================================ */

/* ------------------------------------------------------------
   1) Base Query: Join fact and product dimension
------------------------------------------------------------ */
WITH base_query AS (
    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM fact_sales f
    LEFT JOIN dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
),

/* ------------------------------------------------------------
   2) Product Aggregation: roll up to product level
------------------------------------------------------------ */
product_aggregation AS (
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT customer_key) AS total_customers,
        MAX(order_date) AS last_sale_date,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan_months,
        ROUND(AVG(CAST(sales_amount AS float) / NULLIF(quantity, 0)), 1) AS avg_selling_price
    FROM base_query
    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost
)

/* ------------------------------------------------------------
   3) Final Report: Segments + KPIs
------------------------------------------------------------ */
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,

    last_sale_date,
    DATEDIFF(month, last_sale_date, GETDATE()) AS recency_months,

    -- Product Segment (Revenue-based)
    CASE
        WHEN total_sales >= 10000 THEN 'High-Performer'
        WHEN total_sales BETWEEN 5000 AND 9999 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,

    lifespan_months,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,

    -- Average Order Revenue (AOR)
    CASE
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,

    -- Average Monthly Revenue
    CASE
        WHEN lifespan_months = 0 THEN total_sales
        ELSE total_sales / lifespan_months
    END AS avg_monthly_revenue

FROM product_aggregation
ORDER BY total_sales DESC;
