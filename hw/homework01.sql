\qecho Hayden Lauritzen

-- 1 – building  room_number  for all Rooms in the system. ( Note  room_number not roomnum)   
-- Order By roomNumber, building
\qecho
\qecho #1
\qecho

SELECT building, roomnum AS room_number
FROM room
ORDER BY room_number, building
;

-- 2 -  building room_number capacity  For all rooms with capacity between 10 through 15 inclusive
\qecho
\qecho #2
\qecho

SELECT building, roomnum AS room_number, capacity
FROM room
WHERE capacity >= 10
    AND capacity <= 15
;

-- 3 – attendees  For the DB Issues meeting ( By attendees I mean the name of the Employee)
-- Order by attendee name
\qecho
\qecho #3
\qecho

SELECT employee.name AS attendees
FROM employee
    JOIN attendees ON (employee.id = attendees.employeeid)
    JOIN meeting ON (meeting.id = attendees.meetingid)
WHERE meeting.purpose = 'DB Issues'
ORDER BY attendees
;

-- 4 – starttime duration purpose  for all of Winston’s  meetings ( Where Winston  is the creator of the 
-- meeting)  Sort with earliest meeting date at the top of the list)
\qecho
\qecho #4
\qecho

SELECT starttime, duration, purpose
FROM meeting
    JOIN employee ON (meeting.creator = employee.id)
WHERE employee.name = 'Winston'
ORDER BY starttime
;

-- 5 – starttime duration purpose building roomnum for all meetings Alice is attending.  Sort by Purpose 
-- and StartTime.  For purpose, sort in reverse order ( Staff at top)  For starttime order with earliest data at top.
\qecho
\qecho #5
\qecho

SELECT starttime, duration, purpose, room.building, room.roomnum
FROM meeting
    JOIN room ON (meeting.roomid = room.id)
    JOIN attendees ON (attendees.meetingid = meeting.id)
    JOIN employee ON (attendees.employeeid = employee.id)
WHERE employee.name = 'Alice'
ORDER BY purpose DESC, starttime
;

-- 6 – name phone  For all employees.  Sort by employee name.  ‘A’ at the top of the list. 
\qecho
\qecho #6
\qecho

SELECT employee.name, employee.phone
FROM employee
ORDER BY employee.name
;

-- 7 – creator_name purpose building room_number meetingreason, starttime, duration  for all meetings 
-- owned  by Alice 
-- Sort by starttime ( most recent data at top)   ( note use of creator_name and room_number  )  
\qecho
\qecho #7
\qecho

SELECT employee.name as creator_name, purpose, building, roomnum AS room_number, purpose as meetingreason, starttime, duration
FROM meeting
    JOIN employee ON (meeting.creator = employee.id)
    JOIN room ON (meeting.roomid = room.id)
WHERE employee.name = 'Alice'
ORDER BY starttime DESC
;

-- 8 – dept_name  emp_name purpose  building  roomnum  for all meetings in every department that 
-- starts with ‘Software’  where the meeting is in building  ‘B’   Sort by dept_name, emp_name, purpose 
\qecho
\qecho #8
\qecho
SELECT department.name as dept_name, employee.name as emp_name, purpose, building, roomnum
FROM meeting
    JOIN attendees ON meeting.id = attendees.meetingid
    JOIN employee ON employee.id = attendees.employeeid
    JOIN department ON employee.departmentid = department.id
    JOIN room ON meeting.roomid = room.id
WHERE room.building = 'B'
    AND department.name LIKE 'Software%'
ORDER BY dept_name, emp_name, purpose 
;

-- 9 – creator_name homephone  for every meeting organizer order by organizer_name.  
\qecho
\qecho #9
\qecho
SELECT employee.name as creator_name, homephone
FROM meeting
    JOIN employee ON meeting.creator = employee.id
GROUP BY creator_name, homephone
ORDER BY creator_name
;


-- 10 – building roomnumber starttime  for every meeting. order by start time, roomnum ;
\qecho
\qecho #10
\qecho

SELECT building, roomnum as roomnumber, starttime
FROM meeting
    JOIN room ON meeting.roomid = room.id
ORDER BY starttime, roomnum
;

/*
Hayden Lauritzen

#1

 building | room_number 
----------+-------------
 A        | 101
 B        | 101
 A        | 102
 B        | 102
 A        | 103
 A        | 104
 B        | 104
 B        | 201
 B        | 202
(9 rows)


#2

 building | room_number | capacity 
----------+-------------+----------
 A        | 101         |       10
(1 row)


#3

 attendees 
-----------
 Albert
 Alice
 Mark
 Martha
(4 rows)


#4

      starttime      | duration | purpose 
---------------------+----------+---------
 2018-03-04 09:30:00 | 00:45:00 | Staff
 2018-03-17 11:00:00 | 01:30:00 | Sales
 2018-03-18 09:30:00 | 00:45:00 | Staff
(3 rows)


#5

      starttime      | duration |     purpose     | building | roomnum 
---------------------+----------+-----------------+----------+---------
 2018-03-04 09:30:00 | 00:45:00 | Staff           | A        | 101
 2018-03-11 09:30:00 | 00:45:00 | Staff           | A        | 101
 2018-03-18 09:30:00 | 00:45:00 | Staff           | A        | 101
 2018-03-25 09:30:00 | 00:45:00 | Staff           | A        | 101
 2018-03-15 09:30:00 | 01:00:00 | Post Mortem     | B        | 201
 2018-03-07 11:30:00 | 01:30:00 | HR Presentation | B        | 202
 2018-03-09 09:30:00 | 01:00:00 | DB Issues       | B        | 201
(7 rows)


#6

  name   | phone 
---------+-------
 Albert  | 7234
 Alice   | 7233
 Ariel   | 134
 Dan     | 4501
 Dave    | 7229
 Jack    | 7230
 James   | 7231
 John    | 8314
 Mark    | 7228
 Martha  | 7232
 Max     | 3261
 Sarah   | 4592
 Sarah   | 7227
 Winston | 7248
(14 rows)


#7

 creator_name |  purpose   | building | room_number | meetingreason |      starttime      | duration 
--------------+------------+----------+-------------+---------------+---------------------+----------
 Alice        | Staff      | A        | 101         | Staff         | 2018-03-25 09:30:00 | 00:45:00
 Alice        | Staff      | A        | 101         | Staff         | 2018-03-18 09:30:00 | 00:45:00
 Alice        | Staff      | A        | 101         | Staff         | 2018-03-11 09:30:00 | 00:45:00
 Alice        | Team Build | A        | 102         | Team Build    | 2018-03-07 09:30:00 | 01:00:00
 Alice        | Staff      | A        | 101         | Staff         | 2018-03-04 09:30:00 | 00:45:00
(5 rows)


#8

   dept_name   | emp_name |     purpose     | building | roomnum 
---------------+----------+-----------------+----------+---------
 Software Dev  | Ariel    | HR Presentation | B        | 202
 Software Dev  | James    | HR Presentation | B        | 202
 Software Dev  | James    | Post Mortem     | B        | 201
 Software Dev  | Sarah    | HR Presentation | B        | 202
 Software Test | John     | HR Presentation | B        | 202
 Software Test | Martha   | DB Issues       | B        | 201
 Software Test | Martha   | HR Presentation | B        | 202
 Software Test | Martha   | Post Mortem     | B        | 201
 Software Test | Sarah    | HR Presentation | B        | 202
(9 rows)


#9

 creator_name | homephone 
--------------+-----------
 Alice        | 341
 Ariel        | 336
 Dan          | 335
 Jack         | 342
 Winston      | 333
(5 rows)


#10

 building | roomnumber |      starttime      
----------+------------+---------------------
 A        | 101        | 2018-03-04 09:30:00
 A        | 103        | 2018-03-04 09:30:00
 A        | 102        | 2018-03-07 09:30:00
 B        | 202        | 2018-03-07 11:30:00
 B        | 201        | 2018-03-09 09:30:00
 A        | 101        | 2018-03-11 09:30:00
 B        | 201        | 2018-03-15 09:30:00
 A        | 104        | 2018-03-17 11:00:00
 A        | 101        | 2018-03-18 09:30:00
 A        | 103        | 2018-03-18 09:30:00
 A        | 101        | 2018-03-25 09:30:00
(11 rows)


*/