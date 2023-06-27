-- Looking at Total deaths and Total cases to find the percentage of death when getting Covid
-- Show likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float)*100)
from CovidDeaths
where location like '%state%'
and continent is not null
order by 1,2

-- Looking at Total deaths and Total cases
-- Show what percentage of population got Covid
select location, date, total_cases, population, (cast(total_cases as float)/cast(population as float)*100) as DeathPercentage
from CovidDeaths
where continent is not null
--where location like '%state%'
order by 1,2


-- What country got the highest infection rate comparing to population
select location, population, max(total_cases) as HighestInfectionCount, 
Max(cast(total_cases as float)/cast(population as float))*100 as PercentagePopulationInfected
from CovidDeaths
where continent is not null
--where location like '%state%'
group by location,population
order by PercentagePopulationInfected desc

-- Showing Countries with Highest Death Count per Population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- Let's break thing down by continent
--Showing the continent with the highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- 1
select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths
,SUM(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as DeathPercentage
from CovidDeaths
--where location like '%state%'
where continent is not null
and new_cases > 0
--group by date
order by 1,2

-- 2

-- We take thes out as they are not included in the above queries and want to stay consistent
-- Eutopean Union is part of Europe

select location, Sum(cast(new_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is null
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 
'Lower middle income', 'Low income')
group by location
order by TotalDeathCount desc

-- 3
select location, population, max(total_cases) as HighestInfectionCount, 
Max(cast(total_cases as float)/cast(population as float))*100 as PercentagePopulationInfected
from CovidDeaths
--where location like '%state%'
group by location,population
order by PercentagePopulationInfected desc

-- 4
select location, population, date, max(total_cases) as HighestInfectionCount, 
Max(cast(total_cases as float)/cast(population as float))*100 as PercentagePopulationInfected
from CovidDeaths
--where location like '%state%'
group by location,population,date
order by PercentagePopulationInfected desc


-- Looking at total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations as NewVaccinationPerDay
, SUM(convert(float, vac.new_vaccinations)) over (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/dea.population)*100
From PortfolioProject..CovidDeaths dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE
with PopvsVac (Continent, Locatopn, Date, Population,NewVaccinationPerDay, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations as NewVaccinationPerDay
, SUM(convert(float, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac
order by 2,3


--TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations as NewVaccinationPerDay
, SUM(convert(float, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations as NewVaccinationPerDay
, SUM(convert(float, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated
order by 2,3