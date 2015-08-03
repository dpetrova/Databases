--Part I – SQL Queries
--You are given a MS SQL Server database "Football" holding continents,
--countries, leagues, teams, and matches, available as SQL script.
--Your task is to write SQL queries for displaying data from the 
--given database. In all problems, please name the columns exactly like in 
--the sample tables below.

--Problem 1. All Teams
--Display all teams in alphabetical order. 
USE Football

SELECT TeamName
FROM Teams

--Problem 2. Biggest Countries by Population
--Find the 50 biggest countries by population. Display the country name and population.
--Sort the results by population (from biggest to smallest), then by country alphabetically.
SELECT TOP 50 CountryName, Population
FROM Countries
ORDER BY Population DESC, CountryName


--Problem 3. Countries and Currency (Eurzone)
--Find all countries along with information about their currency.
--Display the country name, country code and information if the country is in the Eurozone or not
--(the currency is EUR or not): either "Inside" or "Outside".
--Sort the results by country name alphabetically.
SELECT  CountryName,
		CountryCode,
		(CASE CurrencyCode WHEN 'EUR' THEN 'Inside' ELSE 'Outside' END) AS [Eurozone]
FROM Countries
ORDER BY CountryName


--Problem 4. Teams Holding Numbers
--Find all teams that holds numbers in their name, sorted by country code.
--Display the team name and country code.
SELECT  TeamName AS [Team Name],
		CountryCode AS [Country Code]
FROM Teams
WHERE TeamName LIKE '%[0-9]%'
ORDER BY [Country Code]


--Problem 5. International Matches
--Find all international matches sorted by date. Display the country name of the home and away team.
--Sort the results starting from the newest date and ending with games with no date.
SELECT  c.CountryName AS [Home Team],
		cou.CountryName AS [Away Team],
		im.MatchDate AS [Match Date]
FROM InternationalMatches im
JOIN Countries c
	ON c.CountryCode = im.HomeCountryCode
JOIN Countries cou
	ON cou.CountryCode = im.AwayCountryCode
ORDER BY im.MatchDate DESC


--Problem 6. *Teams with their League and League Country
--Find all teams, along with the leagues, they play in and the country of the league.
--If the league does not have a country, display"International" instead.
--Sort the results by team name.
SELECT
	t.TeamName AS [Team Name],
	l.LeagueName AS League,
	ISNULL((SELECT CountryName FROM Countries WHERE CountryCode = l.CountryCode), 'International') AS [League Country]
FROM Teams t
LEFT OUTER JOIN Leagues_Teams lt
    ON t.Id = lt.TeamId
LEFT OUTER JOIN Leagues l
    ON lt.LeagueId = l.Id
ORDER BY t.TeamName, l.LeagueName


--Problem 7. * Teams with more than One Match
--Find all teams that have more than 1 match in any league. Sort the results by team name.
SELECT  t.TeamName AS Team,
		(SELECT COUNT(DISTINCT tm.Id) 
		 FROM TeamMatches tm
		 WHERE tm.HomeTeamId = t.Id OR tm.AwayTeamId = t.Id) AS [Matches Count]
FROM Teams t
WHERE
	(SELECT COUNT(DISTINCT tm.Id) 
	 FROM TeamMatches tm
	 WHERE tm.HomeTeamId = t.Id OR tm.AwayTeamId = t.Id) > 1
ORDER BY Team


--Problem 8. Number of Teams and Matches in Leagues
--For each league in the database, display the number of teams, number of matches and
--average goals per match in it. Sort the results by number of teams (from largest to smallest),
--then by numbers of matches (from largest to smallest). 
SELECT  l.LeagueName AS [League Name],
		COUNT(DISTINCT lt.TeamId) AS [Teams],
		COUNT(DISTINCT tm.Id) AS [Matches],
		ISNULL(AVG(tm.HomeGoals + tm.AwayGoals), 0) AS [Average Goals]
FROM Leagues l
lEFT JOIN Leagues_Teams lt
	ON lt.LeagueId = l.Id
LEFT JOIN TeamMatches tm
	ON tm.LeagueId = l.Id
GROUP BY l.LeagueName
ORDER BY Teams  DESC, Matches DESC


--Problem 9. Total Goals per Team in all Matches
--Find the number of goals for each Team from all matches played.
--Sort the results by number of goals (from highest to lowest), then by team name alphabetically.
SELECT  t.TeamName,
		ISNULL((SELECT sum(tm.HomeGoals) FROM TeamMatches tm WHERE tm.HomeTeamId = t.Id), 0) +
		ISNULL((SELECT sum(tm.AwayGoals) FROM TeamMatches tm WHERE tm.AwayTeamId = t.Id), 0) AS [Total Goals]
FROM Teams t
ORDER BY [Total Goals] DESC, t.TeamName

--or (дава грешен резултат)
SELECT
  t.TeamName,
  ISNULL(SUM(tm1.HomeGoals), 0) + ISNULL(SUM(tm2.AwayGoals), 0) AS [Total Goals]
FROM Teams t
LEFT JOIN TeamMatches tm1 on tm1.HomeTeamId = t.Id
LEFT JOIN TeamMatches tm2 on tm2.AwayTeamId = t.Id
GROUP BY t.TeamName
ORDER BY [Total Goals] DESC, TeamName


--Problem 10. Pairs of Matches on the Same Day
--Find all pairs of team matches that are on the same day. Show the date and time of each pair.
--Sort the dates from the newest to the oldest first date,
--then from the newest to the oldest second date.
SELECT t1.MatchDate AS [First Date], t2.MatchDate AS [Second Date]
FROM TeamMatches t1, TeamMatches t2
WHERE DAY(t1.MatchDate) = DAY(t2.MatchDate) AND
	  t2.MatchDate > t1.MatchDate
ORDER BY [First Date] DESC, [Second Date] DESC
	

--Problem 11. Mix of Team Names
--Combine all team names with one another (including itself),
--so that the last letter of the first team name is the same as the first letter of the
--reversed second team name. Sort the results by the obtained mix alphabetically.
SELECT LOWER(LEFT(t1.TeamName, LEN(t1.TeamName) - 1) + REVERSE(t2.TeamName)) AS Mix
FROM Teams t1, Teams t2
WHERE RIGHT(t1.TeamName, 1) = LEFT(REVERSE(t2.TeamName), 1)
--WHERE RIGHT(t1.TeamName, 1) = RIGHT(t2.TeamName, 1)
ORDER BY Mix


--Problem 12. Countries with International and Team Matches
--For each country, extract the total amount of international and team matches.
--List only countries with at least one international or team match.
--Sort the results in decreasing order by international matches count, then by team matches count,
--than alphabetically by country name.
SELECT
  c.CountryName AS [Country Name],
  COUNT(DISTINCT im1.Id) + COUNT(DISTINCT im2.Id) AS [International Matches],
  COUNT(DISTINCT tm.Id) AS [Team Matches]
FROM Countries c
LEFT JOIN InternationalMatches im1 ON im1.HomeCountryCode = c.CountryCode
LEFT JOIN InternationalMatches im2 ON im2.AwayCountryCode = c.CountryCode
LEFT JOIN Leagues l ON l.CountryCode = c.CountryCode
LEFT JOIN TeamMatches tm ON l.Id = tm.LeagueId
GROUP BY c.CountryName
HAVING  (COUNT(DISTINCT im1.Id) + COUNT(DISTINCT im2.Id)) > 0 OR
		(COUNT(DISTINCT tm.Id) > 0)
ORDER BY [International Matches] DESC, [Team Matches] DESC, [Country Name]