-- error code 45000 source : https://dev.mysql.com/doc/refman/8.4/en/signal.html

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

