
select location, date, total_cases, new_cases, total_cases, population
from [Portfolio Project].dbo.[Covid Death]
order by 1,2
-- total cases VS total deaths 
select location, date, total_deaths, total_cases, (cast (total_deaths as decimal) /cast (total_cases as decimal) )*100 as deathpercentage
from [Portfolio Project].dbo.[Covid Death]
where location = 'egypt'
order by 1,2
-- total cases vs population :
select location, date, population , total_cases, (cast (total_cases as decimal) /cast (population as decimal) )*100 as covidpercentage
from [Portfolio Project].dbo.[Covid Death]
--where location like '%egypt%'
order by 1,2

-- countries with highest infection rate :
select location, population , max (total_cases) as maxtotalcases, max ((cast (total_cases as decimal) /cast (population as decimal)))*100 as maxinfectionrate 
from [Portfolio Project].dbo.[Covid Death]
--where location like '%egypt%'
Group by location , population
order by maxinfectionrate

-- countries with highst death rate per population 

select location, population ,max ((cast (total_deaths as decimal))) as maxdeath 
from [Portfolio Project].dbo.[Covid Death]
where continent is not null 
Group by location , population
order by maxdeath desc

--highst deaths per continent 
select continent , max ((cast (total_deaths as decimal))) as maxdeath 
from [Portfolio Project].dbo.[Covid Death]
where continent is not null 
Group by  continent
order by maxdeath desc

select location , max ((cast (total_deaths as decimal))) as maxdeath 
from [Portfolio Project].dbo.[Covid Death]
where continent is  null 
Group by  location
order by maxdeath desc

-- global numbers 

select  date,sum (new_cases) as Totalcases , sum (cast (new_deaths as int)) as totaldeaths 
, sum (cast (new_deaths as int))/sum (new_cases)*100 as deathpercentage
FROM [Portfolio Project]..[Covid Death] 
where continent is not null 
group by date 
order by 1,2

--looking at total population v total vaccination 
select [Portfolio Project]..[Covid Death].continent, [Portfolio Project]..[Covid Death].date , [Portfolio Project]..[Covid Death].location, 
[Portfolio Project]..[Covid vaccinations].new_vaccinations, sum (cast([Portfolio Project]..[Covid vaccinations].new_vaccinations as int) ) 
over (partition by [Portfolio Project]..[Covid Death].location order by [Portfolio Project]..[Covid Death].location ) as totalvaccination
from [Portfolio Project]..[Covid Death] 
  join [Portfolio Project]..[Covid vaccinations] 
  on [Portfolio Project]..[Covid Death].date = [Portfolio Project]..[Covid vaccinations].date
  and [Portfolio Project]..[Covid Death].location = [Portfolio Project]..[Covid vaccinations].location
  where [Portfolio Project]..[Covid Death].continent is not null
  order by 3,2


-- using CTE 
with popVSvac (continent, location , date , population , RollingPeopleVaccinated)
as 
(select [Portfolio Project]..[Covid Death].continent, [Portfolio Project]..[Covid Death].date , [Portfolio Project]..[Covid Death].location, 
[Portfolio Project]..[Covid vaccinations].new_vaccinations, sum (cast([Portfolio Project]..[Covid vaccinations].new_vaccinations as decimal) ) 
over (partition by [Portfolio Project]..[Covid Death].location order by [Portfolio Project]..[Covid Death].location ) as totalvaccination
from [Portfolio Project]..[Covid Death] 
  join [Portfolio Project]..[Covid vaccinations] 
  on [Portfolio Project]..[Covid Death].date = [Portfolio Project]..[Covid vaccinations].date
  and [Portfolio Project]..[Covid Death].location = [Portfolio Project]..[Covid vaccinations].location
  where [Portfolio Project]..[Covid Death].continent is not null
  --order by 3,2
  )
select * , (RollingPeopleVaccinated/population)*100 
from popVSvac
where population is not null
-- using temp table 
Drop TABLE IF exists #populationvsvaccibation 
CREATE TABLE #populationvsvaccibation
( continent nvarchar (255),
   date datetime,
   location nvarchar (255),
   population numeric, 
   RollingPeopleVaccinated numeric)
   insert into #populationvsvaccibation
   select [Portfolio Project]..[Covid Death].continent, [Portfolio Project]..[Covid Death].date , [Portfolio Project]..[Covid Death].location, 
[Portfolio Project]..[Covid vaccinations].new_vaccinations, sum (cast([Portfolio Project]..[Covid vaccinations].new_vaccinations as decimal) ) 
over (partition by [Portfolio Project]..[Covid Death].location order by [Portfolio Project]..[Covid Death].location ) as totalvaccination
from [Portfolio Project]..[Covid Death] 
  join [Portfolio Project]..[Covid vaccinations] 
  on [Portfolio Project]..[Covid Death].date = [Portfolio Project]..[Covid vaccinations].date
  and [Portfolio Project]..[Covid Death].location = [Portfolio Project]..[Covid vaccinations].location
  --where [Portfolio Project]..[Covid Death].continent is not null
  --order by 3,2
  select *
  from #populationvsvaccibation
  where population is not null 
  
-- create view 
Create View popvacpercentage as 
select [Portfolio Project]..[Covid Death].continent, [Portfolio Project]..[Covid Death].date , [Portfolio Project]..[Covid Death].location, 
[Portfolio Project]..[Covid vaccinations].new_vaccinations, sum (cast([Portfolio Project]..[Covid vaccinations].new_vaccinations as decimal) ) 
over (partition by [Portfolio Project]..[Covid Death].location order by [Portfolio Project]..[Covid Death].location ) as totalvaccination
from [Portfolio Project]..[Covid Death] 
  join [Portfolio Project]..[Covid vaccinations] 
  on [Portfolio Project]..[Covid Death].date = [Portfolio Project]..[Covid vaccinations].date
  and [Portfolio Project]..[Covid Death].location = [Portfolio Project]..[Covid vaccinations].location
 where [Portfolio Project]..[Covid Death].continent is not null
 --order by 3,2
  ---------------------------------------------------------------------------------------------------------
 
 SELECT *
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'popvacpercentage';

SELECT *
FROM sys.views
WHERE name = 'popvacpercentage';

