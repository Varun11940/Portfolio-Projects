-- Selecting all records from CovidDeaths table where continent is not null and ordering by columns 3 and 4
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 3, 4;

-- Selecting specific columns from CovidDeaths table where continent is not null and ordering by location and date
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1, 2;

-- Calculating death percentage based on total cases and total deaths in countries with 'states' in their name
SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%' AND continent IS NOT NULL 
ORDER BY 1, 2;

-- Calculating percentage of population infected with Covid
SELECT Location, date, population, total_cases, (total_cases / population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2;

-- Finding countries with the highest infection rate compared to population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;

-- Finding countries with the highest death count per population
SELECT Location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY Location
ORDER BY TotalDeathCount DESC;

-- Showing continents with the highest death count per population
SELECT continent, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Calculating global Covid numbers
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT)) / SUM(New_Cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL;

-- Calculating percentage of population that has received at least one Covid vaccine
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS
(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
    FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL 
)
SELECT *, (RollingPeopleVaccinated / Population) * 100
FROM PopvsVac;

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP TABLE IF EXISTS #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *, (RollingPeopleVaccinated / Population) * 100
FROM #PercentPopulationVaccinated;

-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
