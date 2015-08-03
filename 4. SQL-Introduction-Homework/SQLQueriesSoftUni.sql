--to execite a certan query just mark it and press F5

--Problem 4. Write a SQL query to find all information about all departments (use "SoftUni" database).
SELECT * FROM Departments


--Problem 5. Write a SQL query to find all department names.
SELECT Name FROM Departments


--Problem 6. Write a SQL query to find the salary of each employee. 
SELECT EmployeeID, FirstName, LastName, Salary
FROM Employees


--Problem 7. Write a SQL to find the full name of each employee.
SELECT FirstName + ' ' + ISNULL(MiddleName, '') + ' ' + LastName AS [Full Name]
FROM Employees
--ISNULL(MiddleName, '') means if MiddleName IS NULL replace it by ''


-- Problem 8.   Write a SQL query to find the email addresses of each employee.
-- Write a SQL query to find the email addresses of each employee. (by his first and last name).
-- Consider that the mail domain is softuni.bg. Emails should look like “John.Doe@softuni.bg".
-- The produced column should be named "Full Email Addresses".
SELECT FirstName + ' ' + LastName AS [Full Name],
	   FirstName + '.' + LastName + '@softuni.bg' AS [Full Email Addresses]
FROM Employees


--Problem 9. Write a SQL query to find all different employee salaries.
SELECT DISTINCT Salary
FROM Employees


--Problem 10. Write a SQL query to find all information about the employees whose job title is “Sales Representative“.
SELECT * FROM Employees
WHERE JobTitle = 'Sales Representative'


--Problem 11. Write a SQL query to find the names of all employees whose first name starts with "SA".
SELECT FirstName + ' ' + ISNULL(MiddleName, '') + ' ' + LastName AS [Full Name]
FROM Employees
WHERE FirstName LIKE 'SA%'


--Problem 12. Write a SQL query to find the names of all employees whose last name contains "ei".
SELECT FirstName + ' ' + ISNULL(MiddleName, '') + ' ' + LastName AS [Full Name]
FROM Employees
WHERE LastName LIKE '%ei%'


--Problem 13. Write a SQL query to find the salary of all employees whose salary is in the range [20000…30000].
SELECT FirstName + ' ' + LastName AS [Full Name],
	   Salary
FROM Employees
WHERE Salary BETWEEN 20000 AND 30000


--Problem 14. Write a SQL query to find the names of all employees whose salary is 25000, 14000, 12500 or 23600.
SELECT FirstName + ' ' + LastName AS [Full Name],
	   Salary
FROM Employees
WHERE Salary IN (25000, 14000, 12500, 23600)


--Problem 15. Write a SQL query to find all employees that do not have manager.
SELECT FirstName, LastName
FROM Employees
WHERE ManagerID IS NULL


--Problem 16. Write a SQL query to find all employees that have salary more than 50000. 
--Order them in decreasing order by salary.
SELECT * FROM Employees
WHERE Salary > 50000
ORDER BY Salary DESC


--Problem 17. Write a SQL query to find the top 5 best paid employees.
SELECT TOP 5 * FROM Employees
ORDER BY Salary DESC

--or
SELECT * FROM Employees
ORDER BY Salary DESC
OFFSET 0 ROWS
FETCH NEXT 5 ROWS ONLY


--Problem 18. Write a SQL query to find all employees along with their address.
--Use inner join with ON clause.
SELECT e.FirstName, e.LastName, 
	   a.AddressText
FROM Employees e INNER JOIN Addresses a
ON e.AddressID = a.AddressID


--Problem 19. Write a SQL query to find all employees and their address.
--Use equijoins (conditions in the WHERE clause).
SELECT FirstName, LastName, AddressText
FROM Employees e, Addresses a
WHERE e.AddressID = a.AddressID


--Problem 20. Write a SQL query to find all employees along with their manager.
SELECT e.FirstName + ' ' + e.LastName AS [Employee Name],
	   m.FirstName + ' ' + m.LastName AS [Manager Name]
FROM Employees e JOIN Employees m
ON e.ManagerID = m.EmployeeID


--Problem 21. Write a SQL query to find all employees, along with their manager and their address.
--You should join the 4 tables: Employees e, Employees m, Towns t and Addresses a.
SELECT e.FirstName + ' ' + e.LastName AS [Employee Name],
	   m.FirstName + ' ' + m.LastName AS [Manager Name],
	   t.Name AS Town,
	   a.AddressText AS [Address]
FROM Employees e 
	JOIN Employees m ON e.ManagerID = m.EmployeeID
	JOIN Addresses a ON e.AddressID = a.AddressID
	JOIN Towns t ON a.TownID = t.TownID


--Problem 22. Write a SQL query to find all departments and all town names as a single list.
--Use UNION.
SELECT Name FROM Departments 
UNION
SELECT Name FROM Towns


--Problem 23. Write a SQL query to find all the employees and the manager for each of them along with the employees that do not have manager. 
--Use right outer join. Rewrite the query to use left outer join.
SELECT e.FirstName + ' ' + e.LastName AS EmployeeName,
	   m.FirstName + ' ' + m.LastName AS ManagerName
FROM Employees e RIGHT OUTER JOIN Employees m
ON e.ManagerID = m.EmployeeID

SELECT e.FirstName + ' ' + e.LastName AS EmployeeName,
	   m.FirstName + ' ' + m.LastName AS ManagerName
FROM Employees e LEFT OUTER JOIN Employees m
ON e.ManagerID = m.EmployeeID


--Problem 24. Write a SQL query to find the names of all employees from the departments "Sales" and "Finance"
--whose hire year is between 1995 and 2005.
SELECT e.FirstName, e.LastName, e.HireDate,
	   d.Name AS [Department]	   
FROM Employees e, Departments d
WHERE (e.DepartmentID = d.DepartmentID) AND
	  (YEAR(e.HireDate) BETWEEN 1995 AND 2005) AND
	  (d.Name IN ('Sales', 'Finance'))

