--Problem 1. Create a database with two tables
--Persons (id (PK), first name, last name, SSN) and Accounts (id (PK), person id (FK), balance). 
--Insert few records for testing. 
--Write a stored procedure that selects the full names of all persons.
CREATE DATABASE BankSystem
GO

USE BankSystem
GO

CREATE TABLE Persons(
	Id int IDENTITY,
	FirstName nvarchar(10) NOT NULL ,	
	LastName nvarchar(50) NOT NULL,
	SSN nvarchar(50) NOT NULL UNIQUE,
	CONSTRAINT PK_Persons PRIMARY KEY(Id)	
	)
GO

CREATE TABLE Accounts(
	Id int IDENTITY NOT NULL,
	PersonId int NOT NULL,
	Balance money NOT NULL,		
	CONSTRAINT PK_Accounts PRIMARY KEY(Id),
	CONSTRAINT FK_Accounts_Persons FOREIGN KEY(PersonId) REFERENCES Persons(Id)	
	)
GO

INSERT INTO Persons (FirstName, LastName, SSN)
	VALUES ('Minka', 'Mincheva', '721-07-4426')
INSERT INTO Persons (FirstName, LastName, SSN)
	VALUES ('Boiko', 'Boichev', '999-06-3456')
INSERT INTO Persons (FirstName, LastName, SSN)
	VALUES ('Rumen', 'Hristov', '789-76-9127')
INSERT INTO Persons (FirstName, LastName, SSN)
	VALUES ('Georgi', 'Ganchev', '123-11-1334')
INSERT INTO Persons (FirstName, LastName, SSN)
	VALUES ('Rosa', 'Ilieva', '990-22-4455')

INSERT INTO Accounts (PersonId, Balance)
	VALUES (1, 3000.99)
INSERT INTO Accounts (PersonId, Balance)
	VALUES (2, 100.10)
INSERT INTO Accounts (PersonId, Balance)
	VALUES (3, 25000.00)
INSERT INTO Accounts (PersonId, Balance)
	VALUES (4, 460.25)
INSERT INTO Accounts (PersonId, Balance)
	VALUES (5, 1000.00)
GO

CREATE PROC dbo.usp_GetFullNames
AS
  SELECT FirstName + ' ' + LastName AS [Full Name]
  FROM Persons
GO

EXEC dbo.usp_GetFullNames
GO


--Problem 2. Create a stored procedure
--Your task is to create a stored procedure that accepts a number as a parameter
--and returns all persons who have more money in their accounts than the supplied number.
CREATE PROC dbo.usp_GetPersonsByMoney(@minMoney money)
AS
  SELECT FirstName + ' ' + LastName AS [Full Name], a.Balance
  FROM Persons p JOIN Accounts a
    ON a.PersonId = p.Id
  WHERE a.Balance > @minMoney
GO

EXEC dbo.usp_GetPersonsByMoney 1000
GO


--Problem 3. Create a function with parameters
--Your task is to create a function that accepts as parameters – sum, yearly interest rate and number of months.
--It should calculate and return the new sum. 
--Write a SELECT to test whether the function works as expected.
CREATE FUNCTION ufn_CalcInterest(@sum money, @yearlyInterestRate decimal, @numOfMonths int) RETURNS money
AS
  BEGIN    
	DECLARE @interest money	
	SET @interest = @sum + @sum * @numOfMonths * @yearlyInterestRate / (12 * 100)
	RETURN @interest
  END
GO

SELECT
	FirstName + ' ' + LastName AS [Person],
	dbo.ufn_CalcInterest(a.Balance, 4.9, 24) AS Interest
FROM Persons p JOIN Accounts a
  ON a.PersonId = p.Id
GO

--Problem 4. Create a stored procedure that uses the function from the previous example.
--Your task is to create a stored procedure that uses the function from the previous example to give an 
--interest to a person's account for one month. It should take the AccountId and the interest rate as parameters.
CREATE PROC usp_PersonInterestPerMonth(@accountId int, @interestRate decimal)
AS
  DECLARE @newBalance money
  DECLARE @oldBalnce money
  SET @oldBalnce = 
	(SELECT Balance FROM Accounts
	 WHERE Id = @accountId)
  SET @newBalance = dbo.ufn_CalcInterest(@oldBalnce, @interestRate, 1)
  SELECT @newBalance
GO

EXEC usp_PersonInterestPerMonth 3, 4.05
GO


--Problem 5. Add two more stored procedures WithdrawMoney (AccountId, money)
--and DepositMoney (AccountId, money) that operate in transactions.
CREATE PROC usp_WithdrawMoney (@accountId int, @money money)
AS
  DECLARE @mewBalance money
  SET @mewBalance = (SELECT Balance FROM Accounts WHERE Id = @accountId)
  BEGIN TRAN
	IF (@mewBalance >= @money)
		BEGIN			
			SET @mewBalance -= @money
			UPDATE Accounts
			SET Balance = @mewBalance WHERE Id = @AccountId
			COMMIT TRAN
			PRINT 'Transaction complete'
		END
	ELSE
		BEGIN
			ROLLBACK TRAN
			RAISERROR('Transaction aborted. There are not enough money', 16, 1)			
		END
GO

SELECT * FROM Accounts
EXEC usp_WithdrawMoney	2, 1000
SELECT * FROM Accounts
EXEC usp_WithdrawMoney	3, 10000  	  	
SELECT * FROM Accounts
GO

CREATE PROC usp_DepositMoney (@accountId int, @money money)
AS
  DECLARE @mewBalance money
  SET @mewBalance = (SELECT Balance FROM Accounts WHERE Id = @accountId)
  BEGIN TRAN
	IF (@money < 0)
		BEGIN
			ROLLBACK TRAN
			RAISERROR('Transaction aborted. The amount money must be positive value', 16, 1)			
		END		
	ELSE
		BEGIN			
			SET @mewBalance += @money
			UPDATE Accounts
			SET Balance = @mewBalance WHERE Id = @AccountId
			COMMIT TRAN
			PRINT 'Transaction complete'
		END
GO

SELECT * FROM Accounts
EXEC usp_DepositMoney	2, -1000
SELECT * FROM Accounts
EXEC usp_DepositMoney	2, 5000  	  	
SELECT * FROM Accounts
GO


--Problem 6. Create table Logs.
--Create another table – Logs (LogID, AccountID, OldSum, NewSum).
--Add a trigger to the Accounts table that enters a new entry into the Logs table every time
--the sum on an account changes.
CREATE TABLE Logs(
	Id int IDENTITY(1,1) NOT NULL,
	AccountId int NOT NULL,
	OldSum money NOT NULL,
	NewSum money NOT NULL,		
	CONSTRAINT PK_Logs PRIMARY KEY(Id),
	CONSTRAINT FK_Logs_Accounts FOREIGN KEY(AccountId) REFERENCES Accounts(Id)	
	)
GO

CREATE TRIGGER tr_LogsUpdate ON Accounts FOR UPDATE
AS
	INSERT INTO Logs(AccountId, OldSum, NewSum)
	VALUES((SELECT Id FROM INSERTED), (SELECT Balance FROM DELETED), (SELECT Balance FROM INSERTED))	
GO

EXEC usp_DepositMoney	1, 300
SELECT * FROM Logs
GO


--Problem 7. Define function in the SoftUni database.
--Define a function in the database SoftUni that returns all Employee's names (first or middle or last name)
--and all town's names that are comprised of given set of letters. 
--Example: 'oistmiahf' will return 'Sofia', 'Smith', but not 'Rob' and 'Guy'.
USE SoftUni
GO

CREATE FUNCTION ufn_checkWord(@setOfLetters nvarchar(50), @word nvarchar(50)) RETURNS bit
AS
	BEGIN
		DECLARE @index int = 1
        WHILE (@index <= LEN(@word))
        BEGIN
			IF (@setOfLetters NOT LIKE '%' + SUBSTRING(@word, @index, 1) + '%' ) 
			BEGIN  
                RETURN 0
			END
        SET @index += 1
		END
        RETURN 1
	END
GO

--DECLARE db_cursor CURSOR READ_ONLY FOR
--	SELECT e.FirstName, e.MiddleName, e.LastName, t.Name 
--	FROM Employees e JOIN Addresses a
--		ON e.AddressID = a.AddressID
--	JOIN Towns t
--		ON a.TownID = t.TownID

--OPEN db_cursor
--DECLARE @firstName nvarchar(50), @middleName nvarchar(50), @lastName nvarchar(50), @town nvarchar(50)
--FETCH NEXT FROM db_cursor INTO @firstName, @middleName, @lastName, @town

--WHILE @@FETCH_STATUS = 0
--	BEGIN	
--		IF dbo.ufn_checkWord('oistmiahf', @firstName) = 1
--		BEGIN
--			print @firstName
--		END
--		IF dbo.ufn_checkWord('oistmiahf', @middleName) = 1
--		BEGIN
--			print @middleName
--		END		
--		IF dbo.ufn_checkWord('oistmiahf', @lastName) = 1
--		BEGIN
--			print @lastName
--		END	
--		IF dbo.ufn_checkWord('oistmiahf', @town) = 1
--		BEGIN
--			print @town
--		END	
--	FETCH NEXT FROM db_cursor INTO @firstName, @middleName, @lastName, @town
--END

--CLOSE db_cursor
--DEALLOCATE db_cursor

CREATE FUNCTION ufn_InsertMatchedWords()
RETURNS @tbl_MatchedWords TABLE (
	word nvarchar(100) NULL)
AS
BEGIN
INSERT INTO @tbl_MatchedWords
SELECT FirstName
 FROM Employees 
 WHERE dbo.ufn_checkWord('oistmiahf', FirstName) = 1
 INSERT INTO @tbl_MatchedWords
SELECT MiddleName
 FROM Employees 
  WHERE dbo.ufn_checkWord('oistmiahf', MiddleName) = 1
  INSERT INTO @tbl_MatchedWords
SELECT LastName
 FROM Employees
   WHERE dbo.ufn_checkWord('oistmiahf', LastName) = 1
  INSERT INTO @tbl_MatchedWords
SELECT Name
 FROM Towns
   WHERE dbo.ufn_checkWord('oistmiahf', Name) = 1
  RETURN
END
GO

SELECT * FROM ufn_InsertMatchedWords()
GO


--Problem 8. Using database cursor write a T-SQL
--Using database cursor write a T-SQL script that scans all employees and their addresses
--and prints all pairs of employees that live in the same town.
--(this code is borrowed from crazy7)
DECLARE db_Cursor CURSOR READ_ONLY FOR SELECT
	e.FirstName + ' ' + e.LastName, t.Name
FROM Employees e
	JOIN Addresses a
		ON a.AddressID = e.AddressID
	JOIN Towns t
		ON t.TownID = a.TownID

OPEN db_Cursor
DECLARE  @town nvarchar(50), @fullName nvarchar(50) ,@currentTown nvarchar(50), @currentFullName nvarchar(50)
FETCH NEXT FROM db_Cursor INTO @fullName, @town
WHILE @@FETCH_STATUS = 0
  BEGIN
	SET @currentTown = @town
	SET @currentFullName = @fullName
	FETCH NEXT FROM db_Cursor INTO @fullName, @town
	IF( @currentTown = @town)
		PRINT @town + ': ' + @fullName + ' & ' + @currentFullName
  END
CLOSE db_Cursor
DEALLOCATE db_Cursor


--Problem 9. Define a .NET aggregate function
--Define a .NET aggregate function StrConcat that takes as input a sequence of strings and return
--a single string that consists of the input strings separated by ','. 
--(this code is borrowed from  G.Burlakova)
-- More detailded description of this task you can find here
-- http://developmentsimplyput.blogspot.com/2013/03/creating-sql-custom-user-defined.html

--- Help instructions ---
--- Before run the script to create the aggregate function dbo.StrConcat
--- and after that test it you will need to ensure that the
--- ConcatenateStrings.dll has the correct location - in this case C:\ConcatenateStrings.dll

-- 1.FirstStep
-- Turning on CLR functionality
-- By default, CLR is disabled in SQL Server so to turn it on
-- we need to run this command against our database
EXEC sp_configure 'clr enabled', 1
GO
RECONFIGURE
GO

-- 2. SecondStep
-- Creating the SQL assembly and linking it to the C# library DLL
CREATE ASSEMBLY ConcatenateStrings
AUTHORIZATION dbo
FROM 'C:\ConcatenateStrings.dll' --- Please be sure that the dll file is here
WITH PERMISSION_SET = SAFE
GO
 
-- 3. ThirdStep
CREATE AGGREGATE dbo.StrConcat(@value nvarchar(MAX)) RETURNS nvarchar(MAX)
EXTERNAL NAME ConcatenateStrings.[ConcatenateStrings.StringConcatenator]

/*
DROP AGGREGATE dbo.StrConcat
DROP ASSEMBLY ConcatenateStrings
*/

USE SoftUni
SELECT dbo.StrConcat(FirstName + ' ' + LastName)
FROM Employees
