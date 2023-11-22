Select *
from PortfolioProject.dbo.CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--from PortfolioProject.dbo.CovidVaccination
--Order by 3,4

--Select Data that we are going to be using 

Select  Location , date , Total_Cases , New_cases , total_deaths , population 
from Portfolioproject..CovidDeaths
Where continent is not null
Order by  1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your contry

Select  Location , date , Total_Cases , total_deaths , (total_deaths / Total_Cases)*100 as DeathPercentage
from Portfolioproject..CovidDeaths
where location = 'Brazil'
and continent is not null
Order by  1,2

-- Looking at Total Cases VS Population 
--Shows what percentage of population got Covid

Select  Location , date , Total_Cases , Population, (Total_Cases/Population)*100 as PercentPopulationInfected
from Portfolioproject..CovidDeaths
where location = 'Brazil'
Order by  1,2


--Looking at Contries with Highest Infection  Rate compared to Population 

Select  Location , Population,MAX(Total_Cases) as HighestInfectionCount,  MAX((Total_Cases/Population))*100 as PercentPopulationInfected
from Portfolioproject..CovidDeaths
group by Location , Population
Order by  PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

Select  Location , MAX(cast(Total_deaths as int)) as TotalDeathCount
from Portfolioproject..CovidDeaths
Where continent is not null
group by Location
Order by  TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT




--Showing continents with the highest death count per population

Select  continent , MAX(cast(Total_deaths as int)) as TotalDeathCount
from Portfolioproject..CovidDeaths
Where continent is not  null
group by continent
Order by  TotalDeathCount DESC

--Global Numbers

Select   SUM(new_cases) as Total_cases,SUM(cast(new_deaths as int)) as Total_Deaths,SUM(cast(New_deaths as int)) / SUM(New_Cases) *100 as DeathPercentage
from Portfolioproject..CovidDeaths
--where location = 'Brazil'
where continent is not null
--group by date
Order by  1,2

--Looking at Total Population  vs Vaccinations

Select dea.continent, dea.location , dea.date , dea.population , vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100
from PortfolioProject..CovidDeaths dea
Join  PortfolioProject..CovidVaccination vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

--Use CTE

With PopvsVac (Continent, Location, Date, Population ,New_Vaccinations, RollingPeopleVaccined)
as
(
Select dea.continent, dea.location , dea.date , dea.population , vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100
from PortfolioProject..CovidDeaths dea
Join  PortfolioProject..CovidVaccination vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

--Order by 2,3

)
Select *, (RollingPeopleVaccined/Population) *100
From PopvsVac


--TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
Create Table  #PercentpopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccined numeric
)

Insert into   #PercentPopulationVaccinated
Select dea.continent, dea.location , dea.date , dea.population , vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100
from PortfolioProject..CovidDeaths dea
Join  PortfolioProject..CovidVaccination vac
    On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccined/Population) *100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View  PercentPopulationVaccinated as 

Select dea.continent, dea.location , dea.date , dea.population , vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100
from PortfolioProject..CovidDeaths dea
Join  PortfolioProject..CovidVaccination vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select * 
from  PercentPopulationVaccinated

