-- -- Stage 2 — Task 1:
-- CREATE TABLE raw_listings (
--     "cat2_slug" TEXT,
--     "cat3_slug" TEXT,
--     "city_slug" TEXT,
--     "neighborhood_slug" TEXT,
--     "created_at_month" TEXT,
--     "user_type" TEXT,
--     "description" TEXT,
--     "title" TEXT,
--     "rent_mode" TEXT,
--     "rent_value" DOUBLE PRECISION,
--     "rent_to_single" DOUBLE PRECISION,
--     "rent_type" TEXT,
--     "price_mode" TEXT,
--     "price_value" DOUBLE PRECISION,
--     "credit_mode" TEXT,
--     "credit_value" DOUBLE PRECISION,
--     "rent_credit_transform" TEXT,
--     "transformable_price" TEXT,
--     "transformable_credit" DOUBLE PRECISION,
--     "transformed_credit" DOUBLE PRECISION,
--     "transformable_rent" DOUBLE PRECISION,
--     "transformed_rent" DOUBLE PRECISION,
--     "land_size" DOUBLE PRECISION,
--     "building_size" DOUBLE PRECISION,
--     "deed_type" TEXT,
--     "has_business_deed" TEXT,
--     "floor" DOUBLE PRECISION,
--     "rooms_count" TEXT,
--     "total_floors_count" DOUBLE PRECISION,
--     "unit_per_floor" TEXT,
--     "has_balcony" TEXT,
--     "has_elevator" TEXT,
--     "has_warehouse" TEXT,
--     "has_parking" TEXT,
--     "construction_year" TEXT,
--     "is_rebuilt" TEXT,
--     "has_water" TEXT,
--     "has_warm_water_provider" TEXT,
--     "has_electricity" TEXT,
--     "has_gas" TEXT,
--     "has_heating_system" TEXT,
--     "has_cooling_system" TEXT,
--     "has_restroom" TEXT,
--     "has_security_guard" TEXT,
--     "has_barbecue" TEXT,
--     "building_direction" TEXT,
--     "has_pool" TEXT,
--     "has_jacuzzi" TEXT,
--     "has_sauna" TEXT,
--     "floor_material" TEXT,
--     "property_type" TEXT,
--     "regular_person_capacity" DOUBLE PRECISION,
--     "extra_person_capacity" DOUBLE PRECISION,
--     "cost_per_extra_person" DOUBLE PRECISION,
--     "rent_price_on_regular_days" DOUBLE PRECISION,
--     "rent_price_on_special_days" DOUBLE PRECISION,
--     "rent_price_at_weekends" DOUBLE PRECISION,
--     "location_latitude" DOUBLE PRECISION,
--     "location_longitude" DOUBLE PRECISION,
--     "location_radius" DOUBLE PRECISION
-- );

-- ALTER TABLE raw_listings
-- ALTER COLUMN floor TYPE TEXT, -- because the original "floor" DOUBLE PRECISION had a mismatch, and also others
-- ALTER COLUMN extra_person_capacity TYPE TEXT,
-- ALTER COLUMN total_floors_count TYPE TEXT,
-- ALTER COLUMN rent_to_single TYPE TEXT;

-- COPY raw_listings

-- FROM 'E:\Study\Practical SQL 2nd Edition A Beginners Guide to Storytelling with Data By Anthony DeBarros\4 - Obsidians Summaries\2 - Projects\1 - Divar Iranian Real Estate Market Analysis\real_estate_ads.csv'

-- WITH (FORMAT CSV, HEADER)

-- -- Stage 2 — Task 2: Validate the Imported Dataset

-- SELECT COUNT(cat3_slug) FROM raw_listings
-- WHERE cat3_slug IS NOT NULL;

-- SELECT DISTINCT city_slug 
-- FROM raw_listings ORDER BY city_slug;


-- SELECT city_slug, COUNT(*) AS ad_count
-- FROM raw_listings
-- GROUP BY city_slug
-- ORDER BY ad_count DESC
-- LIMIT 5;

-- SELECT cat3_slug, COUNT(*)  AS dis_cat3
-- FROM raw_listings
-- GROUP BY cat3_slug
-- ORDER BY dis_cat3 DESC;

-- SELECT COUNT(DISTINCT cat3_slug) AS dis_cat3
-- FROM raw_listings
-- WHERE cat3_slug IS NOT NULL;

-- SELECT COUNT(DISTINCT city_slug) AS dis_city
-- FROM raw_listings
-- WHERE city_slug IS NOT NULL;


-- -- Stage 2 — Task 3: Identify Residential Apartment Sales

-- SELECT DISTINCT
--     cat2_slug,
--     cat3_slug
-- FROM raw_listings
-- WHERE cat2_slug IS NOT NULL
--   AND cat3_slug IS NOT NULL
-- ORDER BY cat2_slug, cat3_slug;


-- -- Stage 2 — Task 4: Analyze Apartment Sales by City

-- SELECT cat2_slug, cat3_slug, city_slug, neighborhood_slug
-- FROM raw_listings
-- WHERE cat2_slug = 'residential-sell'
--   AND cat3_slug = 'apartment-sell'
-- ORDER BY cat2_slug, cat3_slug;


-- SELECT city_slug, COUNT(*) AS ad_count
-- FROM raw_listings
-- WHERE cat2_slug = 'residential-sell'
--   AND cat3_slug = 'apartment-sell'
-- GROUP BY city_slug
-- ORDER BY ad_count DESC
-- LIMIT 5;


-- -- Stage 2 — Task 5: Create an Analytical Subset


-- CREATE TABLE apartment_sales AS
-- SELECT * FROM raw_listings
-- WHERE cat2_slug = 'residential-sell'
-- 	AND cat3_slug = 'apartment-sell'
-- 	AND city_slug IN ('tehran','mashhad','karaj','andisheh-new-town','isfahan');

-- SELECT COUNT(*) AS total_apartments
-- FROM apartment_sales;

-- -- Stage 3 — Task 1: Investigate Missing Values

-- SELECT
--     COUNT(*) AS total,
--     COUNT(*) FILTER (WHERE price_value IS NULL) AS price_missing,
-- 	COUNT(*) FILTER (WHERE building_size IS NULL) AS size_missing,
-- 	COUNT(*) FILTER (WHERE construction_year IS NULL) AS construction_missing
-- FROM apartment_sales;


-- SELECT
--     COUNT(*) AS total,
--     COUNT(*) FILTER (WHERE price_value = 0) AS price_0,
-- 	COUNT(*) FILTER (WHERE price_value < 0) AS price_NEG,
-- 	COUNT(*) FILTER (WHERE price_value IS NULL) AS price_NULL
-- FROM apartment_sales;

-- -- Stage 3 — Task 3: Investigate Zero-Priced Advertisements


-- SELECT city_slug, title, description, price_mode, price_value, building_size
-- FROM apartment_sales
-- WHERE price_value = 0 LIMIT 20;


-- SELECT
-- 	price_mode,
--     COUNT(*) AS total,
--     COUNT(*) FILTER (WHERE price_value = 0) AS price_0,
-- 	COUNT(*) FILTER (WHERE price_value IS NULL) AS price_NULL
-- FROM apartment_sales
-- GROUP BY price_mode
-- ORDER BY total DESC;

-- -- Stage 3 — Task 5: Investigate Property Sizes


-- SELECT
-- MIN(building_size) AS size_min,
-- MAX(building_size) AS size_max,
-- AVG(building_size) AS size_avg,
-- PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY building_size) AS size_median
-- FROM apartment_sales;

-- -- Stage 3 — Task 6: Investigate Size Outliers

-- SELECT 
-- 	COUNT(*) FILTER (WHERE building_size < 20) AS size_lower_20,
-- 	COUNT(*) FILTER (WHERE building_size BETWEEN 20 AND 500) AS size_20_AND_500,
-- 	COUNT(*) FILTER (WHERE building_size > 500) AS size_over_500,
-- 	COUNT(*) FILTER (WHERE building_size IS NULL) AS size_null
-- FROM apartment_sales;


-- -- Stage 3 — Task 7: Inspect Extreme Property Sizes
-- SELECT city_slug, title, building_size, price_value, description
-- FROM apartment_sales
-- WHERE building_size < 20 OR building_size > 500
-- ORDER BY building_size DESC LIMIT 20;

-- -- Stage 3 — Task 8: Investigate the Size Distribution

-- SELECT 
-- 	PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY building_size) AS P90,
-- 	PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY building_size) AS P95,
-- 	PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY building_size) AS P99,
-- 	PERCENTILE_CONT(0.999) WITHIN GROUP (ORDER BY building_size) AS P999
-- FROM apartment_sales;


-- -- Stage 3 — Task 9: Investigate the Upper Tail
-- SELECT
-- 	COUNT(*) FILTER (WHERE building_size > 300 AND building_size <= 500) AS size_301_500,
-- 	COUNT(*) FILTER (WHERE building_size > 500 AND building_size <= 1000) AS size_501_1000,
-- 	COUNT(*) FILTER (WHERE building_size > 1000 AND building_size <= 1500) AS size_1001_1500,
-- 	COUNT(*) FILTER (WHERE building_size > 1500) AS size_above_1500
-- FROM apartment_sales;


-- -- Stage 3 — Task 10: Investigate Small Apartments

-- SELECT city_slug, title, building_size, price_value, description
-- FROM apartment_sales
-- WHERE building_size < 20
-- ORDER BY building_size ASC LIMIT 20;

-- -- Stage 3 — Task 11: Evaluate a Cleaning Threshold

-- SELECT 
-- COUNT(*) AS total,
-- COUNT(*) FILTER (WHERE building_size BETWEEN 20 AND 500) AS size_20_500,
-- COUNT(*) - COUNT(*) FILTER (WHERE building_size BETWEEN 20 AND 500) AS size_above_20_500,
-- ROUND(
--     COUNT(*) FILTER (WHERE building_size BETWEEN 20 AND 500)
--     * 100.0 / COUNT(*),
--     2
-- ) AS percentage_retained

-- FROM apartment_sales;

-- -- Stage 3 — Task 12: Investigate Construction Years

-- SELECT
-- 	construction_year AS years,
--     COUNT(*) AS total	
-- FROM apartment_sales
-- WHERE construction_year IS NOT NULL
-- GROUP BY construction_year
-- ORDER BY total  DESC;

-- -- Stage 3 — Task 13: Convert Persian Digits

-- SELECT DISTINCT
--     construction_year,
--     TRANSLATE(
--         construction_year,
--         '۰۱۲۳۴۵۶۷۸۹',
--         '0123456789'
--     ) AS construction_year_normalized
-- FROM apartment_sales
-- WHERE construction_year IS NOT NULL
-- ORDER BY construction_year DESC
-- LIMIT 20;

-- -- Stage 3 — Task 14: Identify Numeric Construction Years

-- SELECT DISTINCT
--     construction_year,
--     TRANSLATE(
--         construction_year,
--         '۰۱۲۳۴۵۶۷۸۹',
--         '0123456789'
--     ) AS construction_year_normalized,
--     CASE
--         WHEN TRANSLATE(
--             construction_year,
--             '۰۱۲۳۴۵۶۷۸۹',
--             '0123456789'
--         ) ~ '^[0-9]{4}$'
--         THEN 'numeric'
--         ELSE 'non_numeric'
--     END AS year_type
-- FROM apartment_sales
-- ORDER BY construction_year DESC;


-- -- Stage 3 — Task 15: Convert Construction Years to Integers

-- SELECT DISTINCT
--     construction_year,
--     CASE
--         WHEN TRANSLATE(
--             construction_year,
--             '۰۱۲۳۴۵۶۷۸۹',
--             '0123456789'
--         ) ~ '^[0-9]{4}$'
-- 		THEN CAST(
--     		TRANSLATE(
--         		construction_year,
--         		'۰۱۲۳۴۵۶۷۸۹',
--         		'0123456789'
--     			) AS INTEGER
-- 							)
-- 		ELSE NULL
--     		END AS construction_year_cleaned
-- FROM apartment_sales;

-- -- Stage 3 — Task 16: Create a Cleaned Analytical Table

-- CREATE TABLE apartment_sales_cleaned AS 
-- SELECT 
-- 	*,
-- 	CASE
--         WHEN TRANSLATE(
--             construction_year,
--             '۰۱۲۳۴۵۶۷۸۹',
--             '0123456789'
--         ) ~ '^[0-9]{4}$'
-- 		THEN CAST(
--     		TRANSLATE(
--         		construction_year,
--         		'۰۱۲۳۴۵۶۷۸۹',
--         		'0123456789'
--     			) AS INTEGER
-- 							)
-- 		ELSE NULL
--     		END AS construction_year_cleaned
-- FROM apartment_sales
-- WHERE building_size BETWEEN 20 AND 500
-- 	AND price_mode = 'مقطوع'
-- 	AND price_value > 0;
	 
-- -- Stage 3 — Task 16: Final Verification

-- SELECT COUNT(*) AS cleaned_total
-- FROM apartment_sales_cleaned;

-- -- Stage 3 — Task 17: Check for Duplicate Advertisements

-- SELECT
--     city_slug,
--     neighborhood_slug,
--     title,
--     price_value,
--     building_size,
--     COUNT(*) AS duplicate_count
-- FROM apartment_sales_cleaned
-- GROUP BY 
-- 	city_slug,
--     neighborhood_slug,
--     title,
--     price_value,
--     building_size

-- HAVING COUNT(*) > 1
-- ORDER BY duplicate_count DESC
-- LIMIT 20;


-- -- Stage 4 — Task 1: Compare Apartment Prices Across Cities

-- SELECT 
-- COUNT(*), 
-- AVG(price_value) AS price_avg,
-- PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_value) AS price_median,
-- city_slug AS city
-- FROM apartment_sales_cleaned
-- GROUP BY city_slug
-- ORDER BY price_median DESC;


-- -- Stage 4 — Task 2: Analyze Price per Square Meter

-- SELECT 
-- COUNT(*),
-- city_slug AS city,
-- AVG(price_value / building_size) AS price_per_size_avg,
-- PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_value / building_size) AS price_per_size_median
-- FROM apartment_sales_cleaned
-- GROUP BY city_slug
-- ORDER BY price_per_size_median DESC;

-- -- Stage 4 — Task 3: Investigate Price-per-m² Outliers

-- SELECT 
-- COUNT(*),
-- city_slug AS city,
-- MIN(price_value / building_size) AS min_price_per_size,
-- MAX(price_value / building_size) AS max_price_per_size,
-- PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY price_value / building_size) AS price_per_size_P95,
-- PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY price_value / building_size) AS price_per_size_P99
-- FROM apartment_sales_cleaned
-- GROUP BY city_slug
-- ORDER BY COUNT(*) DESC;

-- -- Stage 4 — Task 4: Investigate Extreme Prices

-- SELECT
--     city_slug,
--     title,
--     price_value,
--     building_size,
--     description,
--     price_value / building_size AS price_per_sqm
-- FROM apartment_sales_cleaned
-- ORDER BY price_per_sqm DESC
-- LIMIT 10;

-- -- 

-- SELECT
--     city_slug,
--     title,
--     price_value,
--     building_size,
--     description,
--     price_value / building_size AS price_per_sqm
-- FROM apartment_sales_cleaned
-- ORDER BY price_per_sqm ASC
-- LIMIT 10;

-- -- Stage 4 — Task 6: Investigate Low-Price Outliers

-- SELECT 
-- COUNT(*) AS total,
-- COUNT(*) FILTER (WHERE price_value = 1) AS price_1,
-- COUNT(*) FILTER (WHERE price_value BETWEEN 2 AND 1000000) AS price_2_1m,
-- COUNT(*) FILTER (WHERE price_value BETWEEN 1000001 AND 100000000) AS price_1m_100m,
-- COUNT(*) FILTER (WHERE price_value >= 100000001) AS price_above_100m
-- FROM apartment_sales_cleaned;

-- -- Stage 4 — Task 7: Investigate Price Percentiles

-- SELECT 
-- COUNT(*) AS total,
-- city_slug ,
-- PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY price_value / building_size) AS price_per_size_P01,
-- PERCENTILE_CONT(0.05) WITHIN GROUP (ORDER BY price_value / building_size) AS price_per_size_P05,
-- PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_value / building_size) AS price_per_size_P5,
-- PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY price_value / building_size) AS price_per_size_P95,
-- PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY price_value / building_size) AS price_per_size_P99
-- FROM apartment_sales_cleaned
-- GROUP BY city_slug
-- ORDER BY price_per_size_P5 DESC;

-- -- Stage 4 — Task 8: Evaluate Percentile-Based Filtering

-- WITH city_percentiles AS (
--     SELECT
--         city_slug,
--         PERCENTILE_CONT(0.01)
--             WITHIN GROUP (ORDER BY price_value / building_size) AS p01,
--         PERCENTILE_CONT(0.99)
--             WITHIN GROUP (ORDER BY price_value / building_size) AS p99
--     FROM apartment_sales_cleaned
--     GROUP BY city_slug
-- )
-- SELECT
--     a.city_slug,
--     COUNT(*) AS total,
--     COUNT(*) FILTER (
--         WHERE (a.price_value / a.building_size)
--               BETWEEN p.p01 AND p.p99
--     ) AS retained,
--     ROUND(
--         COUNT(*) FILTER (
--             WHERE (a.price_value / a.building_size)
--                   BETWEEN p.p01 AND p.p99
--         ) * 100.0 / COUNT(*),
--         2
--     ) AS percentage_retained
-- FROM apartment_sales_cleaned AS a
-- JOIN city_percentiles AS p
--     ON a.city_slug = p.city_slug
-- GROUP BY a.city_slug
-- ORDER BY percentage_retained DESC;

-- -- Stage 4 — Task 9: Compare Prices Before and After Filtering

-- WITH city_percentiles AS (
--     SELECT
--         city_slug,
--         PERCENTILE_CONT(0.01)
--             WITHIN GROUP (ORDER BY price_value / building_size) AS p01,
--         PERCENTILE_CONT(0.99)
--             WITHIN GROUP (ORDER BY price_value / building_size) AS p99
--     FROM apartment_sales_cleaned
--     GROUP BY city_slug
-- )
-- SELECT
--     a.city_slug,

--     -- Before filtering
--     AVG(a.price_value / a.building_size)
--         AS avg_before_filtering,

--     PERCENTILE_CONT(0.5)
--         WITHIN GROUP (ORDER BY a.price_value / a.building_size)
--         AS median_before_filtering,

--     -- After filtering
--     AVG(a.price_value / a.building_size)
--         FILTER (
--             WHERE a.price_value / a.building_size
--                   BETWEEN p.p01 AND p.p99
--         ) AS avg_after_filtering,

--     PERCENTILE_CONT(0.5)
--         WITHIN GROUP (ORDER BY a.price_value / a.building_size)
--         FILTER (
--             WHERE a.price_value / a.building_size
--                   BETWEEN p.p01 AND p.p99
--         ) AS median_after_filtering

-- FROM apartment_sales_cleaned AS a
-- JOIN city_percentiles AS p
--     ON a.city_slug = p.city_slug

-- GROUP BY a.city_slug
-- ORDER BY a.city_slug;


-- -- Stage 5 — Task 1: Create an Analytical View

-- CREATE VIEW v_apartment_prices AS
-- SELECT
--     city_slug,
--     neighborhood_slug,
--     price_value,
--     building_size,
--     construction_year_cleaned,
--     price_value / building_size AS price_per_sqm
-- FROM apartment_sales_cleaned;


-- SELECT *
-- FROM v_apartment_prices
-- LIMIT 10;

-- -- Stage 5 — Task 2: Rank Neighborhoods by Housing Prices

-- SELECT
--     city_slug,
--     neighborhood_slug,
--     COUNT(*) AS ad_count,
--     PERCENTILE_CONT(0.5)
--         WITHIN GROUP (ORDER BY price_per_sqm) AS median_price
-- FROM v_apartment_prices
-- WHERE neighborhood_slug IS NOT NULL
-- GROUP BY city_slug, neighborhood_slug
-- HAVING  COUNT(*) >= 30
-- ORDER BY median_price DESC;


-- WITH neighborhood_stats AS (
--     SELECT
--         city_slug,
--         neighborhood_slug,
--         COUNT(*) AS ad_count,
--         PERCENTILE_CONT(0.5)
--             WITHIN GROUP (ORDER BY price_per_sqm) AS median_price
--     FROM v_apartment_prices
--     WHERE neighborhood_slug IS NOT NULL
--     GROUP BY city_slug, neighborhood_slug
--     HAVING COUNT(*) >= 30
-- ),
-- ranked_neighborhoods AS (
--     SELECT
--         *,
--         ROW_NUMBER() OVER (
--             PARTITION BY city_slug
--             ORDER BY median_price DESC, neighborhood_slug
--         ) AS neighborhood_rank
--     FROM neighborhood_stats
-- )
-- SELECT *
-- FROM ranked_neighborhoods
-- WHERE neighborhood_rank <= 5
-- ORDER BY city_slug, neighborhood_rank;

-- -- Stage 5 — Task 3: Investigate Missing Neighborhood Data

-- SELECT 
-- COUNT(*) AS total,
-- COUNT(*) FILTER (WHERE neighborhood_slug IS NULL) AS andisheh_null,
-- COUNT(*) FILTER (WHERE neighborhood_slug IS NOT NULL) AS andisheh_not_null,
-- ROUND(
--     COUNT(*) FILTER (WHERE neighborhood_slug IS NULL)
--     * 100.0 / COUNT(*),
--     2
-- ) AS missing_percentage
-- FROM apartment_sales_cleaned
-- WHERE city_slug = 'andisheh-new-town';

-- -- Stage 5 — Task 4: Investigate Geographic Coordinate Coverage

-- SELECT 
-- COUNT(*) AS total,
-- city_slug,
-- COUNT(*) FILTER (WHERE location_latitude IS NOT NULL AND location_longitude IS NOT NULL) AS n_locations,
-- COUNT(*) FILTER (WHERE location_latitude IS NULL OR location_longitude IS NULL) AS miss_locations,
-- ROUND(
--     COUNT(*) FILTER (WHERE location_latitude IS NOT NULL AND location_longitude IS NOT NULL)
--     * 100.0 / COUNT(*), 2
-- ) AS n_locations_percent
-- FROM apartment_sales_cleaned
-- GROUP BY city_slug
-- ORDER BY city_slug;

-- -- Stage 5 — Task 5: Investigate Location Accuracy

-- SELECT 
-- COUNT(*) AS total,
-- location_radius
-- FROM apartment_sales_cleaned
-- GROUP BY location_radius
-- ORDER BY COUNT(*) DESC;

-- -- Stage 6 — Task 1: Validate Geographic Coordinates
-- SELECT
-- COUNT(*) total,
-- city_slug,
-- COUNT(*) FILTER (
--     WHERE location_latitude BETWEEN -90 AND 90
--       AND location_longitude BETWEEN -180 AND 180
-- ) AS valid_coordinates,
-- COUNT(*) FILTER (WHERE location_longitude = 0 AND location_latitude = 0) AS zero_loc,
-- COUNT(DISTINCT (location_latitude, location_longitude)) AS unique_loc
-- FROM apartment_sales_cleaned
-- GROUP BY city_slug
-- ORDER BY city_slug;

-- -- Stage 6 — Task 2: Prepare Dashboard Data

-- CREATE VIEW v_housing_map AS
-- SELECT
--     city_slug,
--     neighborhood_slug,
-- 	location_latitude,
--     location_longitude,
-- 	location_radius,
--     price_value,
--     building_size,
--     construction_year_cleaned,
-- ROUND((price_value / building_size)::numeric, 2) AS price_per_sqm
-- FROM apartment_sales_cleaned
-- WHERE location_latitude BETWEEN -90 AND 90
--   AND location_longitude BETWEEN -180 AND 180
--   AND location_latitude <> 0
--   AND location_longitude <> 0;

-- SELECT *
-- FROM v_housing_map
-- LIMIT 10;

-- -- Enable PostGIS

-- SELECT *
-- FROM pg_available_extensions
-- WHERE name = 'postgis';

-- CREATE EXTENSION IF NOT EXISTS postgis;
-- SELECT PostGIS_Version();

-- --  Generate geographic points
SELECT
    city_slug,
    ST_SetSRID(
        ST_MakePoint(
            location_longitude,
            location_latitude
        ),
        4326
    ) AS geom
FROM v_housing_map
WHERE city_slug = 'tehran'
LIMIT 100;


































