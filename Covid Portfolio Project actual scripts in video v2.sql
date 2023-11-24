SELECT * FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT * FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select data that we are using 

SELECT Location,date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Order By 1,2

--Looking at total_cases vs total_deaths
--show likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deaths_percentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
Order By 1,2

--Looking at total cases vs Population 
--shows what percentage of population got covid 
SELECT Location, date, total_cases, population, (total_cases/population)*100 as person_population_infected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Order By 1,2


--Looking at Countries with highest infections rate compared to population
SELECT Location, population,  MAX(total_cases) as highest_infectedcountry, MAX((total_cases/population))*100 as person_population_infected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
Order By person_population_infected desc


--showing countries with highest deaths count per population 
SELECT Location,  MAX(cast(total_deaths as int)) as total_deaths_count
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Where continent is not null
GROUP BY location
Order By total_deaths_count desc


--Lets breake thing down by continent 
--showing continent with highest deaths count per population 
SELECT continent,  MAX(cast(total_deaths as int)) as total_deaths_count
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Where continent is not null
GROUP BY continent
Order By total_deaths_count desc


--Global Numbers  
SELECT SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
--GROUP BY date
	ORDER BY 1,2



SELECT * FROM CovidDeaths



--USE CTE

With PopvsVac(continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 
FROM PopvsVac


--TEMP TABLE

DROP Table if exists #PercentPopulationvaccinated
CREATE TABLE #PercentPopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric,
)
INSERT INTO #PercentPopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3


SELECT *, (RollingPeopleVaccinated/population)*100 
FROM #PercentPopulationvaccinated


CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL 

SELECT * FROM PercentPopulationVaccinated 