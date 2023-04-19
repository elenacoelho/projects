/*
Expora��o de Dados COVID 19
Habilidades Utilizadas: Joins, CTE's, Tabelas Tempor�rias, Fun��es Agregadas, Cria��o de Visualiza��o, Convers�o de Tipos de Dados
*/


-- Selecionando dados para iniciar

SELECT location, date, total_cases, new_cases, total_deaths, new_deaths, population
FROM Portifolio..CovidDeaths$
order by 1,2

-- Total de Casos vs Total de Mortes
-- Mostra a propabilidade de morte no caso de contrair COVID no Brasil

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Portifolio..CovidDeaths$
where location = 'brazil'
order by 1,2

--Total de Casos vs Popula��o
-- Mostra a porcentagem da popula��o infectada com COVID at� a data
SELECT location, date,population, total_cases, (total_cases/population)*100 as InfectedPercentage
FROM Portifolio..CovidDeaths$
where location = 'brazil'
order by 1,2


-- Pa�ses com a maior porcentagem de infec��o em compara��o com a poula��o total

SELECT location,population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as HighestInfectedPercentage
FROM Portifolio..CovidDeaths$
group by location, population
order by HighestInfectedPercentage desc


-- Continentes com o maior n�mero de mortes

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portifolio..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc


-- Pa�ses com o maior n�mero de mortes

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portifolio..CovidDeaths$
where continent is not null 
group by location
order by TotalDeathCount desc


-- N�MEROS GLOBAIS

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100
as DeathPercentage
from Portifolio..CovidDeaths$
where continent is not null
group by date
order by 1,2 

-- Popula��o Total vs Vacina��o
-- Mostra a porcentagem da popula��o que recebeu pelo menos uma dose da vacina

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast (vac.new_vaccinations as int)) OVER
(Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
FROM Portifolio..CovidDeaths$ dea
JOIN Portifolio.. CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Utilizando CTE para fazer o c�lculo na parti��o de uma consulta anterior

With popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast (vac.new_vaccinations as int)) OVER
(Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
FROM Portifolio..CovidDeaths$ dea
JOIN Portifolio.. CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (rollingpeoplevaccinated/population) * 100 as percentageofpeople
from popvsvac
order by 2, 3

--Utilizando tabela tempor�ria para fazer o c�lculo na parti��o de uma consulta anterior

DROP table if exists #percentagepopulationvaccinated
CREATE table #percentagepopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

Insert into #percentagepopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast (vac.new_vaccinations as int)) OVER
(Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
FROM Portifolio..CovidDeaths$ dea
JOIN Portifolio.. CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (rollingpeoplevaccinated/population) * 100 as percentageofpeople
from #percentagepopulationvaccinated
order by 2, 3

--Criando visualiza��o para armazenar dados para constru��o posterior
Create View PercentagePopulationVaccinated1 as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast (vac.new_vaccinations as int)) OVER
(Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
FROM Portifolio..CovidDeaths$ dea
JOIN Portifolio.. CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

SELECT *
from PercentagePopulationVaccinated1