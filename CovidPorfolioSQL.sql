SELECT *
FROM PortfolioProjects..CovidDeaths
WHERE continent is not null

SELECT *
FROM PortfolioProjects..CovidVaccinations
WHERE continent is not null

-- select specific data to work with
SELECT cast(location as NVARCHAR(100)) location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects..CovidDeaths
WHERE continent is not null
Order BY cast(location as NVARCHAR(100)), date 

-- looking at total cases vs total deaths in the U.S
-- shows likelihood of dying if you contract COVID in the U.S
SELECT cast(location as NVARCHAR(100)) location, date, total_cases, total_deaths, (total_deaths*1.0/total_cases)*100 as DeathRate
FROM PortfolioProjects..CovidDeaths
WHERE location like '%states%' and continent is not null
Order BY cast(location as NVARCHAR(100)), date

-- looking at total cases vs population
-- shows what percentage of the population contracted covid
SELECT cast(location as NVARCHAR(100)) location, date, population, total_cases, (total_cases*1.0/population)*100 as CovidPercentage 
FROM PortfolioProjects..CovidDeaths
WHERE location like '%states%' and continent is not null
Order BY cast(location as NVARCHAR(100)), date

--looking at countries with highest infection rate compared to population
SELECT cast(location as NVARCHAR(100)) location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases*1.0/population))*100 as PercentPopulationInfected 
FROM PortfolioProjects..CovidDeaths
GROUP BY cast(location as NVARCHAR(100)), population
Order BY PercentPopulationInfected desc

-- showing countries with highest death count by population
SELECT cast(location as NVARCHAR(100)) location, population, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent is not null
GROUP BY cast(location as NVARCHAR(100)), population
Order BY TotalDeathCount desc

--showing continents with highest death count
SELECT cast(continent as NVARCHAR(100)) continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent is not null
GROUP BY cast(continent as NVARCHAR(100))
Order BY TotalDeathCount desc

-- Global numbers
SELECT date, total_cases, total_deaths, (total_deaths*1.0/total_cases)*100 as DeathRate
FROM PortfolioProjects..CovidDeaths
WHERE continent is not null
Order BY date

-- joining both tables
SELECT *
FROM PortfolioProjects..CovidDeaths AS dea
Join PortfolioProjects..CovidVaccinations AS vac 
    on cast(dea.location as NVARCHAR(100)) = cast(vac.location as NVARCHAR(100))
    and dea.date = vac.date

-- looking at total population vs vaccinations
-- Use CTE
With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    sum(vac.new_vaccinations) over (partition by cast(dea.location as NVARCHAR(100)) 
    order by cast(dea.location as NVARCHAR(100)), dea.date) as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths AS dea
Join PortfolioProjects..CovidVaccinations AS vac 
    on cast(dea.location as NVARCHAR(100)) = cast(vac.location as NVARCHAR(100))
    and dea.date = vac.date
Where dea.continent is not NULL
--order by cast(dea.location as NVARCHAR(100)), dea.date
)
Select *, (RollingPeopleVaccinated*1.0/population)*100
From PopvsVac

-- Temp Table
DROP TABLE if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent NVARCHAR(100), 
Location NVARCHAR(100), 
Date date, 
Population NUMERIC, 
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    sum(vac.new_vaccinations) over (partition by cast(dea.location as NVARCHAR(100)) 
    order by cast(dea.location as NVARCHAR(100)), dea.date) as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths AS dea
Join PortfolioProjects..CovidVaccinations AS vac 
    on cast(dea.location as NVARCHAR(100)) = cast(vac.location as NVARCHAR(100))
    and dea.date = vac.date
Where dea.continent is not NULL
--order by cast(dea.location as NVARCHAR(100)), dea.date

Select *, (RollingPeopleVaccinated*1.0/population)*100
From #PercentPopulationVaccinated

-- Creating view to store for data visualizations
Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    sum(vac.new_vaccinations) over (partition by cast(dea.location as NVARCHAR(100)) 
    order by cast(dea.location as NVARCHAR(100)), dea.date) as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths AS dea
Join PortfolioProjects..CovidVaccinations AS vac 
    on cast(dea.location as NVARCHAR(100)) = cast(vac.location as NVARCHAR(100))
    and dea.date = vac.date
Where dea.continent is not NULL
--order by cast(dea.location as NVARCHAR(100)), dea.date