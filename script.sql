
-- 1
CREATE DATABASE IF NOT EXISTS pandemic;

USE pandemic;

SELECT * FROM infectious_cases_csv;

-- 2

CREATE TABLE entities (
    id SERIAL PRIMARY KEY,
    entity VARCHAR(255) UNIQUE
);

CREATE TABLE codes (
    id SERIAL PRIMARY KEY,
    code VARCHAR(255) UNIQUE
);

CREATE TABLE infectious_cases (
    id SERIAL PRIMARY KEY,
    entity_id INT REFERENCES entities(id),
    code_id INT REFERENCES codes(id),
    year INT,
    Number_yaws INT,
	polio_cases INT,
	cases_guinea_worm INT,
    number_rabies INT,
    number_malaria INT,
    number_hiv INT,
    number_tuberculosis INT,
    number_smallpox INT,
    number_cholera_cases INT
);

INSERT INTO entities (entity)
SELECT DISTINCT entity FROM infectious_cases_csv;

INSERT INTO codes (code)
SELECT DISTINCT code FROM infectious_cases_csv;

INSERT INTO infectious_cases (entity_id, code_id, year, Number_yaws, polio_cases, cases_guinea_worm, number_rabies, number_malaria, number_hiv, number_tuberculosis, number_smallpox, number_cholera_cases)
SELECT 
    e.id, 
    c.id, 
    i.year, 
    CAST(i.Number_yaws AS DOUBLE),
    i.polio_cases,
    i.cases_guinea_worm,
    CASE WHEN i.number_rabies = '' THEN NULL ELSE CAST(i.number_rabies AS DOUBLE) END, 
    CAST(i.number_malaria AS DOUBLE),
    CAST(i.Number_hiv AS DOUBLE),
    CAST(i.Number_tuberculosis AS DOUBLE),
    CAST(i.Number_smallpox AS DOUBLE),
    CAST(i.Number_cholera_cases AS DOUBLE) 
FROM 
    infectious_cases_csv i
JOIN 
    entities e ON i.entity = e.entity
JOIN 
    codes c ON i.code = c.code;

 -- 3
SELECT 
    e.entity,
    c.code,
    AVG(number_rabies) AS avg_rabies,
    MIN(number_rabies) AS min_rabies,
    MAX(number_rabies) AS max_rabies,
    SUM(number_rabies) AS sum_rabies
FROM 
    infectious_cases ic
JOIN 
    entities e ON ic.entity_id = e.id
JOIN 
    codes c ON ic.code_id = c.id
WHERE 
    number_rabies IS NOT NULL
GROUP BY 
    e.entity, c.code
ORDER BY 
    avg_rabies DESC
LIMIT 10;

 -- 4
ALTER TABLE infectious_cases 
ADD COLUMN year_start_date DATE,
ADD COLUMN current_date_col DATE,
ADD COLUMN year_difference INTEGER;

UPDATE infectious_cases
SET 
    year_start_date = STR_TO_DATE(CONCAT(year, '-01-01'), '%Y-%m-%d'),
    current_date_col = CURRENT_DATE,
    year_difference = TIMESTAMPDIFF(YEAR, year_start_date, current_date);

-- 5

DROP FUNCTION IF EXISTS calculate_year_difference;
DELIMITER //

SELECT * FROM infectious_cases;	

CREATE FUNCTION calculate_year_difference(year_input INT) 
RETURNS INT
NO SQL
BEGIN
    DECLARE year_start DATE;
    DECLARE current DATE DEFAULT CURDATE();
    DECLARE year_diff INT;
    
    SET year_start = STR_TO_DATE(CONCAT(year_input, '-01-01'), '%Y-%m-%d');
    SET year_diff = TIMESTAMPDIFF(YEAR, year_start, current);
    
    RETURN year_diff;
END //

DELIMITER ;

 
SELECT 
    year, 
    calculate_year_difference(year) AS year_difference
FROM 
    infectious_cases;
 