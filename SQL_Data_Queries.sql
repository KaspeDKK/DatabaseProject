-- Show the CPR number of all customers who got one of their bike repaired more than once.
-- Show the code and manufacturer of all parts that were never used for any repair
-- For each part, show the code, manufacturer, and total quantity being used for all repair jobs in 2024

-- For each bike type, show the type, code and manufacturer of the most repaired bike. (NEEDS TO BE CHECKED)
DROP VIEW IF EXISTS BikeRepairs;
CREATE VIEW BikeRepairs(bike_code, repairs_count) AS
SELECT bike_code, COUNT(bike_code) FROM repairjobs GROUP BY bike_code;

SELECT bike_code AS Most_Repaired_Bike, MAX(repairs_count) AS Repairs FROM BikeRepairs;

-- Show the code and manufacturer of bikes that can use only parts from the same manufacturer. (NEEDS TO BE CHECKED)
DROP VIEW IF EXISTS IdenticalManufacturers;
CREATE VIEW IdenticalManufacturers AS
SELECT * FROM bikes NATURAL JOIN repairjobs NATURAL JOIN uses GROUP BY bike_code HAVING manufacturer_ID = part_manufacturer;

SELECT bike_code, manufacturer_ID FROM IdenticalManufacturers;