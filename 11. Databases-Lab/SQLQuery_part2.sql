--PART II. Changes in the Database
--You are given a MS SQL Server database "Forum" holding questions, answers, categories, tags,
--votes and users, available as SQL script.
--Your task is to modify the database schema and data and write SQL queries for displaying data
--from the database.
USE Forum
GO

--Problem 13. Answers for the users from town

--1.Create a table Towns(Id, Name). Use auto-increment for the primary key.
--Add a new column TownId in the Users table to link each user to some town (non-mandatory link).
--Create a foreign key between the Users and Towns tables.
--Steps:
	--1.Create table with Id and name. Don’t forget identity and primary key constraint.
	--2.Alter table Users and add the new column.
	--3.Alter table Users again and add the foreign key constraint to Towns table.
CREATE TABLE Towns(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	Name NVARCHAR(50) NOT NULL,	
	)
GO

ALTER TABLE Users
ADD TownId INT FOREIGN KEY REFERENCES Towns(Id)
GO

--2. Execute the following SQL script (it should pass without any errors):
INSERT INTO Towns(Name) VALUES ('Sofia'), ('Berlin'), ('Lyon')

UPDATE Users SET TownId = (SELECT Id FROM Towns WHERE Name='Sofia')

INSERT INTO Towns VALUES
('Munich'), ('Frankfurt'), ('Varna'), ('Hamburg'), ('Paris'), ('Lom'), ('Nantes')

--3.Write and execute a SQL command that changes the town to "Paris" for all users with
--registration date at Friday.
--Steps:
	--1.Write update statement by Users table.
	--2.Get town id with nested select statement.
	--3.Add where statement where check the day of the week (You can use DATEPART function).
UPDATE Users 
SET TownId = (SELECT t.Id
			  FROM Towns t
			  WHERE t.Name = 'Paris')
WHERE DATEPART(dw, RegistrationDate) = 5
GO

--4. Write and execute a SQL command that changes the question to “Java += operator” of Answers,
--answered at Monday or Sunday in February.
--Steps:
	--1.Write update statement by Answers table.
	--2.Get QuestionId with nested select statement.
	--3.Add where filter (You can check the day of week with DATEPART function
	--and the month with MONTH function).
UPDATE Questions
SET Title = 'Java += operator'
WHERE Id IN (SELECT DISTINCT QuestionId FROM Answers AS a
			 WHERE DATENAME(DW, CreatedOn) IN ('Monday', 'Sunday') AND MONTH(a.CreatedOn) = 2)
GO

--or
UPDATE Answers 
SET QuestionId = (SELECT q.Id
				  FROM Questions q
				  WHERE q.Title = 'Java += operator')
WHERE DATEPART(mm, CreatedOn) = 2 AND 
	  DATEPART(dw, CreatedOn) = 1 OR DATEPART(dw, CreatedOn) = 7
GO

--5.Delete all answers with negative sum of votes.
--Steps:
	--1.Create temporary table [#AnswerIds] with one column AnswerId (int)
	--2.Insert into [#AnswerIds] table all answer ids where sum of answer votes are negative number.
	--3.Delete votes where sum of answer votes are negative number.
	--4.Delete answers which ids are in table [#AnswerIds]
	--5.Drop temporary table [#AnswerIds]
--Hint: Think how to delete votes with answers.
CREATE TABLE #AnswerIds(
	AnswerId INT
	)
GO

INSERT INTO #AnswerIds
	SELECT a.Id 
	FROM Answers a
	JOIN Votes v ON v.AnswerId = a.Id
	GROUP BY a.Id
	HAVING SUM(v.Value) < 0

DELETE Votes
WHERE AnswerId IN (SELECT * FROM #AnswerIds)

DELETE Answers
WHERE Id IN (SELECT * FROM #AnswerIds)

DROP TABLE #AnswerIds

--6. Add a new question holding the following information:
--Title="Fetch NULL values in PDO query", Content="When I run the snippet,
--NULL values are converted to empty strings. How can fetch NULL values?",
--CreatedOn={current date and time}, Owner="darkcat", Category="Databases".
--Hint: You can use GETDATE function for current datetime and nested select statements
--for user id and category id.
INSERT INTO Questions(Title, Content, CreatedOn, UserId, CategoryId)
VALUES ('Fetch NULL values in PDO query',
		'When I run the snippet, NULL values are converted to empty strings. How can fetch NULL values?',
		GETDATE(),
		(SELECT Id FROM Users WHERE Username = 'darkcat'),
		(SELECT Id FROM Categories WHERE Name = 'Databases')
		)
GO

--7. Find the count of the answers for the users from town.
--Display the town name, username and answers count.
--Sort the results by answers count in descending order, then by username.
SELECT t.Name AS Town, u.Username, COUNT(a.Id) AS AnswersCount
FROM Towns t
LEFT JOIN Users u ON t.Id = u.TownId
LEFT JOIN Answers a ON a.UserId = u.Id
GROUP BY t.Name, u.Username
ORDER BY AnswersCount DESC, u.Username