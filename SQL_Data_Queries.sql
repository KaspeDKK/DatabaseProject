-- Show the CPR number of all customers who got one of their bike repaired more than once.
SELECT customerCPR FROM RepairJobs
GROUP BY customerCPR
HAVING COUNT(customerCPR)>1;


-- Show the code and manufacturer of all parts that were never used for any repair
SELECT part_code, manufacturer_ID 
FROM Parts
WHERE (part_code, manufacturer_ID) NOT IN 
      (SELECT part_code, part_manufacturer FROM Uses);


-- For each part, show the code, manufacturer, and total quantity being used for all repair jobs in 2024
SELECT p.part_code, p.manufacturer_ID, SUM(u.quantity) AS total_quantity
FROM Uses u, Parts p, RepairJobs r
WHERE p.part_code = u.part_code
  AND p.manufacturer_ID = u.part_manufacturer
  AND r.repair_ID = u.repair_ID
  AND r.repair_date LIKE '2024%'
GROUP BY p.part_code, p.manufacturer_ID;


-- For each bike type, show the type, code and manufacturer of the most repaired bike. (NEEDS TO BE CHECKED)
DROP VIEW IF EXISTS BikeRepairs;
CREATE VIEW BikeRepairs AS
SELECT bike_code, bike_manufacturer, COUNT(*) AS repairs_count
FROM RepairJobs
GROUP BY bike_code, bike_manufacturer;

SELECT bike_code, bike_manufacturer, repairs_count
FROM BikeRepairs
WHERE repairs_count = (SELECT MAX(repairs_count) FROM BikeRepairs);


-- Show the code and manufacturer of bikes that can use only parts from the same manufacturer. (NEEDS TO BE CHECKED)
SELECT bike_code, bike_manufacturer
FROM CompatibleParts
GROUP BY bike_code, bike_manufacturer
HAVING MIN(part_manufacturer) = bike_manufacturer -- We have min and max because some bikes could have the same code but not the same manufacturer
   AND MAX(part_manufacturer) = bike_manufacturer;
