--Part III – Changes in the Database
--You are given an MS SQL Server database "Diablo holding users, games, items, characters and
--statistics available as SQL script. Your task is to modify the database schema and data and
--write SQL queries for displaying data from the database. 

--Problem 12. Buy items for user in game
  --1. User Alex is in the shop in the game “Edinburgh” and she wants to buy some items.
  --She likes Blackguard, Bottomless Potion of Amplification, Eye of Etlich (Diablo III),
  --Gem of Efficacious Toxin, Golden Gorget of Leoric and Hellfire Amulet. Buy the items.
  --You should add the data in the right tables. Get the money for the items from user in game Cash.
  --2. Select all users in the current game with their items.
  --Display username, game name, cash and item name. Sort the result by item name.
insert into UserGameItems(ItemId, UserGameId)
values 
	(
		(select Id from Items where Name = 'Blackguard'), 
		(select ug.Id from UsersGames ug 
			join Users u on u.Id = ug.UserId
			join Games g on g.Id = ug.GameId
			where u.Username = 'Alex' and g.Name = 'Edinburgh')
	)

update UsersGames
set Cash = Cash - (select Price from Items where Name = 'Blackguard')
where Id = (select ug.Id from UsersGames ug 
			join Users u on u.Id = ug.UserId
			join Games g on g.Id = ug.GameId
			where u.Username = 'Alex' and g.Name = 'Edinburgh')

insert into UserGameItems(ItemId, UserGameId)
values 
	(
		(select Id from Items where Name = 'Bottomless Potion of Amplification'), 
		(select ug.Id from UsersGames ug 
			join Users u on u.Id = ug.UserId
			join Games g on g.Id = ug.GameId
			where u.Username = 'Alex' and g.Name = 'Edinburgh')
	)

update UsersGames
set Cash = Cash - (select Price from Items where Name = 'Bottomless Potion of Amplification')
where Id = (select ug.Id from UsersGames ug 
	join Users u on u.Id = ug.UserId
	join Games g on g.Id = ug.GameId
	where u.Username = 'Alex' and g.Name = 'Edinburgh')

insert into UserGameItems(ItemId, UserGameId)
values (
		(select Id from Items where Name = 'Eye of Etlich (Diablo III)'), 
		(select ug.Id from UsersGames ug 
			join Users u on u.Id = ug.UserId
			join Games g on g.Id = ug.GameId
			where u.Username = 'Alex' and g.Name = 'Edinburgh')
	)

update UsersGames
set Cash = Cash - (select Price from Items where Name = 'Eye of Etlich (Diablo III)')
where Id = (select ug.Id from UsersGames ug 
	join Users u on u.Id = ug.UserId
	join Games g on g.Id = ug.GameId
	where u.Username = 'Alex' and g.Name = 'Edinburgh')

insert into UserGameItems(ItemId, UserGameId)
values (
		(select Id from Items where Name = 'Gem of Efficacious Toxin'), 
		(select ug.Id from UsersGames ug 
			join Users u on u.Id = ug.UserId
			join Games g on g.Id = ug.GameId
			where u.Username = 'Alex' and g.Name = 'Edinburgh')
	)

update UsersGames
set Cash = Cash - (select Price from Items where Name = 'Gem of Efficacious Toxin')
where Id = (select ug.Id from UsersGames ug 
	join Users u on u.Id = ug.UserId
	join Games g on g.Id = ug.GameId
	where u.Username = 'Alex' and g.Name = 'Edinburgh')

insert into UserGameItems(ItemId, UserGameId)
values (
		(select Id from Items where Name = 'Golden Gorget of Leoric'), 
		(select ug.Id from UsersGames ug 
			join Users u on u.Id = ug.UserId
			join Games g on g.Id = ug.GameId
			where u.Username = 'Alex' and g.Name = 'Edinburgh')
	)

update UsersGames
set Cash = Cash - (select Price from Items where Name = 'Golden Gorget of Leoric')
where Id = (select ug.Id from UsersGames ug 
	join Users u on u.Id = ug.UserId
	join Games g on g.Id = ug.GameId
	where u.Username = 'Alex' and g.Name = 'Edinburgh')

	
insert into UserGameItems(ItemId, UserGameId)
values (
		(select Id from Items where Name = 'Hellfire Amulet'), 
		(select ug.Id from UsersGames ug 
			join Users u on u.Id = ug.UserId
			join Games g on g.Id = ug.GameId
			where u.Username = 'Alex' and g.Name = 'Edinburgh')
	)

update UsersGames
set Cash = Cash - (select Price from Items where Name = 'Hellfire Amulet')
where Id = (select ug.Id from UsersGames ug 
	join Users u on u.Id = ug.UserId
	join Games g on g.Id = ug.GameId
	where u.Username = 'Alex' and g.Name = 'Edinburgh')


/* --hack with hardcoded values:

INSERT INTO UserGameItems
VALUES (51, 235),
	(71,235),
	(157,235),
(184, 235),
(197, 235),
(223, 235)


UPDATE UsersGames
SET CASH = Cash - 2957
WHERE UsersGames.GameId = 221 AND
UsersGames.UserId = 5
*/

SELECT u.Username, g.Name, ug.Cash, i.Name AS [Item Name]
FROM Users u
JOIN UsersGames ug ON ug.UserId = u.Id
JOIN Games g ON g.Id = ug.GameId
JOIN UserGameItems ugi ON ugi.UserGameId = ug.Id
JOIN Items i ON i.Id = ugi.ItemId
WHERE g.Name = 'Edinburgh'
ORDER BY [Item Name]


--Problem 13. Massive shopping
  --1.	User Stamat in Safflower game wants to buy some items. He likes all items from Level 11 to 12
  --as well as all items from Level 19 to 21. As it is a bulk operation you have to use transactions. 
  --2.	A transaction is the operation of taking out the cash from the user in the current game
  --as well as adding up the items. 
  --3.	Write transactions for each level range. If anything goes wrong turn back the changes
  --inside of the transaction.
  --4.	Extract all item names in the given game sorted by name alphabetically
SET XACT_ABORT ON 
BEGIN TRANSACTION [Tran1]

BEGIN TRY

	UPDATE 
		UsersGames 
	SET 
		Cash = Cash - (
			SELECT SUM(Price) FROM Items WHERE MinLevel BETWEEN 11 AND 12
		) 
	WHERE Id = 110

	INSERT INTO UserGameItems (UserGameId, ItemId)
	SELECT 110, Id FROM Items WHERE MinLevel BETWEEN 11 AND 12

COMMIT TRANSACTION [Tran1]

END TRY
BEGIN CATCH
  ROLLBACK TRANSACTION [Tran1]
END CATCH 
GO

BEGIN TRANSACTION [Tran2]

BEGIN TRY

	UPDATE 
		UsersGames 
	SET 
		Cash = Cash - (
			SELECT SUM(Price) FROM Items WHERE MinLevel BETWEEN 19 AND 21
		) 
	WHERE Id = 110

	INSERT INTO UserGameItems (UserGameId, ItemId)
	SELECT 110, Id FROM Items WHERE MinLevel BETWEEN 19 AND 21

COMMIT TRANSACTION [Tran2]

END TRY
BEGIN CATCH
  ROLLBACK TRANSACTION [Tran2]
END CATCH 
GO

SELECT Items.Name [Item Name] 
FROM Items 
INNER JOIN UserGameItems ON Items.Id = UserGameItems.ItemId 
WHERE UserGameId = 110 
ORDER BY [Item Name]
