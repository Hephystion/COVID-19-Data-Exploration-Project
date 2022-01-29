SELECT * FROM [Portfolio Project]..['Covid deaths$']
Order by 3,4


--Below is what will be explored in this section of the project

SELECT location, date, new_cases, total_cases, total_deaths, new_deaths,continent, icu_patients, weekly_icu_admissions, hosp_patients 
FROM [Portfolio Project]..['Covid deaths$']

--Percentage of people who have died from COVID in Australia from 2020-2022

SELECT location, date, total_deaths, total_cases, ( total_deaths/ total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..['Covid deaths$']
WHERE location like '%australia%'


--The amount of infected people in each country

SELECT location,MAX(total_cases) as InfectedPeople  
FROM [Portfolio Project]..['Covid deaths$']
WHERE continent is not null
GROUP BY location
ORDER BY 1,2

--Continent with the highest death rate

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeaths
FROM [Portfolio Project]..['Covid deaths$']
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeaths desc

--The amount of COVID patients in ICU and weekly ICU admissions in Australia

SELECT location, date, icu_patients, weekly_icu_admissions
FROM [Portfolio Project]..['Covid deaths$']
WHERE location like '%australia%'
ORDER BY date desc

--The amount of hospitle patients in Australia from 2020-2022

SELECT location, date, hosp_patients 
FROM [Portfolio Project]..['Covid deaths$']
WHERE location like '%australia%'
ORDER BY date desc

-- Percentage of Australians Vaccinated from 2020-2022

SELECT location, date, people_vaccinated, population, (people_vaccinated/population)*100 as VaccinationsPercent
FROM [Portfolio Project]..['Covid Vaccinations$'_xlnm#_FilterDatabase] 
WHERE location like '%australia%'
ORDER BY date asc 

--Comparison of people who have been vaccinated and fully vaccinated in Australia

SELECT location, date, people_vaccinated,(SELECT people_fully_vaccinated) as FullyVaccinated
FROM [Portfolio Project]..['Covid Vaccinations$'_xlnm#_FilterDatabase]
WHERE location like '%australia%'
ORDER BY date asc

--Percentage of those who have been vaccinated and those who have been fully vaccinated in Australia

SELECT location, date,people_vaccinated,population, (people_vaccinated/population)*100 as Vaccinated,(SELECT people_fully_vaccinated/population)*100 as FullyVaccinated
FROM [Portfolio Project]..['Covid Vaccinations$'_xlnm#_FilterDatabase]
WHERE location like '%australia%'
ORDER BY date asc


--Below is what will be explored in this section of the project

SELECT location,continent, date, new_vaccinations, population 
FROM [Portfolio Project]..['Covid Vaccinations$'_xlnm#_FilterDatabase]
Order by 3,4

--Simple join of the two datasets being explored in this project

SELECT *
FROM [Portfolio Project]..['Covid deaths$'] dea
Join [Portfolio Project]..['Covid Vaccinations$'_xlnm#_FilterDatabase] vac
ON dea.location = vac.location
and dea.date = vac.date

--New vaccinations across the world from 2020-2022

SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations 
FROM [Portfolio Project]..['Covid deaths$'] dea
Join [Portfolio Project]..['Covid Vaccinations$'_xlnm#_FilterDatabase] vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3


-- Rolling count of people vaccinated over time in Australia

SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations, vac.population
,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..['Covid deaths$'] dea
Join [Portfolio Project]..['Covid Vaccinations$'_xlnm#_FilterDatabase] vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.location like '%australia%'


--CTE table to show Total Population vs People Vaccinated in Australia

With POPvsVAC (continent, location, date, new_vaccinations, population, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations, vac.population
,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..['Covid deaths$'] dea
Join [Portfolio Project]..['Covid Vaccinations$'_xlnm#_FilterDatabase] vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.location like '%australia%'

)
SELECT *
FROM POPvsVAC

--CTE table to calculate the Percentage of Australians who have been vaccinated over time

With POPvsVAC (continent, location, date, new_vaccinations, population, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations, vac.population
,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..['Covid deaths$'] dea
Join [Portfolio Project]..['Covid Vaccinations$'_xlnm#_FilterDatabase] vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.location like '%australia%'

)
SELECT *,(RollingPeopleVaccinated/Population)*100 AS PercentageOfPopulationVaccinated
FROM POPvsVAC

--Creating view to store data for later visualisations

CREATE VIEW RollingPeopleVaccinated AS
With POPvsVAC (continent, location, date, new_vaccinations, population, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations, vac.population
,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..['Covid deaths$'] dea
Join [Portfolio Project]..['Covid Vaccinations$'_xlnm#_FilterDatabase] vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.location like '%australia%'

)
SELECT *,(RollingPeopleVaccinated/Population)*100 AS PercentageOfPopulationVaccinated
FROM POPvsVAC