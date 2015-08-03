USE Forum
GO

BEGIN TRAN

CREATE TABLE Towns(
	Id INT IDENTITY PRIMARY KEY,
	Name NVARCHAR(50) NOT NULL)
GO

ALTER TABLE Users
ADD TownId INT FOREIGN KEY REFERENCES Towns(Id)
GO

INSERT INTO Towns(Name) VALUES ('Sofia'), ('Berlin'), ('Lyon')
UPDATE Users SET TownId = (SELECT Id FROM Towns WHERE Name='Sofia')
INSERT INTO Towns VALUES
('Munich'), ('Frankfurt'), ('Varna'), ('Hamburg'), ('Paris'), ('Lom'), ('Nantes')
GO

UPDATE Users
SET TownId = (SELECT t.Id FROM Towns AS t WHERE t.Name = 'Paris')
WHERE DATENAME(DW, RegistrationDate) = 'Friday'
GO

UPDATE Questions
SET Title = 'Java += operator'
WHERE Id IN (
SELECT DISTINCT QuestionId FROM Answers AS a
WHERE DATENAME(DW, CreatedOn) IN ('Monday', 'Sunday') AND MONTH(a.CreatedOn) = 2)
GO

DECLARE @temp TABLE(
	Id INT)

INSERT INTO @temp
SELECT 
		a.Id
	FROM Answers AS a
	JOIN Votes AS v
		ON a.Id = v.AnswerId
	GROUP BY a.Id
	HAVING SUM(v.Value) < 0

DELETE Votes
WHERE AnswerId IN (SELECT * FROM @temp)

DELETE Answers
WHERE Id IN (SELECT * FROM @temp)
GO

INSERT INTO Questions(Title, Content, CreatedOn, UserId, CategoryId) VALUES
	('Fetch NULL values in PDO query',
	'When I run the snippet, NULL values are converted to empty strings. How can fetch NULL values?',
	GETDATE(),
	(SELECT u.Id FROM Users AS u WHERE u.Username = 'darkcat'),
	(SELECT c.Id FROM Categories AS c WHERE c.Name = 'Databases'))
GO

SELECT 
	t.Name AS Town,
	u.Username,
	COUNT(a.Id) AS AnswersCount
FROM Towns AS t
LEFT JOIN Users AS u
	ON t.Id = u.TownId
LEFT JOIN Answers AS a
	ON a.UserId = u.Id
GROUP BY t.Name, u.Username
ORDER BY AnswersCount DESC, u.Username ASC
GO

ROLLBACK