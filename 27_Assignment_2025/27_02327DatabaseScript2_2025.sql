-- 5. SQL TABLE MODIFICATIONS EXAMPLES --

-- 1st. COMMAND: INSERT STATEMENT --

-- Example 1:
-- The shop receives a new type of tire tube from manufacturer 98765 ("Nordic Speed")
-- and registers it in the Parts table so it can be used in future repairs.
INSERT INTO Parts (part_code, manufacturer_ID, description, unit_price)
VALUES ('P-900', 98765, 'All-weather tire tube, reinforced for hybrid bikes', 110.00);

-- so we verify the insertion
SELECT * FROM Parts
WHERE part_code = 'P-900' AND manufacturer_ID = 98765;


-- Example 2:
-- The new part is also marked as compatible with John's bike (BK-F600)
INSERT INTO CompatibleParts (bike_code, part_code, bike_manufacturer, part_manufacturer)
VALUES ('BK-F600', 'P-900', 98765, 98765);

-- verify the new compatibility record
SELECT * FROM CompatibleParts
WHERE bike_code = 'BK-F600' AND part_code = 'P-900';



-- 2nd. COMMAND: UPDATE STATEMENT --

-- Example 3:
-- John changes his phone number; the shop updates his contact info.
UPDATE Customer
SET phone_number = '99887766'
WHERE customerCPR = '1308981817';

-- Verify that the phone number was updated
SELECT first_name, last_name, phone_number
FROM Customer
WHERE customerCPR = '1308981817';


-- Example 4: 
-- The ongoing repair job (repair_ID = 1) is updated to include total cost.
-- This value is derived from used parts but can also be updated manually.
UPDATE RepairJobs
SET total_cost = 520.00
WHERE repair_ID = 1;

-- Verify that the total cost was updated
SELECT repair_ID, customerCPR, bike_code, total_cost
FROM RepairJobs
WHERE repair_ID = 1;



-- 3rd. DELETE STATEMENTS --

-- Example 5: 
-- An old test repair (repair_ID = 7) was mistakenly entered and had no parts used.
-- The shop removes it to keep the system clean.
DELETE FROM RepairJobs
WHERE repair_ID = 7;

-- Verify that the repair was deleted
SELECT * FROM RepairJobs
WHERE repair_ID = 7;  -- Here it should return an empty result set


-- Example 6: 
-- Similarly a discontinued part from manufacturer 55555 ("P-300") is removed.
-- We do it stepwise:
-- Step 1: is to remove the repair usages of that part first (to avoid FK violation)
DELETE FROM Uses
WHERE part_code = 'P-300' AND part_manufacturer = 55555;

-- Step 2: and then delete the part itself
DELETE FROM Parts
WHERE part_code = 'P-300' AND manufacturer_ID = 55555;

-- Verify that both the part and its uses are gone
SELECT * FROM Parts
WHERE part_code = 'P-300' AND manufacturer_ID = 55555;

SELECT * FROM Uses
WHERE part_code = 'P-300' AND part_manufacturer = 55555;


--
-- NEXT PART
--

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

--
-- NEXT PART
--

-- FUNCTION
-- Lets check repairjobs first. Should be all nulls in cost
SELECT * FROM RepairJobs;

DROP FUNCTION IF EXISTS totalCost;
DELIMITER //
CREATE FUNCTION totalCost (vrepair_ID INT) RETURNS DECIMAL(10,2)
BEGIN
    DECLARE TotalUnitPrice DECIMAL(10,2);

    SELECT SUM(Uses.quantity * Parts.unit_price)
    INTO TotalUnitPrice
    FROM Uses, Parts
    WHERE Uses.repair_ID = vrepair_ID
      AND Uses.part_code = Parts.part_code
      AND Uses.part_manufacturer = Parts.manufacturer_ID;

    RETURN TotalUnitPrice;
END//
DELIMITER ;

-- now test (note that total_cost for job 7 should remain at null since no parts exists for that job)
UPDATE RepairJobs
SET total_cost = totalCost(repair_ID);

SELECT * FROM RepairJobs;



/*
PROCEDURE

-- error code 45000 source : https://dev.mysql.com/doc/refman/8.4/en/signal.html
A procedure that, given a part, a quantity, and a repair job, if the part can be
used by the bike being repaired, adds the specified quantity of that part to
the repair job

A part is identified by : part_code, manufacturer_ID

A Repair Job is identified by : repair id

Remember to refresh "BikeShopDB.sql" upon testing.

*/

-- Look in uses first
SELECT * FROM uses WHERE part_code = 'P-400' OR part_code = 'P-600';

DROP PROCEDURE IF EXISTS InsertParts;
DELIMITER //
CREATE PROCEDURE InsertParts (
    IN vPart_Code VARCHAR(10), 
    IN vManufacturer_ID INT, 
    IN vQuantity INT, 
    IN vRepair_ID INT
)
BEGIN
    DECLARE vExists INT;
    DECLARE vCompatible INT;
    DECLARE vBikeCode VARCHAR(10);
    DECLARE vBikeManu INT;

    -- Find the bike being repaired
    SELECT bike_code, bike_manufacturer
    INTO vBikeCode, vBikeManu
    FROM RepairJobs
    WHERE repair_ID = vRepair_ID;

    -- Check if the part is compatible with that bike
    SELECT COUNT(*)
    INTO vCompatible
    FROM CompatibleParts
    WHERE bike_code = vBikeCode
      AND bike_manufacturer = vBikeManu
      AND part_code = vPart_Code
      AND part_manufacturer = vManufacturer_ID;

    -- If incompatible: stop the procedure with error of course
    IF vCompatible = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Part is NOT compatible with this bike.';
    END IF;

    -- Check if the part already exists in Uses
    SELECT COUNT(*)
    INTO vExists
    FROM Uses
    WHERE part_code = vPart_Code
      AND part_manufacturer = vManufacturer_ID
      AND repair_ID = vRepair_ID;

    -- Update existing part qty
    IF vExists > 0 THEN
        UPDATE Uses
        SET quantity = quantity + vQuantity
        WHERE part_code = vPart_Code
          AND part_manufacturer = vManufacturer_ID
          AND repair_ID = vRepair_ID;

    -- Insert new since there wasnt one already
    ELSE
        INSERT INTO Uses (part_code, part_manufacturer, repair_ID, quantity)
        VALUES (vPart_Code, vManufacturer_ID, vRepair_ID, vQuantity);
    END IF;

END //
DELIMITER ;


--  Test the procedure
-- The first one adds 3 P-400 parts that come from manufacturer[55555] into the repair-job with id [5].
-- This information stored in the uses table
CALL InsertParts('P-400', 55555, 3, 5); -- No parts already in uses for that repair job, so it inserts
CALL InsertParts('P-600', 98765, 5, 5); -- Those parts already exist for that repair job, so it updates

-- Look in uses again
SELECT * FROM uses WHERE part_code = 'P-400' OR part_code = 'P-600'; -- You can se the correct jobs update quantity and the others stay the same


-- TRIGGER
-- error code 45000 source : https://dev.mysql.com/doc/refman/8.4/en/signal.html
DROP TRIGGER IF EXISTS tooMuch;
DELIMITER //
CREATE TRIGGER tooMuch
BEFORE INSERT ON repairJobs
FOR EACH ROW
BEGIN
    IF NEW.total_cost > 100000 OR NEW.duration > 4320 THEN
        SIGNAL SQLSTATE '45000'
            SET MYSQL_ERRNO = 1525,
                MESSAGE_TEXT = 'Too expensive or too long';
    END IF;
END //

DELIMITER ;

-- Test if it throws an error here. It should do of course "Too expensive or too long"
INSERT INTO RepairJobs
(repair_ID, bike_code, bike_manufacturer, customerCPR, repair_date, duration, total_cost)
VALUES
(100, 'BK-A100', 11111, '1308981817', '2025-06-01', 120, 200000);

