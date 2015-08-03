--Part I – SQL Queries
--You are given a MS SQL Server database "Ads" holding advertisements, organized by categories and
--towns, available as SQL script. Your task is to write SQL queries for displaying data from the
--given database.



--Problem 10. Not Published Ads from the First Month
--Find all not published ads, created in the same month and year like the earliest ad.
--Display for each ad its id, title, date and status. Sort the results by Id.
SELECT a.Id, a.Title, a.Date, ads.Status
FROM Ads a
JOIN AdStatuses ads ON a.StatusId = ads.Id
WHERE 
	  MONTH(Date) = (SELECT MONTH(MIN(Date)) FROM Ads) AND
	  YEAR(Date) = (SELECT YEAR(MIN(Date)) FROM Ads) AND
	  ads.Status <> 'Published'
ORDER BY a.Id


--Problem 13. * Ads by Users
--Find the count of ads for each user. Display the username, ads count and "yes" or "no" depending on
--whether the user belongs to the role "Administrator". Sort the results by username.
--Display all users, including the users who have no ads.
SELECT  anu.UserName,
		COUNT(a.Id) AS AdsCount,
		(CASE WHEN anr.Name = 'Administrator' THEN 'yes' ELSE 'no' END) as IsAdministrator
FROM Ads a
LEFT JOIN AspNetUsers anu ON anu.Id = a.OwnerId
LEFT JOIN AspNetUserRoles anur ON anur.UserId = anu.Id
LEFT JOIN AspNetRoles anr ON anr.Id = anur.RoleId
GROUP BY anu.UserName, anr.Name
ORDER BY anu.UserName

--or
SELECT 
  MIN(u.UserName) as UserName, 
  COUNT(a.Id) as AdsCount,
  (CASE WHEN admins.UserName IS NULL THEN 'no' ELSE 'yes' END) AS IsAdministrator
FROM 
  AspNetUsers u
  LEFT JOIN Ads a ON u.Id = a.OwnerId
  LEFT JOIN (
    SELECT DISTINCT u.UserName
	FROM AspNetUsers u
	  LEFT JOIN AspNetUserRoles ur ON ur.UserId = u.Id
	  LEFT JOIN AspNetRoles r ON ur.RoleId = r.Id
	WHERE r.Name = 'Administrator'
  ) AS admins ON u.UserName = admins.UserName
GROUP BY OwnerId, u.UserName, admins.UserName
ORDER BY u.UserName


--Problem 14. Ads by Town
--Find the count of ads for each town. Display the ads count and town name or "(no town)" for
--the ads without a town. Display only the towns, which hold 2 or 3 ads.
--Sort the results by town name.
SELECT  COUNT(a.Id) AS AdsCount,
		ISNULL(t.Name, '(no town)') as Town
FROM Ads a
LEFT JOIN Towns t ON t.Id = a.TownId
GROUP BY t.Name
HAVING COUNT(a.Id) IN (2,3)
ORDER BY Town


--Problem 15.	Pairs of Dates within 12 Hours
--Consider the dates of the ads. Find among them all pairs of different dates, such that the
--second date is no later than 12 hours after the first date. Sort the dates in increasing order
--by the first date, then by the second date.
SELECT a1.Date AS FirstDate, a2.Date AS SecondDate
FROM Ads a1, Ads a2
WHERE a2.Date > a1.Date AND
      DATEDIFF(HOUR, a1.Date, a2.Date) < 12
ORDER BY FirstDate, SecondDate