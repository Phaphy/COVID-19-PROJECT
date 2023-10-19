-- Getting the percentage of death cases for Africa countries
SELECT Location,date,population,total_cases,total_deaths, 
		(cast(total_deaths as float)/cast(total_cases as float))*100 as Percentage_Death
FROM Covid_Deaths
WHERE Continent = 'Africa'
ORDER BY 1,2;
-- End


-- Getting the percentage of the infected population
SELECT Location,date,population ,total_cases,total_deaths, 
		(total_cases/population)*100 as Infected_Population_Per
FROM Covid_Deaths
WHERE Continent = 'Africa'
ORDER BY 1,2;
-- End


-- Getting the maximum number of cases for each Africa country
SELECT Location,population ,MAX(total_cases) as Hightest_Infection_Count,
	MAX((total_cases/population)*100) as Infected_Population_Per
FROM Covid_Deaths
WHERE Continent = 'Africa'
GROUP BY Location,Population
ORDER BY 4 desc;
-- Seychelles has the highest infection percentage rate
-- End


-- Getting the Countries with higest death counts in Africa
SELECT Location, MAX(cast(total_deaths as int)) as total_death_count
FROM Covid_Deaths
WHERE Continent = 'Africa'
GROUP BY location
ORDER BY 2 desc;
-- South Africa has the highest number of death cases in Africa
-- End


-- Getting the continent with the highest number of death cases
SELECT Continent,SUM(CAST(total_deaths as int)) as total_death
FROM Covid_Deaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY total_death desc;
-- Europe is the continent with the highest number of death and then the North-America
-- End


-- Global Analysis (getting the total cases, total deaths, and percentage deaths)
CREATE VIEW GLOBAL_CASES AS 
SELECT 
    date,
    SUM(new_cases) as Total_cases_per_day,
    SUM(CAST(new_deaths AS INT)) as total_deaths_per_day,
    SUM(CAST(new_deaths AS FLOAT)) / NULLIF(SUM(CAST(new_cases AS FLOAT)),0) * 100 as Death_percentage	
FROM Covid_Deaths
WHERE Continent IS NOT NULL
GROUP BY date
--ORDER BY date, Total_cases_per_day;
-- End


-- Getting the date at which the death percentage was at its maximum 
CREATE TABLE PERCENTAGE_DEATH(
date datetime, Total_cases_per_day numeric, tota_deaths_per_day numeric, Death_percentage Float)

Insert into PERCENTAGE_DEATH
SELECT 
    date,
    SUM(new_cases) as Total_cases_per_day,
    SUM(CAST(new_deaths AS INT)) as total_deaths_per_day,
    SUM(CAST(new_deaths AS FLOAT)) / NULLIF(SUM(CAST(new_cases AS FLOAT)),0) * 100 as Death_percentage	
FROM Covid_Deaths
WHERE Continent IS NOT NULL
GROUP BY date
ORDER BY date, Total_cases_per_day;

SELECT date,MAX(Death_percentage) AS Max_Death_Percentage
FROM PERCENTAGE_DEATH
GROUP BY date
ORDER BY 2 DESC;
-- On the 24th February 2020, 30% of the total recorded cases were confirmed dead.
-- End

-- Writing the same query using CTE
WITH CTE AS (
    SELECT 
        date,
        SUM(new_cases) as Total_cases_per_day,
        SUM(CAST(new_deaths AS INT)) as total_deaths_per_day,
		SUM(CAST(new_deaths AS FLOAT)) / NULLIF(SUM(CAST(new_cases AS FLOAT)),0) * 100 as Death_percentage	
    FROM Covid_Deaths
    WHERE Continent IS NOT NULL
    GROUP BY date
)
SELECT date, Death_percentage
FROM CTE
ORDER BY 2 DESC;
-- On the 24th February 2020, 30% of the total recorded cases were confirmed dead.
-- End

-- Getting the total vaccinated vs the population of the respective country
CREATE VIEW VACCINATIONS AS
WITH Vaccinated_population AS (
SELECT d.date,population, d.continent, d.location, v.new_vaccinations,
		SUM(CAST(v.new_vaccinations as bigint)) OVER 
		(PARTITION BY d.Location ORDER BY d.location,d.date) as total_vaccinations		
FROM Covid_Deaths d
JOIN Covid_Vaccination v
ON d.Location = v.Location and d.date = v.date
WHERE d.continent IS NOT NULL
)
SELECT *,total_vaccinations/Population * 100 as total_vaccinated_percentage
FROM Vaccinated_population









