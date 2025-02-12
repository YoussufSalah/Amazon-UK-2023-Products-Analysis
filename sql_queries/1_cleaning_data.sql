-- Count rows before cleaning (2222742)
SELECT COUNT(*)
FROM products_dim;
-- Get the products with missing data
SELECT *
FROM products_dim
WHERE "Price" IN (NULL, 0, '0.0')
    OR "Category Name" IS NULL
    OR "Title" IS NULL
    OR "Product URL" IS NULL
    OR "Is Best Seller" IS NULL
    OR "Bought In Last Month" IS NULL
    OR "ASIN" IS NULL;
-- Delete the products with missing data from the database
DELETE FROM products_dim
WHERE "Price" IN (NULL, 0, '0.0')
    OR "Category Name" IS NULL
    OR "Title" IS NULL
    OR "Product URL" IS NULL
    OR "Is Best Seller" IS NULL
    OR "Bought In Last Month" IS NULL
    OR "ASIN" IS NULL;
--  ---------------------------- --
-- Detect outliers
WITH CategoryStats AS (
    SELECT "Category Name",
        AVG("Price") AS AvgPrice,
        STDDEV_POP("Price") AS StdDevPrice
    FROM products_dim
    GROUP BY "Category Name"
),
StandardizedPrices AS (
    SELECT p.*,
        (p."Price" - c.AvgPrice) / NULLIF(c.StdDevPrice, 0) AS ZScore
    FROM products_dim p
        JOIN CategoryStats c ON p."Category Name" = c."Category Name"
)
SELECT *
FROM StandardizedPrices
WHERE ABS(ZScore) > 3;
-- Delete outliers
DELETE FROM products_dim
WHERE (
        "ASIN",
        "Title",
        "Image URL",
        "Product URL",
        "Stars",
        "Reviews",
        "Price",
        "Is Best Seller",
        "Bought In Last Month",
        "Category Name"
    ) IN (
        WITH CategoryStats AS (
            SELECT "Category Name",
                AVG("Price") AS AvgPrice,
                STDDEV_POP("Price") AS StdDevPrice
            FROM products_dim
            GROUP BY "Category Name"
        ),
        StandardizedPrices AS (
            SELECT p.*,
                (p."Price" - c.AvgPrice) / NULLIF(c.StdDevPrice, 0) AS ZScore
            FROM products_dim p
                JOIN CategoryStats c ON p."Category Name" = c."Category Name"
        )
        SELECT "ASIN",
            "Title",
            "Image URL",
            "Product URL",
            "Stars",
            "Reviews",
            "Price",
            "Is Best Seller",
            "Bought In Last Month",
            "Category Name"
        FROM StandardizedPrices
        WHERE ABS(ZScore) > 3
    );
--  ---------------------------- --
-- Check if there any duplicates
SELECT CASE
        WHEN (
            SELECT DISTINCT COUNT("ASIN")
            FROM products_dim
        ) = (
            SELECT COUNT(*)
            FROM products_dim
        ) THEN FALSE
        ELSE TRUE
    END AS "Has Duplicates";
-- Delete any duplicated products
DELETE FROM products_dim
WHERE "ASIN" IN (
        SELECT "ASIN"
        FROM (
                SELECT "ASIN",
                    COUNT(*) AS "ASIN Count"
                FROM products_dim
                GROUP BY "ASIN"
                HAVING COUNT(*) > 1
            )
    );
-- Count rows after cleaning (2187831)
SELECT COUNT(*)
FROM products_dim;