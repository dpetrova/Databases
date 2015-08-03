/* Part IV – Database Schema Design
Your task is to design a MySQL database schema,
fill some data in it and write a query to retrieve some data. */

/*Problem 18. Design a Database Schema in MySQL and Write a Query
1. Design a MySQL database "trainings" to hold training centers, courses and a course timetable.
Courses hold name and optional description.
Training centers hold name, optional description and optional URL.
The course timetable holds a set of timetable items,
each consisting of course, training center and starting date.
All tables should have auto-increment primary key – id.
All text fields should accept Unicode characters.*/
DROP DATABASE IF EXISTS `trainings`;

CREATE DATABASE `trainings`
CHARACTER SET utf8 COLLATE utf8_unicode_ci;

USE `trainings`;

create table training_centers(
id int not null AUTO_INCREMENT,
name nvarchar(50) not null,
description text,
url nvarchar(300),
PRIMARY KEY (id)
);


create table courses(
id int not null AUTO_INCREMENT,
name nvarchar(50) not null,
description text,
PRIMARY KEY (id)
);

create table courses_timetables(
id int not null AUTO_INCREMENT,
start_date date not null,
training_center_id int not null,
course_id int not null,
PRIMARY KEY (id),
CONSTRAINT fk_courses_timetables_training_centers
	FOREIGN KEY (training_center_id) 
    REFERENCES training_centers (id)
    ON DELETE CASCADE,
CONSTRAINT fk_courses_timetables_courses    
FOREIGN KEY (course_id) 
    REFERENCES courses (id)
    ON DELETE CASCADE
);

/*2. Execute the following SQL script to load data in your tables. It should pass without any errors: */
INSERT INTO `training_centers` VALUES
(1, 'Sofia Learning', NULL, 'http://sofialearning.org'),
(2, 'Varna Innovations & Learning', 'Innovative training center, located in Varna. Provides trainings in software development and foreign languages', 'http://vil.edu'),
(3, 'Plovdiv Trainings & Inspiration', NULL, NULL),
(4, 'Sofia West Adult Trainings', 'The best training center in Lyulin', 'https://sofiawest.bg'),
(5, 'Software Trainings Ltd.', NULL, 'http://softtrain.eu'),
(6, 'Polyglot Language School', 'English, French, Spanish and Russian language courses', NULL),
(7, 'Modern Dances Academy', 'Learn how to dance!', 'http://danceacademy.bg');

INSERT INTO `courses` VALUES
(101, 'Java Basics', 'Learn more at https://softuni.bg/courses/java-basics/'),
(102, 'English for beginners', '3-month English course'),
(103, 'Salsa: First Steps', NULL),
(104, 'Avancée Français', 'French language: Level III'),
(105, 'HTML & CSS', NULL),
(106, 'Databases', 'Introductionary course in databases, SQL, MySQL, SQL Server and MongoDB'),
(107, 'C# Programming', 'Intro C# corse for beginners'),
(108, 'Tango dances', NULL),
(109, 'Spanish, Level II', 'Aprender Español');

INSERT INTO `courses_timetables`(course_id, training_center_id, start_date) VALUES
(101, 1, '2015-01-31'), (101, 5, '2015-02-28'),
(102, 6, '2015-01-21'), (102, 4, '2015-01-07'), (102, 2, '2015-02-14'), (102, 1, '2015-03-05'), (102, 3, '2015-03-01'),
(103, 7, '2015-02-25'), (103, 3, '2015-02-19'),
(104, 5, '2015-01-07'), (104, 1, '2015-03-30'), (104, 3, '2015-04-01'),
(105, 5, '2015-01-25'), (105, 4, '2015-03-23'), (105, 3, '2015-04-17'), (105, 2, '2015-03-19'),
(106, 5, '2015-02-26'),
(107, 2, '2015-02-20'), (107, 1, '2015-01-20'), (107, 3, '2015-03-01'), 
(109, 6, '2015-01-13');

SET SQL_SAFE_UPDATES = 0; /*ако не е изключен от Edit -> Preferences -> SQL Editor */

UPDATE `courses_timetables` t
  JOIN `courses` c ON t.course_id = c.id
SET t.start_date = DATE_SUB(t.start_date, INTERVAL 7 DAY)
WHERE c.name REGEXP '^[a-j]{1,5}.*s$';

/* 3. Write a SQL query to list all entries from the timetable ordered by start date and then by id.
Display the training center, start date, course name and more info about the course (course details). */
SELECT  tc.name AS `traning center`,
		ct.start_date AS `start date`,
        c.name AS `course name`,
        IFNULL(c.description, 'NULL') AS `more info`
FROM courses_timetables ct
JOIN training_centers tc
	ON ct.training_center_id = tc.id
JOIN courses c
	ON ct.course_id = c.id
ORDER BY ct.start_date, ct.id


