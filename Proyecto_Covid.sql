SELECT *
FROM ProyectoPortafolio..CovidMuertos
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM ProyectoPortafolio..CovidVacunados
--ORDER BY 3,4

-- Seleccionar la Data que vamos a utilizar

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM ProyectoPortafolio..CovidMuertos
WHERE continent is not null
ORDER BY 1,2


-- Los casos totales vs total de muertes
-- Muestra la posibilidad de morir si contraes covid en tu país
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Porcentaje_Muertos
FROM ProyectoPortafolio..CovidMuertos
WHERE Location LIKE 'Chile' AND continent is not null
ORDER BY 1,2

-- Los casos totales vs la población
-- Muestra que porcentaje de la población contrajo covid
SELECT Location, date, Population, total_cases, (total_cases/Population)*100 AS Porcentaje_Covid
FROM ProyectoPortafolio..CovidMuertos
WHERE Location like 'Chile' AND continent is not null
ORDER BY 1,2

-- Paises con la mayor tasa de infectados comparados a la población
SELECT Location, Population, MAX(total_cases) AS mayor_cantidad_infectados, MAX((total_cases/population))*100 AS Porcentaje_Covid
FROM ProyectoPortafolio..CovidMuertos
WHERE continent is not null
GROUP BY Location, Population
ORDER BY Porcentaje_Covid DESC

-- Paises con la mayor tasa de muertes por población
SELECT Location, MAX(Total_deaths) AS Muertes_totales
FROM ProyectoPortafolio..CovidMuertos
WHERE continent is not null
GROUP BY Location
ORDER BY Muertes_totales DESC

-- Dividamoslo por continente


-- Muestra los continentes con la mayor tasa de muertes por población
SELECT continent, MAX(Total_deaths) AS Muertes_totales
FROM ProyectoPortafolio..CovidMuertos
WHERE continent is not null
GROUP BY continent 
ORDER BY Muertes_totales DESC



-- NÚMEROS GLOBALES


SELECT date, SUM(new_cases) AS casos_totales, SUM(new_deaths) AS muertes_totales, SUM(new_deaths)/SUM(new_cases)*100 AS Porcentaje_Muertos
FROM ProyectoPortafolio..CovidMuertos
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS casos_totales, SUM(new_deaths) AS muertes_totales, SUM(new_deaths)/SUM(new_cases)*100 AS Porcentaje_Muertos
FROM ProyectoPortafolio..CovidMuertos
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- Población total vs vacunados

SELECT muer.continent, muer.location, muer.date, muer.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY muer.location ORDER BY muer.location,
 muer.date) as vacunas_puestas
--, (vacunas_puestas/population)*100
FROM ProyectoPortafolio..CovidMuertos muer
JOIN ProyectoPortafolio..CovidVacunados vac
	ON muer.location = vac.location
	and muer.date = vac.date
WHERE muer.continent IS NOT NULL
ORDER BY 2,3

--CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, vacunas_puestas)
as
(
SELECT muer.continent, muer.location, muer.date, muer.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY muer.location ORDER BY muer.location,
 muer.date) as vacunas_puestas
--, (vacunas_puestas/population)*100
FROM ProyectoPortafolio..CovidMuertos muer
JOIN ProyectoPortafolio..CovidVacunados vac
	ON muer.location = vac.location
	and muer.date = vac.date
WHERE muer.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (vacunas_puestas/population)*100
FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PorcentajePoblacionVacunada
CREATE TABLE #PorcentajePoblacionVacunada
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
vacunas_puestas numeric
)

INSERT INTO #PorcentajePoblacionVacunada
SELECT muer.continent, muer.location, muer.date, muer.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY muer.location ORDER BY muer.location,
 muer.date) as vacunas_puestas
--, (vacunas_puestas/population)*100
FROM ProyectoPortafolio..CovidMuertos muer
JOIN ProyectoPortafolio..CovidVacunados vac
	ON muer.location = vac.location
	and muer.date = vac.date
WHERE muer.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (vacunas_puestas/population)*100
FROM #PorcentajePoblacionVacunada


-- View para guardar data para futuras visualizaciones

CREATE VIEW PorcentajePoblacionVacunada AS
SELECT muer.continent, muer.location, muer.date, muer.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY muer.location ORDER BY muer.location,
 muer.date) as vacunas_puestas
--, (vacunas_puestas/population)*100
FROM ProyectoPortafolio..CovidMuertos muer
JOIN ProyectoPortafolio..CovidVacunados vac
	ON muer.location = vac.location
	and muer.date = vac.date
WHERE muer.continent IS NOT NULL
--ORDER BY 2,3

SELECT * 
FROM PorcentajePoblacionVacunada