CREATE DATABASE stolen_vehicles_db;
USE stolen_vehicles_db;


SELECT * FROM LOCATIONS;
SELECT * FROM MAKE_DETAILS;
SELECT * FROM STOLEN_VEHICLES;

-- 1. What day of the week are vehicles most often and least often stolen?

SELECT DAYNAME(DATE_STOLEN) AS DayOfWeek, COUNT(*) AS StolenVehicles, 'Most Stolen' AS Status
FROM stolen_vehicles
GROUP BY DayOfWeek
HAVING COUNT(*) = (SELECT MAX(CountVehicles) FROM (SELECT DAYNAME(DATE_STOLEN) AS DayOfWeek, COUNT(*) AS CountVehicles FROM stolen_vehicles GROUP BY DayOfWeek) AS MaxCounts)
UNION ALL
SELECT DAYNAME(DATE_STOLEN) AS DayOfWeek, COUNT(*) AS StolenVehicles, 'Least Stolen' AS Status
FROM stolen_vehicles
GROUP BY DayOfWeek
HAVING COUNT(*) = (SELECT MIN(CountVehicles) FROM (SELECT DAYNAME(DATE_STOLEN) AS DayOfWeek, COUNT(*) AS CountVehicles FROM stolen_vehicles GROUP BY DayOfWeek) AS MinCounts)
ORDER BY DayOfWeek, Status;

-- 2. What types of vehicles are most often and least often stolen? Does this vary by region?

/*Removed Null Values*/
SET SQL_SAFE_UPDATES = 0;
delete from stolen_vehicles
where vehicle_type is null;

-- Most Stolen Vehicle Types by Region
SELECT locations.region, vehicle_type, COUNT(*) AS StolenCount, 'Most Stolen' AS Status
FROM stolen_vehicles
INNER JOIN locations ON stolen_vehicles.location_id = locations.location_id
GROUP BY locations.region, vehicle_type
HAVING StolenCount = (SELECT MAX(CountVehicles)
                     FROM (SELECT locations.region, vehicle_type, COUNT(*) AS CountVehicles
                          FROM stolen_vehicles
                          INNER JOIN locations ON stolen_vehicles.location_id = locations.location_id
                          GROUP BY locations.region, vehicle_type) AS MaxCounts)
UNION ALL

-- Least Stolen Vehicle Types by Region
SELECT locations.region, vehicle_type, COUNT(*) AS StolenCount, 'Least Stolen' AS Status
FROM stolen_vehicles
INNER JOIN locations ON stolen_vehicles.location_id = locations.location_id
GROUP BY locations.region, vehicle_type
HAVING StolenCount = (SELECT MIN(CountVehicles)
                     FROM (SELECT locations.region, vehicle_type, COUNT(*) AS CountVehicles
                          FROM stolen_vehicles
                          INNER JOIN locations ON stolen_vehicles.location_id = locations.location_id
                          GROUP BY locations.region, vehicle_type) AS MinCounts)
ORDER BY region, Status, StolenCount DESC;

-- 3. What is the average age of the vehicles that are stolen? Does this vary based on the vehicle type?
SELECT year(date_stolen) as Year_Stole , vehicle_type, 
       round(AVG(YEAR(date_stolen) - model_year),0) AS Average_Age
FROM stolen_vehicles
GROUP BY vehicle_type ,Year_Stole
ORDER BY Year_Stole desc,Average_Age DESC ;

-- 4. What are the most frequently stolen vehicle makes in each region, and how does this vary by region? 

SELECT L.REGION, MD.make_type, COUNT(*) AS STOLE_VEHICLES
             FROM make_details MD INNER JOIN stolen_vehicles SV USING (make_id)
              INNER JOIN locations L USING (LOCATION_ID)
                   GROUP BY L.REGION,  MD.make_type
                   ORDER BY STOLE_VEHICLES DESC;

-- 5. Are there any trends in the colors of stolen vehicles? 
DELETE FROM stolen_vehicles
WHERE COLOR IS NULL;

SELECT  year(date_stolen) as Year_Stole,
COLOR ,  COUNT(*) AS VEHICLES_STOLE
FROM stolen_vehicles
GROUP BY COLOR, Year_Stole
ORDER BY VEHICLES_STOLE DESC,Year_Stole desc;

-- 6. Which regions have the highest and lowest population densities, and do these densities correlate with higher or lower rates of vehicle theft?

SELECT REGION, ROUND(AVG(DENSITY),2) AS Avg_Population_Density,  'HIGHER POPULATION DENSITY' AS Status
FROM LOCATIONS
GROUP BY REGION
HAVING Avg_Population_Density = (SELECT MAX(POPULATION_DENSITY) 
                            FROM (SELECT REGION, AVG(DENSITY) AS POPULATION_DENSITY
                                       FROM LOCATIONS
                                        GROUP BY REGION) AS MaxCounts)
UNION ALL
SELECT REGION, ROUND(AVG(DENSITY),2) AS Avg_Population_Density, 'LOWER POPULATION DENSITY' AS Status
FROM LOCATIONS
GROUP BY REGION
HAVING Avg_Population_Density = (SELECT MIN(POPULATION_DENSITY) 
                            FROM (SELECT REGION, AVG(DENSITY) AS POPULATION_DENSITY
                                       FROM LOCATIONS
                                        GROUP BY REGION) AS MINCounts);
                                        
-- 7. Is there a correlation between the make type (standard or luxury) and the average age of stolen vehicles? 
SELECT MAKE_TYPE, round(AVG(YEAR(date_stolen) - model_year),0) AS Average_Age
FROM make_details MD LEFT JOIN stolen_vehicles SV USING (MAKE_ID)
GROUP BY make_type;