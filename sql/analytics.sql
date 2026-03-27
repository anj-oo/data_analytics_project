USE DataWarehouseAnalytics;

SELECT
    *
FROM
    INFORMATION_SCHEMA.COLUMNS;

-- Analyse Sales Performance Over Time
SELECT
    DATEPART(year, order_date) AS order_date,
    DATEPART(month, order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customer,
    SUM(quantity) AS total_quantity
FROM
    gold.fact_sales
WHERE
    order_date IS NOT NULL
GROUP BY
    DATEPART(year, order_date),
    DATEPART(month, order_date)
ORDER BY
    DATEPART(year, order_date),
    DATEPART(month, order_date);

-- --------------------------Cumulative analysis--------------------------------------
-- Total Sales per month and running toal of sales over time
SELECT
    order_date,
    total_sales,
    SUM(total_sales) OVER(
        ORDER BY
            order_date
    ) AS running_total,
    AVG(average_price) OVER(
        ORDER BY
            order_date
    ) AS moving_total
FROM
    (
        SELECT
            DATETRUNC(year, order_date) AS order_date,
            SUM(sales_amount) AS total_sales,
            AVG(price) AS average_price
        FROM
            gold.fact_sales
        WHERE
            order_date IS NOT NULL
        GROUP BY
            DATETRUNC(year, order_date)
    ) t;

-- --------------------------Performance analysis--------------------------------------
-- Analyse the yearly performance of products by comparing their sales to both average sales performance of the productd previous year's sales
WITH yearly_product_sales AS (
    SELECT
        Year(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM
        gold.fact_sales f
        LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
    WHERE
        order_date IS NOT NULL
    GROUP BY
        Year(f.order_date),
        p.product_name
)
SELECT
    order_year,
    product_name,
    current_sales,
    AVG(current_sales) OVER(PARTITION BY product_name) average_sales,
    current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS diff_avergae,
    CASE
        WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END avg_chnage,
    LAG(current_sales) OVER(
        PARTITION BY product_name
        ORDER BY
            order_year
    ) AS py_sales,
    current_sales - LAG(current_sales) OVER(
        PARTITION BY product_name
        ORDER BY
            order_year
    ) AS diff_year_sales,
    CASE
        WHEN current_sales - LAG(current_sales) OVER(
            PARTITION BY product_name
            ORDER BY
                order_year
        ) > 0 THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER(
            PARTITION BY product_name
            ORDER BY
                order_year
        ) < 0 THEN 'Decrease'
        ELSE 'No chnage'
    END diff_year_change
FROM
    yearly_product_sales
ORDER BY
    product_name,
    order_year;

-- --------------------------Part to whole analysis--------------------------------------
-- Categories that contribute most to sales 
WITH category_sales AS (
    SELECT
        category,
        SUM(sales_amount) AS total_sales
    FROM
        gold.fact_sales f
        LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
    GROUP BY
        category
)
SELECT
    category,
    total_sales,
    SUM(total_sales) OVER() overall_sales,
    (
        CONCAT(
            ROUND(
                CAST(total_sales AS FLOAT) / SUM(total_sales) OVER() * 100,
                2
            ),
            '%'
        )
    ) percentage_total
FROM
    category_sales
ORDER BY
    total_sales DESC;

-- -------------------------- Data Segmentation --------------------------------------
-- Segment products into cost range and count how many products falls into each segment
WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE
            WHEN cost < 100 THEN 'BELOW 100'
            WHEN cost BETWEEN 100
            AND 500 THEN '100-500'
            WHEN cost BETWEEN 500
            AND 1000 THEN '500-1000'
            ELSE 'ABOVE 1000'
        END cost_range
    FROM
        gold.dim_products
)
SELECT
    cost_range,
    COUNT(product_key) AS total_product
FROM
    product_segments
GROUP BY
    cost_range
ORDER BY
    total_product DESC;

-- Group customers into three segments based on their spending behaviour
-- VIP: Atleast 12 months of history and spend more that 5000
-- Regular : Atleast 12 months of history and spend less than 5000
-- New: Lifespan less than 12 month 
-- Total customers by each group 
WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spend,
        MIN(f.order_date) AS first_order,
        MAX(f.order_date) AS last_order,
        DATEDIFF(month, MIN(f.order_date), MAX(f.order_date)) AS lifespan
    FROM
        gold.fact_sales f
        LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
    GROUP BY
        c.customer_key
)
SELECT
    customer_grp,
    COUNT(customer_key) AS total_customers
FROM
    (
        SELECT
            customer_key,
            CASE
                WHEN lifespan > 12
                and total_spend > 5000 THEN 'VIP'
                WHEN lifespan > 12
                and total_spend < 5000 THEN 'Regular'
                ELSE 'New '
            END customer_grp
        FROM
            customer_spending
    ) t
GROUP BY
    customer_grp
ORDER BY
    total_customers DESC