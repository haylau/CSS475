\qecho Hayden Lauritzen, Mohammad Zahid, Abhimanyu Kumar

-- #1  List all author’s who are not being used with any book
-- Column Names:  id, firstname, lastname
-- Order by id

\qecho
\qecho #1 
\qecho

SELECT id, firstname, lastname
FROM author
    LEFT JOIN booktoauthor ON author.id = booktoauthor.authorid
WHERE bookcatid IS NULL
ORDER BY id
;

-- #2  List all books who do not have an author associated with them
-- Column names:  id, title
-- Order By id

\qecho
\qecho #2 
\qecho

SELECT id, title
FROM bookcat
    LEFT JOIN booktoauthor ON booktoauthor.bookcatid = bookcat.id
WHERE authorid IS NULL
ORDER BY id
;

-- #3 Find the Author.id for all books that have a genre.name that includes the string  ‘Science’  This will 
-- not use an outer join, but should be useful in #4
-- Column Names:  id
--               Order by id;

\qecho
\qecho #3 
\qecho

SELECT DISTINCT author.id
FROM bookcat
    JOIN bookcattogenre ON bookcat.id = bookcattogenre.bookcatid
    JOIN genre ON bookcattogenre.genreid = genre.id
    JOIN booktoauthor ON bookcat.id = booktoauthor.bookcatid
    JOIN author ON booktoauthor.authorid = author.id
WHERE genre.name ILIKE '%Science%'
ORDER BY author.id
; 

-- #4 Find how many authors do not have a book with a genre.name that include the string ‘Science’  Use 
-- and outer join for this query ( it is likely you will want to use some of the query in #3 above)
-- Column Names: numNonScienceAuthors

\qecho
\qecho #4 
\qecho

SELECT COUNT(*) - 
    (
        SELECT COUNT(*)
        FROM
        (
            SELECT DISTINCT author.id
            FROM bookcat
            JOIN bookcattogenre ON bookcat.id = bookcattogenre.bookcatid
            JOIN genre ON bookcattogenre.genreid = genre.id
            JOIN booktoauthor ON bookcat.id = booktoauthor.bookcatid
            JOIN author ON booktoauthor.authorid = author.id
            WHERE genre.name ILIKE '%Science%'
            ORDER BY author.id
        ) AS authorsWithoutScience 
    ) AS "numNonScienceAuthors" 
FROM author
;

-- #5  Find customerid, firstname, lastname for any customers who do not have an active library card
-- Column Names id, firstname, lastname  
-- Order by id

\qecho
\qecho #5
\qecho

SELECT customer.id, firstname, lastname
FROM customer
    LEFT JOIN 
    (
        SELECT *
        FROM libcard
        WHERE libcard.isactive = 't'
    ) AS active ON active.customerid = customer.id
    WHERE customerid IS NULL
;

/*
Hayden Lauritzen, Mohammad Zahid, Abhimanyu Kumar

#1

 id  | firstname  |     lastname      
-----+------------+-------------------
  70 | Madeleine  | L'Engle
  79 | China      | Miéville
 132 | Stanisław | Lem
 146 | Andrea     | K. Höst
 181 | Erich      | von Däniken
 264 | Laura      | Jo
 273 | Antoine    | de Saint-Exupéry
 300 | John       | W. Campbell
 305 | Bianca     | D'Arc
 311 | Christine  | d'Abo
(10 rows)


#2

  id  |             title              
------+--------------------------------
  597 | The Spawning
  610 | The Gladiators
  695 | The Lion's Woman
  760 | The Dracons' Woman
  803 | The Little Prince
  866 | Who Goes There
  878 | Hara's Legacy
  900 | The Bond That Ties Us
  983 | Sleeping with the Enemy
 1035 | Discovery (The Forgotten
 1036 | When Night Falls
 1037 | Alien Penetration
 1337 | Adaptation (Genus: Unknown, #1
(13 rows)


#3

 id  
-----
   1
   3
   4
   5
   6
   7
   8
   9
  10
  11
  12
  14
  15
  16
  17
  18
  19
  21
  22
  23
  24
  25
  26
  27
  30
  31
  32
  33
  34
  38
  39
  40
  42
  44
  45
  47
  49
  50
  52
  53
  54
  56
  59
  60
  61
  65
  67
  69
  72
  73
  74
  75
  77
  80
  82
  84
  89
  90
  92
  93
  97
  98
  99
 103
 106
 108
 111
 114
 115
 117
 120
 121
 127
 131
 136
 138
 141
 142
 143
 144
 147
 148
 151
 153
 154
 159
 161
 165
 169
 177
 179
 180
 182
 183
 187
 192
 193
 195
 198
 199
 201
 202
 204
 212
 213
 216
 217
 220
 223
 230
 237
 239
 241
 246
 249
 250
 251
 253
 254
 255
 257
 258
 263
 268
 272
 276
 277
 278
 282
 283
 284
 285
 287
 290
 294
 295
 302
 303
 316
 327
 329
 331
 333
 337
 338
 341
 343
 344
 345
 348
 359
 364
 365
 371
 372
 375
 389
 398
 402
 406
 409
 410
 416
 417
 425
 428
 429
 434
 435
 440
 446
 449
 452
 456
 457
(175 rows)


#4

 numNonScienceAuthors 
----------------------
                  284
(1 row)


#5

 id | firstname | lastname 
----+-----------+----------
 30 | fname29   | lname29
 40 | fname39   | lname39
(2 rows)


*/