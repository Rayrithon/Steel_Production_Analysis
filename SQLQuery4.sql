--First, Selecting the largest steel producers in the world

SELECT
    *
FROM 
    steel_production
ORDER BY 
   year_2018 DESC


-- Then, deleting the coutries that don't produce steel. Also, deleting the line 'others', since it's not
-- described as a country and also because this amount, compared to the total, is insignificant;

BEGIN TRANSACTION 

DELETE
FROM 
	steel_production
WHERE 
	year_2018 = 0 OR
	year_2019 = 0 OR
	year_2020 = 0 OR
	year_2021 = 0 OR
	year_2022 = 0 OR
	Country = 'Others'

COMMIT TRANSACTION


-- Using the function ROUND in order to round the production:

BEGIN TRANSACTION

UPDATE 
	steel_production
SET
	year_2018 = ROUND(year_2018,0),
	year_2019 = ROUND(year_2019,0),
	year_2020 = ROUND(year_2020,0),
	year_2021 = ROUND(year_2021,0),
	year_2022 = ROUND(year_2022,0)
FROM steel_production

COMMIT TRANSACTION


-- Now, let's correct some countrie's name:

BEGIN TRANSACTION

UPDATE 
	steel_production
SET
	Country =
		CASE
			WHEN Country = 'Türkiye' THEN 'Turkey'
			WHEN Country = 'Taiwan, China' THEN 'Taiwan'
			WHEN Country = 'Viet Nam' THEN 'Vietnam'
			WHEN Country = 'United States' THEN 'USA'
			WHEN Country = 'Bosnia and Herzegovina' THEN 'Bosnia'
			WHEN Country = 'Czechia' THEN 'Czech Republic'
			WHEN Country = 'D.P.R. Korea' THEN 'North Korea'
		ELSE Country
	END

COMMIT TRANSACTION


-- Creating a new column describing the continent of each country:

ALTER TABLE steel_production
ADD Continent VARCHAR(50)

BEGIN TRANSACTION

UPDATE steel_production
SET Continent = 
		CASE
 
        WHEN Country IN ('Kenya','Egypt','Algeria', 'Angola', 'Ghana', 'Libya', 'Morocco', 'Nigeria', 'South Africa', 'Tanzania', 'Tunisia') 
        THEN 'Africa'

        WHEN Country IN ('Azerbaijan','Bahrain', 'Bangladesh', 'China', 'India', 'Indonesia', 'Iran', 'Iraq', 'Israel', 'Japan', 'Jordan', 'Kazakhstan', 'Kuwait', 'Malaysia', 'Myanmar', 'North Korea', 'Oman', 'Pakistan', 'Philippines', 'Qatar', 'Russia', 'Saudi Arabia', 'Singapore', 'South Korea', 'Sri Lanka', 'Syria', 'Taiwan', 'Thailand', 'Turkey', 'United Arab Emirates', 'Uzbekistan', 'Vietnam') 
        THEN 'Asia'

        WHEN Country IN ('Belarus','Austria', 'Belgium', 'Bosnia', 'Bulgaria', 'Croatia', 'Czech Republic', 'Finland', 'France', 'Germany', 'Greece', 'Hungary', 'Italy', 'Luxembourg', 'Macedonia', 'Moldova', 'Montenegro', 'Netherlands', 'Norway', 'Poland', 'Portugal', 'Romania', 'Serbia', 'Slovakia', 'Slovenia', 'Spain', 'Sweden', 'Switzerland', 'Ukraine', 'United Kingdom') 
        THEN 'Europe'

        WHEN Country IN ('Canada', 'USA', 'Mexico','Cuba','El Salvador','Guatemala','Canada', 'USA', 'Mexico','Argentina', 'Brazil', 'Chile', 'Colombia', 'Ecuador', 'Paraguay', 'Peru', 'Uruguay', 'Venezuela') 
        THEN 'America'

		WHEN Country IN ('New Zealand', 'Australia')
		THEN 'Oceania'

		END

COMMIT TRANSACTION


-- Now, using the table with the steel producers, let's answer some questions:

-- 1 - What is the corresponding percentage of each country in the total production each year?
-- 2 - Wich countries had the maximum and minimum production in the years 2018 to 2022?
-- 3 - What's the average production of each country from 2018 to 2022? Std dev as well.
-- 4 - What countries are among the top 20 steel producers?
--	   4.1 - How many of them are coastal coutries? 
--	   4.2 - Wich of these countries have iron ore deposits?
--     4.3 - How many steel production plants do these countries have?
--     4.5 - What is the per capita steel production for these countries?
--     4.6 - How does steel production relate to GDP for these countries?


-- Sum of countries outside the top 20 (equivalent to ~8% of the total production)

SELECT
	SUM(year_2018) AS sum_others_2018,
	SUM(year_2019) AS sum_others_2019,
	SUM(year_2020) AS sum_others_2020,
	SUM(year_2021) AS sum_others_2021,
	SUM(year_2022) AS sum_others_2022
FROM( 
	SELECT year_2018, year_2019, year_2020, year_2021,year_2022
	FROM steel_production
	WHERE Country NOT IN (SELECT TOP 20
				Country
				FROM steel_production
				ORDER BY year_2018 DESC)) AS top_20


-- Sum of countries that are top 20 (equivalent to ~92% of the total production)

SELECT 
	SUM(year_2018) AS sum_top_20
FROM steel_production
WHERE Country IN (SELECT TOP 20
			Country
			FROM steel_production
			ORDER BY year_2018 DESC)


-- Sum of the total production

SELECT
	SUM(year_2018) as total_2018,
	SUM(year_2019) as total_2019,
	SUM(year_2020) as total_2020,
	SUM(year_2021) as total_2021,
	SUM(year_2022) as total_2022
FROM steel_production


-- Inserting "others" row, summing production of countries outside top 20

BEGIN TRANSACTION

INSERT INTO steel_production (Id,Country, year_2018, year_2019, year_2020, year_2021, year_2022,Continent)
VALUES('1','Others', 
        (SELECT SUM(year_2018) 
         FROM steel_production
         WHERE Country NOT IN (SELECT TOP 20 Country
                               FROM steel_production
                               ORDER BY year_2018 DESC)),
        (SELECT SUM(year_2019) 
         FROM steel_production
         WHERE Country NOT IN (SELECT TOP 20 Country
                               FROM steel_production
                               ORDER BY year_2018 DESC)),
        (SELECT SUM(year_2020) 
         FROM steel_production
         WHERE Country NOT IN (SELECT TOP 20 Country
                               FROM steel_production
                               ORDER BY year_2018 DESC)),
        (SELECT SUM(year_2021) 
         FROM steel_production
         WHERE Country NOT IN (SELECT TOP 20 Country
                               FROM steel_production
                               ORDER BY year_2018 DESC)),
        (SELECT SUM(year_2022) 
         FROM steel_production
         WHERE Country NOT IN (SELECT TOP 20 Country
                               FROM steel_production
                               ORDER BY year_2018 DESC)),
		'Others'
       )

COMMIT TRANSACTION 


-- 1 - What is the corresponding percentage of each country in the total production each year?

SELECT TOP 20
	Country,
	ROUND(year_2018 / SUM(year_2018) OVER (),4)*100 AS pct_2018,
	ROUND(year_2019 / SUM(year_2019) OVER (),4)*100 AS pct_2019,
	ROUND(year_2020 / SUM(year_2020) OVER (),4)*100 AS pct_2020,
	ROUND(year_2021 / SUM(year_2021) OVER (),4)*100 AS pct_2021,
	ROUND(year_2022 / SUM(year_2022) OVER (),4)*100 AS pct_2022
FROM steel_production
GROUP BY Country, year_2018, year_2019, year_2020, year_2021, year_2022
ORDER BY pct_2018 DESC


-- 2 - Wich countries had the maximum production in the years 2018 to 2022?

SELECT
	Country,
	MAX(year_2018) AS max_2018,
	MAX(year_2019) AS max_2019,
	MAX(year_2020) AS max_2020,
	MAX(year_2021) AS max_2021,
	MAX(year_2022) AS max_2022
FROM steel_production
	WHERE 
		year_2018 = (SELECT MAX(year_2018) FROM steel_production) OR
	  	year_2019 = (SELECT MAX(year_2019) FROM steel_production) OR
		year_2020 = (SELECT MAX(year_2020) FROM steel_production) OR
		year_2021 = (SELECT MAX(year_2021) FROM steel_production) OR
		year_2022 = (SELECT MAX(year_2022) FROM steel_production)
GROUP BY Country


-- 3 - What's the average production of each country from 2018 to 2022? Median and std dev as well.

WITH top_20 AS(

	SELECT Country, Year, Production
	FROM steel_production
	UNPIVOT (
	  Production FOR Year IN (
		year_2018, 
		year_2019, 
		year_2020, 
		year_2021, 
		year_2022
	  )
	) AS unpvt
	WHERE Country IN (SELECT TOP 20 Country 
				FROM steel_production  
				WHERE Country <>'Others'
				ORDER BY year_2018 DESC))

SELECT DISTINCT 
	Country,
	AVG(Production) OVER(PARTITION BY Country) AS avg_prod_2018_2022,
	ROUND(STDEV(Production) OVER(PARTITION BY Country),1) AS st_dev_prod
FROM top_20
ORDER BY avg_prod_2018_2022 DESC

-- 4 - For countries among the top 20 steel producers:
--	   4.1 - How many of them are coastal coutries?
SELECT 
    COUNT(CASE WHEN Coastal = '1' THEN 1 ELSE NULL END) AS yes,
    COUNT(CASE WHEN Coastal = '0' THEN 1 ELSE NULL END) AS non
FROM 
    (
SELECT TOP 20 
	Country,
	CASE 
		WHEN Country IN ('China', 'India', 'Japan', 'USA', 'Russia', 'South Korea', 'Turkey', 'Brazil',
		'Italy', 'Taiwan', 'Vietnam', 'Mexico', 'France', 'Spain', 'Canada', 'Poland', 'Saudi Arabia')
		
		THEN '1'

		ELSE '0'

	END AS Coastal
FROM steel_production  
WHERE Country <>'Others'
ORDER BY year_2018 DESC) AS coastal_tab

--	   4.2 - Wich of these countries have iron ore deposits?

-- Only Germany does not have significant iron ore deposits.
-- As a major steel producer, their suppliers include Brazil, Australia and Sweden, 
-- as well as Russia and Canada.

--     4.3 - How many steel production plants do these countries have?

-- The major number of prodction plants are located in China, India, Japan, USA and Russia;
-- Those are the countries with the greatest number of production plants.

--     4.5 - What is the per capita steel production for the top 10 producers?
-- To answer this question, let's create a view table to simplify the query

CREATE VIEW top_10 AS
	SELECT TOP 10
	*
	FROM steel_production
	WHERE Country <> 'Others'
	ORDER BY year_2018 DESC
 
-- And use inner join with the country_data table - The result is on million tons per person.

SELECT
	t.Country, 
	ROUND(t.year_2018 / c.pop_2018, 2) AS per_cap_2018,
	ROUND(t.year_2019 / c.pop_2019, 2) AS per_cap_2019,
	ROUND(t.year_2020 / c.pop_2020, 2) AS per_cap_2020,
	ROUND(t.year_2021 / c.pop_2021, 2) AS per_cap_2021,
	ROUND(t.year_2022 / c.pop_2022, 2) AS per_cap_2022
FROM top_10 AS t
INNER JOIN country_data AS c
	ON t.Country = c.Country
ORDER BY per_cap_2018 DESC

-- Which continent has the highest number of producing countries?

SELECT
	Continent,
	COUNT(
		CASE WHEN Continent = 'Asia' THEN 1 
		     WHEN Continent = 'Europe' THEN 1 
		     WHEN Continent = 'America' THEN 1 
		     WHEN Continent = 'Oceania' THEN 1 
		     WHEN Continent = 'Africa' THEN 1 
		 END) AS numb_of_prod
FROM steel_production
WHERE Continent <> 'Others'
GROUP BY Continent
ORDER BY numb_of_prod DESC


--     4.6 - How does steel production relate to GDP for the countries among top 10? 

--- Creating view table for GDP. In this case, I used Pearson Correlation in order to identify if there is a relationship 
-- between the GDP and the amount of steel production. It is importante to emphasize that this may not be the appropriate method,
-- specially because it needs more data in order to deliver a good coeficient.

CREATE VIEW avg_stdev_gdp AS

	SELECT Country, Year, GDP
	FROM country_gdp
	UNPIVOT (
	  GDP FOR Year IN (
		gdp_2018, 
		gdp_2019, 
		gdp_2020, 
		gdp_2021, 
		gdp_2022
	  )
	) AS unpvt
	

--- Creating view table for Production

CREATE VIEW avg_stdev_prod AS

	SELECT Country, Year, Production
	FROM steel_production
	UNPIVOT (
	  Production FOR Year IN (
		year_2018, 
		year_2019, 
		year_2020, 
		year_2021, 
		year_2022
	  )
	) AS unpvt
	WHERE Country IN (SELECT TOP 10 Country 
					  FROM steel_production  
					  WHERE Country <>'Others'
					  ORDER BY year_2018 DESC)

--Joining the last 2 view tables in order to create a new one


CREATE VIEW pearson_corr AS 
	SELECT
		g.Country,
		p.Production - AVG(p.Production) OVER(PARTITION BY g.Country) AS d1,
		g.GDP - AVG(g.GDP) OVER(PARTITION BY g.Country) AS d2
	FROM avg_stdev_gdp AS g
		INNER JOIN avg_stdev_prod p ON g.Country = p.Country AND REPLACE(g.Year, 'gdp_', '') = REPLACE(p.Year, 'year_', '')
	;
	

SELECT DISTINCT
	Country,
	ROUND(ABS(num/SQRT(den * den_2)),2) AS Pearson_corr
FROM (SELECT
	  Country,
	  SUM(d1*d2) OVER (PARTITION BY Country) AS num,
	  SUM(POWER(d1,2)) OVER (PARTITION BY Country) AS den,
	  SUM(POWER(d2,2)) OVER (PARTITION BY Country) AS den_2
	  FROM pearson_corr) AS tab_2
ORDER BY Pearson_corr DESC




