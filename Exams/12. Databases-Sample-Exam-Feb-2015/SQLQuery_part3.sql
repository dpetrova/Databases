--Part III – Stored Procedures
--You are given a MS SQL Server database "Ads" holding advertisements, organized by categories
--and towns, available as SQL script. Your task is to write some stored procedures, views 
--and other server-side database objects and write some SQL queries for displaying data
--from the database.
--Important: start with a clean copy of the "Ads" database.

--Problem 17. Create a View and a Stored Function
--Create a view "AllAds" in the database that holds information about ads: id, title,
--author (username), date, town name, category name and status, sorted by id.
CREATE VIEW AllAds
AS
SELECT
		a.Id,
		a.Title,
		anu.UserName AS Author,
		a.Date,
		t.Name AS Town,
		c.Name AS Category,
		ads.Status
	FROM Ads a
	LEFT JOIN AspNetUsers anu ON a.OwnerId = anu.Id
	LEFT JOIN Towns t ON t.Id = a.TownId
	LEFT JOIN Categories c ON c.Id = a.CategoryId
	LEFT JOIN AdStatuses ads ON ads.Id = a.StatusId
GO

--If you execute the following SQL query:
SELECT * FROM AllAds
GO

--Using the view above, create a stored function "fn_ListUsersAds" that returns a table,
--holding all users in descending order as first column, along with all dates of their ads
--(in ascending order) in format "yyyyMMdd", separated by "; " as second column.
CREATE FUNCTION fn_ListUsersAds()
	RETURNS @tbl_UsersAds TABLE(
		UserName NVARCHAR(MAX),
		AdDates NVARCHAR(MAX)
	)
AS
BEGIN
	DECLARE UsersCursor CURSOR FOR
		SELECT UserName FROM AspNetUsers
		ORDER BY UserName DESC;
	OPEN UsersCursor;
	DECLARE @username NVARCHAR(MAX);
	FETCH NEXT FROM UsersCursor INTO @username;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @ads NVARCHAR(MAX) = NULL;
		SELECT
			@ads = CASE
				WHEN @ads IS NULL THEN CONVERT(NVARCHAR(MAX), Date, 112)
				ELSE @ads + '; ' + CONVERT(NVARCHAR(MAX), Date, 112)
			END
		FROM AllAds
		WHERE Author = @username
		ORDER BY Date;

		INSERT INTO @tbl_UsersAds
		VALUES(@username, @ads)
		
		FETCH NEXT FROM UsersCursor INTO @username;
	END;
	CLOSE UsersCursor;
	DEALLOCATE UsersCursor;
	RETURN;
END
GO

--If your function is correct and you execute the following SQL query:
SELECT * FROM fn_ListUsersAds()