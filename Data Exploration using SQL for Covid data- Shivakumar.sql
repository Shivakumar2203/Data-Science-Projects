
Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

Select *
From PortfolioProject..CovidVaccination
order by 3,4

--select data the we are going to be using 

Select location, date, total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at total cases v/s Total death
-- Shows likelihood of dying if you contract covid in INDIA

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
Where location like '%India%'
and continent is not null
order by 1,2

--Looking at Total Cases v/s Population
-- Shows what percentage of population affected covid in INDIA

Select location, date,population, total_cases, (total_cases/population)*100 as Percentage_Population_infected
From PortfolioProject..CovidDeaths
Where location like '%India%'
and continent is not null
order by 1,2

--Looking at coutries with highestinfection rate campared to population

Select location,population, Max(total_cases) as Highest_Infection, Max((total_cases/population))*100 as Percentage_Population_infected
From PortfolioProject..CovidDeaths
group by location, population 
order by Percentage_Population_infected desc

--Showing countries with highest Death Count per population

Select location, max(cast(total_deaths as int)) as Total_Death_Count
From PortfolioProject..CovidDeaths
where continent is not null
group by location
order by Total_Death_Count desc

--Lets Break things down by Contitent

--Showing the Contient with the highest death count per population

Select continent, max(cast(total_deaths as int)) as Total_Death_Count
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by Total_Death_Count desc


--Global Numbers

Select date, sum(new_cases) as Total_Cases, Sum(cast(new_deaths as int))as Total_Deaths, Sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
--Where location like '%India%'
where continent is not null
group by date
order by 1,2


--Looking at total Global Death Percetage due to covid

Select sum(new_cases) as Total_Cases, Sum(cast(new_deaths as int))as Total_Deaths, Sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
--Where location like '%India%'
where continent is not null
--group by date
order by 1,2

--Looking at total Population v/s Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 1,2,3

-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *
from PercentPopulationVaccinated

	
