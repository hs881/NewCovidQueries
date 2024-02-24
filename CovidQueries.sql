select location, date, total_cases,new_cases, total_deaths, population
from PP..covid_deaths
order by 1,2
-- Global numbers ***************

SELECT 
    SUM(ISNULL(CAST(new_cases AS BIGINT), 0)) AS total_cases_sum,
    SUM(ISNULL(CAST(new_deaths AS BIGINT), 0)) AS total_deaths_sum,
    (CAST(SUM(ISNULL(CAST(new_deaths AS BIGINT), 0)) AS DECIMAL(10, 2)) / NULLIF(SUM(ISNULL(CAST(new_cases AS BIGINT), 0)), 0))*100 AS percentage
FROM pp..covid_deaths
WHERE continent IS NOT NULL;


-- Calcualting COVID-19 death percentage sorted by country and date 

select location, date,CAST(total_deaths AS INT) AS numeric_deaths,
    CAST(total_cases AS INT) AS numeric_cases,
    CASE 
        WHEN CAST(total_cases AS INT) = 0 THEN NULL  
        ELSE (CAST(total_deaths AS INT) * 100.0 / CAST(total_cases AS INT))
    END AS death_rate_percentage
from PP..covid_deaths
order by location,date

-- Calcualting the percent of the population who got COVID-19 sorted by country and date 

select location, date, CAST(total_cases AS INT) AS numeric_cases,
    CAST(population AS BIGINT) AS population,
    CASE 
        WHEN CAST(population AS BIGINT) = 0 THEN NULL  -- or handle as needed
        ELSE (CAST(total_cases AS INT) * 100.0 / CAST(population AS BIGINT))
    END AS percent_infected
from PP..covid_deaths
order by location,date

-- Countries with highest rate of COVID-19

select location, max(cast(total_cases as int)) AS max_cases,
    CAST(population AS BIGINT) AS population,
    CASE 
        WHEN CAST(population AS BIGINT) = 0 THEN NULL  -- or handle as needed
        ELSE max(cast(total_cases as int)) * 100.0 / CAST(population AS BIGINT)
    END AS percent_infected
from PP..covid_deaths
group by location, population
order by percent_infected desc

--Countries with highest deaths

select location, max(cast(total_deaths as int)) AS max_deaths
from PP..covid_deaths
where continent is not null
group by location
order by max_deaths desc

-- Continents with highest deaths ***************

select continent, max(cast(total_deaths as int)) AS max_deaths
from PP..covid_deaths
where continent is not null
group by continent
order by max_deaths desc

-- Death percent of the world

select SUM(CAST(new_cases AS INT)) AS total_cases,
    SUM(CAST(new_deaths AS INT)) AS total_deaths,
    CASE 
        WHEN SUM(CAST(new_cases AS INT)) = 0 THEN NULL
        ELSE (SUM(CAST(new_deaths AS INT)) * 100.0 / NULLIF(SUM(CAST(new_cases AS INT)), 0))
    END AS death_percent
from pp..covid_deaths
where continent is not null


-- Percent of poeple vaccinated by date and country

WITH peoplevac (Continent, location, date, population, new_vaccinations, total_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as total_vaccinated
from pp..covid_deaths dea
join pp..covid_vac vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (total_vaccinated / CAST(population AS DECIMAL(18, 2))) * 100 AS percent_vaccinated
from peoplevac



---------VIEW---------

create view deathPercent as
select location, date,CAST(total_deaths AS INT) AS numeric_deaths,
    CAST(total_cases AS INT) AS numeric_cases,
    CASE 
        WHEN CAST(total_cases AS INT) = 0 THEN NULL  
        ELSE (CAST(total_deaths AS INT) * 100.0 / CAST(total_cases AS INT))
    END AS death_rate_percentage
from PP..covid_deaths



-- Percent of people infected by continent *****************

select continent, max(CAST(total_cases AS BIGINT)) AS numeric_cases,
    max(CAST(population AS BIGINT)) AS population,
    CASE 
        WHEN max(CAST(population AS BIGINT)) = 0 THEN NULL  -- or handle as needed
        ELSE (max(CAST(total_cases AS INT)) * 100.0 / max(CAST(population AS BIGINT)))
    END AS percent_infected
from PP..covid_deaths
where continent is not null
group by continent
order by continent

