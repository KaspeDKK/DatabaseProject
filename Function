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
