/*
Queries used for Covid-19 Project
*/


select * from CovidProject..CovidDeaths
where continent <> ''
order by 3,5

-- Select Data that we are going to be starting with

select location, date, total_cases, new_cases, total_deaths, population
from CovidProject..CovidDeaths
where continent <> ''
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, CAST(total_deaths as float)/nullif(CAST(total_cases as float),0)*100 as DeathPercentage
from CovidProject..CovidDeaths
where continent <> ''
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location, date, population, total_cases, CAST(total_cases as float)/nullif(CAST(population as float),0)*100 as PercentPopulationInfected
from CovidProject..CovidDeaths
order by 1,2

-- Countries with Highest Infection Rate compared to Population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX(CAST(total_cases as float)/nullif(CAST(population as float),0)*100) as PercentPopulationInfected
from CovidProject..CovidDeaths
group  by location, population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
from CovidProject..CovidDeaths
where continent <> ''
group by location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
from CovidProject..CovidDeaths
where continent <> ''
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

select SUM(CAST(new_cases as int)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as float))/SUM(CAST(New_Cases as float))*100 as DeathPercentage
from CovidProject..CovidDeaths
where continent <> ''
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent <> '' 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent <> ''
)
Select *, cast(RollingPeopleVaccinated as float)/nullif(cast(Population as float),0)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date nvarchar(255),
Population int,
New_vaccinations int,
RollingPeopleVaccinated int
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent <> ''


Select *, cast(RollingPeopleVaccinated as float)/nullif(cast(Population as float),0)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent <> ''
