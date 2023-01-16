\qecho Mohammad Zahid, Hayden Lauritzen, Abhimanyu Kumar

\qecho
\qecho #1 
\qecho

SELECT roomnum, building 
FROM Room 
ORDER BY roomnum, building
;

\qecho
\qecho #2
\qecho

SELECT building, roomnum, capacity
FROM room
WHERE capacity >= 10 
  AND capacity <= 15
;

\qecho
\qecho #3
\qecho
SELECT creator, starttime, duration
FROM meeting
WHERE purpose = 'Staff'
;

\qecho
\qecho #4
\qecho

SELECT employee.name
FROM attendees
  JOIN employee ON (attendees.employeeid = employee.id)
  JOIN meeting ON (meeting.id = attendees.meetingid)
WHERE purpose = 'Sales'
;

\qecho
\qecho #5
\qecho
SELECT employee.name
FROM employee
WHERE employee.employeenum LIKE  '_________2%'
;

\qecho
\qecho #6
\qecho
SELECT purpose, starttime, duration
FROM meeting
  JOIN attendees ON (attendees.meetingid = meeting.id)
  JOIN employee ON (attendees.employeeid = employee.id)
WHERE employee.name = 'Ariel'
;

\qecho
\qecho #7
\qecho
SELECT employee.name, meeting.purpose, meeting.starttime, meeting.duration
FROM meeting
  JOIN attendees ON (attendees.meetingid = meeting.id)
  JOIN employee ON (attendees.employeeid = employee.id)
WHERE employee.homephone= '341'
ORDER BY meeting.starttime
;

\qecho
\qecho #8
\qecho
SELECT employee.name, employee.homephone
FROM employee
WHERE employee.homephone LIKE '3_3%'
;
\qecho

/*Mohammad Zahid, Hayden Lauritzen, Abhimanyu Kumar

#1

 roomnum | building 
---------+----------
 101     | A
 101     | B
 102     | A
 102     | B
 103     | A
 104     | A
 104     | B
 201     | B
 202     | B
(9 rows)


#2

 building | roomnum | capacity 
----------+---------+----------
 A        | 101     |       10
(1 row)


#3

 creator |      starttime      | duration 
---------+---------------------+----------
      14 | 2018-03-04 09:30:00 | 00:45:00
      14 | 2018-03-11 09:30:00 | 00:45:00
      14 | 2018-03-18 09:30:00 | 00:45:00
      14 | 2018-03-25 09:30:00 | 00:45:00
       3 | 2018-03-04 09:30:00 | 00:45:00
       3 | 2018-03-18 09:30:00 | 00:45:00
(6 rows)


#4

 name  
-------
 Sarah
 Mark
 Dave
(3 rows)


#5

 name  
-------
 Sarah
 Mark
 Jack
 Alice
(4 rows)


#6

     purpose     |      starttime      | duration 
-----------------+---------------------+----------
 Staff           | 2018-03-04 09:30:00 | 00:45:00
 Staff           | 2018-03-18 09:30:00 | 00:45:00
 HR Presentation | 2018-03-07 11:30:00 | 01:30:00
 Team Build      | 2018-03-07 09:30:00 | 01:00:00
(4 rows)


#7

  name  |     purpose     |      starttime      | duration 
--------+-----------------+---------------------+----------
 Alice  | Staff           | 2018-03-04 09:30:00 | 00:45:00
 Albert | Staff           | 2018-03-04 09:30:00 | 00:45:00
 Alice  | HR Presentation | 2018-03-07 11:30:00 | 01:30:00
 Alice  | DB Issues       | 2018-03-09 09:30:00 | 01:00:00
 Albert | DB Issues       | 2018-03-09 09:30:00 | 01:00:00
 Alice  | Staff           | 2018-03-11 09:30:00 | 00:45:00
 Albert | Staff           | 2018-03-11 09:30:00 | 00:45:00
 Alice  | Post Mortem     | 2018-03-15 09:30:00 | 01:00:00
 Albert | Post Mortem     | 2018-03-15 09:30:00 | 01:00:00
 Albert | Staff           | 2018-03-18 09:30:00 | 00:45:00
 Alice  | Staff           | 2018-03-18 09:30:00 | 00:45:00
 Albert | Staff           | 2018-03-25 09:30:00 | 00:45:00
 Alice  | Staff           | 2018-03-25 09:30:00 | 00:45:00
(13 rows)


#8

  name   | homephone 
---------+-----------
 Winston | 333
 James   | 343
(2 rows)


*/