\qecho Hayden Lauritzen

-- 1 – building  room_number  for all Rooms in the system. ( Note  room_number not roomnum)   
-- Order By roomNumber, building
\qecho
\qecho #1
\qecho

SELECT building, roomnum AS room_number
FROM Room
ORDER BY room_number, building
;

-- 2 -  building room_number capacity  For all rooms with capacity between 10 through 15 inclusive
\qecho
\qecho #2
\qecho

SELECT building, roomnum AS room_number, capacity
FROM Room
WHERE capacity >= 10
    AND capacity <= 15
;

-- 3 – attendees  For the DB Issues meeting ( By attendees I mean the name of the Employee)
-- Order by attendee name
\qecho
\qecho #3
\qecho

SELECT employee.name as attendees
FROM employee
    JOIN attendees on (employee.id = attendees.employeeid)
    JOIN meeting on (meeting.id = attendees.meetingid)
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
    JOIN attendees ON (meeting.id = attendees.meetingid)
    JOIN employee ON (attendees.employeeid = employee.id)
WHERE employee.name = 'Winston'
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
ORDER BY starttime, purpose DESC
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
ORDER BY starttime
;

-- 8 – dept_name  emp_name purpose  building  roomnum  for all meetings in every department that 
-- starts with ‘Software’  where the meeting is in building  ‘B’   Sort by dept_name, emp_name, purpose 
\qecho
\qecho #8
\qecho
SELECT department.name as dept_name, employee.name as emp_name, purpose, building, roomnum
FROM meetings
    JOIN 

\qecho
\qecho #1
\qecho
