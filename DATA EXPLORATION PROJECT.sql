SELECT *
FROM PortfolioProject..CovidDeaths$
--WHERE continent IS NOT NULL
ORDER BY 3, 4

SELECT *
FROM PortfolioProject..CovidVaccinations$
--WHERE continent IS NOT NULL
ORDER BY 3, 4


-- Total cases vs Total deaths in United State Per day.

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS Deathpercenttage
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%states'
	AND continent IS NOT NULL
ORDER BY 1, 2;


-- Percentage of Population That contacted Covid per day

SELECT location, date, population, total_cases, (total_cases/population) * 100 AS PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 2,3;


-- Country With The Highest Infection Rate Compared To Population.

CREATE VIEW HighestInfected AS
SELECT date, continent, location, population,
	SUM(new_cases) OVER (PARTITION BY location)sumcase
FROM PortfolioProject..CovidDeaths$

SELECT location, (sumcase/population) * 100 as PercentCasePopulation
FROM HighestInfected
WHERE continent IS NOT NULL
GROUP BY continent, location, population, sumcase
ORDER BY 2 DESC


-- Country With The Highest Death Count per Population.

SELECT continent, location,population,SUM(CAST(new_deaths AS INT)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, continent,population
ORDER BY 4 DESC;


-- Continent With The Highest Death Count

WITH ContMaxDeath (continent, date, HighestDeathCount,maxDeathCount)
AS
(SELECT continent, date,
	SUM(CAST(new_deaths AS INT)) OVER (PARTITION BY continent ORDER BY location,date) AS HighestDeathCount,
	MAX(CAST(new_deaths AS INT)) OVER (PARTITION BY continent ) maxDeathCountInADayPerCont
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL)
SELECT *, MAX(HighestDeathCount) OVER (PARTITION BY continent ORDER BY date) HighestDeathPerContinent
FROM ContMaxDeath
ORDER BY 5 DESC


-- Total Death Rate Across The Globe

SELECT SUM(new_cases) AS GlobalCasesPerDay, SUM(CAST(new_deaths AS INT)) AS GlobalDeathPerDay, 
	(SUM(CAST(new_deaths AS INT))/SUM(new_cases)) * 100 AS TotalDeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL


-- Total Population vs Vaccinations for each country

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER 
		(PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location= vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1, 2, 3


-- CTE To Get the Population Vs The Total Rate vaccinated per country.

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER 
		(PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location= vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, ROUND((RollingPeopleVaccinated/Population) * 100,2) AS PercentRollingPeopleVaccinated
FROM PopVsVac
ORDER BY 1,2, 3


-- TEMP TAB To Get the Population Vs The Total Rate vaccinated per country.

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER 
		(PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location= vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 1, 2, 3

SELECT *, ROUND((RollingPeopleVaccinated/ population) *100,2) shii
FROM #PercentPopulationVaccinated
ORDER BY 1, 2;


-- CREATE VIEW To Get the Population Vs The Total Rate vaccinated per country.

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER 
		(PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location= vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 1, 2, 3
