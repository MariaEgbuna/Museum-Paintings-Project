SELECT * FROM artists AS a;
SELECT * FROM canvas_size AS cs;
SELECT * FROM museums AS m;
SELECT * FROM museum_hours AS mh;
SELECT * FROM works AS w;
SELECT * FROM subjects AS s;
SELECT * FROM product_details AS pd;

-- (1). Fetch all the paintings which are not displayed on any museums?
SELECT
	w.work_id,
	w.work_name,
	w.art_style
FROM works AS w
WHERE w.museum_id IS NULL;
-- Out of 14,716, there are 10,163 paintings which are not displayed on any museums


-- (2). How many paintings have an asking price of more than their regular price?
SELECT COUNT(*) AS number_of_paintings
FROM product_details AS pd
WHERE pd.sales_price > pd.regular_price;
-- None.


-- (3). Identify the paintings whose asking price is less than 50% of its regular price
SELECT
	w.work_name,
	pd.size_id,
	pd.regular_price,
	pd.sales_price
FROM product_details AS pd
INNER JOIN works AS w 
ON pd.work_id = w.work_id
WHERE pd.sales_price < ( pd.regular_price * 0.5 );
-- A total of 56 paintings have an asking price less than 50% of its regular price


-- (4). Which canva size costs the most?
SELECT
	cs.canvas_label AS "Label",
	pd.size_id AS "Most Expensive Size ID",
	pd.regular_price AS "Highest Regular Price"
FROM product_details AS pd
INNER JOIN canvas_size AS cs
ON pd.size_id = cs.size_id
ORDER BY pd.regular_price DESC
LIMIT 1;
-- The 48" x 96"(122 cm x 244 cm) is the most expensive with a price of $2,045.00


-- (5). Delete duplicate records from works, product_details and subjects tables

-- ===================
-- WORKS TABLE
-- ===================
WITH ranked_rows AS 
(
    SELECT
    	w.*,
	    ROW_NUMBER() OVER (PARTITION BY work_id) AS row_num
    FROM works AS w
)
DELETE FROM works
WHERE work_id IN 
(
    SELECT work_id
    FROM ranked_rows
    WHERE row_num > 1
);

-- =====================
-- PRODUCT_DETAILS TABLE
-- =====================
WITH ranked_rows AS (
    SELECT pd.work_id, pd.size_id, 
    ROW_NUMBER() OVER (PARTITION BY work_id, size_id) AS row_num
    FROM product_details AS pd
)
DELETE FROM product_details
WHERE (work_id, size_id) IN
(
	SELECT work_id, size_id
    FROM ranked_rows
    WHERE row_num > 1
);
-- Deleted 2 rows

-- ===============
-- SUBJECTS TABLE
-- ===============
WITH ranked_rows AS 
(
    SELECT
    	s.*,
	    ROW_NUMBER() OVER (PARTITION BY work_id) AS row_num
    FROM subjects AS s
)
DELETE FROM subjects
WHERE work_id IN 
(
    SELECT work_id
    FROM ranked_rows
    WHERE row_num > 1
);
-- Removed Over 1000 rows (1380).


-- (6). Identify the museums with invalid city information in the given dataset
SELECT  *
FROM museums AS m
WHERE m.city ~ '^[0-9]';


-- (7). Fetch the top 10 most famous painting subject
SELECT 
	s.subject,
	COUNT(w.work_id) AS number_of_paintings
FROM subjects AS s
INNER JOIN works AS w
ON s.work_id = w.work_id
GROUP BY s.subject
ORDER BY number_of_paintings DESC
LIMIT 10;


-- (8). Identify the museums which are open on both Sunday and Monday. Display museum name, city
SELECT 
	m.museum_name,
	m.city
FROM museums AS m
WHERE m.museum_id IN 
(	
	SELECT mh.museum_id
	FROM museum_hours AS mh
	WHERE mh.day_of_week IN ('Sunday', 'Monday')
	GROUP BY mh.museum_id
	HAVING COUNT(DISTINCT mh.day_of_week) = 2
);
-- Out of 57 Museums, only 28 are open on both Sundays and Mondays


-- (9). How many museums are open every single day?
SELECT COUNT(m.museum_id) AS "Number of Museums Opened Daily"
FROM museums AS m
WHERE m.museum_id IN
( 
	SELECT mh.museum_id
	FROM museum_hours AS mh
	GROUP BY mh.museum_id
	HAVING COUNT(mh.day_of_week) = 7
)
-- 17 Museums


-- (10). Which are the top 5 most popular museum?
SELECT 
	m.museum_name, 
	m.city, 
	COUNT(w.work_id) AS count_of_paintings
FROM works AS w
JOIN museums AS m ON w.museum_id = m.museum_id
GROUP BY m.museum_name, m.city
ORDER BY count_of_paintings DESC
LIMIT 5;
-- The Metropolitan Museum of Art(939), Rijksmuseum (452), National Gallery(423), National Gallery of Art(375), The Barnes Foundation(350)


-- (11). Who are the top 5 most popular artist?
SELECT
	a.full_name, 
	a.nationality, 
	COUNT(w.work_id) AS number_of_paintings
FROM works AS w
JOIN artists AS a ON w.artist_id = a.artist_id
GROUP BY a.artist_id, a.full_name, a.nationality
ORDER BY number_of_paintings DESC
LIMIT 5;
-- Pierre Auguste Renoir(469), Claude Monet (378), Vincent Van Gogh (308), Maurice Utrillo (253), Albert Marquet (233)


-- (12). Display the 3 least popular canva sizes
SELECT 
	cs.size_id AS "Canvas Size",
	cs.canvas_label AS "Canvas Label",
	COUNT(w.work_id) AS "Number of Paintings"
FROM product_details AS pd
INNER JOIN works AS w
ON pd.work_id = w.work_id
INNER JOIN canvas_size AS cs
ON cs.size_id = pd.size_id
GROUP BY cs.size_id, cs.canvas_label
ORDER BY "Number of Paintings"
LIMIT 3;
-- Several sizes had only 1 painting.


-- (13). Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?
SELECT 
	m.museum_name,
	m.state,
	mh.opening_time,
	mh.closing_time,
	( mh.closing_time - mh.opening_time) AS opening_duration,
	mh.day_of_week
FROM museum_hours AS mh
INNER JOIN museums AS m
ON mh.museum_id = m.museum_id
ORDER BY opening_duration DESC
LIMIT 1;
-- Musée du Louvre in Île-de-France (Opens for almost 13hrs on Fridays)


-- (14). Which museum has the most no of most popular painting style?
WITH MostPopularStyle AS (
    SELECT w.art_style
    FROM works AS w
    GROUP BY w.art_style
    ORDER BY COUNT(w.work_id) DESC
    LIMIT 1
)
SELECT
    m.museum_name,
    mps.art_style,
    COUNT(w.work_id) AS number_of_paintings_in_style
FROM works AS w
INNER JOIN museums AS m
    ON w.museum_id = m.museum_id
INNER JOIN MostPopularStyle AS mps
    ON w.art_style = mps.art_style
GROUP BY m.museum_name, mps.art_style
ORDER BY number_of_paintings_in_style DESC
LIMIT 1;
-- The Metropolitan Museum of Art has the highest number (216) of most popular painting style (Impressionism)


-- (15). Identify the artists whose paintings are displayed in multiple countries
SELECT 
	a.full_name, 
	COUNT(DISTINCT m.country) AS number_of_countries
FROM artists AS a
JOIN works AS w ON a.artist_id = w.artist_id
JOIN museums AS m ON w.museum_id = m.museum_id
GROUP BY a.full_name
HAVING COUNT(DISTINCT m.country) > 1
ORDER BY number_of_countries DESC;


-- (16). Display the country and the city with most no of museums. 
-- Output: 2 seperate columns to mention the city and country. 
-- If there are multiple value, seperate them with comma.
WITH CountryCounts AS (
    SELECT
        m.country,
        COUNT(museum_id) AS country_museum_count,
        RANK() OVER (ORDER BY COUNT(museum_id) DESC) as country_rank
    FROM museums AS m
    GROUP BY m.country  
),
CityCounts AS (
    SELECT
        m.city,
        COUNT(m.museum_id) AS city_museum_count,
        RANK() OVER (ORDER BY COUNT(m.museum_id) DESC) as city_rank
    FROM museums AS m
    GROUP BY m.city
)
SELECT
    STRING_AGG(cc.country, ', ') AS "Top Country(s)",
    STRING_AGG(mc.city, ', ') AS "Top City(s)"
FROM CountryCounts AS cc
CROSS JOIN CityCounts AS mc
WHERE cc.country_rank = 1 AND mc.city_rank = 1;
-- Country with the most number of museums is USA (25), City with the most number is Paris(4)


-- (17). Identify the artist and the museum where the most expensive and least expensive painting is placed. 
-- Display the artist name, sale_price, painting name, museum name, museum city and canvas label
(
    SELECT
        'Most Expensive' AS price_category,
        a.full_name AS artist_name,
        w.work_name,
        pd.sales_price,
        m.museum_name,
        m.city,
        cs.canvas_label
    FROM product_details AS pd
    JOIN works AS w ON pd.work_id = w.work_id
    JOIN artists AS a ON a.artist_id = w.artist_id
    JOIN museums AS m ON w.museum_id = m.museum_id
    JOIN canvas_size AS cs ON cs.size_id = pd.size_id
    ORDER BY pd.sales_price DESC
    LIMIT 1
)
UNION ALL
(
    SELECT
        'Least Expensive' AS price_category,
        a.full_name AS artist_name,
        w.work_name,
        pd.sales_price,
        m.museum_name,
        m.city,
        cs.canvas_label
    FROM product_details AS pd
    JOIN works AS w ON pd.work_id = w.work_id
    JOIN artists AS a ON a.artist_id = w.artist_id
    JOIN museums AS m ON w.museum_id = m.museum_id
    JOIN canvas_size AS cs ON cs.size_id = pd.size_id
    ORDER BY pd.sales_price ASC
    LIMIT 1
);


-- (18). Which country has the 5th highest no of paintings?
WITH RankedCountries AS (
    SELECT
        m.country,
        COUNT(w.work_id) AS "No of Paintings",
        DENSE_RANK() OVER (ORDER BY COUNT(w.work_id) DESC) as country_rank
    FROM museums AS m
    INNER JOIN works AS w
    ON m.museum_id = w.museum_id
    GROUP BY m.country
)
SELECT
    country,
    "No of Paintings"
FROM RankedCountries
WHERE country_rank = 5;


-- (19). Which are the 3 most popular and 3 least popular painting styles?
(
	SELECT 
		w.art_style, 
		COUNT(w.work_id) AS number_of_paintings,
		'Most Popular' AS popularity_category
	FROM works AS w
	GROUP BY w.art_style
	ORDER BY number_of_paintings DESC
	LIMIT 3
)
UNION ALL
(
	SELECT 
		w.art_style, 
		COUNT(w.work_id) AS number_of_paintings,
		'Least Popular' AS popularity_category
	FROM works AS w
	GROUP BY w.art_style
	ORDER BY number_of_paintings
	LIMIT 3
);


-- (20). Which artist has the most no of Portraits paintings outside USA?. Display artist name, no of paintings and the artist nationality.
WITH NonUSAPortraitWorks AS (
    SELECT w.artist_id
    FROM works AS w
    INNER JOIN museums AS m
    ON w.museum_id = m.museum_id
    INNER JOIN subjects AS s
    ON w.work_id = s.work_id
    WHERE s.subject = 'Portraits' AND m.country <> 'USA'
)
SELECT
    a.full_name,
    a.nationality,
    COUNT(nupw.artist_id) AS no_of_paintings
FROM artists AS a
INNER JOIN NonUSAPortraitWorks AS nupw
ON a.artist_id = nupw.artist_id
WHERE a.nationality <> 'American' 
GROUP BY a.artist_id, a.full_name, a.nationality
ORDER BY no_of_paintings DESC
LIMIT 1;
-- Jan Willem Pieneman (Dutch) with 14 paintings and Vincent Van Gogh (also Dutch) with 14 as well
