\qecho Hayden Lauritzen

SELECT current_database();
CREATE DATABASE hw08;
\c hw08
SELECT current_database();

CREATE TABLE employee (
    id SERIAL NOT NULL,
    employee_number VARCHAR(10) NOT NULL UNIQUE,
    first_name VARCHAR(30) NOT NULL,
    middle_name VARCHAR(30),
    last_name VARCHAR(30) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    supervisor_id INTEGER,
    PRIMARY KEY (id),
    FOREIGN KEY (supervisor_id) REFERENCES employee(id) DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE state (
    id CHAR(2) NOT NULL,
    state_name VARCHAR(30) NOT NULL,
    PRIMARY KEY (id)
);
CREATE TABLE building (
    id SERIAL NOT NULL,
    building_name VARCHAR(20) NOT NULL,
    address1 VARCHAR(30) NOT NULL,
    address2 VARCHAR(30),
    city VARCHAR(30) NOT NULL,
    zip VARCHAR(5) NOT NULL,
    state_id VARCHAR(2) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (state_id) REFERENCES state(id) DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE room (
    id SERIAL NOT NULL,
    room_number VARCHAR(10) NOT NULL,
    building_id INTEGER NOT NULL,
    capacity INTEGER NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (building_id) REFERENCES building(id) DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE meeting (
    id SERIAL NOT NULL,
    room_id INTEGER NOT NULL,
    start_time TIMESTAMP NOT NULL,
    duration INTERVAL NOT NULL,
    purpose VARCHAR(30) NOT NULL,
    agenda VARCHAR(120),
    creator INTEGER NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (creator) REFERENCES employee(id) DEFERRABLE INITIALLY DEFERRED,
    FOREIGN KEY (room_id) REFERENCES room(id) DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE attendees (
    meeting_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    PRIMARY KEY (meeting_id, employee_id),
    FOREIGN KEY (employee_id) REFERENCES employee(id) DEFERRABLE INITIALLY DEFERRED,
    FOREIGN KEY (meeting_id) REFERENCES meeting(id) DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE phone_type (
    id CHAR(1) NOT NULL,
    phone_type VARCHAR(30) NOT NULL,
    PRIMARY KEY (id)
);
CREATE TABLE phone_number (
    phone_type_id CHAR(1) NOT NULL,
    employee_id INTEGER NOT NULL,
    area_code CHAR(3) NOT NULL,
    Number CHAR(7) NOT NULL,
    PRIMARY KEY (phone_type_id, employee_id),
    FOREIGN KEY (employee_id) REFERENCES employee(id) DEFERRABLE INITIALLY DEFERRED
);

\qecho #1
\d

\qecho #2
\d employee

\qecho #3
\d meeting

\qecho #4
\d room

\qecho #5
\d building

\qecho #6
\d attendees

\qecho #7
\c postgres
SELECT current_database();
DROP DATABASE hw08;

/*
Hayden Lauritzen
 current_database 
------------------
 postgres
(1 row)

CREATE DATABASE
 current_database 
------------------
 hw08
(1 row)

CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
#1
               List of relations
 Schema |      Name       |   Type   |  Owner   
--------+-----------------+----------+----------
 public | attendees       | table    | postgres
 public | building        | table    | postgres
 public | building_id_seq | sequence | postgres
 public | employee        | table    | postgres
 public | employee_id_seq | sequence | postgres
 public | meeting         | table    | postgres
 public | meeting_id_seq  | sequence | postgres
 public | phone_number    | table    | postgres
 public | phone_type      | table    | postgres
 public | room            | table    | postgres
 public | room_id_seq     | sequence | postgres
 public | state           | table    | postgres
(12 rows)

#2
                                        Table "public.employee"
     Column      |          Type          | Collation | Nullable |               Default                
-----------------+------------------------+-----------+----------+--------------------------------------
 id              | integer                |           | not null | nextval('employee_id_seq'::regclass)
 employee_number | character varying(10)  |           | not null | 
 first_name      | character varying(30)  |           | not null | 
 middle_name     | character varying(30)  |           |          | 
 last_name       | character varying(30)  |           | not null | 
 email           | character varying(100) |           | not null | 
 supervisor_id   | integer                |           |          | 
Indexes:
    "employee_pkey" PRIMARY KEY, btree (id)
    "employee_email_key" UNIQUE CONSTRAINT, btree (email)
    "employee_employee_number_key" UNIQUE CONSTRAINT, btree (employee_number)
Foreign-key constraints:
    "employee_supervisor_id_fkey" FOREIGN KEY (supervisor_id) REFERENCES employee(id) DEFERRABLE INITIALLY DEFERRED
Referenced by:
    TABLE "attendees" CONSTRAINT "attendees_employee_id_fkey" FOREIGN KEY (employee_id) REFERENCES employee(id) DEFERRABLE INITIALLY DEFERRED
    TABLE "employee" CONSTRAINT "employee_supervisor_id_fkey" FOREIGN KEY (supervisor_id) REFERENCES employee(id) DEFERRABLE INITIALLY DEFERRED
    TABLE "meeting" CONSTRAINT "meeting_creator_fkey" FOREIGN KEY (creator) REFERENCES employee(id) DEFERRABLE INITIALLY DEFERRED
    TABLE "phone_number" CONSTRAINT "phone_number_employee_id_fkey" FOREIGN KEY (employee_id) REFERENCES employee(id) DEFERRABLE INITIALLY DEFERRED

#3
                                        Table "public.meeting"
   Column   |            Type             | Collation | Nullable |               Default               
------------+-----------------------------+-----------+----------+-------------------------------------
 id         | integer                     |           | not null | nextval('meeting_id_seq'::regclass)
 room_id    | integer                     |           | not null | 
 start_time | timestamp without time zone |           | not null | 
 duration   | interval                    |           | not null | 
 purpose    | character varying(30)       |           | not null | 
 agenda     | character varying(120)      |           |          | 
 creator    | integer                     |           | not null | 
Indexes:
    "meeting_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "meeting_creator_fkey" FOREIGN KEY (creator) REFERENCES employee(id) DEFERRABLE INITIALLY DEFERRED
    "meeting_room_id_fkey" FOREIGN KEY (room_id) REFERENCES room(id) DEFERRABLE INITIALLY DEFERRED
Referenced by:
    TABLE "attendees" CONSTRAINT "attendees_meeting_id_fkey" FOREIGN KEY (meeting_id) REFERENCES meeting(id) DEFERRABLE INITIALLY DEFERRED

#4
                                      Table "public.room"
   Column    |         Type          | Collation | Nullable |             Default              
-------------+-----------------------+-----------+----------+----------------------------------
 id          | integer               |           | not null | nextval('room_id_seq'::regclass)
 room_number | character varying(10) |           | not null | 
 building_id | integer               |           | not null | 
 capacity    | integer               |           | not null | 
Indexes:
    "room_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "room_building_id_fkey" FOREIGN KEY (building_id) REFERENCES building(id) DEFERRABLE INITIALLY DEFERRED
Referenced by:
    TABLE "meeting" CONSTRAINT "meeting_room_id_fkey" FOREIGN KEY (room_id) REFERENCES room(id) DEFERRABLE INITIALLY DEFERRED

#5
                                       Table "public.building"
    Column     |         Type          | Collation | Nullable |               Default                
---------------+-----------------------+-----------+----------+--------------------------------------
 id            | integer               |           | not null | nextval('building_id_seq'::regclass)
 building_name | character varying(20) |           | not null | 
 address1      | character varying(30) |           | not null | 
 address2      | character varying(30) |           |          | 
 city          | character varying(30) |           | not null | 
 zip           | character varying(5)  |           | not null | 
 state_id      | character varying(2)  |           | not null | 
Indexes:
    "building_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "building_state_id_fkey" FOREIGN KEY (state_id) REFERENCES state(id) DEFERRABLE INITIALLY DEFERRED
Referenced by:
    TABLE "room" CONSTRAINT "room_building_id_fkey" FOREIGN KEY (building_id) REFERENCES building(id) DEFERRABLE INITIALLY DEFERRED

#6
                Table "public.attendees"
   Column    |  Type   | Collation | Nullable | Default 
-------------+---------+-----------+----------+---------
 meeting_id  | integer |           | not null | 
 employee_id | integer |           | not null | 
Indexes:
    "attendees_pkey" PRIMARY KEY, btree (meeting_id, employee_id)
Foreign-key constraints:
    "attendees_employee_id_fkey" FOREIGN KEY (employee_id) REFERENCES employee(id) DEFERRABLE INITIALLY DEFERRED
    "attendees_meeting_id_fkey" FOREIGN KEY (meeting_id) REFERENCES meeting(id) DEFERRABLE INITIALLY DEFERRED

#7
 current_database 
------------------
 postgres
(1 row)

DROP DATABASE

*/