-- =================================
-- ARTISTS TABLE
-- =================================

CREATE TABLE Artists
( 
	artist_id INT PRIMARY KEY,
	full_name VARCHAR(100),
	nationality VARCHAR(50),
	artist_style VARCHAR(50),
	birth_year INT,
	death_year INT
);

-- =================================
-- CANVAS SIZE TABLE
-- =================================

CREATE TABLE Canvas_Size
( 
	size_id INT PRIMARY KEY,
	width INT,
	height INT,
	canvas_label VARCHAR(50)
);

-- =================================
-- MUSEUM TABLE
-- =================================

CREATE TABLE Museums
( 
	museum_id INT PRIMARY KEY,
	museum_name VARCHAR(100),
	address VARCHAR(50),
	city VARCHAR(50),
	state VARCHAR(50),
	postal TEXT,
	country VARCHAR(50),
	phone VARCHAR(20),
	url TEXT
);

-- =================================
-- MUSEUM WORKING HOURS TABLE
-- =================================

CREATE TABLE Museum_Hours
( 
	museum_id INT,
	day_of_week VARCHAR(20),
	opening_time TIME,
	closing_time TIME,
	CONSTRAINT fk_museum FOREIGN KEY (museum_id) REFERENCES museums (museum_id)
);

-- =================================
-- WORK BY ARTISTS AND THE MUSEUMS TABLE
-- =================================

CREATE TABLE Works
( 
	work_id INT PRIMARY KEY,
	work_name TEXT,
	artist_id INT,
	art_style VARCHAR(50),
	museum_id INT,
	CONSTRAINT fk_artist FOREIGN KEY (artist_id) REFERENCES artists (artist_id),
	CONSTRAINT fk_museum FOREIGN KEY (museum_id) REFERENCES museums (museum_id)
);

-- =================================
-- WORKS AND SUBJECTS TABLE
-- =================================

CREATE TABLE Subjects
( 
	work_id INT,
	subject VARCHAR(50),
	CONSTRAINT fk_work FOREIGN KEY (work_id) REFERENCES works (work_id)
);

-- =================================
-- PRODUCT DETAILS TABLE
-- =================================

CREATE TABLE Product_Details
( 
	work_id INT,
	size_id INT,
	sales_price NUMERIC(10,2),
	regular_price NUMERIC(10,2),
	CONSTRAINT fk_work FOREIGN KEY (work_id) REFERENCES works (work_id)
);
