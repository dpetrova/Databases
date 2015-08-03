--Part III – Stored Procedures
--You are given a MS SQL Server database "Geography" holding continents, countries, currencies,
--rivers, mountains and peaks, available as SQL script. 
--Your task is to write some stored procedures, views and other server-side database objects
--and write some SQL queries for displaying data from the database.
--Important: start with a clean copy of the "Geography" database. Just execute the SQL script again.

--Problem 17. Stored Function: Mountain Peaks JSON
--Create a stored function fn_MountainsPeaksJSON that lists all mountains alphabetically
--along with all its peaks alphabetically. Format the output as JSON string without any whitespace.
CREATE FUNCTION fn_MountainsPeaksJSON() RETURNS NVARCHAR(MAX)
AS
	BEGIN
		DECLARE @json NVARCHAR(MAX) = '{"mountains":['

		DECLARE mountainCursor CURSOR FOR
			SELECT MountainRange, Id FROM Mountains

		OPEN mountainCursor
			DECLARE @mountainName NVARCHAR(MAX), @mountainId INT
			FETCH NEXT FROM mountainCursor INTO @mountainName, @mountainId
			WHILE @@fetch_status = 0 --докато имаме записи в нашите редове продължавай нататък
			BEGIN
				SET @json = @json + '{"name":"' + @mountainName + '","peaks":['
				DECLARE peakCursor CURSOR FOR
					SELECT PeakName, Elevation FROM Peaks
					WHERE MountainId = @mountainId --за да намерим всички върхове за дадена планина
				OPEN peakCursor
					DECLARE @peakName NVARCHAR(MAX), @elevation INT
					FETCH NEXT FROM peakCursor INTO @peakName, @elevation
					WHILE @@fetch_status = 0
					BEGIN --това е като цикъл
						SET @json = @json + '{"name":"' + @peakName + '","elevation":' + CONVERT(NVARCHAR(MAX), @elevation) + '}'
						FETCH NEXT FROM peakCursor INTO @peakName, @elevation
						IF @@fetch_status = 0 --ако има още редове 
							SET @json = @json + ',' --сложи запетайка
					END
				CLOSE peakCursor
				DEALLOCATE peakCursor --зачиствам и освобождавам паметта
				SET @json = @json + ']}'
				FETCH NEXT FROM mountainCursor INTO @mountainName, @mountainId
				IF @@fetch_status = 0
					SET @json = @json + ','
			END
		CLOSE mountainCursor
		DEALLOCATE mountainCursor
		SET @json = @json + ']}'
		RETURN @json
	END

--If your function is correct and you execute the following SQL query:
SELECT dbo.fn_MountainsPeaksJSON()
