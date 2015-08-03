--Part II – SQL Queries
--You are given an MS SQL Server database "Diablo" holding users, games, items,
--characters and statistics available as SQL script.
--Your task is to write SQL queries for displaying data from the given database.

--Problem 1. All Diablo Characters
--Display all characters in alphabetical order. 
SELECT Name
FROM Characters
ORDER BY Name


--Problem 2. Games from 2011 and 2012 year
--Find the top 50 games ordered by start date, then by name of the game.
--Display only games from 2011 and 2012 year.
--Display start date in the format “YYYY-MM-DD”. 
SELECT TOP 50 Name AS Game,
			  (SELECT CONVERT(char(10), Start,126)) Start
FROM Games
WHERE DATEPART(yy, Start) IN (2011, 2012)
ORDER BY Start, Name


--Problem 3. User Email Providers
--Find all users along with information about their email providers.
--Display the username and email provider.
--Sort the results by email provider alphabetically, then by username. 
SELECT  Username,
		RIGHT(Email, LEN(Email) - CHARINDEX('@', email)) AS [Email Provider]
FROM Users
ORDER BY [Email Provider], Username


--Problem 4. Get users with IPAddress like pattern
--Find all users along with their IP addresses sorted by username alphabetically.
--Display only rows that IP address matches the pattern: “***.1^.^.***”.
--Legend: * - one symbol, ^ - one or more symbols
SELECT Username, IpAddress AS [IP Address]
FROM Users
WHERE IpAddress LIKE '___.1%.%.___'
ORDER BY Username


--Problem 5. Show All Games with Duration and Part of the Day
--Find all games with part of the day and duration sorted by game name alphabetically
--then by duration and part of the day.
--Parts of the day should be Morning (time is >= 0 and < 12),
--Afternoon (time is >= 12 and < 18), Evening (time is >= 18 and < 24).
--Duration should be Extra Short (smaller or equal to 3), Short (between 4 and 6 including),
--Long (greater than 6) and Extra Long (without duration).
SELECT  Name AS Game,
		(CASE WHEN DATEPART(hh, Start) BETWEEN 0 AND 11 THEN 'Morning'
			  WHEN DATEPART(hh, Start) BETWEEN 12 AND 17 THEN 'Afternoon'
			  ELSE 'Evening' END) AS [Part of the Day],
		(CASE WHEN Duration <= 3 THEN 'Extra Short'
			  WHEN Duration BETWEEN 4 AND 6 THEN 'Short'
			  WHEN Duration > 6 THEN 'Long'
			  ELSE 'Extra Long' END) AS [Duration]
FROM Games
ORDER BY Game, Duration, [Part of the Day]


--Problem 6. Number of Users for Email Provider
--Find number of users for email provider from the largest to smallest.
SELECT  RIGHT(Email, LEN(Email) - CHARINDEX('@', email)) AS [Email Provider],
		COUNT(Id) AS [Number Of Users]
FROM Users
GROUP BY RIGHT(Email, LEN(Email) - CHARINDEX('@', email))
ORDER BY [Number Of Users] DESC, [Email Provider]


--Problem 7. All User in Games
--Find all user in games with information about them.
--Display the game name, game type, username, level, cash and character name.
--Sort the result by level in descending order, then by username and game in alphabetical order.
SELECT  g.Name AS Game,
		gt.Name AS [Game Type],
		u.Username,
		ug.Level,
		ug.Cash,
		c.Name AS [Character]
FROM Users u
JOIN UsersGames ug ON ug.UserId = u.Id
JOIN Games g ON g.Id = ug.GameId
JOIN GameTypes gt ON gt.Id = g.GameTypeId
JOIN Characters c ON c.Id = ug.CharacterId
ORDER BY ug.Level DESC, u.Username, Game


--Problem 8. Users in Games with Their Items
--Find all users in games with their items count and items price.
--Display the username, game name, items count and items price.
--Display only user in games with items count more or equal to 10.
--Sort the results by items count in descending order then by price in descending order and by username in ascending order.
SELECT  u.Username,
		g.Name AS Game,
		COUNT(i.Id) AS [Items Count],
		SUM(i.Price) AS [Items Price]
FROM Users u
JOIN UsersGames ug ON u.Id = ug.UserId
JOIN UserGameItems ugi ON ugi.UserGameId = ug.Id
JOIN Items i ON ugi.ItemId = i.Id
JOIN Games g ON ug.GameId = g.Id
GROUP BY u.Username, g.Name
HAVING COUNT(i.Id) >= 10
ORDER BY [Items Count] DESC, [Items Price] DESC, u.Username


--Problem 9. * User in Games with Their Statistics
--Find all users in games with their statistics.
--Display the username, game name, character name, strength, defence, speed, mind and luck.
--Every statistic (strength, defence, speed, mind and luck) should be a sum of the character statistic,
--game type statistic and items for user in game statistic.
select 
	u.Username, 
	g.Name as Game, 
	MAX(c.Name) Character,
	SUM(its.Strength) + MAX(gts.Strength) + MAX(cs.Strength) as Strength,
	SUM(its.Defence) + MAX(gts.Defence) + MAX(cs.Defence) as Defence,
	SUM(its.Speed) + MAX(gts.Speed) + MAX(cs.Speed) as Speed,
	SUM(its.Mind) + MAX(gts.Mind) + MAX(cs.Mind) as Mind,
	SUM(its.Luck) + MAX(gts.Luck) + MAX(cs.Luck) as Luck
from Users u
join UsersGames ug on ug.UserId = u.Id
join Games g on ug.GameId = g.Id
join GameTypes gt on gt.Id = g.GameTypeId
join [Statistics] gts on gts.Id = gt.BonusStatsId
join Characters c on ug.CharacterId = c.Id
join [Statistics] cs on cs.Id = c.StatisticId
join UserGameItems ugi on ugi.UserGameId = ug.Id
join Items i on i.Id = ugi.ItemId
join [Statistics] its on its.Id = i.StatisticId
group by u.Username, g.Name
order by Strength desc, Defence desc, Speed desc, Mind desc, Luck desc



--Problem 10. All Items with Greater than Average Statistics
--Find all items with statistics larger than average.
--Display only items that have Mind, Luck and Speed greater than average Items mind, luck and speed.
--Sort the results by item names in alphabetical order.
DECLARE @avgStrength INT = (SELECT AVG(Strength) FROM [Statistics])
DECLARE @avgDefence INT = (SELECT AVG(Defence) FROM [Statistics])
DECLARE @avgSpeed INT = (SELECT AVG(Speed) FROM [Statistics])
DECLARE @avgLuck INT = (SELECT AVG(Luck) FROM [Statistics])
DECLARE @avgMind INT = (SELECT AVG(Mind) FROM [Statistics])
SELECT  i.Name,
		i.Price,
		i.MinLevel,
		s.Strength,
		s.Defence,
		s.Speed,
		s.Luck,
		s.Mind
FROM Items i
LEFT JOIN [Statistics] s ON i.StatisticId = s.Id
--GROUP BY i.Name, i.Price, i.MinLevel, s.Strength, s.Defence, s.Speed, s.Luck, s.Mind
WHERE   --s.Strength > @avgStrength AND
		--s.Defence > @avgDefence AND
		s.Speed > @avgSpeed AND
		s.Luck > @avgLuck AND
		s.Mind > @avgMind
ORDER BY i.Name


--Problem 11. Display All Items with Information about Forbidden Game Type
--Find all items and information whether and what forbidden game types they have.
--Display item name, price, min level and forbidden game type. Display all items.
--Sort the results by game type in descending order, then by item name in ascending order.
SELECT  i.Name AS Item,
		i.Price,
		i.MinLevel,
		gt.Name AS [Forbidden Game Type]
FROM Items i
LEFT JOIN GameTypeForbiddenItems fi ON fi.ItemId = i.Id
LEFT JOIN GameTypes gt ON fi.GameTypeId = gt.Id
ORDER BY [Forbidden Game Type] DESC, i.Name


