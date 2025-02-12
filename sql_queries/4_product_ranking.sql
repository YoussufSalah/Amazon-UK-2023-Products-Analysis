-- Unified Scoring Model: (/results/4_product_ranking/unified_best_products.csv)
WITH rankings AS (
    SELECT "ASIN",
        "Title",
        "Category Name",
        "Price",
        "Stars",
        "Reviews",
        RANK() OVER (
            ORDER BY "Stars" ASC,
                "Reviews" ASC
        ) AS "Star Rank Reversed",
        RANK() OVER (
            ORDER BY "Reviews" ASC,
                "Stars" ASC
        ) AS "Review Rank Reversed",
        RANK() OVER (
            ORDER BY "Price" / "Stars" DESC
        ) AS "Price To Value Rank Reversed"
    FROM products_dim
    WHERE "Stars" > 0
        AND "Price" > 0
)
SELECT "ASIN",
    "Title",
    "Category Name",
    "Price",
    "Stars",
    "Reviews",
    ROUND(
        (
            0.0004 * "Star Rank Reversed" + -- Weighted score for stars
            0.0004 * "Review Rank Reversed" + -- Weighted score for reviews
            0.0002 * "Price To Value Rank Reversed" -- Weighted score for price-to-value ratio
        )::DECIMAL,
        2
    ) AS "Final Score"
FROM rankings
WHERE "Price" BETWEEN 5 AND 1000
    AND "Stars" >= 2
    AND "Reviews" > 10
ORDER BY "Final Score" DESC
LIMIT 50;
-- Find best products based on:
--  -- Stars: (/results/4_product_ranking/best_products_by_stars.csv)
SELECT RANK() OVER(
        ORDER BY "Stars" DESC,
            "Reviews" DESC,
            "Price" ASC
    ) AS "Rank",
    *
FROM products_dim
WHERE "Price" BETWEEN 5 AND 1000
    AND "Stars" >= 2
    AND "Reviews" > 10
LIMIT 50;
--  -- Reviews: (/results/4_product_ranking/best_products_by_reviews.csv)
SELECT RANK() OVER(
        ORDER BY "Reviews" DESC,
            "Stars" DESC,
            "Price" ASC
    ) AS "Rank",
    *
FROM products_dim
WHERE "Price" BETWEEN 5 AND 1000
    AND "Stars" >= 2
    AND "Reviews" > 10
LIMIT 50;
--  -- Price-To-Value Ratio: (/results/4_product_ranking/best_products_by_price-to-value_ratio.csv)
SELECT RANK() OVER(
        ORDER BY "Price" / "Stars" ASC
    ) AS "Rank",
    "ASIN",
    "Title",
    "Price",
    "Stars",
    ROUND("Price"::DECIMAL / "Stars"::DECIMAL, 5) AS "Price-To-Value Ratio"
FROM products_dim
WHERE "Price" BETWEEN 5 AND 1000
    AND "Stars" >= 2
    AND "Reviews" > 10
LIMIT 50;