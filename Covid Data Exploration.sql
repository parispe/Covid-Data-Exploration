Select *
From Project_1.. CovidDeaths
Where continent is not null
order by 3,4

-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From Project_1..CovidDeaths
Order by 1,2

-- Total Cases vs Total Deaths
-- Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathtPercentage

From Project_1..CovidDeaths
Where location like '%states%'
Order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2

-- Total Cases vs Population
-- Shows the percentage of population infected by Covid

Select Location, Date, Total_Cases, Population, (Total_Cases/Population)*100 as PercentPopulationInfected
From Project_1..CovidDeaths
Where location like '%states%'
Order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(Total_Cases) as HighestInfectionCount, MAX((Total_cases/Population)*100) as PercentPopulationInfected
From Project_1..CovidDeaths
Group by Location, Population
Order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- Breaking it down by Continent
-- Showing continents with the highest death count per population

Select Continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From Project_1..CovidDeaths
Where continent is not null
Group by Continent
Order by TotalDeathCount desc

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From Project_1..CovidDeaths
Where continent is not null
Group by Location
Order by TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage -- total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Project_1..CovidDeaths
Where continent is not null
-- Group by date
Order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform calculation on Partition 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From Project_1..CovidDeaths dea 
Join Project_1..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp Table used to perform calculation on Partition 

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated ( 
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric, 
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From Project_1..CovidDeaths dea 
Join Project_1..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for visualizations

Create View PercentPopulatedVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From Project_1..CovidDeaths dea 
Join Project_1..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null