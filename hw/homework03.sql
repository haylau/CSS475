\qecho Hayden Lauritzen


-- 1 – Find the number of attendees in each meeting, as well as the capacity of the room and the creator ID   
-- ( by id I  mean meeting.id) 
-- Column Names:  id, butsinseat, capacity, creatorid
-- Order by meeting.id  
\qecho
\qecho #1
\qecho

SELECT meeting.id, COUNT(*) AS buttsinseats, COALESCE(capacity, COUNT(*)) AS capacity, creatorid
FROM meeting
    JOIN attendees ON (meeting.id = attendees.meetingid)
    JOIN room ON (room.id = meeting.roomid)
GROUP BY meeting.id, room.capacity, meeting.creatorid
ORDER BY meeting.id
;

-- 2 – For each creator of a meeting.  Find the total number of attendees in their meetings, the total 
-- capacity of all of their meetings, and the available number of seats in all their meetings.
-- Column Names: name, attendees, capacity, availseats
-- Order By creatorid, availseats

\qecho
\qecho #2
\qecho

SELECT employee.name, SUM(numAttendees.buttsinseats) AS attendees, SUM(numAttendees.capacity), SUM((numAttendees.capacity - numAttendees.buttsinseats)) AS availseats
FROM 
    (
    SELECT meeting.id, COUNT(*) AS buttsinseats, COALESCE(capacity, COUNT(*)) AS capacity, creatorid
    FROM meeting
        JOIN attendees ON (meeting.id = attendees.meetingid)
        JOIN room ON (room.id = meeting.roomid)
    GROUP BY meeting.id, room.capacity, meeting.creatorid
    ORDER BY meeting.id
    ) AS numAttendees
    JOIN employee ON (employee.id = numAttendees.creatorid)
GROUP BY numAttendees.creatorid, employee.name
ORDER BY creatorid, availseats
;


-- 3 – Find the name of the employee who is attending the most meetings.  Compute a number ( 
-- maxMeeetings) which is 75% of the total number of meetings for that person.
-- Column Names:  name maxmeetings

\qecho
\qecho #3
\qecho

SELECT employee.name, (meetingCount.numMeetings * .75) AS maxmeetings
FROM 
    (
        SELECT attendees.employeeid, COUNT(*) AS numMeetings
        FROM attendees 
        GROUP BY attendees.employeeid
        ORDER BY numMeetings DESC
    ) AS meetingCount
JOIN employee ON (meetingCount.employeeid = employee.id) 
LIMIT 1
;

--  4 – Find all employees who are attending almost as many meetings as the most prolific meeting 
-- attender.  ‘almost as many’ is defined as attending 75% of the number of meetings the most prolific 
-- meetening attender attends.
-- Column Names:  name, numMeetings
-- Order by numMeetings;

\qecho
\qecho #4
\qecho

SELECT meetingCount.name, meetingCount.numMeetings 
FROM 
    (
        SELECT (meetingCount.numMeetings * .75) AS maxmeetings
        FROM 
            (
                SELECT attendees.employeeid, COUNT(*) AS numMeetings
                FROM attendees 
                GROUP BY attendees.employeeid
                ORDER BY numMeetings DESC
            ) AS meetingCount
        JOIN employee ON (meetingCount.employeeid = employee.id) 
        LIMIT 1
    ) AS prolific
    JOIN 
    (
        SELECT employee.name, COUNT(*) AS numMeetings
        FROM meeting
            JOIN attendees ON (meeting.id = attendees.meetingid)
            JOIN employee  ON (employee.id = attendees.employeeid)
        GROUP BY attendees.employeeid, employee.name
        ORDER BY attendees.employeeid
    ) AS meetingCount ON (meetingCount.numMeetings >= prolific.maxmeetings) 
ORDER BY meetingCount.numMeetings
;

-- 5 – Find the average room utilization for all rooms occurring on 2018-03-04 at 10:00 AM .  Express the 
-- utilization as a percentage value which is ‘total number of rooms with meeting’ / ‘total number of 
-- rooms’
-- Column Names:  Util in %  

\qecho
\qecho #5
\qecho

SELECT ((roomUsage.count::decimal / numRooms.count::decimal) * 100)::integer AS "Util in %"
FROM
    (
        SELECT COUNT(*) AS count
        FROM meeting
            JOIN room ON (room.id = meeting.roomid)
        WHERE meeting.starttime::timestamp <= '2018-03-04 10:00:00'
            AND (meeting.starttime + duration)::timestamp >= '2018-03-04 10:00:00'
    ) AS roomUsage,
    (
        SELECT COUNT(*) AS count
        FROM room
    ) AS numRooms
;

-- #6 Show how many employees we have using each phone type
--  category | num_employees 
\qecho
\qecho #6
\qecho

SELECT phonetype.name AS category, COUNT(*) AS num_employees
FROM 
    (
        SELECT DISTINCT phone.phonetypeid, phone.employeeid
        FROM phone
            JOIN employee ON (employee.id = phone.employeeid)
        GROUP BY phone.phonetypeid, phone.employeeid
    ) AS phoneD
    JOIN phonetype ON (phoneD.phonetypeid = phonetype.id)
GROUP BY phonetype.name
ORDER BY phonetype.name
;


\qecho
\qecho #7
\qecho

SELECT phonetype.name AS category, COUNT(*) AS num_employees
FROM phone
    JOIN phonetype ON (phone.phonetypeid = phonetype.id)
GROUP BY phonetype.name
ORDER BY phonetype.name
;

-- #8 Number of cell phones in each meeting in building B
-- ( This will be useful in the next query)

\qecho
\qecho #8
\qecho

SELECT meeting.id AS meetingid, meeting.purpose, COUNT(*) AS numphones
FROM attendees
    JOIN meeting ON (attendees.meetingid = meeting.id)
    JOIN room ON (meeting.roomid = room.id)
    JOIN phone ON (attendees.employeeid = phone.employeeid)
    JOIN phonetype ON (phonetype.id = phone.phonetypeid)
WHERE room.building = 'B'
    AND phonetype.name = 'Cell'
GROUP BY meeting.id, meeting.purpose
ORDER BY meeting.id
;

-- #9 Print the average number of cell phones that attendees have in
-- meetings in building B

\qecho
\qecho #9
\qecho

SELECT AVG(numCell.numphones)::numeric(10,2) AS from_avg
FROM 
(   
    SELECT meeting.id, meeting.purpose, COUNT(*) AS numphones
    FROM attendees
        JOIN meeting ON (attendees.meetingid = meeting.id)
        JOIN room ON (meeting.roomid = room.id)
        JOIN phone ON (attendees.employeeid = phone.employeeid)
        JOIN phonetype ON (phonetype.id = phone.phonetypeid)
    WHERE room.building = 'B'
        AND phonetype.name = 'Cell'
    GROUP BY meeting.id, meeting.purpose
    ORDER BY meeting.id
) AS numCell
;

-- #10 find number of Cell phones, and average number of phones for
-- Each meeting in building A
\qecho
\qecho #10
\qecho

SELECT numphone.purpose AS purpose, numphone.count, avg.from_avg::numeric(10, 2)
FROM 
    (
    SELECT meeting.id, meeting.purpose, COUNT(*) AS count
    FROM attendees
        JOIN meeting ON (attendees.meetingid = meeting.id)
        JOIN room ON (meeting.roomid = room.id)
        JOIN phone ON (attendees.employeeid = phone.employeeid)
        JOIN phonetype ON (phonetype.id = phone.phonetypeid)
    WHERE room.building = 'A'
        AND phonetype.name = 'Cell'
    GROUP BY meeting.id, meeting.purpose
    ORDER BY meeting.id
    ) AS numphone,
    (
        SELECT AVG(numCell.numphones)::numeric(10,2) AS from_avg
        FROM 
        (   
            SELECT meeting.id, meeting.purpose, COUNT(*) AS numphones
            FROM attendees
                JOIN meeting ON (attendees.meetingid = meeting.id)
                JOIN room ON (meeting.roomid = room.id)
                JOIN phone ON (attendees.employeeid = phone.employeeid)
                JOIN phonetype ON (phonetype.id = phone.phonetypeid)
            WHERE room.building = 'A'
                AND phonetype.name = 'Cell'
            GROUP BY meeting.id, meeting.purpose
            ORDER BY meeting.id
        ) AS numCell
    ) AS avg
    ORDER BY numphone.purpose, numphone.id
;

/*
Hayden Lauritzen

#1

 id  | buttsinseats | capacity | creatorid 
-----+--------------+----------+-----------
 101 |            6 |       10 |        14
 102 |            6 |       10 |        14
 103 |            8 |       10 |        14
 104 |            6 |       10 |        14
 105 |            6 |       20 |         3
 106 |            7 |       20 |         3
 107 |            3 |        5 |         3
 108 |            4 |        4 |         6
 109 |            6 |        6 |         5
 110 |           14 |       30 |        11
 111 |            6 |       30 |        14
 112 |            6 |       20 |        14
 113 |            7 |       20 |        14
 114 |            6 |       20 |        14
 115 |            7 |       20 |         3
 116 |            6 |        5 |         5
(16 rows)


#2

  name   | attendees | sum | availseats 
---------+-----------+-----+------------
 Winston |        23 |  65 |         42
 Dan     |        12 |  11 |         -1
 Alice   |         4 |   4 |          0
 Jack    |        14 |  30 |         16
 Alice   |        51 | 130 |         79
(5 rows)


#3

 name | maxmeetings 
------+-------------
 Dave |        8.25
(1 row)


#4

  name  | nummeetings 
--------+-------------
 Albert |           9
 Jack   |          10
 Dave   |          11
(3 rows)


#5

 Util in % 
-----------
        22
(1 row)


#6

 category | num_employees 
----------+---------------
 Cell     |            10
 Home     |             7
 Pager    |             3
 Work     |            15
(4 rows)


#7

 category | num_employees 
----------+---------------
 Cell     |            10
 Home     |             8
 Pager    |             3
 Work     |            15
(4 rows)


#8

 id  |     purpose     | numphones 
-----+-----------------+-----------
 108 | DB Issues       |         3
 109 | Post Mortem     |         6
 110 | HR Presentation |         9
 112 | Lunch           |         3
 113 | Lunch           |         4
 114 | Lunch           |         3
 115 | PlanningLunch   |         5
(7 rows)


#9

 from_avg 
----------
     4.71
(1 row)


#10

   purpose   | count | from_avg 
-------------+-------+----------
 Staff       |     6 |     4.89
 Staff       |     6 |     4.89
 Staff       |     7 |     4.89
 Staff       |     6 |     4.89
 Staff       |     4 |     4.89
 Staff       |     4 |     4.89
 Sales       |     1 |     4.89
 Team Build  |     4 |     4.89
 Post Mortem |     6 |     4.89
(9 rows)

*/