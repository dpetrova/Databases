--Part II – Changes in the Database
--You are given a MS SQL Server database "Ads" holding advertisements, organized by categories
--and towns, available as SQL script. Your task is to modify the database schema and data and
--write SQL queries for displaying data from the database.

--Problem 16. Ads by Country
	--1.Create a table Countries(Id, Name). Use auto-increment for the primary key.
	--Add a new column CountryId in the Towns table to link each town to some country
	--(non-mandatory link). Create a foreign key between the Countries and Towns tables.
CREATE TABLE Countries(
	Id int NOT NULL IDENTITY PRIMARY KEY,
	Name nvarchar(50) NOT NULL
)
GO

ALTER TABLE Towns ADD CountryId int
GO

ALTER TABLE Towns ADD CONSTRAINT FK_Towns_Countries
FOREIGN KEY(CountryId) REFERENCES Countries(Id)
GO

--2.Execute the following SQL script (it should pass without any errors):
INSERT INTO Countries(Name) VALUES ('Bulgaria'), ('Germany'), ('France')

UPDATE Towns SET CountryId = (SELECT Id FROM Countries WHERE Name='Bulgaria')

INSERT INTO Towns VALUES
('Munich', (SELECT Id FROM Countries WHERE Name='Germany')),
('Frankfurt', (SELECT Id FROM Countries WHERE Name='Germany')),
('Berlin', (SELECT Id FROM Countries WHERE Name='Germany')),
('Hamburg', (SELECT Id FROM Countries WHERE Name='Germany')),
('Paris', (SELECT Id FROM Countries WHERE Name='France')),
('Lyon', (SELECT Id FROM Countries WHERE Name='France')),
('Nantes', (SELECT Id FROM Countries WHERE Name='France'))

--3. Write and execute a SQL command that changes the town to "Paris" for all ads created at Friday.
UPDATE Ads
SET TownId = (SELECT Id FROM Towns WHERE Name = 'Paris')
WHERE DATENAME(WEEKDAY, Date) = 'Friday'

--4. Write and execute a SQL command that changes the town to "Hamburg" for all ads created at
--Thursday.
UPDATE Ads
SET TownId = (SELECT Id FROM Towns WHERE Name = 'Hamburg')
WHERE DATENAME(WEEKDAY, Date) = 'Thursday'

--5. Delete all ads created by user in role "Partner".
DELETE FROM Ads
FROM Ads a
JOIN AspNetUsers anu ON anu.Id = a.OwnerId
JOIN AspNetUserRoles anur ON anur.UserId = anu.Id
JOIN AspNetRoles anr ON anr.Id = anur.RoleId
WHERE anr.Name = 'Partner'

--6. Add a new add holding the following information: Title="Free Book", Text="Free C# Book",
--Date={current date and time}, Owner="nakov", Status="Waiting Approval".
INSERT INTO Ads(Title, Text, Date, OwnerId, StatusId)
VALUES ('Free Book',
		'Free C# Book',
		GETDATE(),
		(SELECT Id FROM AspNetUsers WHERE UserName = 'nakov'),
		(SELECT Id FROM AdStatuses WHERE Status = 'Waiting Approval')
)

--7. Find the count of ads for each town. Display the ads count, the town name and the country name.
--Include also the ads without a town and country. Sort the results by town, then by country.
SELECT t.Name AS Town, c.Name AS Country, COUNT(a.Id) AS AdsCount
FROM Ads a
FULL OUTER JOIN Towns t ON t.Id = a.TownId
FULL OUTER JOIN Countries c ON c.Id = t.CountryId
GROUP BY t.Name, c.Name
ORDER BY Town, Country