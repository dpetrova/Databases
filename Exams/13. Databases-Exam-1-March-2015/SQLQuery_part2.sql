--Part II – Changes in the Database
--You are given a MS SQL Server database "Geography" holding continents, countries,
--currencies, rivers, mountains and peaks, available as SQL script. 
--Your task is to modify the database schema and data and write SQL queries for displaying data from the database.


--Problem 15. Monasteries by Country
--1.Create a table Monasteries(Id, Name, CountryCode). Use auto-increment for the primary key.
--Create a foreign key between the tables Monasteries and Countries.
CREATE TABLE Monasteries(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	Name NVARCHAR(50) NOT NULL,
	CountryCode CHAR(2) FOREIGN KEY REFERENCES Countries(CountryCode) NOT NULL
	)

--2.Execute the following SQL script (it should pass without any errors):
INSERT INTO Monasteries(Name, CountryCode) VALUES
('Rila Monastery “St. Ivan of Rila”', 'BG'), 
('Bachkovo Monastery “Virgin Mary”', 'BG'),
('Troyan Monastery “Holy Mother''s Assumption”', 'BG'),
('Kopan Monastery', 'NP'),
('Thrangu Tashi Yangtse Monastery', 'NP'),
('Shechen Tennyi Dargyeling Monastery', 'NP'),
('Benchen Monastery', 'NP'),
('Southern Shaolin Monastery', 'CN'),
('Dabei Monastery', 'CN'),
('Wa Sau Toi', 'CN'),
('Lhunshigyia Monastery', 'CN'),
('Rakya Monastery', 'CN'),
('Monasteries of Meteora', 'GR'),
('The Holy Monastery of Stavronikita', 'GR'),
('Taung Kalat Monastery', 'MM'),
('Pa-Auk Forest Monastery', 'MM'),
('Taktsang Palphug Monastery', 'BT'),
('Sümela Monastery', 'TR')

--3. Write a SQL command to add a new Boolean column IsDeleted in the Countries table(defaults to false).
--Note that there is no "Boolean" type in SQL server, so you should use an alternative.
ALTER TABLE Countries
ADD IsDeleted BIT DEFAULT 0

--4. Write and execute a SQL command to mark as deleted all countries that have more than 3 rivers.
UPDATE Countries
SET IsDeleted = 1
WHERE CountryCode IN ( 
		SELECT c.CountryCode FROM Countries c
		JOIN CountriesRivers cr
			ON cr.CountryCode = c.CountryCode
		JOIN Rivers r
			ON r.Id = cr.RiverId
		GROUP BY c.CountryCode
		HAVING COUNT(r.Id) > 3)

--5. Write a query to display all monasteries along with their countries sorted by monastery name.
--Skip all deleted countries and their monasteries.
SELECT m.Name AS Monastery, c.CountryName AS Country
FROM Monasteries m
JOIN Countries c
	ON m.CountryCode = c.CountryCode
WHERE c.IsDeleted IS NULL
ORDER BY Monastery
 

--Problem 16.	Monasteries by Continents and Countries
--This problem assumes that the previous problem is completed successfully without errors.
--1. Write and execute a SQL command that changes the country named "Myanmar" to 
--its other name "Burma".
UPDATE Countries
SET CountryName = 'Burma'
WHERE CountryName = 'Myanmar'

--2. Add a new monastery holding the following information: Name="Hanga Abbey", Country="Tanzania".
--(тук второто няма да се инсъртне, защото променихме Myanmar; за да се инсъртне първото, маркираме заявката без вторите стойности)
INSERT INTO Monasteries (Name, CountryCode)
VALUES('Hanga Abbey', (SELECT CountryCode FROM Countries WHERE CountryName = 'Tanzania')),
	  ('Myin-Tin-Daik', (SELECT CountryCode FROM Countries WHERE CountryName = 'Myanmar'))

--4. Find the count of monasteries for each continent and not deleted country.
--Display the continent name, the country name and the count of monasteries.
--Include also the countries with 0 monasteries.
--Sort the results by monasteries count (from largest to lowest),
--then by country name alphabetically. Name the columns exactly like in the table below.
SELECT con.ContinentName, cou.CountryName, COUNT(m.Id) AS MonasteriesCount
FROM Continents con
LEFT JOIN Countries cou
	ON cou.ContinentCode = con.ContinentCode
LEFT JOIN Monasteries m
	ON m.CountryCode = cou.CountryCode
WHERE cou.IsDeleted IS NULL
GROUP BY con.ContinentName, cou.CountryName
ORDER BY MonasteriesCount DESC, cou.CountryName
