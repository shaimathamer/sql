select*
from sql_porject_portfolio..covid_death
order by 3,4

select*
from sql_porject_portfolio..covid_vaccin
order by 3,4

--now lets select the data that we want to 
select location,date,total_cases,new_cases,total_deaths,population
from sql_porject_portfolio..covid_death
order by 1,2

--looking on total cases vs total death
--show likelihood death in your country 
select location,date,total_cases,new_cases,total_deaths,(total_cases/total_deaths)*100 as DeathPercentage
from sql_porject_portfolio..covid_death
where location like '%states%'
order by 1,2

--looking the number of totalcases vs the popultion 
select location,date,population,total_cases,new_cases,total_deaths,(total_cases/population)*100 as CasesPercentage
from sql_porject_portfolio..covid_death
where location like '%states%'
order by 1,2

--looking with where the country with highest infection rate 
select location,population,max(total_cases) as HighestCase,MAX((total_cases/population))*100 as MaxCasesPercentage
from sql_porject_portfolio..covid_death
--where location like '%states%'
Group by location,population
order by 1,2

--looking for countries with highest death count 
select location,max(cast(total_deaths as int)) as HighestDeath
from sql_porject_portfolio..covid_death
--where location like '%states%'
where continent is not null
Group by location
order by HighestDeath desc

--looking total population vs total vaccination
select death.continent,death.location,death.date,death.population,vaccin.new_vaccinations,
SUM(convert(int,vaccin.new_vaccinations)) over (partition by death.location order by death.location,death.date)
from sql_porject_portfolio..covid_death death join sql_porject_portfolio..covid_vaccin vaccin
on death.location =vaccin.location and death.date=vaccin.date
where death.continent is not null
order by 2,3


Select death.continent, death.location, death.date, death.population, vaccin.new_vaccinations
, SUM(CONVERT(int,vaccin.new_vaccinations)) OVER (Partition by death.Location Order by convert(varchar(30),death.location), death.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From sql_porject_portfolio..covid_death death join sql_porject_portfolio..covid_vaccin vaccin
	On death.location = vaccin.location
	and death.date = vaccin.date
where death.continent is not null 
--order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
