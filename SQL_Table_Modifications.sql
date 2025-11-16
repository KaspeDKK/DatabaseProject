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
