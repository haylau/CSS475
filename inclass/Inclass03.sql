\qecho Hayden Lauritzen
\qecho Mohammad Zahid
\qecho Abhimanyu Kumar

\qecho
\qecho #1
\qecho 
SELECT building, roomnumber, COUNT(*) AS num_meetings
FROM meeting
    JOIN room ON (meeting.roomid = room.id)
GROUP BY room.id
ORDER BY building, roomnumber
;

\qecho
\qecho #2
\qecho 

-- not quite

SELECT round(AVG(t1.num_meetings)::numeric, 2) AS meeting_average
FROM (
    SELECT building, roomnumber, COUNT(*) AS num_meetings
    FROM meeting
        JOIN room ON (meeting.roomid = room.id)
    GROUP BY room.id
    ) AS t1
;

\qecho
\qecho #3
\qecho 

SELECT round(AVG(t1.num_attendees)::numeric, 2) AS attendees_average
FROM (
    SELECT meeting.purpose, COUNT(*) AS num_attendees
    FROM meeting
        JOIN attendees ON (attendees.meetingid = meeting.id)
    GROUP BY meeting.purpose
    ) AS t1
;

\qecho
\qecho #4
\qecho 

-- missing building_count

SELECT building, roomnumber, t1.room_count, COUNT(*) AS building_count
FROM room
JOIN (
    SELECT meeting.roomid, COUNT(*) AS room_count
    FROM attendees
    JOIN meeting ON (meeting.id = attendees.meetingid)
    GROUP BY meeting.roomid
    ORDER BY meeting.roomid
    ) AS t1 ON (t1.roomid = room.id)
ORDER BY building, roomnumber
;

\qecho
\qecho #5
\qecho
SELECT phonetype.name, Count() as number_type, 
    count() * 100/ sum(count(*)) over () as percent
FROM phone
    JOIN phonetype ON (phone.phonetypeid = phonetype.id)
GROUP BY phonetype.name
order by phonetype.name
;