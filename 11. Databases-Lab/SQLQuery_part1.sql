--Part I – SQL Queries
--You are given a MS SQL Server database "Forum" holding questions, answers, categories, tags,
--votes and users, available as SQL script.
--Your task is to write SQL queries for displaying data from the given database.

--Problem 1. All Question Titles
--Display all question titles in ascending order.
--Steps:
--1.Select all question titles from questions table.
--2.Add order by ascending statement.
SELECT Title
FROM Questions
ORDER BY Title


--Problem 2. Answers in Date Range
--Find all answers created between 15-June-2012 (00:00:00) and 21-Mart-2013 (23:59:59) sorted by date.
--Steps:
--1.Select all answers (only Content and CreatedOn columns).
--2.Add where filter by CreatedOn, then by Id columns. You can use between or comparison statements.
SELECT Content, CreatedOn
FROM Answers
WHERE CreatedOn BETWEEN '15-Jun-2012' AND  '21-Mar-2013'
ORDER BY CreatedOn


--Problem 3. Users with "1/0" Phones
--Display usernames and last names along with a column named "Has Phone" holding "1" or "0"
--for all users sorted by their last name, then by id.
--Steps:
--1.Select all users (only Username and LastName columns).
--2.Add order by last name statement.
--3.Add “Has Phone” column. You can use case statement in select to check is there a phone and set 1 or 0.
SELECT  Username,
		LastName,
		(CASE WHEN PhoneNumber IS NULL THEN 0 ELSE 1 END) AS [Has Phone]
FROM Users
ORDER BY LastName, Id


--Problem 4. Questions with their Author
--Find all questions along with their user sorted by question title.
--Display the question title and author username.
--Steps:
--1.Select all columns from Questions table.
--2.Join Users table.
--3.Add only the required columns in the expression.
--4.Add the required aliases.
--5.Order by question title
SELECT q.Title AS [Question Title], u.Username AS Author
FROM Questions q
JOIN Users u
	ON q.UserId = u.Id
ORDER BY [Question Title]


--Problem 5. Answers with their Question with their Category and User 
--Find top 50 answers along with their questions, along with question category,
--along with answer author sorted by Category Name, then by Answer Author, then by CreatedOn.
--Display the answer content, created on, question title, category name and author username.
--Steps:
--1.Select all columns from Answers table.
--2.Join Questions table by QuestionId foreign key.
--3.Join Categories table by CategoryId foreign key.
--4.Join Users table by UserId foreign key in Answers table.
--5.Add order by statement by Category Name, Answer Author and CreatedOn.
--6.Select only the required columns with their aliases.
SELECT TOP 50
		a.Content AS [Answer Content],
		a.CreatedOn,
		u.Username AS [Answer Author],
		q.Title AS [Question Title],
		c.Name AS [Category Name]
FROM Answers a
JOIN Users u ON a.UserId = u.Id
JOIN Questions q ON a.QuestionId = q.Id
JOIN Categories c ON q.CategoryId = c.Id
ORDER BY [Category Name], [Answer Author], a.CreatedOn


--Problem 6. Category with Questions
--Find all categories along with their questions sorted by category name and question title.
--Display the category name, question title and created on columns.
--1.Select all Questions.
--2.Join Categories table (think how to display null values).
--3.Add order by statement by category name, then by question title.
--4.Select only required columns.
SELECT
	c.Name AS Category,
	q.Title AS Question,
	q.CreatedOn
FROM Categories c
LEFT JOIN Questions q ON q.CategoryId = c.Id
ORDER BY Category, Question


--Problem 7. *Users without PhoneNumber and Questions
--Find all users that have no phone and no questions sorted by RegistrationDate. Show all user data.
--1.Select all users.
--2.Add where filter by null phone number.
--3.Add order by statement by RegistrationDate.
--4.Join Questions table and display all users with questions for each user (with questions with null values).
--5.Add filter to show only users with no questions.
SELECT
	u.Id,
	u.Username,
	u.FirstName,	
	u.PhoneNumber,
	u.RegistrationDate,
	u.Email
FROM Users u
LEFT JOIN Questions q ON q.UserId = u.Id
WHERE u.PhoneNumber IS NULL AND q.Title IS NULL
ORDER BY u.RegistrationDate


--Problem 8. Earliest and Latest Answer Date
--Find the dates of the earliest answer for 2012 year and the latest answer for 2014 year.
--Steps:
--1.Select min and max date from Answers.
--2.Add where filter by year.
SELECT MIN(a1.CreatedOn) AS MinDate, MAX(a2.CreatedOn) AS MaxDate
FROM Answers a1, Answers a2
WHERE YEAR(a1.CreatedOn) = 2012 AND YEAR(a2.CreatedOn) = 2014


--Problem 9. Find the last ten answers
--Find the last 10 answers sorted by date of creation in ascending order.
--Display for each ad its content, date and author. 
SELECT TOP 10 a.Content AS Answer, a.CreatedOn, u.UserName AS Username
FROM Answers a
JOIN Users u ON a.UserId = u.Id
ORDER BY a.CreatedOn DESC


--Problem 10. Not Published Answers from the First and Last Month
--Find the answers which is hidden from the first and last month where there are any published answer,
--from the last year where there are any published answers.
--Display for each ad its answer content, question title and category name.
--Sort the results by category name.
--Steps:
--1.Select all data from Answers.
--2.Join Questions and Categories by foreign keys.
--3.Add order by statement by category name.
--4.Select only needed columns.
--5.Add where statement. You can use MONTH and YEAR functions and nested select statements.
DECLARE @lastYear INT = (SELECT YEAR(MAX(CreatedOn)) FROM Answers)
DECLARE	@firstMonth INT = MONTH((SELECT MIN(CreatedOn) FROM Answers WHERE YEAR(CreatedOn) = @lastYear))
DECLARE	@lastMonth INT = MONTH((SELECT MAX(CreatedOn) FROM Answers WHERE YEAR(CreatedOn) = @lastYear))

SELECT  a.Content AS [Answer Content],
		q.Title AS Question,
		c.Name AS Category
FROM Answers a
JOIN Questions q ON a.QuestionId = q.Id
JOIN Categories c ON q.CategoryId = c.Id
WHERE a.IsHidden = 1 AND
	  YEAR(a.CreatedOn) = @lastYear AND 
	  MONTH(a.CreatedOn) BETWEEN @firstMonth AND @lastMonth
ORDER BY Category


--Problem 11. Answers count for Category
--Display the count of answers in each category. Sort the results by answers count in descending order.
--Steps:
--1.Select all data from Categories.
--2.Join Questions and Answers (What type of join do you need?).
--3.Order results.
--4.Group results and add COUNT column in select statement.
SELECT c.Name AS Category, COUNT(a.Id) AS [Answers Count]
FROM Categories c
LEFT JOIN Questions q ON c.Id = q.CategoryId
LEFT JOIN Answers a ON a.QuestionId = q.Id
GROUP BY c.Name
ORDER BY [Answers Count] DESC


--Problem 12. Answers Count by Category and Username
--Display the count of answers for category and each username.
--Sort the results by Answers count, then by Username. Display only non-zero counts.
--Display only users with phone number.
--Steps:
--1.Select all data from Categories.
--2.Join Questions, Answers and Users (What type of joins do you need?).
--3.Add needed columns in select statement and group by them.
--4.Add order by statement by answers count and username.
SELECT c.Name AS Category, u.Username, u.PhoneNumber, COUNT(a.Id) AS [Answers Count]
FROM Categories c
JOIN Questions q ON c.Id = q.CategoryId
JOIN Answers a ON a.QuestionId = q.Id
JOIN Users u ON u.Id = a.UserId
GROUP BY c.Name, u.Username, u.PhoneNumber
HAVING u.PhoneNumber IS NOT NULL
ORDER BY [Answers Count] DESC, u.Username