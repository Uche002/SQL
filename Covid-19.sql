Select *
From PortfolioProject..CovidDeaths
--To ensure your location is not grouped as a continent, use 'where continent is not null' as shown below
where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
Order by 1,2

--Total_Cases vs Total_Deaths
--Chance of dying when you contact COVID-19 in Nigeria
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths
Where location like 'Nigeria'
Order by 1,2

--Total_cases vs Population
--Showing percentage of Nigerian population with COVID-19

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentageofAffectedPopulation
From PortfolioProject..CovidDeaths
Where location like 'Nigeria'
Order by 1,2

--Countries with Highest Infection Rate Compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like 'Nigeria'
Group by Location, Population
Order by PercentPopulationInfected desc

--Countries with Highest Death Count per Population
--To convert to integers(int) when data is in nvarchar, cast it by adding (cast), 'as int' as shown below

Select Location, MAX(cast (Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like 'Nigeria'
where continent is not null
Group by Location, Population
Order by TotalDeathCount desc



--BREAK-DOWN BY CONTINENT

Select location, MAX(cast (Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like 'Nigeria'
where continent is null
Group by location
Order by TotalDeathCount desc

--The above query is the correct one, but we'll use the one below
--Showing Continents with Highest Death Count

Select continent, MAX(cast (Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like 'Nigeria'
where continent is not null
Group by continent
Order by TotalDeathCount desc


--GLOBAL NUMBERS
--To do multiple grouping, use aggregate functions
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths
--Where location like 'Nigeria'
where continent is not null
Group by date
Order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths
--Where location like 'Nigeria'
where continent is not null
--Group by date
Order by 1,2


--Total Population vs Vaccination
--example
Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date


--Nigeria
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.location like 'Nigeria'
	Order by 1,2,3


--Global we are partitioning by location since we are braking it up by location and not continent so as not to run over when entering another location
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	Order by 2,3

	--USE THE ABOVE CASTING OR USE CONVERT FUNCTION. The  rollingpeoplevaccinated is simple cumulation, why we added the 'Order by dea.location, dea.date'
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100 will give the percentage of the population vaccinated. It won't work here because the query will require a CTE
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	Order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100 will give the percentage of the population vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--TEM TABLE

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
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100 will give the percentage of the population vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
--Order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Use this if you want to make alterations on table without getting a syntax error

Drop table if exists #PercentPopulationVaccinated
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
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100 will give the percentage of the population vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
--Order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--TO VISUALIZE, GO BACK RUN THE CODES AND TOSS THE EXACT QUERY YOU RE-RAN INTO VIEW
-- CREATING VIEW TO STORE DATA FOR VISUALIZATION

Create View PortfolioProject as 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths
Where location like 'Nigeria'
--Order by 1,2

Create View Total_casesbypopulation as
Select Location, date, total_cases, population, (total_cases/population)*100 as PercentageofAffectedPopulation
From PortfolioProject..CovidDeaths
Where location like 'Nigeria'
--Order by 1,2

Create View Highest as
Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like 'Nigeria'
Group by Location, Population
--Order by PercentPopulationInfected desc


Create View Highest_Death as
Select Location, MAX(cast (Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like 'Nigeria'
where continent is not null
Group by Location, Population
--Order by TotalDeathCount desc

Create View Highest_Death_Global as
Select location, MAX(cast (Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like 'Nigeria'
where continent is null
Group by location


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100 will give the percentage of the population vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
--Order by 2,3
