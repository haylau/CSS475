
\qecho Hayden Lauritzen

\qecho
\qecho #1
\qecho
-- 1 - Find the number of meetings in each building – ordered by building ( A before B) 
-- Column names: building  num_meetings 
SELECT building, COUNT(*) as num_meetings
FROM meeting 
    JOIN room ON (room.id = meeting.roomid)
GROUP BY room.building  
ORDER BY room.building
;
\qecho
\qecho #2
\qecho
-- 2 - Show start time / end time for each meeting in building A  Order by starttime, roomNumber
-- Column names: building roomNumber startTime endTime
SELECT room.building, room.roomnumber AS "roomNumber", 
    meeting.starttime AS "startTime", meeting.starttime + meeting.duration AS "endTime"
FROM room
    JOIN meeting ON (room.id = meeting.roomid)
WHERE room.building = 'A'
ORDER BY room.building, roomNumber
;
\qecho
\qecho #3
\qecho
-- 3 - Return the number of meetings in each room in each building  order by building,  roomNumber
-- Column names: building  roomNumber  nummeetings
SELECT room.building, room.roomnumber as roomNumber, COUNT(*) as nummeetings
FROM meeting
    JOIN room ON (room.id = meeting.roomid)
GROUP BY roomNumber, room.building
ORDER BY building, roomNumber
;
\qecho
\qecho #4
\qecho
-- 4 - Find all meetings with no Moderator.  Order by starttime
-- Column names:  purpose  startime 
SELECT purpose, starttime
FROM meeting
WHERE moderatorid IS NULL;
;
\qecho
\qecho #5
\qecho
-- 5 – Find the number of attendees in each meeting.  Order by starttime, purpose
-- Column names  purpose, starttime,  num_attendees
SELECT meeting.purpose, meeting.starttime, COUNT(*) as num_attendees
FROM attendees
    JOIN meeting ON (meeting.id = attendees.meetingid)
    GROUP BY attendees.meetingid, meeting.purpose, meeting.starttime
ORDER BY meeting.starttime, meeting.purpose
;
\qecho
\qecho #6
\qecho
-- 6 – Find the number of available seats in each meeting.  Order by available seats_available Ascending, 
-- starttime
-- Column names: purpose starttime  num_attendees, seats_available
SELECT purpose, starttime, COUNT(*) as num_attendees, capacity - COUNT(*) as seats_available
FROM meeting
    JOIN room ON (meeting.roomid = room.id)
    JOIN attendees ON (attendees.meetingid = meeting.id)
GROUP BY attendees.meetingid, meeting.purpose, meeting.purpose, meeting.starttime, room.capacity
ORDER BY seats_available, starttime
;
\qecho
\qecho #7
\qecho
-- 7. Find the moderator and type of meeting.  List the combination of Moderator and Type only once.  
-- Order by name, purpose
--     Column names: name purpose
SELECT employee.name, meeting.purpose
FROM meeting
    JOIN employee ON (meeting.moderatorid = employee.id)
    GROUP BY employee.name, meeting.purpose
ORDER BY employee.name, meeting.purpose
;

-- 8. Find the number of meetings by moderator  Order by Moderator
-- Column names: name, moderator  num_meetings 
\qecho
\qecho #8
\qecho
SELECT employee.name AS moderator, COUNT(*) AS num_meetings
FROM meeting    
    JOIN employee ON (meeting.moderatorid = employee.id)
GROUP BY moderatorid, employee.name
ORDER BY moderator
;

-- 9. Find the employee with the most meetings in the system.  
-- Column names  name, num_meetings
\qecho
\qecho #9
\qecho
SELECT employee.name AS name, COUNT(*) as num_meetings
FROM attendees
    JOIN employee ON (attendees.employeeid = employee.id)
GROUP BY attendees.employeeid, employee.name
ORDER BY num_meetings DESC
LIMIT 1
;

-- 10. Find all attendees in any meeting going on at ‘2018-03-18 10:00’  Order by building, roomnumber
-- Column names:  name purpose starttime building roomnumber    
\qecho
\qecho #10
\qecho
SELECT employee.name AS name, purpose, starttime::timestamp, building, roomnumber
FROM attendees
    JOIN meeting ON (attendees.meetingid = meeting.id)
    JOIN employee ON (attendees.employeeid = employee.id)
    JOIN room ON (meeting.roomid = room.id)
WHERE starttime <= '2018-03-18 10:00' 
    AND (starttime + duration) >= '2018-03-18 10:00'
ORDER BY building, roomnumber
;

-- 11. Create a list giving the count of phone numbers under each category ( Cell, Pager, etc)  Order by 
-- category 
-- Column names:  category, count 
\qecho
\qecho #11
\qecho
SELECT 
    CASE phonetypeid 
    WHEN 'C' THEN 'Cell'
    WHEN 'H' THEN 'Home'
    WHEN 'P' THEN 'Pager'
    WHEN 'W' THEN 'Work'
    END AS category,
    COUNT(*) AS count
FROM phone
GROUP BY phonetypeid
ORDER BY phonetypeid
;
-- 12. The ‘Lunch’ meeting scheduled for 2018-03-28 has been canceled.  Create a list of all attendees ( 
-- who have cell numbers)  to the meeting and give the cell phone number for each. Order by name
-- Column name: attendee  cell_number
\qecho
\qecho #12
\qecho
SELECT employee.name AS attendee, phone.number AS cell_number
FROM phone
    JOIN employee ON (phone.employeeid = employee.id)
    JOIN attendees ON (employee.id = attendees.employeeid)
    JOIN meeting ON (attendees.meetingid = meeting.id)
WHERE phonetypeid = 'C'
    AND purpose = 'Lunch'
    AND starttime::date = '2018-03-28' 
ORDER BY attendee
;

/*
Hayden Lauritzen

#1

 building | num_meetings 
----------+--------------
 A        |            9
 B        |            7
(2 rows)


#2

 building | roomNumber |      startTime      |       endTime       
----------+------------+---------------------+---------------------
 A        | 101        | 2018-03-11 09:30:00 | 2018-03-11 10:30:00
 A        | 101        | 2018-03-18 09:30:00 | 2018-03-18 10:30:00
 A        | 101        | 2018-03-25 09:30:00 | 2018-03-25 10:30:00
 A        | 101        | 2018-03-04 09:30:00 | 2018-03-04 10:30:00
 A        | 102        | 2018-03-07 09:30:00 | 2018-03-07 10:30:00
 A        | 103        | 2018-03-04 09:30:00 | 2018-03-04 10:30:00
 A        | 103        | 2018-03-18 09:30:00 | 2018-03-18 10:30:00
 A        | 104        | 2018-03-17 11:00:00 | 2018-03-17 12:30:00
 A        | 104        | 2018-05-15 09:30:00 | 2018-05-15 10:30:00
(9 rows)


#3

 building | roomnumber | nummeetings 
----------+------------+-------------
 A        | 101        |           4
 A        | 102        |           1
 A        | 103        |           2
 A        | 104        |           2
 B        | 101        |           4
 B        | 201        |           2
 B        | 202        |           1
(7 rows)


#4

 purpose |      starttime      
---------+---------------------
 Lunch   | 2018-03-21 12:00:00
 Lunch   | 2018-03-28 12:00:00
 Lunch   | 2018-04-05 12:00:00
(3 rows)


#5

     purpose     |      starttime      | num_attendees 
-----------------+---------------------+---------------
 Staff           | 2018-03-04 09:30:00 |             6
 Staff           | 2018-03-04 09:30:00 |             6
 Team Build      | 2018-03-07 09:30:00 |             6
 HR Presentation | 2018-03-07 11:30:00 |            14
 DB Issues       | 2018-03-09 09:30:00 |             4
 Staff           | 2018-03-11 09:30:00 |             6
 Post Mortem     | 2018-03-15 09:30:00 |             6
 Sales           | 2018-03-17 11:00:00 |             3
 Staff           | 2018-03-18 09:30:00 |             8
 Staff           | 2018-03-18 09:30:00 |             7
 Lunch           | 2018-03-21 12:00:00 |             6
 Staff           | 2018-03-25 09:30:00 |             6
 Lunch           | 2018-03-28 12:00:00 |             7
 PlanningLunch   | 2018-03-28 12:00:00 |             7
 Lunch           | 2018-04-05 12:00:00 |             6
 Post Mortem     | 2018-05-15 09:30:00 |             6
(16 rows)


#6

     purpose     |      starttime      | num_attendees | seats_available 
-----------------+---------------------+---------------+-----------------
 Post Mortem     | 2018-05-15 09:30:00 |             6 |              -1
 Sales           | 2018-03-17 11:00:00 |             3 |               2
 Staff           | 2018-03-18 09:30:00 |             8 |               2
 Staff           | 2018-03-04 09:30:00 |             6 |               4
 Staff           | 2018-03-11 09:30:00 |             6 |               4
 Staff           | 2018-03-25 09:30:00 |             6 |               4
 Staff           | 2018-03-18 09:30:00 |             7 |              13
 Lunch           | 2018-03-28 12:00:00 |             7 |              13
 PlanningLunch   | 2018-03-28 12:00:00 |             7 |              13
 Staff           | 2018-03-04 09:30:00 |             6 |              14
 Lunch           | 2018-03-21 12:00:00 |             6 |              14
 Lunch           | 2018-04-05 12:00:00 |             6 |              14
 HR Presentation | 2018-03-07 11:30:00 |            14 |              16
 Team Build      | 2018-03-07 09:30:00 |             6 |              24
 DB Issues       | 2018-03-09 09:30:00 |             4 |                
 Post Mortem     | 2018-03-15 09:30:00 |             6 |                
(16 rows)


#7

  name  |     purpose     
--------+-----------------
 Albert | Post Mortem
 Albert | Team Build
 Alice  | Staff
 Dan    | DB Issues
 Jack   | HR Presentation
 Max    | PlanningLunch
 Max    | Sales
 Max    | Staff
(8 rows)


#8

 moderator | num_meetings 
-----------+--------------
 Albert    |            3
 Alice     |            4
 Dan       |            1
 Jack      |            1
 Max       |            4
(5 rows)


#9

 name | num_meetings 
------+--------------
 Dave |           11
(1 row)


#10

  name   | purpose |      starttime      | building | roomnumber 
---------+---------+---------------------+----------+------------
 Dave    | Staff   | 2018-03-18 09:30:00 | A        | 101
 Jack    | Staff   | 2018-03-18 09:30:00 | A        | 101
 John    | Staff   | 2018-03-18 09:30:00 | A        | 101
 Martha  | Staff   | 2018-03-18 09:30:00 | A        | 101
 Alice   | Staff   | 2018-03-18 09:30:00 | A        | 101
 Albert  | Staff   | 2018-03-18 09:30:00 | A        | 101
 Sarah   | Staff   | 2018-03-18 09:30:00 | A        | 101
 Sarah   | Staff   | 2018-03-18 09:30:00 | A        | 101
 Sarah   | Staff   | 2018-03-18 09:30:00 | A        | 103
 John    | Staff   | 2018-03-18 09:30:00 | A        | 103
 Winston | Staff   | 2018-03-18 09:30:00 | A        | 103
 Max     | Staff   | 2018-03-18 09:30:00 | A        | 103
 Dan     | Staff   | 2018-03-18 09:30:00 | A        | 103
 Alice   | Staff   | 2018-03-18 09:30:00 | A        | 103
 Sarah   | Staff   | 2018-03-18 09:30:00 | A        | 103
(15 rows)


#11

 category | count 
----------+-------
 Cell     |    10
 Home     |     8
 Pager    |     3
 Work     |    15
(4 rows)


#12

 attendee | cell_number 
----------+-------------
 Albert   | 134-4567
 Alice    | 126-5678
 Dave     | 127-7890
 Jack     | 128-6789
(4 rows)

*/
