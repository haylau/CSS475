\qecho Hayden Lauritzen

-- #1  create a list of book titles, and number of copies that have been checked out in our database, where 
-- the number is greater than 1
\qecho
\qecho #1
\qecho

SELECT title, COUNT(*) AS numco
FROM corecord 
    JOIN book ON (corecord.bookid = book.id)
    JOIN bookcat ON (bookcat.id = book.bookcatid)
GROUP BY title, bookcat.id
    HAVING COUNT(*) > 1
ORDER BY numco, title
;

-- #2  How many book titles do we have in each genre type?
\qecho
\qecho #2
\qecho

SELECT genre.name AS "Genre", COUNT(*) AS "Num Titles"
FROM genre  
    JOIN bookcattogenre ON (bookcattogenre.genreid = genre.id)
    JOIN bookcat ON (bookcattogenre.bookcatid = bookcat.id)
GROUP BY genre.id, genre.name
ORDER BY genre.name
;

-- #3 How many Books do we have of each genre type?
SELECT genre.name AS "Genre", COUNT(*) AS "Num Titles"
FROM genre  
    JOIN bookcattogenre ON (bookcattogenre.genreid = genre.id)
    JOIN bookcat ON (bookcattogenre.bookcatid = bookcat.id)
    JOIN book ON (book.bookcatid = bookcat.id)
GROUP BY genre.id, genre.name
ORDER BY genre.name
;

-- #4 What is the average number of authors per book title. Show to 
-- four decimal places.

SELECT AVG(numAuthor)::numeric(8,4) AS "Avg Author Book"
FROM
(
    SELECT bookcatid, COUNT(*) AS numAuthor
    FROM author
        JOIN booktoauthor ON (author.id = booktoauthor.authorid)
    GROUP BY bookcatid
    ORDER BY numAuthor DESC
) AS AuthorPerBook
;

-- #5 What is the average time a book takes to be returned based on the 
-- state of the borrower.
-- Remember that a Date - Date = (integer) num Days R
SELECT customer.stateid AS "State", AVG(overdueDays)::numeric(4,2) AS "State Average" 
FROM 
    (
        SELECT *, (cidate::date - ciduedate::date) AS overdueDays
        FROM corecord
        WHERE cidate IS NOT NULL
        ORDER BY overdueDays
    ) AS overdueBooks
    JOIN libcard ON (overdueBooks.libcardid = libcard.id)
    JOIN customer ON (libcard.customerid = customer.id)
GROUP BY customer.stateid
ORDER BY customer.stateid
;

-- #6  Today is Feb 1, 2022
-- Create a list of all customers that have overdue books.  For each customer print their name and home 
-- phone number
SELECT firstname, lastname, number, ciduedate
FROM corecord
    JOIN libcard ON (corecord.libcardid = libcard.id)
    JOIN customer ON (libcard.customerid = customer.id)
    JOIN phone ON (phone.customerid = customer.id)
    JOIN phonetype ON (phone.phonetypeid = phonetype.id)
WHERE phonetype.name = 'Home'
    AND corecord.cidate IS NULL
    AND (corecord.ciduedate::date <= '2022-02-01')
ORDER BY ciduedate, customer.id
;

-- #7 Find how many books in what genre(s) anyone named Frances Smith 
-- has ever checked out

SELECT genre.name, COUNT(*) AS numbooks
FROM corecord
    JOIN libcard ON (corecord.libcardid = libcard.id)
    JOIN customer ON (libcard.customerid = customer.id)
    JOIN book ON (corecord.bookid = book.id)
    JOIN bookcat ON (book.bookcatid = bookcat.id)
    JOIN bookcattogenre ON (bookcat.id = bookcattogenre.bookcatid)
    JOIN genre ON (bookcattogenre.genreid = genre.id)
WHERE customer.firstname = 'Frances' 
    AND customer.lastname = 'Smith'
GROUP BY genre.name, genre.id;
;

-- #8
-- what is the percentage of books that are checked out of our entire 
-- inventory?

SELECT (COUNT(*)::numeric / (SELECT COUNT(*) AS bookCount FROM book) * 100)::numeric as "Avg %"
FROM corecord
WHERE cidate IS NULL
;

/*
Hayden Lauritzen

#1

       title        | numco 
--------------------+-------
 Captive            |     2
 Tamed By The Beast |     2
 The Bone Season    |     2
 The Hunter's Mate  |     2
(4 rows)


#2

       Genre       | Num Titles 
-------------------+------------
 Biography         |        144
 Classic Adventure |        149
 Computer Science  |        139
 Detective         |        156
 Dystopian Fantasy |        154
 Military History  |        137
 Romance           |        171
 Romantic Fantasy  |        127
 Science Fiction   |        165
 Thriller          |        153
(10 rows)

       Genre       | Num Titles 
-------------------+------------
 Biography         |        273
 Classic Adventure |        294
 Computer Science  |        312
 Detective         |        313
 Dystopian Fantasy |        286
 Military History  |        271
 Romance           |        329
 Romantic Fantasy  |        270
 Science Fiction   |        324
 Thriller          |        314
(10 rows)

 Avg Author Book 
-----------------
          1.0065
(1 row)

 State | State Average 
-------+---------------
 ID    |         10.67
 OR    |          9.00
 WA    |         10.64
(3 rows)

 firstname | lastname |   number   | ciduedate  
-----------+----------+------------+------------
 fname15   | lname15  | 2066003848 | 2022-01-27
 fname15   | lname15  | 2063154413 | 2022-01-27
 Frances   | Smith    | 2065088817 | 2022-01-27
 fname43   | lname43  | 2068376809 | 2022-01-27
 fname43   | lname43  | 2062524547 | 2022-01-27
 fname43   | lname43  | 2062524547 | 2022-01-27
 fname43   | lname43  | 2068376809 | 2022-01-27
 fname28   | lname28  | 2066057253 | 2022-01-28
 fname7    | lname7   | 2064476692 | 2022-01-29
 fname7    | lname7   | 2064000434 | 2022-01-29
 fname48   | lname48  | 2065340579 | 2022-01-29
 fname37   | lname37  | 2066353906 | 2022-01-30
 fname38   | lname38  | 2069726350 | 2022-01-30
 fname40   | lname40  | 2069034448 | 2022-01-30
 fname48   | lname48  | 2065340579 | 2022-01-30
 Frances   | Smith    | 2065088817 | 2022-01-31
 fname45   | lname45  | 2066075461 | 2022-01-31
 fname33   | lname33  | 2066171281 | 2022-02-01
(18 rows)

       name        | numbooks 
-------------------+----------
 Dystopian Fantasy |        1
 Detective         |        2
 Computer Science  |        1
(3 rows)

         Avg %          
------------------------
 2.00481154771451483600
(1 row)

*/