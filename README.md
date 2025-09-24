# Paintings-Project
This project involved a full-stack data analysis process, from data cleaning and database setup to querying for insights.

***
### Data Cleaning

Before writing the SQL queries, the dataset was cleaned using **Microsoft Excel**. The data cleaning process included:

* Removing duplicate rows to ensure each entry was unique.
* Removing blank rows to eliminate incomplete records.

### Database Setup

The analysis was performed on a PostgreSQL database. The setup process included the following steps:

1.  Creating a new database named **`paintings`**.
2.  Importing the raw data from CSV files into their respective tables within the database.
3.  Updating the tables by defining **primary and foreign keys** to establish relationships and ensure data integrity.

***

### Database Schema

[!ER Diagram](ER-Diagram.png)

The queries operate on the following key tables and their relationships:

* **`artist`**: Contains artist details (`artist_id`, `full_name`, `nationality`, `artist_style`, `birth_year`, `death_year`).
* **`work`**: Contains painting details (`work_id`, `work_name`, `artist_id`, `museum_id`, `art_style`).
* **`museum`**: Contains museum details (`museum_id`, `museum_name`, `city`, `country`, `postal_code`, `url `).
* **`museum_hours`**: Stores daily opening and closing times for museums (`museum_id`, `day_of_week`, `opening_time`, `closing_time`).
* **`product_details`**: Links paintings to pricing information (`work_id`, `size_id`, `sale_price`, `regular_price`).
* **`subject`**: Lists the subjects of each painting (`work_id`, `subject`).

***

### Queries

#### Artist Analysis

##### Find the Top 5 Most Popular Artists

Finds the artists with the most paintings in the database.

```sql
SELECT a.artist_id, a.full_name, a.nationality, COUNT(w.work_id) AS number_of_paintings
FROM work AS w
JOIN artist AS a ON w.artist_id = a.artist_id
GROUP BY a.artist_id, a.full_name, a.nationality
ORDER BY number_of_paintings DESC
LIMIT 5;
```

##### Identify Artists with Paintings in Multiple Countries

Finds artists whose work is displayed in museums in more than one country.

``` sql
SELECT a.full_name, COUNT(DISTINCT m.country) AS number_of_countries
FROM artist AS a
JOIN work AS w ON a.artist_id = w.artist_id
JOIN museum AS m ON w.museum_id = m.museum_id
GROUP BY a.full_name
HAVING COUNT(DISTINCT m.country) > 1
ORDER BY number_of_countries DESC;
```

#### Museum Analysis

##### Find the Top 5 Most Popular Museums

Defines popularity by the total number of paintings held by a museum

``` sql
SELECT m.museum_name, m.city, COUNT(w.work_id) AS count_of_paintings
FROM work AS w
JOIN museum AS m ON w.museum_id = m.museum_id
GROUP BY m.museum_name, m.city
ORDER BY count_of_paintings DESC
LIMIT 5;
```

##### Identify Museums Open Every Day

Finds museums that have entries for all seven days of the week in the museum_hours table.

```sql
SELECT m.museum_name, m.city
FROM museum AS m
WHERE m.museum_id IN
( 
    SELECT mh.museum_id
    FROM museum_hours AS mh
    GROUP BY mh.museum_id
    HAVING COUNT(mh.day_of_week) = 7
);
```

#### Painting & Pricing Analysis

Find the Most and Least Expensive Paintings

This query uses UNION ALL to combine two result sets, identifying both the highest and lowest-priced paintings in the database.

``` sql
(
    SELECT
        'Most Expensive' AS price_category,
        a.full_name AS artist_name,
        w.work_name,
        pd.sale_price,
        m.museum_name,
        m.city,
        cs.canvas_label
    FROM product_details AS pd
    JOIN work AS w ON pd.work_id = w.work_id
    JOIN artist AS a ON a.artist_id = w.artist_id
    JOIN museum AS m ON w.museum_id = m.museum_id
    JOIN canvas_size AS cs ON cs.size_id = pd.size_id
    ORDER BY pd.sale_price DESC
    LIMIT 1
)
UNION ALL
(
    SELECT
        'Least Expensive' AS price_category,
        a.full_name AS artist_name,
        w.work_name,
        pd.sale_price,
        m.museum_name,
        m.city,
        cs.canvas_label
    FROM product_details AS pd
    JOIN work AS w ON pd.work_id = w.work_id
    JOIN artist AS a ON a.artist_id = w.artist_id
    JOIN museum AS m ON w.museum_id = m.museum_id
    JOIN canvas_size AS cs ON cs.size_id = pd.size_id
    ORDER BY pd.sale_price ASC
    LIMIT 1
);
```

##### Find the 3 Most and Least Popular Painting Styles

Identifies painting styles with the highest and lowest number of works.

``` sql
--  Which are the 3 most popular painting styles?
SELECT w.art_style, COUNT(w.work_id) AS number_of_paintings
FROM work AS w
GROUP BY w.art_style
ORDER BY number_of_paintings DESC
LIMIT 3;

-- Which are the 3 least popular painting styles?
SELECT w.art_style, COUNT(w.work_id) AS number_of_paintings
FROM work AS w
GROUP BY w.art_style
ORDER BY number_of_paintings
LIMIT 3;
```
