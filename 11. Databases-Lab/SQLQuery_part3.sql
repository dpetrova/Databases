--Part III – Stored Procedures
--You are given a MS SQL Server database "Forum" holding questions, answers, categories, tags,
--votes and users, available as SQL script.
--Your task is to write some stored procedures, views and other server-side database objects
--and write some SQL queries for displaying data from the database.
--Important: start with a clean copy of the "Forum" database.
USE FORUM
GO

--Problem 14. Create a View and a Stored Function
--1. Create a view "AllQuestions" in the database that holds information about questions and users
--(use RIGHT OUTER JOIN): 
CREATE VIEW [AllQuestions]
AS
	SELECT 
		u.Id AS UId,
		u.Username,
		u.FirstName,
		u.LastName,
		u.Email,
		u.PhoneNumber,
		u.RegistrationDate,
		q.Id AS QId,
		q.Title,
		q.Content,
		q.CategoryId,
		q.UserId,
		q.CreatedOn
	FROM Questions q
	RIGHT OUTER JOIN Users u ON q.UserId = u.Id
GO

--If you execute the following SQL query:
SELECT * FROM AllQuestions
GO

--2.Using the view above, create a stored function "fn_ListUsersQuestions" that returns a table,
--holding all users in descending order as first column, along with all titles of their questions
--(in ascending order), separated by ", " as second column.
CREATE FUNCTION fn_ListUsersQuestions() RETURNS @Table TABLE(
	UserName NVARCHAR(50),
	Questions NVARCHAR(MAX))
AS
	BEGIN
		INSERT INTO @Table
			SELECT 
				a.Username AS UserName,
				STUFF(ISNULL(
				(SELECT 
					', ' + b.Title
				FROM AllQuestions AS b
				WHERE b.Username = a.Username
				GROUP BY b.Username, b.Title
				ORDER BY b.Title DESC
				FOR XML PATH (''), TYPE).value('.','NVARCHAR(max)'), ''), 1, 2, '') AS Questions
			FROM AllQuestions AS a
			GROUP BY a.Username
			ORDER BY a.Username ASC

			RETURN
	END
GO

--If your function is correct and you execute the following SQL query:
SELECT * FROM fn_ListUsersQuestions()