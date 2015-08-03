--Problem 1. Create a table in SQL Server
--Your task is to create a table in SQL Server with 10 000 000 entries (date + text).
--Search in the table by date range. Check the speed (without caching).
CREATE DATABASE PerformanceDB
GO

USE PerformanceDB
GO

CREATE TABLE Messages(
  MsgId int PRIMARY KEY IDENTITY(1,1) NOT NULL,
  MsgText nvarchar(MAX),
  MsgDate datetime  
)
GO

CREATE PROC dbo.usp_fillData(@entries int)
AS
	DECLARE @date datetime,
			@text nvarchar(MAX)
	SET @date = GETDATE()
	SET	@text = 'The date is '
	WHILE (@entries > 0)
	BEGIN
		INSERT INTO Messages
		VALUES(@text + CONVERT(nvarchar(MAX), @date), @date)
		SET @date = DATEADD(DAY, 1, @date)
		SET @entries -= 1
	END  
GO

EXEC dbo.usp_fillData 1000000
GO

--clean the cache
CHECKPOINT; 
GO 
DBCC DROPCLEANBUFFERS; 
GO

SELECT MsgDate
FROM Messages
WHERE MsgDate BETWEEN CONVERT(DATETIME, '01/01/2020') AND CONVERT(DATETIME, '01/01/5020')


--Problem 2. Add an index to speed-up the search by date 
--Your task is to add an index to speed-up the search by date. 
--Test the search speed (after cleaning the cache).
/*
Missing Index Details from SQLQueries.sql - (local).PerformanceDB (DANIELA-PC\Daniela (52))
The Query Processor estimates that implementing the following index could improve the query cost by 94.5104%.
*/

USE [PerformanceDB]
GO
CREATE NONCLUSTERED INDEX [IDX_Messages_MsgDate]
ON [dbo].[Messages] ([MsgDate])
GO



