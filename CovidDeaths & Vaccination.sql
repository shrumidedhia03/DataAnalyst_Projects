select * from ..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

--select * from ..CovidVaccinations
--ORDER BY 3,4

--data we will use 
select location, date, total_cases, new_cases, total_deaths, population
From ..CovidDeaths
ORDER BY 1,2

--looking at total cases vs total deaths 
--shows likelihood of dying from covid in a your country 
select location, date, total_cases, total_deaths, (CONVERT(FLOAT, total_deaths)/total_cases)*100 as DeathPercentage
From ..CovidDeaths
where location like '%states'
ORDER BY 1,2

--Looking at total cases vs population 
--Shows what percentage of population got covid
select location, date, population, total_cases, (CONVERT(FLOAT, total_cases)/population)*100 as PercentPoulationInfected
From ..CovidDeaths
--where location like '%india'
ORDER BY 1,2

--Countries with highest infection rate in comparison to population
select location, population, max(total_cases) as Highest_Infection_Count, max((CONVERT(FLOAT, total_cases)/population))*100 as PercentPoulationInfected
From ..CovidDeaths
GROUP by location, population
ORDER BY PercentPoulationInfected DESC

--Countries with highest deaths per population
select location, max(total_deaths) as TotalDeathCount
From ..CovidDeaths
WHERE continent is NOT NULL
GROUP by location
ORDER BY TotalDeathCount DESC

--continent with highest death count per population
select continent, max(total_deaths) as TotalDeathCount
From ..CovidDeaths
--where location like '%states%'
WHERE continent is not NULL
GROUP by continent
ORDER BY TotalDeathCount DESC

--Gloabl numbers
select sum(new_cases) as Total_Cases, sum(new_deaths) as total_deaths, sum(CONVERT(FLOAT, new_deaths))/sum(new_cases)*100 as DeathPercentage
From ..CovidDeaths
where continent is not null
ORDER BY 1,2

--Looking at total poulation vs vaccination
select dea.continent, dea.location, dea.date, dea.population, CONVERT(int, dea.new_vaccinations) as new_vaccinations, 
SUM(CONVERT(int, dea.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from ..CovidDeaths dea
join ..CovidVaccinations vac 
    on dea.location = vac.location 
    and dea.date = vac.date
where dea.continent is not null
ORDER BY 2,3

-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(select dea.continent, dea.location, dea.date, dea.population, CONVERT(int, dea.new_vaccinations) as new_vaccinations, 
SUM(CONVERT(int, dea.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from ..CovidDeaths dea
join ..CovidVaccinations vac 
    on dea.location = vac.location 
    and dea.date = vac.date
where dea.continent is not null)
--ORDER BY 2,3)
select * , (RollingPeopleVaccinated/population)*100 as RollingPeopleVaccinated_percent from PopvsVac

--Temp table 
drop TABLE if exists #PercentPoulationVaccinated
create table #PercentPoulationVaccinated (
    Continent NVARCHAR(255),
    LOCATION NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_Vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC 
)

Insert into #PercentPoulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, CONVERT(int, dea.new_vaccinations) as new_vaccinations, 
SUM(CONVERT(int, dea.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from ..CovidDeaths dea
join ..CovidVaccinations vac 
    on dea.location = vac.location 
    and dea.date = vac.date
--where dea.continent is not null
--ORDER BY 2,3)
select * , (RollingPeopleVaccinated/population)*100 as RollingPeopleVaccinated_percent from #PercentPoulationVaccinated


--Creating view to store data for later visualizations
CREATE view PercentPoulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, CONVERT(int, dea.new_vaccinations) as new_vaccinations, 
SUM(CONVERT(int, dea.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from ..CovidDeaths dea
join ..CovidVaccinations vac 
    on dea.location = vac.location 
    and dea.date = vac.date
where dea.continent is not null
--ORDER BY 2,3

select * from PercentPoulationVaccinated
