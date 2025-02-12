-- Create an index on "Category Name" in table "products_dim"
CREATE INDEX idx_products_category_name ON products_dim ("Category Name");
-- Create temporary table for price ranges within categories
CREATE TEMP TABLE categories_ranges AS (
    SELECT "Category Name",
        MIN("Price") AS "Minimum",
        MAX("Price") AS "Maximum",
        ROUND(AVG("Price"), 2) AS "Average"
    FROM products_dim
    GROUP BY "Category Name"
);
CREATE INDEX idx_category_name ON categories_ranges ("Category Name");
-- Identify underpriced or overpriced products (/results/5_price_optimization/underpriced_and_overpriced_products.csv)
WITH price_categories AS (
    SELECT p."ASIN",
        p."Title",
        p."Price",
        CASE
            WHEN c."Average" * 0.75 >= p."Price" THEN 'Underpriced'
            WHEN c."Average" * 1.25 <= p."Price" THEN 'Overpriced'
        END AS "Price Category",
        p."Category Name",
        c."Average" AS "Average Category Price",
        ABS(p."Price" - c."Average") AS "Price Difference"
    FROM products_dim AS p
        LEFT JOIN categories_ranges AS c USING ("Category Name")
    WHERE NOT c."Average" BETWEEN p."Price" * 0.75 AND p."Price" * 1.25
        AND p."ASIN" BETWEEN '0000060259' AND 'B0002BBOPC' -- Identifying specific ASIN range
)
SELECT *
FROM price_categories
ORDER BY "Price Difference" DESC;
-- Count overpriced & underpriced products by category (/results/5_price_optimization/count_underpriced_and_overpriced_products.csv)
SELECT p."Category Name",
    SUM(
        CASE
            WHEN p."Price" <= c."Average" * 0.75 THEN 1
            ELSE 0
        END
    ) AS "Underpriced Count",
    SUM(
        CASE
            WHEN p."Price" >= c."Average" * 1.25 THEN 1
            ELSE 0
        END
    ) AS "Overpriced Count"
FROM products_dim AS p
    LEFT JOIN categories_ranges AS c USING("Category Name")
GROUP BY p."Category Name"
ORDER BY "Underpriced Count" DESC,
    "Overpriced Count" DESC;
-- Price Clustring: (/results/5_price_optimization/price_clustring.csv)
SELECT WIDTH_BUCKET("Price", 0, 5000, 10) AS "Price Cluster",
    COUNT(*) AS product_count,
    ROUND(AVG("Reviews"), 2) AS "AVG. Reviews",
    ROUND(AVG("Stars"), 2) AS "AVG. Stars"
FROM products_dim
GROUP BY "Price Cluster"
ORDER BY "Price Cluster";
-- Compute the correlation between price, reviews, and stars to quantify the strength of the relationship.
/*
 *  Price-Review Correlation: -0.0153
 *  Price-Star Correlation: -0.1415
 *  Star-Review Correlation: 0.0849
 */
SELECT ROUND(CORR("Price", "Reviews")::DECIMAL, 4) AS "Price-Review Correlation",
    ROUND(CORR("Price", "Stars")::DECIMAL, 4) AS "Price-Star Correlation",
    ROUND(CORR("Stars", "Reviews")::DECIMAL, 4) AS "Star-Review Correlation"
FROM products_dim;
-- Identify price ranges that maximize reviews
/*
 *  MIN: 0.01
 *  MAX: 2746.09
 *  AVG: 33.17
 */
WITH review_deciles AS (
    SELECT NTILE(10) OVER (
            ORDER BY "Reviews" DESC
        ) AS decile,
        "Price",
        "Reviews"
    FROM products_dim
)
SELECT MIN("Price") AS "MIN. Price",
    MAX("Price") AS "MAX. Price",
    ROUND(AVG("Price"), 2) AS "AVG. Price"
FROM review_deciles
WHERE decile = 1
GROUP BY decile;
-- Identify price ranges that maximize stars
/*
 *  MIN: 0.01
 *  MAX: 3999
 *  AVG: 47.99
 */
WITH star_deciles AS (
    SELECT NTILE(10) OVER (
            ORDER BY "Stars" DESC
        ) AS decile,
        "Price",
        "Stars"
    FROM products_dim
)
SELECT MIN("Price") AS "MIN. Price",
    MAX("Price") AS "MAX. Price",
    ROUND(AVG("Price"), 2) AS "AVG. Price"
FROM star_deciles
WHERE decile = 1
GROUP BY decile;