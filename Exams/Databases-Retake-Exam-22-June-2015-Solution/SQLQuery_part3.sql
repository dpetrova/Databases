--Part III – Stored Procedures
--You are given a MS SQL Server database "Football" holding countries, leagues, teams, and matches,
--available as SQL script.  Your task is to write some stored procedures, views and other server-side
--database objects and write some SQL queries for displaying data from the database.
--Important: start with a clean copy of the "Football" database. Just execute the SQL script again.

--Problem 15. Stored Function: Bulgarian Teams with Matches JSON
--Create a stored function fn_TeamsJSON that lists all Bulgarian teams alphabetically
--along with all games starting from the newest date and ending with games with no date.
--Format the output as JSON string without any whitespace.
--HINT: Use code 103 for date conversion

CREATE FUNCTION fn_TeamsJSON() RETURNS NVARCHAR(MAX)
AS
	BEGIN
		DECLARE @json NVARCHAR(MAX) = '{"teams":['

		DECLARE teamCursor CURSOR FOR
			SELECT TeamName, Id FROM Teams
			WHERE CountryCode = 'BG'
			ORDER BY TeamName

		OPEN teamCursor
			DECLARE @teamName NVARCHAR(MAX), @teamId INT
			FETCH NEXT FROM teamCursor INTO @teamName, @teamId
			WHILE @@fetch_status = 0 --докато имаме записи в нашите редове продължавай нататък
			BEGIN
				SET @json = @json + '{"name":"' + @teamName + '","matches":['

				DECLARE matchCursor CURSOR FOR
					SELECT t1.TeamName, t2.TeamName, HomeGoals, AwayGoals, MatchDate FROM TeamMatches tm
					LEFT JOIN Teams t1
						ON tm.HomeTeamId = t1.Id
					LEFT JOIN Teams t2
						ON tm.AwayTeamId = t2.Id
					WHERE tm.HomeTeamId = @teamId OR tm.AwayTeamId = @teamId
					ORDER BY tm.MatchDate DESC
				OPEN matchCursor
					DECLARE @homeTeamName NVARCHAR(MAX),
							@awayTeamName NVARCHAR(MAX),
							@homeGoals INT,
							@awayGoals INT,
							@matchDate DATETIME
					FETCH NEXT FROM matchCursor INTO @homeTeamName, @awayTeamName, @homeGoals, @awayGoals, @matchDate
					WHILE @@fetch_status = 0
					BEGIN --това е като цикъл
						SET @json = @json + '{"' + @homeTeamName + '":' + 
						CONVERT(NVARCHAR(MAX), @homeGoals) + ',"' + @awayTeamName + '":' + 
						CONVERT(NVARCHAR(MAX), @awayGoals) + ',"date":' + 
						CONVERT(NVARCHAR(MAX), @matchDate, 103) + + '}'
						FETCH NEXT FROM matchCursor INTO @homeTeamName, @awayTeamName, @homeGoals, @awayGoals, @matchDate
						IF @@fetch_status = 0 --ако има още редове 
							SET @json = @json + ',' --сложи запетайка
					END
				CLOSE matchCursor
				DEALLOCATE matchCursor --зачиствам и освобождавам паметта
				SET @json = @json + ']}'
				FETCH NEXT FROM teamCursor INTO @teamName, @teamId
				IF @@fetch_status = 0
					SET @json = @json + ','
			END
		CLOSE teamCursor
		DEALLOCATE teamCursor
		SET @json = @json + ']}'
		RETURN @json
	END

	GO

--If your function is correct and you execute the following SQL query:
SELECT dbo. fn_TeamsJSON()
