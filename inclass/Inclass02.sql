/* 
1 - Find the number of meetings in each building – ordered by building ( A before B) 
Column names: building  num_meetings 
2 - Show start time / end time for each meeting in building A   Order by starttime, roomNumber
Column names: building roomNumber startTime endTime
3 - Return the number of meetings in each room in each building.  Order by building,  roomNumber
Column names: building  roomNumber  nummeetings
4 – Find the building and room number of all buildings with more than 1 meeting Order by 
numMeetings, building, roomNumber
Column names : building, roomNumber, numMeetings
5 - Find all meetings with no Moderator.  Order by starttime
Column names:  purpose  startime  
 6 – Find the number of attendees in each meeting.  Order by starttime, purpose
Column names  purpose, starttime,  num_attendees
7 – Find the number of available seats in each meeting.  Order by available seats_available Ascending, 
starttime
Column names: purpose starttime  num_attendees, seats_available
8 - Find the moderator and type of meeting.  List the combination of Moderator and Type only once.  
Order by name, purpose
Column names: name purpose
*/

\qecho Hayden Lauritzen

\qecho
\qecho #1
\qecho
SELECT building, COUNT(*) as num_meetings
FROM meeting 
    JOIN room ON (room.id = meeting.roomid)
GROUP BY room.building  
ORDER BY room.building
;

\qecho
\qecho #2
\qecho

\qecho
\qecho #3
\qecho
SELECT room.building, room.roomnumber as roomNumber, COUNT(*) as nummeetings
FROM meeting
    JOIN room ON (room.id = meeting.roomid)
GROUP BY roomNumber, room.building
ORDER BY building, roomNumber
;

\qecho
\qecho #4
\qecho

-- 5 - Find all meetings with no Moderator.  Order by starttime
-- Column names:  purpose  startime  
\qecho
\qecho #5
\qecho
SELECT purpose, starttime
FROM meeting
WHERE moderatorid IS NOT NULL;
;

\qecho
\qecho #6
\qecho

-- 7 – Find the number of available seats in each meeting.  Order by available seats_available Ascending, 
-- starttime
-- Column names: purpose starttime  num_attendees, seats_available
\qecho
\qecho #7
\qecho
SELECT purpose, starttime, COUNT(*) as num_attendees, capacity - COUNT(*) as seats_available
FROM meeting
    JOIN room ON (meeting.roomid = room.id)
    JOIN attendees ON (attendees.meetingid = meeting.id)
GROUP BY attendees.meetingid, meeting.purpose, meeting.purpose, meeting.starttime, room.capacity
ORDER BY seats_available, starttime
;

\qecho
\qecho #8
\qecho

