--Part IV – Stored Procedures / Functions / Triggers
--You are given an MS SQL Server database "Diablo" holding users, games, items, characters and statistics
--available as SQL script. Your task is to write some stored procedures, views and other server-side database objects
--and write some SQL queries for displaying data from the database.
--Important: start with a clean copy of the "Diablo" database on each problem.
--Just execute the SQL script again.

--Problem 14. Scalar Function: Cash in User Games Odd Rows
--Create a function fn_CashInUsersGames that returns the sum of the cash on odd rows ordered by cash in descending order.
--The function should take a game name as a parameter.
--Execute the function over the following game names, ordered exactly like:
--“Bali”, “Lily Stargazer”, “Love in a mist”, “Mimosa”, “Ming fern”.
create function ufn_CashInUsersGames(@gameName nvarchar(max))
returns table
as return
with prices as (
	select Cash, (ROW_NUMBER() OVER(ORDER BY ug.Cash desc)) as RowNum from UsersGames ug
	join Games g on ug.GameId = g.Id
	where g.Name = @gameName
) 
select SUM(Cash) [SumCash] FROM prices WHERE RowNum % 2 = 1
GO

select * from ufn_CashInUsersGames('Bali')
union
select * from ufn_CashInUsersGames('Lily Stargazer')
union
select * from ufn_CashInUsersGames('Love in a mist')
union
select * from ufn_CashInUsersGames('Mimosa')
union
select * from ufn_CashInUsersGames('Ming fern')


--Problem 15.	Trigger
--Users should not be allowed to buy items with higher level than their level. Create a trigger that restricts that.
--Add bonus cash of 50000 to users: baleremuda, loosenoise, inguinalself, buildingdeltoid, monoxidecos in the game “Bali”.
--There are two groups of items that you should buy for the above users in the game.
--First group is with id between 251 and 299 including. Second group is with id between 501 and 539 including.
--Take off cash from each user for the bought items.
--Select all users in the current game with their items. Display username, game name, cash and item name.
--Sort the result by username alphabetically, then by item name alphabetically. 
create trigger tr_UserGameItems on UserGameItems
instead of insert
as
	insert into UserGameItems
	select ItemId, UserGameId from inserted
	where 
		ItemId in (
			select Id 
			from Items 
			where MinLevel <= (
				select [Level]
				from UsersGames 
				where Id = UserGameId
			)
		)
go

-- Add bonus cash for users

update UsersGames
set Cash = Cash + 50000 + (SELECT SUM(i.Price) FROM Items i JOIN UserGameItems ugi ON ugi.ItemId = i.Id WHERE ugi.UserGameId = UsersGames.Id)
where UserId in (
	select Id 
	from Users 
	where Username in ('loosenoise', 'baleremuda', 'inguinalself', 'buildingdeltoid', 'monoxidecos')
)
and GameId = (select Id from Games where Name = 'Bali')

-- Buy items for users

insert into UserGameItems (UserGameId, ItemId)
select  UsersGames.Id, i.Id 
from UsersGames, Items i
where UserId in (
	select Id 
	from Users 
	where Username in ('loosenoise', 'baleremuda', 'inguinalself', 'buildingdeltoid', 'monoxidecos')
) and GameId = (select Id from Games where Name = 'Bali' ) and ((i.Id > 250 and i.Id < 300) or (i.Id > 500 and i.Id < 540))


-- Get cash from users
update UsersGames
set Cash = Cash - (SELECT SUM(i.Price) FROM Items i JOIN UserGameItems ugi ON ugi.ItemId = i.Id WHERE ugi.UserGameId = UsersGames.Id)
where UserId in (
	select Id 
	from Users 
	where Username in ('loosenoise', 'baleremuda', 'inguinalself', 'buildingdeltoid', 'monoxidecos')
)
and GameId = (select Id from Games where Name = 'Bali')


select u.Username, g.Name, ug.Cash, i.Name [Item Name] from UsersGames ug
join Games g on ug.GameId = g.Id
join Users u on ug.UserId = u.Id
join UserGameItems ugi on ugi.UserGameId = ug.Id
join Items i on i.Id = ugi.ItemId
where g.Name = 'Bali'
order by Username, [Item Name]