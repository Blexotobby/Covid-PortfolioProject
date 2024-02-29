SELECT *
FROM PortfolioProject..CovidDeath

SELECT *
FROM PortfolioProject..Covidvacination


/* Select the needed columns of DAta*/
SELECT location, date, total_cases, total_deaths,population
FROM PortfolioProject..CovidDeath
ORDER BY 1,2

/*to Determine DeathPrecentage, Total Cases VS Total Death*/
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS DeathPrecentage
FROM PortfolioProject..CovidDeath
ORDER BY 1,2

/* to Determine DeathPercentage, Total cases Vs Total Death from specfic location*/
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS DeathPrecentage
FROM PortfolioProject..CovidDeath
WHERE location = 'Africa'
ORDER BY 1,2


/* Looking At percentage of population affected by covid*/
SELECT location, date, total_cases, population, (total_cases/population)*100 As AffectedPoulationPrecent
FROM PortfolioProject..CovidDeath
Order BY 1,2

/* Looking At percentage of population affected by covid specfic loaction*/
SELECT location, date, total_cases, population, (total_cases/population)*100 As AffectedPoulationPrecent
FROM PortfolioProject..CovidDeath
WHERE location='Africa'
Order BY 1,2


/* Looking At country with highestinfection rate compared with pouplation*/
SELECT location,  population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 As PrecentPopulationInfected
FROM PortfolioProject..CovidDeath
GROUP BY location,population 
Order BY PrecentPopulationInfected DESC

-- Showing Countries with highest Death count per population
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
GROUP BY location
Order BY TotalDeathCount DESC

-- LET BREAK THINGS DOWN BY CONTIENET
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
GROUP BY continent
Order BY TotalDeathCount DESC


SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeath
WHERE continent IS  NULL
GROUP BY location
Order BY TotalDeathCount DESC

--Global Numbers  by Dates
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathprecentage
FROM PortfolioProject..CovidDeath

--- Global Numbers 
Select SUM(new_cases) As Total_cases, SUM(new_deaths) AS Total_Deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPrecentage
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL

-- Looking At Total Population VS Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
FROM PortfolioProject..CovidDeath AS dea
	JOIN PortfolioProject..Covidvacination AS vac
	ON dea.continent=vac.continent
	AND dea.date=vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY 2,3

	--- Looking At Total Population showing the Progression of Vacinnation
	SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition BY dea.location ORDER BY dea.location,dea.date) 
	AS RollingPeoplevacinated
FROM PortfolioProject..CovidDeath AS dea
	JOIN PortfolioProject..Covidvacination AS vac
	ON dea.continent=vac.continent
	AND dea.date=vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY 2,3

--Cerating A TempTable
DROP TABLE if exists #PrecentPOpulationVaccinated
CREATE  TABLE #PrecentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PrecentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location,dea.date) 
	AS RollingPeoplevacinated
FROM PortfolioProject..CovidDeath AS dea
	JOIN PortfolioProject..Covidvacination AS vac
	ON dea.continent=vac.continent
	AND dea.date=vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY 2,3



	SELECT *, (RollingPeopleVaccinated/Population)*100
	FROM #PrecentPopulationVaccinated


	--Cerating A View For Later Visualization
	CREATE VIEW PrecentPopulationVaccinate
	AS
	SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location,dea.date) 
	AS RollingPeoplevacinated
FROM PortfolioProject..CovidDeath AS dea
	JOIN PortfolioProject..Covidvacination AS vac
	ON dea.continent=vac.continent
	AND dea.date=vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3


	SELECT *
	FROM PrecentPopulationVaccinate