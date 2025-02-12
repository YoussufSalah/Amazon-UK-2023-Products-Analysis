-- Most popular products: (/results/3_customer_behavior/most_popular_products.csv)
SELECT RANK() OVER(
        ORDER BY "Reviews" DESC,
            "Stars" DESC
    ) AS "Rank",
    "ASIN",
    "Title",
    "Reviews",
    "Stars"
FROM products_dim
LIMIT 50;
-- Customer preferences across categories: (/results/3_customer_behavior/customer_preferences_by_category.csv)
SELECT "Category Name",
    ROUND(AVG("Stars"), 2) AS "Average Rating",
    SUM("Reviews") AS "Total Reviews",
    ROUND(
        SUM("Reviews") * 100.0 / SUM(SUM("Reviews")) OVER(),
        2
    ) AS "Percentage of Total Reviews"
FROM products_dim
GROUP BY "Category Name"
ORDER BY "Total Reviews" DESC;
-- Segment products by target audience: (/results/3_customer_behavior/segment_products_by_audience.csv)
WITH categorized_products AS (
    SELECT "Category Name",
        CASE
            WHEN "Price" BETWEEN 0 AND 80
            OR "Price" = '0.0' THEN 'Low Price'
            WHEN "Price" BETWEEN 81 AND 200 THEN 'Mid Price'
            WHEN "Price" > 200 THEN 'High Price'
        END AS "Price Range",
        CASE
            WHEN "Reviews" < 500 THEN 'Low Engagement'
            WHEN "Reviews" BETWEEN 500 AND 2000 THEN 'Moderate Engagement'
            WHEN "Reviews" > 2000 THEN 'High Engagement'
        END AS "Engagement Level"
    FROM products_dim
)
SELECT "Category Name",
    "Price Range",
    "Engagement Level",
    COUNT(*) AS "Product Count"
FROM categorized_products
GROUP BY "Category Name",
    "Price Range",
    "Engagement Level"
ORDER BY "Category Name",
    CASE
        WHEN "Price Range" = 'Low Price' THEN 1
        WHEN "Price Range" = 'Mid Price' THEN 2
        WHEN "Price Range" = 'High Price' THEN 3
    END,
    CASE
        WHEN "Engagement Level" = 'Low Engagement' THEN 1
        WHEN "Engagement Level" = 'Moderate Engagement' THEN 2
        WHEN "Engagement Level" = 'High Engagement' THEN 3
    END;