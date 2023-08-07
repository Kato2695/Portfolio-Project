SELECT *
FROM PortfolioProject..CovidDeaths$
where continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

-- select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
order by 1,2

-- Looking at total cases vs total deaths
-- shows probability of dying if you contract covid

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
where location like '%United Kingdom%'
order by 1,2

-- totals cases vs population 
-- shows what pecentage of population got covid

SELECT location, date, population total_cases, (total_cases/population)*100 as CovidPercentage
FROM PortfolioProject..CovidDeaths$
where location like '%United Kingdom%'
order by 1,2

-- countries with highest infection rate vs population

SELECT location, population, max(total_cases) as InfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
where continent is not null
Group by location, population
order by PercentPopulationInfected desc

-- Countries with highest death count

SELECT location, MAX(cast(total_deaths as int)) as DeathCount
FROM PortfolioProject..CovidDeaths$
where continent is not null
Group by location, population
order by DeathCount desc

-- breaking out by continent instead of location 

SELECT continent, MAX(cast(total_deaths as int)) as DeathCount
FROM PortfolioProject..CovidDeaths$
where continent is not null
Group by continent
order by DeathCount desc

-- Location with highest death count vs population

SELECT location, MAX(cast(total_deaths as int)) as DeathCount, max(population) as TotalPopulation
FROM PortfolioProject..CovidDeaths$
where continent is not null
Group by location
order by DeathCount desc

-- Global N# by date

SELECT date, sum(new_cases) as Cases, sum(cast(new_deaths as int)) as Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2

-- Global N# summed

SELECT sum(new_cases) as Cases, sum(cast(new_deaths as int)) as Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
where continent is not null
--group by date
order by 1,2

-- adding in Vaccination data
-- looking at total population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidDeaths$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- adding a sum function to add up total new vaccinations per day

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Count_of_Vaccinations
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidDeaths$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- CTE

with PopvsVacc (Continent, Location, Date, Population, New_Vaccinations, Count_of_Vaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Count_of_Vaccinations
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidDeaths$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (Count_of_Vaccinations/Population)*100 as PercentageVaccinated
from PopvsVacc
order by 2,3

-- Temp Table

drop table if exists PercentPopulationVaccinated
Create table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_Vaccinations numeric, 
Count_of_Vaccinations numeric
)

Insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Count_of_Vaccinations
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidDeaths$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (Count_of_Vaccinations/Population)*100 as PercentageVaccinated
from PercentPopulationVaccinated
order by 2,3

-- creating views for future visulisations

create view PopulationVaccinatedPercentage as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Count_of_Vaccinations
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidDeaths$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * 
from PopulationVaccinatedPercentage
order by 2,3
