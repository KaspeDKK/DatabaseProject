/*

A procedure that, given a part, a quantity, and a repair job, if the part can be
used by the bike being repaired, adds the specified quantity of that part to
the repair job

A part is identified by : part_code, manufacturer_ID

A Repair Job is identified by : repair id

*/

DELIMITER //
CREATE PROCEDURE InsertParts (
IN vPart_Code VARCHAR(10), vManufacturer_ID INT, vQuantity INT, vRepair_ID INT)

BEGIN

/* If the part is not already in uses with that specific repair job, then create it with the assigned quantity
    If the part is ALREADY in uses with that specific repair job, then add the assigned quantity to the current quantity
*/ 

IF something = someginelse THEN

ELSE

END IF;

END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE InstBackup1 ()
BEGIN
	DECLARE vSQLSTATE CHAR(5) DEFAULT '00000';
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
	# this handler statement below ensures that
	# if an exception is raised by SQL during the transaction
	# then vSQLSTATE will be assigned a value <> '00000'
	# and continue
	BEGIN
		GET DIAGNOSTICS CONDITION 1
		vSQLSTATE = RETURNED_SQLSTATE;
	END;
    
	START TRANSACTION;
    
	DELETE FROM InstOld; -- CLEAR OLD BACKUP
	INSERT INTO InstOld (InstID, InstName, DeptName, Salary) SELECT * FROM instructor; -- INSERT COPY INTO BACKUP
	DELETE FROM InstLog; -- CLEAR LOGS
    
	-- SELECT vSQLSTATE;
    IF vSQLSTATE = '00000' THEN
		COMMIT; -- Backup Succesfull
    ELSE
		ROLLBACK; -- Backup failed - Restores logs and old backup
	END IF;
END//
DELIMITER ;

# Test the procedure before and after “DROP TABLE InstLog;”.
INSERT Instructor VALUES ('10000', 'Hansen', 'Comp. Sci.', 50000);
SELECT * FROM InstLog;
SET SQL_SAFE_UPDATES = 0;

CALL InstBackup1;

SELECT * FROM Instructor;
SELECT * FROM InstOld;
SELECT * FROM InstLog;

DROP TABLE InstLog;
CALL InstBackup1;

SELECT * FROM Instructor;
SELECT * FROM InstOld;