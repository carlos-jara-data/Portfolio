-- Base data to be used

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent = 'South America'
order by 1,2

-- Total cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where continent = 'South America'
Group by Location, date, total_cases, total_deaths
Order by 1,2

-- Total Cases vs Population

Select location, date, total_cases, population, (total_cases/population) *100 as InfectionPercentage
From CovidDeaths
Where continent = 'South America'
Group by location, date, total_cases, population
order by 1,2

-- Highest Infection rate


Select location, population, max(total_cases) as HighestInfectionCount, max((Total_cases)/population)*100 as PercentPopulationInfected
From CovidDeaths
Where continent = 'South America'
Group by location, population
Order by 4 Desc

-- Highest death rate

Select location, population, max(total_deaths) as HighestDeathCount, MAX((total_deaths)/population)*100 as PercentagePopulationDeath
From CovidDeaths
Where continent = 'South America'
Group by location, population
Order by 4 desc

-- Highest Death Count

Select location, MAX(total_deaths) as HighestDeathCount
From CovidDeaths
Where continent = 'South America'
Group By location
Order By 2 Desc

-- Highest Death Count by continent


Select continent, location, MAX(total_deaths) TotalDeathCount
From CovidDeaths
Where continent is not null
Group By continent, location
Having MAX(total_deaths) is not null
Order By 1,3 Desc

--Global Numbers

Select date, MAX(total_cases), MAX(total_deaths), (MAX(total_deaths)/MAX(total_cases))*100 DeathPercentage
From CovidDeaths
Where continent is not null
Group By date
Order By 1

-- JOIN VAC

Select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location, dea.date) PeopleVac
From CovidDeaths dea
Join CovidVacs vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent = 'South America'

--CTE

With PopvsVac(continent,location,date, population, new_vaccionations, PeopleVac)
as (
Select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location, dea.date) PeopleVac
From CovidDeaths dea
Join CovidVacs vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent = 'South America'
)
Select * , (PeopleVac/population) *100
From PopvsVac

--TEMP TABLE

Drop Table if exists #PopvsVac
Create Table #PopvsVac(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccionation numeric,
PeopleVac numeric,
)

Insert into #PopvsVac
Select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location, dea.date) PeopleVac
From CovidDeaths dea
Join CovidVacs vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent = 'South America'

Select * , (PeopleVac/population) *100
From #PopvsVac

-- VIEW

Drop View if Exists PopvsVac

Create View PopvsVac as
Select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location, dea.date) PeopleVac
From CovidDeaths dea
Join CovidVacs vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent = 'South America'

Select * from PopvsVac