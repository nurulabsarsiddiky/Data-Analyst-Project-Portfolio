
/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


select * 
From Project_Covid19..CovidDeaths
where continent is not null
order by 3,4




-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From Project_Covid19..CovidDeaths
order by 1,2




-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Project_Covid19..CovidDeaths
Where Location like '%states%' AND continent is not null
order by 1,2




-- Looking at Total Cases vs population
-- shows what percentage of population got COVID

Select Location, date, population, total_cases,  (total_cases/population)*100 as InfectionPercentage
From Project_Covid19..CovidDeaths
where continent is not null
--Where Location like '%states%'
order by 1,2




-- Looking at Countries with Highest Infection rate Compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount ,  Max((total_cases/population))*100 as InfectionPercentage
From Project_Covid19..CovidDeaths
--Where Location like '%states%'
where continent is not null
Group by Location, population
order by InfectionPercentage DESC





-- Showing countries with highest death count per population

Select Location,  MAX(cast(total_deaths as int)) as TotalDeathCount
From Project_Covid19..CovidDeaths
where continent is not null
--Where Location like '%states%'
Group by Location
order by TotalDeathCount DESC




-- Lets break things down by continent
-- Showing contintents with the highest death count per population

Select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
From Project_Covid19..CovidDeaths
where continent is not null
--Where Location like '%states%'
Group by continent
order by TotalDeathCount DESC




-- Global Numbers
Select date, SUM(new_cases)as Total_cases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From Project_Covid19..CovidDeaths
where continent is not null
--Where Location like '%states%'
Group by date
order by 1, 2





-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) over ( Partition by dea.Location  order by dea.location, dea.date) as RollingPeopleVaccinated 
From Project_Covid19..CovidDeaths as dea
JOIN Project_Covid19..CovidVaccinations as vac
ON dea.location= vac.location
and dea.date=vac.date
WHERE dea.continent is not null
order by 2, 3





-- Using CTE to perform Calculation on Partition By in previous query

With PopVsVac (continent,location,date, population, new_vaccinations, RollingPeopleVaccinated )
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) over ( Partition by dea.Location  order by dea.location, dea.date) as RollingPeopleVaccinated 
From Project_Covid19..CovidDeaths as dea
JOIN Project_Covid19..CovidVaccinations as vac
ON dea.location= vac.location
and dea.date=vac.date
WHERE dea.continent is not null
--order by 2, 3
)

Select *, (RollingPeopleVaccinated/population)*100
From PopVsVac 




-- Using Temp Table to perform Calculation on Partition By in previous query
 
 DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) over ( Partition by dea.Location  order by dea.location, dea.date) as RollingPeopleVaccinated 
From Project_Covid19..CovidDeaths as dea
JOIN Project_Covid19..CovidVaccinations as vac
ON dea.location= vac.location
and dea.date=vac.date
--WHERE dea.continent is not null
order by 1,2

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated 




--- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) over ( Partition by dea.Location  order by dea.location, dea.date) as RollingPeopleVaccinated 
From Project_Covid19..CovidDeaths as dea
JOIN Project_Covid19..CovidVaccinations as vac
ON dea.location= vac.location
and dea.date=vac.date
WHERE dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated
 
