-- Show the CPR number of all customers who got one of their bike repaired more than once.
SELECT customerCPR FROM RepairJobs
GROUP BY customerCPR
HAVING COUNT(customerCPR)>1;
-- Show the code and manufacturer of all parts that were never used for any repair
SELECT DISTINCT part_code, manufacturer_ID FROM Parts NATURAL JOIN Manufacturer
WHERE part_code NOT IN (SELECT part_code FROM Uses);
-- For each part, show the code, manufacturer, and total quantity being used for all repair jobs in 2024

-- For each bike type, show the type, code and manufacturer of the most repaired bike.

-- Show the code and manufacturer of bikes than can use only parts from the same manufacturer.
