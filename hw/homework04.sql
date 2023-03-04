BEGIN;

\qecho Hayden Lauritzen

-- #1 – Perform a checkout on the book 0737494331 ( ‘War of the Worlds’) to library card 0028613547.  Do 
-- not use a surrogate key in any of your statements.    You may use the default for the date fields in the 
-- corecord ( or enter in your own date) 

INSERT INTO corecord(libcardid, bookid, codate, ciduedate)
VALUES 
    (
    (SELECT libcard.id FROM libcard WHERE barcode = '0028613547'), 
    (SELECT book.id FROM book WHERE barcode = '0737494331'),
    '2022-02-01',
    '2022-02-15'
    )
;

UPDATE book
SET liblocationid = NULL
WHERE barcode = '0737494331'
;

\qecho Check #1
SELECT count (*) as "numCheckedOut"
FROM corecord
WHERE  corecord.libcardid = ( SELECT id FROM libcard WHERE barcode = '0028613547')
;
       
SELECT count (*) as "book count"
FROM book
WHERE book.barcode = '0737494331' 
    AND book.liblocationid IS NULL
;

-- #2– Check in the book you checked out in #1.  

UPDATE corecord
SET cidate = '2022-02-01'
WHERE bookid = (SELECT id FROM book WHERE barcode = '0737494331')
    AND libcardid = (SELECT id FROM libcard WHERE barcode ='0028613547')
;

UPDATE book
SET liblocationid = (SELECT id FROM liblocation WHERE name = 'In Checkin Cart')
WHERE barcode = '0737494331'
;

\qecho Check #2
SELECT count (*) as numincart
FROM book
WHERE book.liblocationid = 5;
SELECT count (*) as numCheckedOut
FROM corecord
WHERE  libcardid = ( SELECT id from libcard where barcode = '0028613547')
AND cidate is not null;


-- #3  Add a new genre to the database
--  The new type is “550 Fans”
--  Return the ID ( surrogate key) for future calls in this question ( IE you may use the returned 
-- auto-generated key in this question) 
--  Associate any book with the word ‘green’ in the description to this genre
--  Ignore case for the match  IE ‘GreEnish’ would match.
-- You may use the surrogate primary key returned from the insert in your commands.
-- Use a single command to add the associations for all of the books that include ‘green’
-- 3 Extra points to the first student who sends me email as to why green is associated with ‘550 Fans’

INSERT INTO genre(id, name)
    VALUES ((SELECT nextval('genre_id_seq')), '550 Fans')
    RETURNING id
;

INSERT INTO bookcattogenre(bookcatid, genreid)
(SELECT bookcat.id, 12 FROM BookCat WHERE BookCat.description ILIKE '%green%');

-- could not figure how how to join these, it thought the 1 row was multiple rows

-- WITH fan AS (
--     INSERT INTO genre(id, name)
--     VALUES ((SELECT nextval('genre_id_seq')), '550 Fans')
--     RETURNING id
-- )

-- INSERT INTO bookcattogenre(bookcatid, genreid)
--     VALUES (
--         (SELECT id FROM bookcat WHERE BookCat.description ILIKE '%green%'), 12)
-- ;

-- SET genreid = (12)
-- WHERE (bookcatid = (SELECT id FROM bookcat WHERE description ILIKE '%green%' ))
-- ;


\qecho Check #3
SELECT * from BookCatToGenre
WHERE BookCatToGenre.Genreid = 12
order by BookCatid;


-- #4 The library has decided that the SF Classic ‘Dune’ ( bookCat.ID = 576) promotes drug use.  They want 
-- to remove all mention of the book anywhere in the database ( bookCat, book, genre, etc) 
-- You may use the Surrogate key for the book ( 576) in your commands. 
-- Hint – think about what to remove first. 

-- WITH rows AS 
--     (
--         SELECT 
--     )

DELETE FROM book
WHERE bookcatid = 576;

DELETE FROM booktoauthor
WHERE bookcatid = 576;

DELETE FROM bookcattogenre
WHERE bookcatid = 576;

DELETE FROM bookcat
WHERE id = 576;

\qecho Check #4
SELECT count (*) as numcat
FROM bookCat
WHERE bookCat.id = 576;
SELECT count (*) as numBook
FROM Book
WHERE bookcatid = 576;

-- #5  We want to create a new customer and their library card
--  Customer info
-- o firstName ‘George’
-- o lastName ‘Spelvin’
-- o email ‘Pseudonum@gmail.com’
-- o address ‘1234 Plain Street’
-- o City ‘Rochester’
-- o State ‘NY’
--  Library Card
-- o BarCode  ‘B123456789’
-- o Issue Date 1/15/2323
-- You may use the Surrogate PK of the created customer when you crate the library card record

INSERT INTO Customer (id, firstName, lastName, email, address1, city, stateid)
VALUES 
(
    (SELECT nextval('customer_id_seq')),
    'George',
    'Spelvin',
    'Pseudonum@gmail.com',
    '1234 Plain Street',
    'Rochester',
    'NY'

)
;

-- WITH() didnt work here either

INSERT INTO libcard (id, customerid, barcode, issuedate, isactive)
VALUES 
(
    (SELECT nextval('libcard_id_seq')),
    (SELECT currval('customer_id_seq')),
    'B123456789',
    '2323-01-15',
    't'
)
;

\qecho Check #5
SELECT *
FROM Customer
WHERE firstName = 'George' 
    AND lastName = 'Spelvin';
SELECT * 
FROM Libcard
WHERE libcard.customerid = 102;

-- #6 Georgina Spelvin has lost her library card.  Deactivate the lost card and give her a new one.
-- You may do a query to get the surrogate ID for Georginia Spelvin and use that ID in your subsequent 
-- commands.
--  Creation date for the new library card is 1/5/2023
--  Barcode for new card is ‘X123456789’

UPDATE libcard
SET isactive = false
WHERE customerid = (SELECT id FROM customer WHERE firstName = 'Georgina' AND lastName = 'Spelvin' AND isactive = true)
;

INSERT INTO libcard (id, customerid, barcode, issuedate, isactive)
VALUES (
    (SELECT nextval('libcard_id_seq')),
    (SELECT id FROM customer WHERE firstName = 'Georgina' AND lastName = 'Spelvin'),
    'X123456789',
    '2023-01-5',
    true
)
;

\qecho Check #6
SELECT count (*) as numlibcards
FROM Libcard;
SELECT count (*) as numactivecards
FROM Libcard
WHERE isactive = true;
SELECT * 
FROM Libcard
WHERE customerid = 50 AND isactive;

-- #7  Add a new bookCatalog entry to the system.
--  Title ‘A Stich in Time’
--  Description ‘One Second’
--  Isbn ‘183456789’
--  Ddnum 482.123
--  Genres ‘Thriller’ and ‘Romance’
--  No Author
-- You may return the surrogate ID for the new entry to use in setting up Genre records

INSERT INTO BookCat(id, title, description, isbn, ddnum)
VALUES 
(
    (SELECT nextval( 'bookCat_id_seq' )),
    'A Stich in Time',
    'One Second',
    '183456789',
    '482.123'
)
;

INSERT INTO BookCatToGenre(bookcatid, genreid)
VALUES 
(
    (SELECT currval('bookCat_id_seq ')),
    (SELECT id FROM genre WHERE name = 'Thriller')
),
(
    (SELECT currval( 'bookCat_id_seq' )),
    (SELECT id FROM genre WHERE name = 'Romance')
);

\qecho Check #7
SELECT count (*) as "num Thriller"
FROM bookcatToGenre
    JOIN genre ON ( genre.id = bookCatToGenre.genreid)
WHERE genre.name ilike 'Thriller';
SELECT count (*) as "num Romance"
FROM bookcatToGenre
    JOIN genre ON ( genre.id = bookCatToGenre.genreid)
WHERE genre.name ilike 'Romance';


-- #8 For the bookCat you added in #7 – add three instances to the database of the book.
--  Book barcodes are  ‘C123456789', 'D123456789', 'E123456789'
--  Location of books is in ‘Cart’
--  You man NOT use the surrogate PK of the BookCat for this problem

INSERT INTO Book (id, bookcatid, barcode, liblocationid)
VALUES 
(
    (SELECT nextval('book_id_seq' )),
    (SELECT id FROM bookcat WHERE title = 'A Stich in Time' AND description = 'One Second' AND isbn = '183456789' AND ddnum = '482.123'),
    'C123456789',
    (SELECT id FROM liblocation WHERE name = 'Cart')
    
),
(
    (SELECT nextval('book_id_seq' )),
    (SELECT id FROM bookcat WHERE title = 'A Stich in Time' AND description = 'One Second' AND isbn = '183456789' AND ddnum = '482.123'),
    'D123456789',
    (SELECT id FROM liblocation WHERE name = 'Cart')
),
(
    (SELECT nextval('book_id_seq' )),
    (SELECT id FROM bookcat WHERE title = 'A Stich in Time' AND description = 'One Second' AND isbn = '183456789' AND ddnum = '482.123'),
    'E123456789',
    (SELECT id FROM liblocation WHERE name = 'Cart')
);

\qecho Check #8
SELECT count (*) as numNewBooks 
FROM book
    JOIN bookcat ON ( book.bookcatid = bookcat.id)
WHERE bookcat.isbn = '183456789';

-- #9  A water leak has damaged all of the books in the checkin cart.  They have been moved to Repair.
-- Update the database to show that all books in the checking cart have been moved to repair.  Use a 
-- single update statement.

UPDATE book
SET liblocationid = (SELECT id FROM liblocation WHERE name = 'Repair')
WHERE book.liblocationid = (SELECT id FROM liblocation WHERE name = 'In Checkin Cart');

\qecho Check #9
SELECT count (*) as NumInRepair
FROM book
WHERE liblocationid = 3;


ROLLBACK;
ALTER SEQUENCE Genre_id_seq  RESTART WITH 12;
ALTER SEQUENCE customer_id_seq  RESTART WITH 102;
ALTER SEQUENCE Libcard_id_seq  RESTART WITH 113;
ALTER SEQUENCE bookCat_id_seq  RESTART WITH 1350;

/*
BEGIN
Hayden Lauritzen
INSERT 0 1
UPDATE 1
Check #1
 numCheckedOut 
---------------
             4
(1 row)

 book count 
------------
          1
(1 row)

UPDATE 1
UPDATE 1
Check #2
 numincart 
-----------
         6
(1 row)

 numcheckedout 
---------------
             1
(1 row)

 id 
----
 12
(1 row)

INSERT 0 1
INSERT 0 4
Check #3
 bookcatid | genreid 
-----------+---------
       521 |      12
       704 |      12
       800 |      12
       836 |      12
(4 rows)

DELETE 3
DELETE 1
DELETE 1
DELETE 1
Check #4
 numcat 
--------
      0
(1 row)

 numbook 
---------
       0
(1 row)

INSERT 0 1
INSERT 0 1
Check #5
 id  | firstname | lastname |        email        |     address1      | address2 |   city    | stateid | postalcode 
-----+-----------+----------+---------------------+-------------------+----------+-----------+---------+------------
 102 | George    | Spelvin  | Pseudonum@gmail.com | 1234 Plain Street |          | Rochester | NY      | 
(1 row)

 id  | customerid |  barcode   |      issuedate      | isactive 
-----+------------+------------+---------------------+----------
 113 |        102 | B123456789 | 2323-01-15 00:00:00 | t
(1 row)

UPDATE 1
INSERT 0 1
Check #6
 numlibcards 
-------------
         114
(1 row)

 numactivecards 
----------------
            100
(1 row)

 id  | customerid |  barcode   |      issuedate      | isactive 
-----+------------+------------+---------------------+----------
 114 |         50 | X123456789 | 2023-01-05 00:00:00 | t
(1 row)

INSERT 0 1
INSERT 0 2
Check #7
 num Thriller 
--------------
          154
(1 row)

 num Romance 
-------------
         172
(1 row)

INSERT 0 3
Check #8
 numnewbooks 
-------------
           3
(1 row)

UPDATE 6
Check #9
 numinrepair 
-------------
          25
(1 row)

ROLLBACK
ALTER SEQUENCE
ALTER SEQUENCE
ALTER SEQUENCE
ALTER SEQUENCE

*/