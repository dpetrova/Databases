--Part I – SQL Queries
--You are given a MS SQL Server database "Geography" holding continents, countries, currencies,
--rivers, mountains and peaks, available as SQL script.
--Your task is to write SQL queries for displaying data from the given database.
--In all problems, please name the columns exactly like in the sample tables below.

--Problem 1. All Mountain Peaks
--Display all ad mountain peaks in alphabetical order. 
SELECT PeakName FROM Peaks
ORDER BY PeakName


--Problem 2. Biggest Countries by Population
--Find the 30 biggest countries by population from Europe (или да проверим кода на континента дали е 'EU'; или да join-ем таблицата континенти и да прожерим дали континента е Europe).
--Display the country name and population.
--Sort the results by population (from biggest to smallest), then by country alphabetically. 
SELECT TOP 30 CountryName, [Population]
FROM Countries
WHERE ContinentCode = 'EU'
ORDER BY [Population] DESC, CountryName

--or
SELECT TOP 30 CountryName, [Population]
FROM Countries a JOIN Continents b
ON a.ContinentCode = b.ContinentCode
WHERE b.ContinentName = 'Europe'
ORDER BY [Population] DESC, CountryName


--Problem 3. Countries and Currency (Euro / Not Euro)
--Find all countries along with information about their currency.
--Display the country code, country name and information about its currency:
--either "Euro" or "Not Euro". Sort the results by country name alphabetically.
SELECT	CountryName,
		CountryCode,
		(CASE CurrencyCode WHEN 'EUR' THEN 'Euro' ELSE 'Not Euro' END) AS [Currency]
FROM Countries
ORDER BY CountryName


--Problem 4. Countries Holding 'A' 3 or More Times
--Find all countries that holds the letter 'A' in their name at least 3 times (case insensitively),
--sorted by ISO code. Display the country name and ISO code.
SELECT CountryName AS [Country Name], IsoCode AS [ISO Code]
FROM Countries
WHERE CountryName LIKE '%A%A%A%' --може и '%a%a%a% 'понеже колацията е case insensitive ( % означава 0 или повече chars; _ означава 1 char)
ORDER BY [ISO Code]


--Problem 5. Peaks and Mountains
--Find all peaks along with their mountain sorted by elevation (from the highest to the lowest),
--then by peak name alphabetically. Display the peak name, mountain range name and elevation. 
SELECT p.PeakName, m.MountainRange AS [Mountain], p.Elevation
FROM Peaks p JOIN Mountains m
	ON p.MountainId = m.Id
ORDER BY p.Elevation DESC, p.PeakName


--Problem 6. Peaks with Their Mountain, Country and Continent
--Find all peaks along with their mountain, country and continent.
--When a mountain belongs to multiple countries, display them all.
--Sort the results by peak name alphabetically, then by country name alphabetically.
SELECT p.PeakName, m.MountainRange AS [Mountain], cou.CountryName, con.ContinentName
FROM Peaks p
JOIN Mountains m
	ON p.MountainId = m.Id
JOIN MountainsCountries mc --join-ваме междинната таблица, защото връзката м/у планини и държави е много-към-много
	ON mc.MountainId = m.Id
JOIN Countries cou
	ON mc.CountryCode = cou.CountryCode
JOIN Continents con
	ON cou.ContinentCode = con.ContinentCode
ORDER BY p.PeakName, cou.CountryName


--Problem 7. * Rivers Passing through 3 or More Countries
--Find all rivers that pass through to 3 or more countries. 
--Display the river name and the number of countries. Sort the results by river name.
SELECT r.RiverName AS [River], COUNT(c.CountryCode) AS [Countries Count]
FROM Rivers r
JOIN CountriesRivers cr
	ON r.Id = cr.RiverId
JOIN Countries c
	ON c.CountryCode = cr.CountryCode
GROUP BY r.RiverName 
HAVING COUNT(c.CountryCode) >= 3
ORDER BY r.RiverName


--Problem 8. Highest, Lowest and Average Peak Elevation
--Find the highest, lowest and average peak elevation. 
SELECT
	MAX(Elevation) AS MaxElevation,
	MIN(Elevation) AS MinElevation,
	AVG(Elevation) AS AverageElevation
FROM Peaks


--Problem 9. Rivers by Country
--For each country in the database, display the number of rivers passing through that country and
--the total length of these rivers. When a country does not have any river,
--display 0 as rivers count and as total length.
--Sort the results by rivers count (from largest to smallest),
--then by total length (from largest to smallest), then by country alphabetically.
SELECT	cou.CountryName,
		con.ContinentName,
		COUNT(r.Id) AS RiversCount,
		ISNULL (SUM(r.[Length]), 0) AS TotalLength
FROM Countries cou
LEFT JOIN CountriesRivers cr -- така с LEFT JOIN ще изкара и държавите в които няма реки, ако е само JOIN ще ги пропусне
	ON cou.CountryCode = cr.CountryCode
LEFT JOIN Continents con
	ON con.ContinentCode = cou.ContinentCode
LEFT JOIN Rivers r
	ON r.Id = cr.RiverId
GROUP BY cou.CountryName, con.ContinentName
ORDER BY RiversCount DESC, TotalLength DESC, cou.CountryName


--Problem 10. Count of Countries by Currency
--Find the number of countries for each currency.
--Display three columns: currency code, currency description and number of countries.
--Sort the results by number of countries (from highest to lowest),
--then by currency description alphabetically. Name the columns exactly like in the table below.
SELECT  cur.CurrencyCode,
		cur.Description AS Currency,
		COUNT(cou.CountryCode) AS NumberOfCountries
FROM Currencies cur
LEFT JOIN Countries cou --за да се покажат всички валути (и тези които нямат държави)
	ON cur.CurrencyCode = cou.CurrencyCode
GROUP BY cur.CurrencyCode, cur.Description
ORDER BY NumberOfCountries DESC, Currency


--Problem 11. * Population and Area by Continent
--For each continent, display the total area and total population of all its countries.
--Sort the results by population from highest to lowest.
SELECT  con.ContinentName,
		SUM(CAST(cou.AreaInSqKm AS BIGINT)) AS CountriesArea,
		SUM(CAST(cou.Population AS BIGINT)) AS CountriesPopulation
FROM Continents con
JOIN Countries cou
	ON con.ContinentCode = cou.ContinentCode
GROUP BY con.ContinentName
ORDER BY CountriesPopulation DESC


--Problem 12. Highest Peak and Longest River by Country
--For each country, find the elevation of the highest peak and the length of the longest river,
--sorted by the highest peak elevation (from highest to lowest),
--then by the longest river length (from longest to smallest),
--then by country name (alphabetically).
--Display NULL when no data is available in some of the columns.
SELECT  cou.CountryName,
		MAX(p.Elevation) AS HighestPeakElevation,
		MAX(r.Length) AS LongestRiverLength
FROM Countries cou
LEFT JOIN MountainsCountries mc
	ON cou.CountryCode = mc.CountryCode
LEFT JOIN Peaks p
	ON p.MountainId = mc.MountainId
LEFT JOIN CountriesRivers cr
	ON cou.CountryCode = cr.CountryCode
LEFT JOIN Rivers r
	ON r.Id = cr.RiverId
GROUP BY cou.CountryName
ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC, cou.CountryName


--Problem 13. Mix of Peak and River Names
--Combine all peak names with all river names, so that the last letter of each peak name is
--the same like the first letter of its corresponding river name.
--Display the peak names, river names, and the obtained mix.
--Sort the results by the obtained mix.
SELECT  p.PeakName,
		r.RiverName,
		LOWER(SUBSTRING(p.PeakName, 1, LEN(p.PeakName) - 1) + r.RiverName) AS Mix
FROM Peaks p, Rivers r --така се прави cross join (Cartesian product): комбинира всяка стойност от едната таблица с всяка стойност от другата таблица
WHERE RIGHT(p.PeakName, 1) = LEFT(r.RiverName, 1)
ORDER BY Mix

--or
SELECT  p.PeakName,
		r.RiverName,
		LOWER(SUBSTRING(p.PeakName, 1, LEN(p.PeakName) - 1) + r.RiverName) AS Mix
FROM Peaks p, Rivers r 
WHERE LOWER(SUBSTRING(p.PeakName, LEN(p.PeakName), 1)) = LOWER(SUBSTRING(r.RiverName, 1, 1))
ORDER BY Mix


--Problem 14. ** Highest Peak Name and Elevation by Country
--For each country, find the name and elevation of the highest peak, along with its mountain.
--When no peaks are available in some country, display elevation 0,
--"(no highest peak)" as peak name and "(no mountain)" as mountain name.
--When multiple peaks in some country have the same elevation, display all of them.
--Sort the results by country name alphabetically, then by highest peak name alphabetically. 
SELECT  cou.CountryName AS Country,
		p.PeakName AS [Highest Peak Name],
		p.Elevation AS [Highest Peak Elevation],
		m.MountainRange AS Mountain
FROM Countries cou
LEFT JOIN MountainsCountries mc
	ON mc.CountryCode = cou.CountryCode
LEFT JOIN Mountains m
	ON m.Id = mc.MountainId
LEFT JOIN Peaks p
	ON p.MountainId = m.Id
WHERE p.Elevation =
  (SELECT MAX(p.Elevation)
  FROM Peaks p
  LEFT JOIN Mountains m ON p.MountainId = m.Id
  LEFT JOIN MountainsCountries mc ON mc.MountainId = m.Id
  WHERE cou.CountryCode = mc.CountryCode)   
UNION
SELECT
  cou.CountryName AS [Country],
  '(no highest peak)' AS [Highest Peak Name],
  0 AS [Highest Peak Elevation],
  '(no mountain)' AS [Mountain]
FROM
  Countries cou
  LEFT JOIN MountainsCountries mc ON cou.CountryCode = mc.CountryCode
  LEFT JOIN Mountains m ON m.Id = mc.MountainId
  LEFT JOIN Peaks p ON p.MountainId = m.Id
WHERE
  (SELECT MAX(p.Elevation)
  FROM Peaks p
  LEFT JOIN Mountains m ON p.MountainId = m.Id
  LEFT JOIN MountainsCountries mc ON mc.MountainId = m.Id
  WHERE cou.CountryCode = mc.CountryCode) IS NULL
ORDER BY cou.CountryName, [Highest Peak Name]