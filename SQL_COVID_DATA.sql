SELECT *
FROM PortfolioProject..covidDeaths
WHERE continent is not null
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..covidVaccinations
--WHERE continent is not null
--ORDER BY 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covidDeaths
WHERE continent is not null
ORDER BY 1, 2

-- Changed datatype of the column to deal with null values

Alter TABLE PortfolioProject..covidDeaths
ALTER column total_cases FLOAT

-- Looking at total Cases vs total Deaths
--Shows the Likelihood of dying in case of contact of covid

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Per_of_deaths
FROM PortfolioProject..covidDeaths 
WHERE location like '%india' AND continent is not null
ORDER BY 1, 2


--Looking at Total Cases vs Population
-- Shows what percentage of Population got affected by Covid

SELECT location, date,  population , total_cases, (total_cases/population)*100 AS AffectPercentage
FROM PortfolioProject..covidDeaths
WHERE location like '%india' AND continent is not null
ORDER BY 1, 2


-- Looking at Countries with Highest Infection Rate as compared to population

SELECT location, population , MAX(total_cases) AS HighestInfectionCount , MAX((total_cases/population))*100 AS HighestCovidPercentage
FROM PortfolioProject..covidDeaths
--WHERE location like '%india' AND continent is not null
GROUP BY location, population
ORDER BY 4 DESC


-- Showing Countries with Highest Death Count / Population

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeaths
FROM PortfolioProject..covidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeaths DESC


-- STATS BY CONTINENT

--CONTINENTS with highest Death Count

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeaths
FROM PortfolioProject..covidDeaths
WHERE continent is NOT null
GROUP BY continent
ORDER BY TotalDeaths DESC

-- Global Numbers Count 

SELECT  SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS Total_Deaths, SUM(new_deaths)/SUM(NULLIF(new_cases,0))*100 AS Per_of_NewDeath
FROM PortfolioProject..covidDeaths 
--WHERE location like '%india' 
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2

-- Getting info from Covid Vaccinations Dataset
-- Joining both two tables and Looking at Total Population and Vaccination

SELECT de.continent, de.location, de.date, de.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY de.location ORDER BY de.location, de.date) AS TotalVaccinationTillDate
FROM PortfolioProject..covidDeaths de
JOIN PortfolioProject..covidVaccinations vac
ON de.location = vac.location 
AND de.date = vac.date
WHERE de.continent is not null
ORDER BY 2,3 



--USE CTE

WITH PopvsVac( continent, location, date, population, New_Vaccinations, TotalVaccinationTillDate)
AS
(
SELECT de.continent, de.location, de.date, de.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY de.location ORDER BY de.location, de.date) AS TotalVaccinationTillDate
FROM PortfolioProject..covidDeaths de
JOIN PortfolioProject..covidVaccinations vac
ON de.location = vac.location 
AND de.date = vac.date
WHERE de.continent is not null
--ORDER BY 2,3
)
SELECT *, (TotalVaccinationTillDate/population)*100 
FROM PopvsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
TotalVaccinationTillDate numeric
)


INSERT INTO #PercentagePopulationVaccinated

SELECT de.continent, de.location, de.date, de.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY de.location ORDER BY de.location, de.date) AS TotalVaccinationTillDate
FROM PortfolioProject..covidDeaths de
JOIN PortfolioProject..covidVaccinations vac
ON de.location = vac.location 
AND de.date = vac.date
--WHERE de.continent is not null
--ORDER BY 2,3

SELECT *, (TotalVaccinationTillDate/population)*100 
FROM #PercentagePopulationVaccinated




-- Creating View to store data for Visualization


CREATE VIEW PercentagePopulationVaccinated AS 
SELECT de.continent, de.location, de.date, de.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY de.location ORDER BY de.location, de.date) AS TotalVaccinationTillDate
FROM PortfolioProject..covidDeaths de
JOIN PortfolioProject..covidVaccinations vac
ON de.location = vac.location 
AND de.date = vac.date
WHERE de.continent is not null
--ORDER BY 2,3


SELECT *
FROM PercentagePopulationVaccinated