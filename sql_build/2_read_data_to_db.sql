COPY products_dim
FROM 'D:/Youssuf/Programming/sql-projects/amazon_uk_2023_products_analysis/data.csv' WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ',',
        ENCODING 'UTF8',
        NULL 'NA'
    );