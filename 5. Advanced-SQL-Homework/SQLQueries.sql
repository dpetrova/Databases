-- Problem 1. Write a SQL query to find the names and salaries of the employees that take the minimal salary in the company.
-- Use a nested SELECT statement.
SELECT FirstName, LastName, Salary
FROM Employees
WHERE Salary = (SELECT MIN(Salary) FROM Employees)


--Problem 2. Write a SQL query to find the names and salaries of the employees that have a salary
-- that is up to 10% higher than the minimal salary for the company.
SELECT FirstName, LastName, Salary
FROM Employees
WHERE Salary <= (SELECT MIN(Salary) * 1.1 FROM Employees)


--Problem 3. Write a SQL query to find the full name, salary and department of the employees
-- that take the minimal salary in their department.
--Use a nested SELECT statement.
SELECT e.FirstName, e.LastName, e.Salary, d.Name AS Department
FROM Employees e JOIN Departments d
ON e.DepartmentID = d.DepartmentID
WHERE Salary =
	(SELECT MIN(Salary) FROM Employees 
	 WHERE DepartmentID = e.DepartmentID)
ORDER BY d.DepartmentID


--Problem 4. Write a SQL query to find the average salary in the department #1.
SELECT AVG(Salary) [Average Salary]
FROM Employees
WHERE DepartmentID = 1


--Problem 5. Write a SQL query to find the average salary in the "Sales" department.
SELECT AVG(Salary) [Average Salary]
FROM Employees e JOIN Departments d
ON e.DepartmentID = d.DepartmentID
WHERE d.Name = 'Sales'


--Problem 6. Write a SQL query to find the number of employees in the "Sales" department.
SELECT COUNT(*) [Sales Employees Count]
FROM Employees e JOIN Departments d
ON e.DepartmentID = d.DepartmentID
WHERE d.Name = 'Sales'


--Problem 7. Write a SQL query to find the number of all employees that have manager.
SELECT COUNT(ManagerID) [Employees with manager]
FROM Employees
--WHERE ManagerID IS NOT NULL


--Problem 8. Write a SQL query to find the number of all employees that have no manager.
SELECT COUNT(*) [Employees without manager]
FROM Employees
WHERE ManagerID IS NULL


--Problem 9. Write a SQL query to find all departments and the average salary for each of them.
SELECT d.Name AS [Department], AVG(Salary) AS [Average Salary]
FROM Departments d JOIN Employees e
  ON e.DepartmentID = d.DepartmentID
GROUP BY d.Name


--Problem 10. Write a SQL query to find the count of all employees in each department and for each town.
SELECT t.Name [Town], d.Name [Department], COUNT(*) [Employees Count]
FROM Employees e 
	JOIN  Departments d
	  ON d.DepartmentID = e.DepartmentID
	JOIN Addresses a
	  ON  e.AddressID = a.AddressID
	JOIN Towns t
	  ON  a.TownID = t.TownID
GROUP BY t.Name, d.Name


--Problem 11. Write a SQL query to find all managers that have exactly 5 employees.
--Display their first name and last name.
SELECT e.FirstName, e.LastName, m.[Employees count]
FROM Employees e
	JOIN 
		(SELECT ManagerID, COUNT(ManagerID) AS [Employees count]
		FROM Employees
		GROUP BY ManagerID) m
	ON m.ManagerID = e.EmployeeID
WHERE m.[Employees count] = 5

--or
SELECT m.FirstName, m.LastName
FROM Employees m
WHERE (SELECT COUNT(*) FROM Employees e WHERE e.ManagerID = m.EmployeeID) = 5
--or
SELECT m.FirstName, m.LastName, COUNT(e.ManagerID) AS [Employees count]
FROM Employees e 
	JOIN Employees m
		ON m.EmployeeID = e.ManagerID
GROUP BY m.ManagerID, m.FirstName, m.LastName
HAVING COUNT(e.ManagerID) = 5


--Problem 12. Write a SQL query to find all employees along with their managers.
--For employees that do not have manager display the value "(no manager)".
SELECT e.FirstName + ' ' + e.LastName AS [Employee], 
	   ISNULL(m.FirstName + ' ' + m.LastName, 'no manager') AS [Manager]
FROM Employees e LEFT OUTER JOIN Employees m
  ON e.ManagerID = m.EmployeeID


--Problem 13. Write a SQL query to find the names of all employees whose last name is exactly 5 characters long. 
--Use the built-in LEN(str) function.
SELECT FirstName, LastName
FROM Employees
WHERE LEN(LastName) = 5


--Problem 14. Write a SQL query to display the current date and time in the following format
-- "day.month.year hour:minutes:seconds:milliseconds". 
-- Search in Google to find how to format dates in SQL Server.
SELECT CONVERT(varchar, GETDATE(), 113) AS 'Current date and time'
--or
SELECT CONVERT(nvarchar, GETDATE(), 4) + ' ' + CONVERT(nvarchar, GETDATE(), 114) AS [DateTime]


--Problem 15. Write a SQL statement to create a table Users.
--Users should have username, password, full name and last login time. 
--Choose appropriate data types for the table fields. 
--Define a primary key column with a primary key constraint. 
--Define the primary key column as identity to facilitate inserting records. 
--Define unique constraint to avoid repeating usernames. 
--Define a check constraint to ensure the password is at least 5 characters long.
CREATE TABLE Users(
	Id int IDENTITY,
	Username nvarchar(10) NOT NULL UNIQUE,
	[Password] nvarchar(50) NOT NULL,
	FullName nvarchar(50) NOT NULL,
	LoginTime datetime NOT NULL,
	CONSTRAINT PK_Users PRIMARY KEY(Id),
	CONSTRAINT CHK_Password CHECK(LEN([Password]) > 5)
	)
GO


--Problem 16. Write a SQL statement to create a view that displays the users from the Users table 
--that have been in the system today.
--Test if the view works correctly.
CREATE VIEW [Users in system today] AS
SELECT * FROM Users
WHERE DAY(LoginTime) = DAY(GETDATE())
GO


--Problem 17. Write a SQL statement to create a table Groups. 
--Groups should have unique name (use unique constraint). Define primary key and identity column.
CREATE TABLE Groups(
	Id int IDENTITY,
	Name nvarchar(50) NOT NULL UNIQUE,
	CONSTRAINT PK_Groups PRIMARY KEY(Id)
	)
GO


--Problem 18. Write a SQL statement to add a column GroupID to the table Users.
--Fill some data in this new column and as well in the Groups table.
--Write a SQL statement to add a foreign key constraint between tables Users and Groups tables.
ALTER TABLE Users
ADD GroupID int FOREIGN KEY REFERENCES Groups(Id)


--Problem 19. Write SQL statements to insert several records in the Users and Groups tables.
INSERT INTO Users
VALUES('golemia', 'azsymgolemia', 'Angel Angelov', GETDATE(), 1)

INSERT INTO Groups
VALUES('Math'), ('Sport')


--Problem 20. Write SQL statements to update some of the records in the Users and Groups tables.
UPDATE Users
SET [Password] = 'changepassword'
WHERE Username = 'malkia'


--Problem 21. Write SQL statements to delete some of the records from the Users and Groups tables.
DELETE FROM Users
WHERE Username = 'malkia'


--Problem 22. Write SQL statements to insert in the Users table the names of all employees
--from the Employees table.
--Combine the first and last names as a full name. 
--For username use the first letter of the first name + the last name (in lowercase). 
--Use the same for the password, and NULL for last login time.
INSERT INTO Users
SELECT 
	LOWER(SUBSTRING(FirstName, 0, 1) + LastName + CONVERT(nvarchar(max), EmployeeID)),
	LOWER(SUBSTRING(FirstName, 0, 1) + LastName + 'pass'),
	FirstName + ' ' + LastName,
	GETDATE(),
	1
FROM Employees


--Problem 23. Write a SQL statement that changes the password to NULL for all users 
--that have not been in the system since 10.03.2010.
UPDATE Users
SET [Password] = NULL
WHERE LoginTime < CAST('2010-10-03' AS smalldatetime);


--Problem 24. Write a SQL statement that deletes all users without passwords (NULL password).
DELETE FROM Users
WHERE [Password] IS NULL


--Problem 25. Write a SQL query to display the average employee salary by department and job title.
SELECT d.Name [Department], e.JobTitle, AVG(Salary) [Average Salary]
FROM Employees e 
	JOIN  Departments d
	  ON e.DepartmentID = d.DepartmentID	
GROUP BY d.Name, e.JobTitle
ORDER BY d.Name


--Problem 26. Write a SQL query to display the minimal employee salary by department 
--and job title along with the name of some of the employees that take it.
SELECT d.Name AS [Department], e.JobTitle, e.FirstName, e.LastName, e.Salary
FROM Employees e JOIN Departments d
  ON e.DepartmentID = d.DepartmentID
WHERE Salary = (SELECT MIN(Salary) FROM Employees
				WHERE DepartmentID = e.DepartmentID)
GROUP BY d.Name, e.JobTitle, e.FirstName, e.LastName, e.Salary


--Problem 27. Write a SQL query to display the town where maximal number of employees work.
SELECT TOP 1 * FROM (SELECT t.Name AS Town, COUNT(t.TownID) AS [Maximal number of Employees]
FROM Employees e JOIN Addresses a
  ON e.AddressID = a.AddressID
JOIN Towns t
  ON a.TownID = t.TownID
GROUP BY t.Name, t.TownID) m
ORDER BY m.[Maximal number of Employees] DESC


--Problem 28. Write a SQL query to display the number of managers from each town.
SELECT mt.Town, COUNT(*) AS [Number of managers]
FROM (SELECT DISTINCT e.EmployeeID, t.Name AS Town
FROM Employees e 
	JOIN Employees m
		ON m.ManagerID = e.EmployeeID
	JOIN Addresses a
		ON  a.AddressID = e.AddressID
	JOIN Towns t
		ON a.TownID = t.TownID) AS mt
GROUP BY mt.Town


--Problem 29. Write a SQL to create table WorkHours to store work reports for each employee.
--Each employee should have id, date, task, hours and comments. 
--Don't forget to define identity, primary key and appropriate foreign key.
CREATE TABLE WorkHours(
	Id int IDENTITY,
	EmpID int NOT NULL,
	[Date] datetime NOT NULL,
	Task nvarchar(100) NOT NULL,
	[Hours] int NOT NULL,
	Comments text
	CONSTRAINT PK_WorkHours PRIMARY KEY(Id),
	CONSTRAINT FK_WorkHours_Employees FOREIGN KEY(EmpID) REFERENCES Employees(EmployeeID)
	)
GO

--or
CREATE TABLE WorkHours(
	Id int PRIMARY KEY IDENTITY NOT NULL,
	EmpID int FOREIGN KEY REFERENCES Employees(EmployeeID) NOT NULL,
	[Date] datetime NOT NULL,
	Task nvarchar(100) NOT NULL,
	[Hours] int NOT NULL,
	Comments text NULL	
	)
GO


--Problem 30. Issue few SQL statements to insert, update and delete of some data in the table.
INSERT INTO WorkHours
VALUES(ABS(CHECKSUM(NewId())) % (SELECT EmployeeID FROM Employees WHERE EmployeeID = (SELECT MAX(EmployeeID)FROM Employees)), -- it generates random int bettween 0 and max EmployeeID
	   GETDATE(),
	   'Make final investigation report',
	   40,
	   NULL)

INSERT INTO WorkHours
VALUES(ABS(CHECKSUM(NewId())) % (SELECT EmployeeID FROM Employees WHERE EmployeeID = (SELECT MAX(EmployeeID)FROM Employees)), -- it generates random int bettween 0 and max EmployeeID
	   DATEADD(DAY, 10, GETDATE()),
	   'Perform validation tests of FBD',
	   82,
	   NULL)

INSERT INTO WorkHours
VALUES(ABS(CHECKSUM(NewId())) % (SELECT EmployeeID FROM Employees WHERE EmployeeID = (SELECT MAX(EmployeeID)FROM Employees)), -- it generates random int bettween 0 and max EmployeeID
	   CONVERT(DATETIME, '20150701', 112),
	   'Samle validation probes',
	   6,
	   'Probes from water and chemical resdues')

UPDATE WorkHours
SET [Date] = CONVERT(DATETIME, '20150820', 112)
WHERE [Date] = CONVERT(DATETIME, '20150701', 112)

DELETE FROM Users
WHERE Id = 2


--Problem 31. Define a table WorkHoursLogs to track all changes in the WorkHours table with triggers.
--For each change keep the old record data, the new record data and the command (insert / update / delete).
--(this code is borrowed from ZvetanIG!!!)
CREATE TABLE WorkHoursLogs
(
        Id int PRIMARY KEY IDENTITY NOT NULL,
		Message nvarchar(150) NOT NULL,
		DateOfChange datetime NOT NULL
)
GO

CREATE TRIGGER  tr_WorkHoursInsert 
ON WorkHours
 FOR INSERT
AS 
	INSERT INTO WorkHoursLogs (Message, DateOfChange)
	VALUES('Added row', GETDATE ( ))
GO

CREATE TRIGGER  tr_WorkHoursDelete 
ON WorkHours
 FOR DELETE
AS 
	INSERT INTO WorkHoursLogs (Message, DateOfChange)
	VALUES('Deleted row', GETDATE ( ))
GO

CREATE TRIGGER  tr_WorkHoursUpdate
ON WorkHours
 FOR UPDATE
AS 
	INSERT INTO WorkHoursLogs (Message, DateOfChange)
	VALUES('Update row', GETDATE ( ))
GO

INSERT INTO WorkHours
VALUES(ABS(CHECKSUM(NewId())) % (SELECT EmployeeID FROM Employees WHERE EmployeeID = (SELECT MAX(EmployeeID)FROM Employees)), -- it generates random int bettween 0 and max EmployeeID
	   CONVERT(DATETIME, '20151210', 112),
	   'Start bach production of Epinefrin',
	   8,
	   NULL)

DELETE WorkHours
WHERE Id = 2

UPDATE WorkHours
SET Comments = 'Use substance 09-GB-1234'
WHERE Task = 'Start bach production of Epinefrin'


--Problem 32. Start a database transaction, delete all employees from the 'Sales' department 
--along with all dependent records from the pother tables. At the end rollback the transaction.
BEGIN TRAN
DELETE  Employees
WHERE DepartmentID = 
	(SELECT DepartmentID 
	 FROM Departments
	 WHERE Name = 'Sales')
	 SELECT * FROM Employees e
	JOIN Departments d
		ON e.DepartmentID = d.DepartmentID
WHERE d.Name = 'Sales'
ROLLBACK TRAN


--Problem 33. Start a database transaction and drop the table EmployeesProjects.
--Then how you could restore back the lost table data?
BEGIN TRAN
DROP TABLE EmployeesProjects
ROLLBACK TRAN


--Problem 34. Find how to use temporary tables in SQL Server.
--Using temporary tables backup all records from EmployeesProjects and restore them back 
--after dropping and re-creating the table.
SELECT * INTO ##TempTableProjects
FROM EmployeesProjects
 
DROP TABLE EmployeesProjects
 
CREATE TABLE EmployeesProjects
(
   EmployeeID INT FOREIGN KEY REFERENCES Employees(EmployeeID) NOT NULL,
   ProjectID INT FOREIGN KEY REFERENCES Projects(ProjectID) NOT NULL,
)
 
INSERT INTO EmployeesProjects
SELECT * FROM  ##TempTableProjects

