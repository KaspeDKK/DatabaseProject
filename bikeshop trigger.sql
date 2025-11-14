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

