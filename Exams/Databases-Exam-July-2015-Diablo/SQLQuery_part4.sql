/* Part V – Database Schema Design
Your task is to design a MySQL database schema, fill some data in it and write a query to retrieve some data.
 */


/*Problem 16. Design a Database Schema in MySQL and Write a Query
1.Design a MySQL database "Job Portal" to hold users, job ads, job ad applications and salaries.
Users hold username and optional full name.
JobAds hold title and optional description and have author and salary.
The job ad applications hold user, job ad and state. Salaries have from value and to value fields.
All tables should have auto-increment primary key – id. All text fields should accept Unicode characters.*/

CREATE DATABASE `job_portal`
CHARACTER SET utf8 COLLATE utf8_unicode_ci;

USE `job_portal`;

create table users(
id int not null AUTO_INCREMENT,
username nvarchar(50) not null,
fullname nvarchar(50),
PRIMARY KEY (id)
);

create table job_ads(
id int not null AUTO_INCREMENT,
title nvarchar(50) not null,
description text,
author_id int not null,
salary_id int not null,
PRIMARY KEY (id),
CONSTRAINT `fk_job_ads_users`
	FOREIGN KEY (`author_id`) 
    REFERENCES users (`id`),    
CONSTRAINT `fk_job_ads_salaries`
	FOREIGN KEY (`salary_id`) 
    REFERENCES salaries (`id`) 
);

create table job_ad_applications (
id int not null AUTO_INCREMENT,
job_ad_id int not null,
user_id int not null,
PRIMARY KEY (id),
CONSTRAINT fk_job_ad_applications_users
	FOREIGN KEY (user_id) 
    REFERENCES users (id)
    ON DELETE CASCADE,
CONSTRAINT fk_job_ad_applications_job_ads
	FOREIGN KEY (job_ad_id) 
    REFERENCES job_ads (id)
    ON DELETE CASCADE
);

create table salaries  (
id int not null AUTO_INCREMENT,
from_value int,
to_value int,
PRIMARY KEY (id)
);


/* 2.Execute the following SQL script to load data in your tables. It should pass without any errors:*/
insert into users (username, fullname)
values ('pesho', 'Peter Pan'),
('gosho', 'Georgi Manchev'),
('minka', 'Minka Dryzdeva'),
('jivka', 'Jivka Goranova'),
('gago', 'Georgi Georgiev'),
('dokata', 'Yordan Malov'),
('glavata', 'Galin Glavomanov'),
('petrohana', 'Peter Petromanov'),
('jubata', 'Jivko Jurandov'),
('dodo', 'Donko Drozev'),
('bobo', 'Bay Boris');

insert into salaries (from_value, to_value)
values (300, 500),
(400, 600),
(550, 700),
(600, 800),
(1000, 1200),
(1300, 1500),
(1500, 2000),
(2000, 3000);

insert into job_ads (title, description, author_id, salary_id)
values ('PHP Developer', NULL, (select id from users where username = 'gosho'), (select id from salaries where from_value = 300)),
('Java Developer', 'looking to hire Junior Java Developer to join a team responsible for the development and maintenance of the payment infrastructure systems', (select id from users where username = 'jivka'), (select id from salaries where from_value = 1000)),
('.NET Developer', 'net developers who are eager to develop highly innovative web and mobile products with latest versions of Microsoft .NET, ASP.NET, Web services, SQL Server and related applications.', (select id from users where username = 'dokata'), (select id from salaries where from_value = 1300)),
('JavaScript Developer', 'Excellent knowledge in JavaScript', (select id from users where username = 'minka'), (select id from salaries where from_value = 1500)),
('C++ Developer', NULL, (select id from users where username = 'bobo'), (select id from salaries where from_value = 2000)),
('Game Developer', NULL, (select id from users where username = 'jubata'), (select id from salaries where from_value = 600)),
('Unity Developer', NULL, (select id from users where username = 'petrohana'), (select id from salaries where from_value = 550));

insert into job_ad_applications(job_ad_id, user_id)
values 
	((select id from job_ads where title = 'C++ Developer'), (select id from users where username = 'gosho')),
	((select id from job_ads where title = 'Game Developer'), (select id from users where username = 'gosho')),
	((select id from job_ads where title = 'Java Developer'), (select id from users where username = 'gosho')),
	((select id from job_ads where title = '.NET Developer'), (select id from users where username = 'minka')),
	((select id from job_ads where title = 'JavaScript Developer'), (select id from users where username = 'minka')),
	((select id from job_ads where title = 'Unity Developer'), (select id from users where username = 'petrohana')),
	((select id from job_ads where title = '.NET Developer'), (select id from users where username = 'jivka')),
	((select id from job_ads where title = 'Java Developer'), (select id from users where username = 'jivka'));


/* 3. Write an SQL query to list all entries from the Job ad applications ordered by username,
then by job title in ascending order. Display the username, full name, job title, from value, to value. */
SELECT u.username, u.fullname, ja.title AS Job, s.from_value AS `From Value`, s.to_value AS `To Value`
FROM job_ad_applications jaa
  JOIN `users` u ON u.id = jaa.user_id
  JOIN `job_ads` ja ON ja.id = jaa.job_ad_id
  JOIN `salaries` s ON s.id = ja.salary_id
ORDER BY u.username, ja.title


