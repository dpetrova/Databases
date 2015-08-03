/* Problem 3. Create the same table in MySQL
--Your task is to create the same table in MySQL and partition it by date (1990, 2000 and 2010). 
--Fill 1 000 000 log entries. Compare the searching speed in all partitions (random dates) to certain 
--partition (e.g. year 1995).
*/
CREATE DATABASE PerformanceDB

USE PerformanceDB

CREATE TABLE Messages(  
  MsgText nvarchar(300),
  MsgDate datetime  
)
PARTITION BY RANGE(YEAR(MsgDate))
(
	PARTITION p1 VALUES LESS THAN (2016),
    PARTITION p2 VALUES LESS THAN (2017),
    PARTITION p3 VALUES LESS THAN MAXVALUE
);


DELIMITER //
CREATE PROCEDURE fillData()
BEGIN
	DECLARE entries INT;
    SET entries = 1;
    WHILE (entries <= 100000) DO
		INSERT INTO Messages
		SELECT CONCAT('The text is ', CONVERT(entries, char(5))), ADDDATE(CURDATE(), INTERVAL entries * 10 MINUTE);
		SET entries = entries + 1;
	END WHILE;
END; //
DELIMITER ;

CALL fillData();

SELECT min(MsgDate), max(MsgDate) FROM Messages;


SELECT * FROM Messages
WHERE YEAR(MsgDate) IN (2016);


SELECT * FROM Messages
WHERE YEAR(MsgDate) between 2015 and 2017;






