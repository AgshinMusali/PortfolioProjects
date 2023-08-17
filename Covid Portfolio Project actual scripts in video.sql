select * 
from PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Alter Table PortfolioProject..CovidDeaths
--Alter COLUMN [total_deaths] int
--Alter Column [total_cases] int


--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4


-- Select Data that we are going to be using 


Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2


--Looking at Total Cases vs Total Deaths 
--Shows likelihood of dying if you contract in your country

Select Location, date, total_cases, total_deaths, (CONVERT(FLOAT, total_deaths) / CONVERT(FLOAT, total_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2


--Looking at Total Cases vs Population 
--Shows what percentage of population got Covid

Select Location, date, population, total_cases, (CONVERT(FLOAT, total_cases) / CONVERT(FLOAT, population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Order by 1,2



--Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((CONVERT(FLOAT, total_cases) / CONVERT(FLOAT, population)))*100
as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, population
Order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population 

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc



--Let's break things down by continent


--showing continents with the highest death count per population 

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc



-- global numbers 


Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
where continent is not null
group by date
Order by 1,2



SELECT  
       SUM(new_cases) as total_cases, 
       SUM(new_deaths) as total_deaths, 
       CASE WHEN SUM(new_cases) <> 0   
	   THEN (SUM(new_deaths) / SUM(new_cases)) * 100 
            ELSE 0 
       END as DeathPercentage
FROM PortfolioProject..CovidDeaths
-- Where location like '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2



--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
 dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3




--USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
 dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location  
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac






--Temp Table


drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
 dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location  
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



--Creating View to store data for later visualizations 

Create View PercentPopulationVaccinated as  
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
 dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location  
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3



Select* 
from PercentPopulationVaccinated
 