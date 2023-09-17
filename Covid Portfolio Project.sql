--select *
--from PortfolioProjects..CovidDeaths
--order by 3,4

--select *
--from PortfolioProjects..CovidVacinnations
--order by 3,4

--Select location, date, total_cases, new_cases, total_deaths, Population
--from PortfolioProjects..CovidDeaths
--order by 1,2

-- Looking at total cases vs total deaths
-- shows likelihood of death from covid
Select location, date, total_cases, total_deaths, (convert(float, total_deaths)/nullif(convert(float, total_cases),0))*100 as DeathPercentage
from PortfolioProjects..CovidDeaths
where location like 'Australia'
order by 1,2

-- looking at total cases vs Population
-- Shows what percentage of population got covid
Select location, date, total_cases, population, (convert(float, total_deaths)/nullif(convert(float, Population),0))*100 as CovidPercentage
from PortfolioProjects..CovidDeaths
where location like 'Australia'
order by 1,2

-- Looking at countries with highest infection rate compared to population
Select location, MAX(total_cases) as highestInfectionCount, population, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProjects..CovidDeaths
--where location like 'Australia'
where continent is null
Group by location, population
order by 4 desc

-- Lets break things down by Continent
--Showing the continents with the highest death counts

Select continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProjects..CovidDeaths
--where location like 'Australia'
where continent is not null
Group by continent
order by TotalDeathsCount desc



-- Global Numbers
--Global Death Percentage per day

Select date, sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as Totaldeaths, Sum(cast(new_deaths as int))/nullif(sum(new_cases),0) *100 as DeathPercentage
from PortfolioProjects..CovidDeaths
--where location like 'Australia'
where continent is not null
Group by date
order by 1,2


--Covid Vaccination
-- Looking at Total population vs Vaccination

Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as bigint)) Over (Partition by dth.location order by dth.location, dth.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths dth
Join PortfolioProjects..CovidVacinnations vac
	on dth.location = vac.location
	and dth.date = vac.date
Where dth.continent is not null
order by 2,3

--Use CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as bigint)) Over (Partition by dth.location order by dth.location, dth.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths dth
Join PortfolioProjects..CovidVacinnations vac
	on dth.location = vac.location
	and dth.date = vac.date
Where dth.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac
where location like 'australia'




--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated

(Continent nvarchar (255),
Location nvarchar (255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as bigint)) Over (Partition by dth.location order by dth.location, dth.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths dth
Join PortfolioProjects..CovidVacinnations vac
	on dth.location = vac.location
	and dth.date = vac.date
Where dth.continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated
where location like 'australia'


-- Creating view to store data for later visualization

Drop View if exists PercentPopulationVaccinated
Create view PercentPopulationVaccinated as
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as bigint)) Over (Partition by dth.location order by dth.location, dth.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths dth
Join PortfolioProjects..CovidVacinnations vac
	on dth.location = vac.location
	and dth.date = vac.date
Where dth.continent is not null
--order by 2,3