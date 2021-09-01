

--DBMD LECTURE
--UNIVERSITY DATABASE PROJECT 



--CREATE DATABASE


create database E_University


--//////////////////////////////


--CREATE TABLES 

create table Region
(
	region_id int primary key identity(1,1) not null,
	region nvarchar(max) not null
);


create table Staff
(
	staff_id int primary key identity(1,1) not null,
	first_name varchar(max) not null,
	last_name varchar(max) not null,
	region_id int not null,
	foreign key (region_id) references Region (region_id)
)


create table Students
(
	student_id int primary key identity(1,1) not null,
	first_name nvarchar(max) not null,
	last_name nvarchar(max) not null,
	register_date date null,
	region_id int not null,
	staff_id int not null,
	foreign key (region_id) references Region (region_id),
	foreign key (staff_id) references Staff (staff_id)
)


create table Courses
(
	course_id int primary key identity(1,1) not null,
	course_name varchar(max) not null,
	course_credit int check(course_credit in (15, 30)) not null
)


create table Enroll
(
	student_id int not null,
	course_id int not null,
	primary key (student_id, course_id),
	foreign key (student_id) references Students (student_id),
	foreign key (course_id) references Courses (course_id)
)


create table Staff_Course
(
	course_id int not null,
	staff_id int not null,
	primary key (course_id, staff_id),
	foreign key (course_id) references Courses (course_id),
	foreign key (staff_id) references Staff (staff_id)
)


-- INSERTING --

insert Region
values
('England'),
('Scotland'),
('Wales'),
('Northern Ireland')


insert Staff
values
('October', 'Lime', 3),
('Ross', 'Island', 2),
('Harry', 'Smith', 1),
('Neil', 'Mango', 2),
('Kellie', 'Pear', 1),
('Victor', 'Fig', 3),
('Margeret', 'Nolan', 1),
('Yavette', 'Berry', 4),
('Tom', 'Garden', 4)


insert Students
values
('Alec', 'Hunter', '12-05-2020', 3, 1),
('Bronwin', 'Blueberry', '12-05-2020', 2, 2),
('Charlie', 'Apricot', '12-05-2020', 1, 3),
('Ursula', 'Douglas', '12-05-2020', 2, 4),
('Zorro', 'Apple', '12-05-2020', 1, 5),
('Debbie','Orange', '12-05-2020', 3, 6)


insert Courses
values
('Fine Arts', 15),
('German', 15),
('Chemistry', 30),
('French', 30),
('Physics', 30),
('History', 30),
('Music', 30),
('Psychology', 30),
('Biology', 15)


insert Enroll
values
(1, 1),
(1, 2),
(2, 1),
(2, 2),
(3, 1),
(3, 2),
(4, 1),
(4, 2)

insert Staff_Course
values
(1, 4),
(2, 3),
(3, 7),
(4, 5),
(4, 7),
(5, 3),
(5, 5),
(9, 8)



--Make sure you add the necessary constraints.
--You can define some check constraints while creating the table, but some you must define later with the help of a scalar-valued function you'll write.
--Check whether the constraints you defined work or not.
--Import Values (Use the Data provided in the Github repo). 
--You must create the tables as they should be and define the constraints as they should be. 
--You will be expected to get errors in some points. If everything is not as it should be, you will not get the expected results or errors.
--Read the errors you will get and try to understand the cause of the errors.




select a.student_id, a.first_name, a.last_name, a.register_date, c.course_name, c.course_credit
from Students a, Enroll b, Courses c
where a.student_id = b.student_id
and b.course_id = c.course_id





--////////////////////


--CONSTRAINTS

--1. Students are constrained in the number of courses they can be enrolled in at any one time. 
--	 They may not take courses simultaneously if their combined points total exceeds 180 points.









--------///////////////////


--2. The student's region and the counselor's region must be the same.









--///////////////////////////////



------ADDITIONALLY TASKS



--1. Test the credit limit constraint.






--//////////////////////////////////

--2. Test that you have correctly defined the constraint for the student counsel's region. 






--/////////////////////////


--3. Try to set the credits of the History course to 20. (You should get an error.)





--/////////////////////////////

--4. Try to set the credits of the Fine Arts course to 30.(You should get an error.)





--////////////////////////////////////

--5. Debbie Orange wants to enroll in Chemistry instead of German. (You should get an error.)








--//////////////////////////


--6. Try to set Tom Garden as counsel of Alec Hunter (You should get an error.)





--/////////////////////////

--7. Swap counselors of Ursula Douglas and Bronwin Blueberry.






--///////////////////


--8. Remove a staff member from the staff table.
--	 If you get an error, read the error and update the reference rules for the relevant foreign key.





 



















