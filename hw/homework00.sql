\qecho Hayden Lauritzen

\qecho
\qecho #1
\qecho
-- query all rooms with capacity > 10
SELECT 
    *
FROM 
    room
WHERE 
    capacity > 10
;

\qecho
\qecho #2
\qecho
-- query all attendees from meeting 103
SELECT 
    employee.name
FROM 
    attendees, 
    meeting, 
    employee
WHERE 
    meetingid = 103
    AND employee.id = attendees.employeeid
    AND attendees.meetingid = meeting.id
ORDER BY    
    employee.name
;

\qecho
\qecho #3
\qecho
-- query all attendees of department 4 sorted by meetingid
SELECT 
    meeting.id,
    meeting.starttime,
    meeting.duration,
    meeting.creator,
    employee.name
FROM 
    employee, 
    meeting, 
    attendees
WHERE 
    employee.departmentid = 4
    AND employee.id = attendees.employeeid 
    AND attendees.meetingid = meeting.id 
ORDER BY meeting.id
;



/*
Hayden Lauritzen

#1

 id  | building | roomnum | capacity 
-----+----------+---------+----------
 202 | A        | 102     |       30
 203 | A        | 103     |       20
 205 | B        | 101     |       20
 206 | B        | 102     |       20
 207 | B        | 201     |       20
 208 | B        | 202     |       30
(6 rows)


#2

  name  
--------
 Albert
 Alice
 Dave
 Jack
 James
 Martha
(6 rows)


#3

 id  |      starttime      | duration | creator |  name  
-----+---------------------+----------+---------+--------
 101 | 2018-03-04 09:30:00 | 00:45:00 |      14 | Dave
 101 | 2018-03-04 09:30:00 | 00:45:00 |      14 | Albert
 102 | 2018-03-11 09:30:00 | 00:45:00 |      14 | Dave
 102 | 2018-03-11 09:30:00 | 00:45:00 |      14 | Albert
 103 | 2018-03-18 09:30:00 | 00:45:00 |      14 | Dave
 103 | 2018-03-18 09:30:00 | 00:45:00 |      14 | Albert
 104 | 2018-03-25 09:30:00 | 00:45:00 |      14 | Dave
 104 | 2018-03-25 09:30:00 | 00:45:00 |      14 | Albert
 105 | 2018-03-04 09:30:00 | 00:45:00 |       3 | Max
 106 | 2018-03-18 09:30:00 | 00:45:00 |       3 | Max
 107 | 2018-03-17 11:00:00 | 01:30:00 |       3 | Dave
 108 | 2018-03-09 09:30:00 | 01:00:00 |       6 | Albert
 109 | 2018-03-15 09:30:00 | 01:00:00 |       5 | Dave
 109 | 2018-03-15 09:30:00 | 01:00:00 |       5 | Albert
 110 | 2018-03-07 11:30:00 | 01:30:00 |      11 | Max
 110 | 2018-03-07 11:30:00 | 01:30:00 |      11 | Dave
 111 | 2018-03-07 09:30:00 | 01:00:00 |      14 | Max
(17 rows)


*/