--Part II – Changes in the Database
--You are given a MS SQL Server database "Football" holding countries, teams, leagues,
--team matches and international matches, available as SQL script. 
--Your task is to modify the database schema and data and write SQL queries for displaying data
--from the database.

--Problem 13. Non-international Matches
--1. Create a table FriendlyMatches(Id, HomeTeamID, AwayTeamId, MatchDate).
--Use auto-increment for the primary key.
--Create a foreign keys between the tables FriendlyMatches and Teams.
IF OBJECT_ID('FriendlyMatches') IS NOT NULL
  DROP TABLE FriendlyMatches

CREATE TABLE FriendlyMatches(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	HomeTeamID INT FOREIGN KEY REFERENCES Teams(Id) NOT NULL,
	AwayTeamID INT FOREIGN KEY REFERENCES Teams(Id) NOT NULL,
	MatchDate datetime NULL
	)

--2. Execute the following SQL script (it should pass without any errors):
INSERT INTO Teams(TeamName) VALUES
 ('US All Stars'),
 ('Formula 1 Drivers'),
 ('Actors'),
 ('FIFA Legends'),
 ('UEFA Legends'),
 ('Svetlio & The Legends')
GO

INSERT INTO FriendlyMatches(
  HomeTeamId, AwayTeamId, MatchDate) VALUES
  
((SELECT Id FROM Teams WHERE TeamName='US All Stars'), 
 (SELECT Id FROM Teams WHERE TeamName='Liverpool'),
 '30-Jun-2015 17:00'),
 
((SELECT Id FROM Teams WHERE TeamName='Formula 1 Drivers'), 
 (SELECT Id FROM Teams WHERE TeamName='Porto'),
 '12-May-2015 10:00'),
 
((SELECT Id FROM Teams WHERE TeamName='Actors'), 
 (SELECT Id FROM Teams WHERE TeamName='Manchester United'),
 '30-Jan-2015 17:00'),

((SELECT Id FROM Teams WHERE TeamName='FIFA Legends'), 
 (SELECT Id FROM Teams WHERE TeamName='UEFA Legends'),
 '23-Dec-2015 18:00'),

((SELECT Id FROM Teams WHERE TeamName='Svetlio & The Legends'), 
 (SELECT Id FROM Teams WHERE TeamName='Ludogorets'),
 '22-Jun-2015 21:00')

GO

--3. Write a query to display all non-international matches along with the given team names,
--starting from the newest date and ending with games with no date.
SELECT 
  t1.TeamName AS [Home Team],
  t2.TeamName AS [Away Team],
  fm.MatchDate AS [Match Date]
FROM FriendlyMatches fm
JOIN Teams t1 on t1.Id = fm.HomeTeamId
JOIN Teams t2 on t2.Id = fm.AwayTeamId
UNION
SELECT 
  t1.TeamName AS [Home Team],
  t2.TeamName AS [Away Team],
  tm.MatchDate AS [Match Date]
FROM TeamMatches tm
JOIN Teams t1 on t1.Id = tm.HomeTeamId
JOIN Teams t2 on t2.Id = tm.AwayTeamId
ORDER BY [Match Date] DESC


--Problem 14. Seasonal Matches
--1.Write a SQL command to add a new Boolean column IsSeasonal in the Leagues table(defaults to false).
--Note that there is no "Boolean" type in SQL server, so you should use an alternative.
ALTER TABLE Leagues
ADD IsSeasonal BIT DEFAULT 0

--2. Add a new team match holding the following information:
--HomeTeam="Empoli", AwayTeam="Parma", HomeGoals=2, AwayGoals=2, Date= '19-Apr-2015 16:00', League= 'Italian Serie A'.
INSERT INTO TeamMatches(HomeTeamId, AwayTeamId, HomeGoals, AwayGoals, MatchDate, LeagueId)
VALUES ((SELECT Id FROM Teams WHERE TeamName = 'Empoli'),
		(SELECT Id FROM Teams WHERE TeamName = 'Parma'),
		2,
		2,
		'19-Apr-2015 16:00',
		(SELECT Id FROM Leagues WHERE LeagueName = 'Italian Serie A')
		)

--3. Add a new team match holding the following information: HomeTeam=" Internazionale", 
--AwayTeam="AC Milan", HomeGoals=0, AwayGoals=0, Date= '19-Apr-2015 21:45, League= 'Italian Serie A'.
INSERT INTO TeamMatches(HomeTeamId, AwayTeamId, HomeGoals, AwayGoals, MatchDate, LeagueId)
VALUES ((SELECT Id FROM Teams WHERE TeamName = 'Internazionale'),
		(SELECT Id FROM Teams WHERE TeamName = 'AC Milan'),
		0,
		0,
		'19-Apr-2015 21:45',
		(SELECT Id FROM Leagues WHERE LeagueName = 'Italian Serie A')
		)

--4. Write and execute a SQL command to mark as seasonal all leagues that have at least one team match.
UPDATE Leagues
SET IsSeasonal = 1
WHERE Id IN (
	SELECT l.Id
	FROM Leagues l
	  JOIN TeamMatches tm ON tm.LeagueId = l.Id
	GROUP BY l.Id
	HAVING COUNT(tm.Id) > 0
)

--5. Find all seasonal matches strictly after 10th April 2015.
--Display the home team name and score, the away team name and score and the league.
--Sort the results by league name (alphabetically), then by home team score count
--and away team score count (from largest to lowest).
SELECT  t1.TeamName AS [Home Team],
		tm.HomeGoals AS [Home Goals],
		t2.TeamName AS [Away Team],
		tm.AwayGoals AS [Away Goals],
		l.LeagueName AS [League Name]
FROM TeamMatches tm
JOIN Teams t1 
	ON tm.HomeTeamId = t1.Id
JOIN Teams t2
	ON tm.AwayTeamId = t2.Id
JOIN Leagues l
	ON l.Id = tm.LeagueId
WHERE tm.MatchDate > '10-Apr-2015'
ORDER BY [League Name], [Home Goals] DESC, [Away Goals] DESC
