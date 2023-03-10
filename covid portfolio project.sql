select* 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select*
--from PortfolioProject..[Covid vaccinations]
--order by  3,4

-- select data that we are going to be using


select location, date, total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by  1,2


-- look at the total case vs total deaths

-- shows likelihood of dying if you contract covid in your country

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
where continent is not null
order by  1,2


--looking at total cases vs population
-- shows what percetage of population got covid



select location, date, population,total_cases, (total_cases/population)*100 as PopulationPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by  1,2


-- looking at countries with highest infection rate compare with population

select location, population, max(total_cases) as highestInfectioncount, max((total_cases/population))*100 as 
  percentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by  percentPopulationInfected desc




--showing with the highest death count per population

select location,max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by   totaldeathcount desc

--showing continents with the highest death count per population

select continent,max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by   totaldeathcount desc

--Global numbers

select  sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths , sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by  1,2


--Looking at total population vs vaccination, which has been the total people in the world that has been vaccinated 

select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations,
	sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/Population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..[Covid vaccinations] vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--use CTE


WITH PopvsVac (continent,location, Date, Population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations,
	sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/Population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..[Covid vaccinations] vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)

select*, (RollingPeopleVaccinated/population)*100
from popvsVac


-- Creating temp table
drop table if exists #percentPopulationVaccinated
create table #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #percentPopulationVaccinated

select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations,
	sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/Population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..[Covid vaccinations] vac
	on dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select*, (RollingPeopleVaccinated/population)*100
from #percentPopulationVaccinated



--creating view to store data for later visualizations

create view percentPopulationVaccinated as
select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations,
	sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/Population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..[Covid vaccinations] vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select*
from percentPopulationVaccinated
