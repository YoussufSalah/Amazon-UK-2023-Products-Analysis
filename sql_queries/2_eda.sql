-- Average & Median:
-- -- Price: 69.46 & 19.31
SELECT ROUND(AVG("Price"), 2) AS "Average Price",
    PERCENTILE_CONT(0.5) WITHIN GROUP (
        ORDER BY "Price"
    ) AS "Median Price"
FROM products_dim;
-- -- Reviews: 384 & 0
SELECT ROUND(AVG("Reviews"), 0) AS "Average Reviews",
    PERCENTILE_CONT(0.5) WITHIN GROUP (
        ORDER BY "Reviews"
    ) AS "Median Reviews"
FROM products_dim;
-- -- Stars: 2.04 & 0
SELECT ROUND(AVG("Stars"), 2) AS "Average Stars",
    PERCENTILE_CONT(0.5) WITHIN GROUP (
        ORDER BY "Stars"
    ) AS "Median Stars"
FROM products_dim;
-- -- Bought In Last Month: 19
SELECT ROUND(AVG("Bought In Last Month"), 0) AS "Average Bought In Last Month",
    PERCENTILE_CONT(0.5) WITHIN GROUP (
        ORDER BY "Price"
    ) AS "Median Price"
FROM products_dim;
-- Category Analysis:
-- -- Ranking Categories By Total Sales In Last Month: (/results/2_eda/ranking_categories_by_last_month_sales.csv)
SELECT RANK() OVER (
        ORDER BY SUM("Bought In Last Month") DESC
    ) AS "Rank",
    "Category Name",
    SUM("Bought In Last Month") AS "Sales Last Month",
    ROUND(
        SUM("Bought In Last Month") * 100.0 / SUM(SUM("Bought In Last Month")) OVER(),
        2
    ) AS "Percentage Contribution"
FROM products_dim
GROUP BY "Category Name";
-- -- Explore Price Range Within Each Category: (/results/2_eda/price_ranges_within_categories.csv)
SELECT "Category Name",
    ROUND(MIN("Price"), 2) AS "MIN Price",
    ROUND(MAX("Price"), 2) AS "MAX Price",
    ROUND(AVG("Price"), 2) AS "AVG Price"
FROM products_dim
GROUP BY "Category Name"
ORDER BY "AVG Price" DESC;
-- -- Stars Rating Distribution By Category: (/results/2_eda/stars_rating_distribution_by_category.csv)
SELECT "Category Name",
    ROUND(AVG("Stars"), 2) AS "Average Stars",
    COUNT(*) AS "Total Products"
FROM products_dim
GROUP BY "Category Name"
ORDER BY "Average Stars" DESC;
-- Reviews Analysis:
-- -- Ranking Products Based On Review Count: (/results/2_eda/ranking_products_based_on_review_count_sample.csv)
SELECT RANK() OVER(
        ORDER BY "Reviews" DESC
    ) AS "Rank",
    "ASIN",
    "Reviews"
FROM products_dim
LIMIT 50;
-- -- Categorizing Porducts Based On Star Count: (/results/2_eda/categorizing_star_count.csv)
SELECT CASE
        WHEN ROUND("Stars"::DECIMAL, 2) BETWEEN 4.01 AND 5 THEN 'From 4.01 - 5'
        WHEN ROUND("Stars"::DECIMAL, 2) BETWEEN 3.01 AND 4 THEN 'From 3.01 - 4'
        WHEN ROUND("Stars"::DECIMAL, 2) BETWEEN 2.01 AND 3 THEN 'From 2.01 - 3'
        WHEN ROUND("Stars"::DECIMAL, 2) BETWEEN 1.01 AND 2 THEN 'From 1.01 - 2'
        WHEN ROUND("Stars"::DECIMAL, 2) BETWEEN 0 AND 1 THEN 'From 0 - 1'
    END AS "Stars Category",
    COUNT(*) AS "Stars Count",
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS "Percentage"
FROM products_dim
GROUP BY "Stars Category"
ORDER BY "Stars Category" DESC;
-- -- Look For Correlation Between Prices And Stars, and Prices And Reviews: (Price-Stars: -0.14, Price-Reviews: -0.02)
SELECT ROUND(CORR("Price", "Stars")::DECIMAL, 2) AS "Price-Stars Correlation",
    ROUND(CORR("Price", "Reviews")::DECIMAL, 2) AS "Price-Reviews Correlation"
FROM products_dim;
-- Best Sellers Analysis:
-- -- Top 10 Best Sellers: (/results/2_eda/top_10_best_sellers.csv)
SELECT "ASIN",
    "Title",
    "Category Name",
    "Price",
    "Bought In Last Month"
FROM products_dim
WHERE "Is Best Seller" = TRUE
ORDER BY "Bought In Last Month" DESC,
    "Price" ASC
LIMIT 10;