select *
from [Portfolio Project]..CovidDeaths
Order by 3,4

--select *
--from [Portfolio Project]..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be using  

Select location, date, total_cases, new_cases, total_deaths, Population
From [Portfolio Project]..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where Location like '%states%'
order by 1,2


-- Looking at Total Cases vs Population
-- Shows percentage of population that has covid

Select location, date, total_cases, Population, (total_cases/population)*100 as PercentOfPopulationInfected
From [Portfolio Project]..CovidDeaths
Where Location like '%states%'
order by 1,2



-- Looking at Countries with Highest Iinfection Rate Compared To Population

Select location, Population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentOfPopulationInfected
From [Portfolio Project]..CovidDeaths
--Where Location like '%states%'
Group By Location, Population
order by PercentOfPopulationInfected DESC


-- Showing Countries With Highest Death Count Per Population

Select location, Max(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where Location like '%states%'
where Continent is not null
Group By Location
order by TotalDeathCount DESC


-- Let's Break Things Down By Continent

-- Showing Continent with the highest death count per population 

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where Location like '%states%'
where Continent is not null
Group By continent
order by TotalDeathCount DESC



-- GLOBAL NUMBERS 

Select date, sum(cast(new_deaths as int)) as Total_Deaths, sum(new_cases) as Total_Cases,  SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
--Where Location like '%states%'
where continent is not null
Group by Date
order by 1,2

------------------------------------

-- GLOBAL NUMBER
  -- Total Death Percentage Globally

 select sum(cast(new_deaths as Int)) as Total_Deaths, sum(new_cases) as Total_cases, sum(cast(new_deaths as Int))/sum(new_cases)*100
 From [Portfolio Project]..CovidDeaths

 ------------------------------------



 -- DATA JOINING (merging covid death and vaccination data for further exploration)
	-- Looking at Total Population vs Vaccination

 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , Sum(Convert(INT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/Population)*100
 from [Portfolio Project]..CovidDeaths as Dea
 Join [Portfolio Project]..CovidVaccinations as Vac
	ON Dea.location =Vac.location
	AND Dea.date = Vac.date
Where dea.Continent is not null
Order by 2,3


-- Data Exploration and Calculation Using a Derived Table
	-- ( We can do that using two methods)
		-- 1.) USING CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , Sum(Convert(INT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/Population)*100
 from [Portfolio Project]..CovidDeaths as Dea
 Join [Portfolio Project]..CovidVaccinations as Vac
	ON Dea.location =Vac.location
	AND Dea.date = Vac.date
Where dea.Continent is not null
-- Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 
From PopVsVac






--------- 2.) USING TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccicnations numeric,
RollingPeopleVaccinated numeric
)



INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , Sum(Convert(INT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/Population)*100
 from [Portfolio Project]..CovidDeaths as Dea
 Join [Portfolio Project]..CovidVaccinations as Vac
	ON Dea.location =Vac.location
	AND Dea.date = Vac.date
-- Where dea.Continent is not null
-- Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated 