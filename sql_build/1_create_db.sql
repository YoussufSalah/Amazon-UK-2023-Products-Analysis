CREATE DATABASE IF NOT EXISTS amazon_uk_2023;
-- ------------------- --
CREATE TABLE products_dim (
    "ASIN" VARCHAR(10),
    "Title" TEXT,
    "Image URL" TEXT,
    "Product URL" TEXT,
    "Stars" DECIMAL,
    "Reviews" INT,
    "Price" DECIMAL,
    "Is Best Seller" BOOLEAN,
    "Bought In Last Month" INT,
    "Category Name" VARCHAR(128)
);