/*
Queries used for Covid-19 Project
*/



-- Global Numbers Deaths

select SUM(CAST(new_cases as int)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as float))/SUM(CAST(New_Cases as float))*100 as DeathPercentage
from CovidProject..CovidDeaths
-- Where location like '%states%'
where continent <> ''
-- Group By date
order by 1,2


-- Showing continents with the highest death count per population
-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
--Where location like '%states%'
Where continent = ''
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- Countries with Highest Infection Rate compared to Population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX(CAST(total_cases as float)/nullif(CAST(population as float),0))*100 as PercentPopulationInfected
from CovidProject..CovidDeaths
-- where location like '%pakistan%'
group  by location, population
order by PercentPopulationInfected desc


-- Countries with Highest Infection Count and Percentage Population Infected by date 

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  MAX(CAST(total_cases as float)/nullif(CAST(population as float),0))*100 as PercentPopulationInfected
From CovidProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc

-- Global Numbers Vaccinations

select MAX(cast(people_fully_vaccinated as float)) as PeopleFullyVaccinated, MAX(cast(people_vaccinated as float)) as PeopleRecievedFirstDose, MAX(cast(people_fully_vaccinated as float))/MAX(CAST(population as float))*100 as PercentageFullyVaccinated, MAX(CAST(people_vaccinated as float))/MAX(CAST(population as float))*100 as PercentageRecievedFirstDose
from CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
on dea.location = vac.location
order by 1,2

-- Showing contintents with the vaccinations count per population

select continent, MAX(cast(people_fully_vaccinated as float)) as PeopleFullyVaccinated, MAX(cast(people_vaccinated as float)) as PeopleRecievedFirstDose
from CovidProject..CovidVaccinations
where continent <> ''
group by continent
order by PeopleFullyVaccinated desc, PeopleRecievedFirstDose desc 

-- Countries with vaccinations count compared to Population

select vac.location, population, MAX(cast(people_fully_vaccinated as float)) as PeopleFullyVaccinated, MAX(cast(people_vaccinated as float)) as PeopleRecievedFirstDose, MAX(cast(people_fully_vaccinated as float))/nullif(MAX(CAST(population as float)),0)*100 as PercentageFullyVaccinated, MAX(CAST(people_vaccinated as float))/nullif(MAX(CAST(population as float)),0)*100 as PercentageRecievedFirstDose
from CovidProject..CovidVaccinations vac
join CovidProject..CovidDeaths dea
on dea.location = vac.location
group  by vac.location, population
order by PeopleFullyVaccinated desc, PeopleRecievedFirstDose desc

