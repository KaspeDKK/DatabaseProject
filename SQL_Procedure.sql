/*
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
-- Inserts 3 P-300 parts that come from manufacturer[55555] into the repair-job with id [1]. 
-- This information stored in the uses table
CALL InsertParts('P-400', 55555, 3, 5); -- No parts already in uses for that repair job, so it inserts
CALL InsertParts('P-600', 98765, 5, 5); -- Those parts already exist for that repair job, so it updates

-- Look in uses again
SELECT * FROM uses WHERE part_code = 'P-400' OR part_code = 'P-600'; -- You can se the correct jobs update quantity and the others stay the same
