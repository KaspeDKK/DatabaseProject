/*

A procedure that, given a part, a quantity, and a repair job, if the part can be
used by the bike being repaired, adds the specified quantity of that part to
the repair job

A part is identified by : part_code, manufacturer_ID

A Repair Job is identified by : repair id

Remember to refresh "BikeShopDB.sql" upon testing.

*/

-- Look in uses first
SELECT * FROM uses WHERE part_code = 'P-300' AND repair_ID = 1;

DROP PROCEDURE IF EXISTS InsertParts;
DELIMITER //
CREATE PROCEDURE InsertParts (
IN vPart_Code VARCHAR(10), 
IN vManufacturer_ID INT, 
IN vQuantity INT, 
IN vRepair_ID INT
)

BEGIN
/* 	If the part is not already in uses with that specific repair job, then create it with the assigned quantity
	If the part is ALREADY in uses with that specific repair job, then add the assigned quantity to the current quantity */ 
DECLARE vExists INT;

SELECT COUNT(*) INTO vExists FROM uses 
	WHERE part_code = vPart_Code
    AND part_manufacturer = vManufacturer_ID
    AND repair_ID = vRepair_ID;

IF vExists > 0 THEN
	UPDATE Uses
	SET quantity = quantity + vQuantity
	WHERE part_code = vPart_Code
	  AND part_manufacturer = vManufacturer_ID
	  AND repair_ID = vRepair_ID;
ELSE
	INSERT INTO Uses (part_code, part_manufacturer, repair_ID, quantity)
	VALUES (vPart_Code, vManufacturer_ID, vRepair_ID, vQuantity);
END IF;
END //
DELIMITER ;

# Test the procedure
-- Inserts 3 P-300 parts that come from manufacturer[55555] into the repair-job with id [1]. 
-- This information stored in the uses table
CALL InsertParts('P-300', 55555, 3, 1); -- Those parts already exist for that repair job, so it updates
CALL InsertParts('P-600', 98765, 5, 1); -- No parts already in uses for that repair job, so it inserts

-- Look in uses again
SELECT * FROM uses WHERE part_code = 'P-300' OR part_code = 'P-600' AND repair_ID = 1;
