SELECT * FROM artists AS a;
SELECT * FROM canvas_size AS cs;
SELECT * FROM museums AS m;
SELECT * FROM museum_hours AS mh;
SELECT * FROM works AS w;
SELECT * FROM subjects AS s;
SELECT * FROM product_details AS pd;

-- =============================
-- ARTISTS
-- =============================

-- Number of Artists
SELECT COUNT (DISTINCT a.artist_id) AS number_of_artists
FROM artists AS a;

-- Top 5 Artist Nationalities by Count
SELECT 
	a.nationality, 
	COUNT(a.artist_id) AS nationality_count
FROM artists AS a
GROUP BY a.nationality
ORDER BY nationality_count DESC
LIMIT 5;

-- Count of Artists per Style
SELECT 
	a.artist_style,
	COUNT(a.artist_id) AS artstyles_count
FROM artists AS a
GROUP BY a.artist_style
ORDER BY artstyles_count DESC;

-- =============================
-- CANVAS SIZE
-- =============================

-- Number of canvas sizes
SELECT COUNT(DISTINCT cs.size_id)
FROM canvas_size AS cs;

-- Average width and height of painting canvas
SELECT 
	AVG(cs.width) AS avg_width, 
	AVG(cs.height) AS avg_heigth
FROM canvas_size AS cs;

-- Smallest and biggest canvas size
SELECT
	MAX(cs.size_id) AS biggest_canvas_size,
	MIN(cs.size_id) AS smallest_canvas_size
FROM canvas_size AS cs;

-- ===============================
-- MUSEUMS AND THEIR WORKING HOURS
-- ===============================

-- Number of Museums
SELECT COUNT(DISTINCT m.museum_id) AS count_of_museums
FROM museums AS m;

-- Number of Museums in each country
SELECT
	m.country,
	COUNT(m.museum_id) AS count_of_museums
FROM museums AS m
GROUP BY m.country
ORDER BY count_of_museums DESC;

-- Average Daily Museum Operating Hours
SELECT
	mh.day_of_week,
	AVG(mh.opening_time) AS avg_opening_time,
	AVG(mh.closing_time) AS avg_closing_time
FROM museum_hours AS mh
GROUP BY mh.day_of_week;

-- Which Museums Open Seven Days a Week?
SELECT 
	m.museum_name,
	m.country
FROM museum_hours AS mh
INNER JOIN museums AS m
ON mh.museum_id = m.museum_id
GROUP BY m.museum_name, m.country
HAVING COUNT(mh.day_of_week) = 7;

-- =============================
-- ARTISTS AND THEIR WORKS
-- =============================

-- Number of paintings
SELECT COUNT(DISTINCT w.work_id) AS number_of_paintings
FROM works AS w;

-- Total Works Availability Status (Museum/Not Museum)
(
	SELECT
		'Not Available' AS "Available in Museums?",
		COUNT(w.*) AS number_of_paintings
	FROM works AS w
	WHERE w.museum_id IS NULL
)
UNION ALL
(
	SELECT
		'Available' AS "Available in Museums?",
		COUNT(w.*) AS number_of_paintings
	FROM works AS w
	WHERE w.museum_id IS NOT NULL
);

-- Works Count and Museum Count Per Artist and Art Style
SELECT
	a.full_name,
	w.art_style,
	COUNT(w.work_id) AS number_of_paintings,
	COUNT(w.museum_id) AS number_of_museums
FROM works AS w
INNER JOIN artists AS a
ON w.artist_id = a.artist_id
GROUP BY a.full_name, w.art_style
ORDER BY number_of_paintings DESC;

-- Top 10 Art Styles by Work Count
SELECT
	w.art_style,
	COUNT(DISTINCT w.work_id) AS number_of_paintings
FROM works AS w
GROUP BY w.art_style
ORDER BY number_of_paintings DESC
LIMIT 10;

-- =============================
-- PAINTINGS PRICES BY SIZES
-- =============================

-- Most expensive and Least Expensive Paintings
(
	SELECT
	    w.work_name,
	    pd.regular_price,
	    'Most Expensive' AS price_category
	FROM product_details AS pd
	INNER JOIN works AS w
	ON pd.work_id = w.work_id
	ORDER BY pd.regular_price DESC
	LIMIT 1
)
UNION ALL
(
	SELECT
	    w.work_name,
	    pd.regular_price,
	    'Least Expensive' AS price_category
	FROM product_details AS pd
	INNER JOIN works AS w
	ON pd.work_id = w.work_id
	ORDER BY pd.regular_price ASC
	LIMIT 1
)

-- Individual Product Pricing Compared to Average Price Per Size
SELECT
	w.work_name,
	w.art_style,
	pd.size_id,
	AVG(pd.sales_price) OVER (PARTITION BY pd.size_id) AS avg_sales_price,
	AVG(pd.regular_price) OVER (PARTITION BY pd.size_id) AS avg_regular_price 
FROM product_details AS pd
INNER JOIN works AS w
ON pd.work_id = w.work_id

