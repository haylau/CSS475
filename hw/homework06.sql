
\qecho Hayden Lauritzen

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

-- #6 Find any genres that are not being used.  ( 10 points)
-- Column names id, name
--        Order by genre.id

\qecho
\qecho #6
\qecho

SELECT genre.id, genre.name
FROM genre
    LEFT JOIN bookcattogenre ON (bookcattogenre.genreid = genre.id)
WHERE bookcatid IS NULL
ORDER BY genre.id
;

-- #7 Find the count of the number of times each genre is referenced by a book title.  ( 10 points)
-- Column names  genrename, genretotal
-- Order by genretotal

\qecho
\qecho #7
\qecho

SELECT genre.name AS genrename, COALESCE(genrecount.genretotal, 0) AS genretotal
FROM genre
    LEFT JOIN 
    (
        SELECT genre.id, genre.name, COUNT(*) AS genretotal
        FROM genre
        JOIN bookcattogenre ON (bookcattogenre.genreid = genre.id)        
        GROUP BY genre.id, name
        ORDER BY genre.id
    ) AS genrecount ON (genrecount.id = genre.id)
ORDER BY genretotal
;

-- #8 Each book is referenced by 0 or more genres.  Provide a query that shows the total num book that 
-- refer to 0 genre, 1 genre, 2 genres, etc .  ( 10 points)
-- Column names numbooks,  genre_count
-- Order by genre_count;

\qecho
\qecho #8
\qecho

SELECT COUNT(*) AS numbooks, COALESCE(genrecount.count, 0) AS "genre_count"
FROM bookcat
LEFT JOIN
(
    SELECT bookcatid, COUNT(*) AS count
    FROM bookcattogenre
    GROUP BY bookcatid
) AS genrecount ON (genrecount.bookcatid = bookcat.id)
GROUP BY genrecount.count
ORDER BY "genre_count"
;

-- #9  Find all phone numbers for all customers who do not have an active library card .  ( 10 points)
-- Column names:  id, firstname.,Lastname, phonetypeid, number
-- Order by customer.id, phone.number 

\qecho
\qecho #9 
\qecho

SELECT customer.id, firstname, lastname, phonetypeid, number
FROM customer
    LEFT JOIN 
    (
    SELECT customer.id, libcard.id AS libcardid
    FROM customer
        JOIN libcard ON (libcard.customerid = customer.id)
    WHERE isactive = 't'
    ) AS active ON (active.id = customer.id)
    JOIN phone ON (phone.customerid = customer.id)
WHERE libcardid IS NULL
ORDER BY customer.id, phone.number
;

\qecho
\qecho #10 
\qecho

-- #10  Find all cell phones for all customers who do not have an active library card.  Print ‘None’ is no cell 
-- number.  ( 10 points) 
-- Column names:  id, firstname.,Lastname, phonetypeid, number
-- Order by customer.id

SELECT customer.id, firstname, lastname, COALESCE(phonetypeid, 'NONE') AS phonetypeid, COALESCE(number, 'NONE') AS number
FROM customer
    LEFT JOIN 
    (
    SELECT customer.id, libcard.id AS libcardid
    FROM customer
        JOIN libcard ON (libcard.customerid = customer.id)
    WHERE isactive = 't'
    ) AS active ON (active.id = customer.id)
    LEFT JOIN 
    (
        SELECT * 
        FROM phone
        WHERE phonetypeid = 'C'
    ) AS cellphone ON (cellphone.customerid = customer.id)
WHERE libcardid IS NULL
ORDER BY customer.id, cellphone.number
;

-- #11  Find the number of customer who have not checked out a book since 2022-02-01.  Use an outer 
-- join in the final query.    To check your work I want you to print the results of three queries for this 
-- problem ( 15 points  5 each query below) 
--  Print the number of customers 
-- Column Name:  numcustomers  ( no outer join)
--  Print the customerid for each customer that HAS checked checked out a book since 2022-02-01 (
-- no outer join)
-- Column Name:  customerid
-- Order By: customerid
--  Print the customerid for each customer that HAS NOT  checked checked out a book since 2022-
-- 02-01 (outer join)
-- Column Name:  customerid
-- Order By: customerid

\qecho
\qecho #11
\qecho

SELECT COUNT(*) AS numcustomers
FROM customer 
;

SELECT libcard.customerid
FROM libcard 
    JOIN corecord ON (corecord.libcardid = libcard.id)
WHERE codate::date >= '2022-02-01'
GROUP BY customerid
ORDER BY customerid
;

SELECT customer.id
FROM customer
    LEFT JOIN 
    (
    SELECT libcard.customerid
    FROM libcard 
        JOIN corecord ON (corecord.libcardid = libcard.id)
    WHERE codate::date >= '2022-02-01'
    GROUP BY customerid
    ORDER BY customerid
    ) AS active ON (customer.id = active.customerid)
    WHERE customerid IS NULL
;


-- #12 What books in category ‘Computer Science’ have never been checked out? ( 10 points) 
-- Column Names: id, title
-- Order by bookcat.id

\qecho
\qecho #12
\qecho

SELECT csbooks.id, csbooks.title
FROM 
(
    SELECT bookcat.id, bookcat.title
    FROM bookcattogenre
        JOIN genre ON (bookcattogenre.genreid = genre.id)
        JOIN bookcat ON (bookcattogenre.bookcatid = bookcat.id)
    WHERE genre.name LIKE 'Computer Science'
) AS csbooks
    LEFT JOIN corecord ON (corecord.bookid = csbooks.id)
WHERE corecord.codate IS NULL
GROUP BY csbooks.id, csbooks.title
ORDER BY csbooks.id
;

/*
Hayden Lauritzen

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


#6

 id |       name       
----+------------------
 11 | Database stories
(1 row)


#7

     genrename     | genretotal 
-------------------+------------
 Database stories  |          0
 Romantic Fantasy  |        127
 Military History  |        137
 Computer Science  |        139
 Biography         |        144
 Classic Adventure |        149
 Thriller          |        153
 Dystopian Fantasy |        154
 Detective         |        156
 Science Fiction   |        165
 Romance           |        171
(11 rows)


#8

 numbooks | genre_count 
----------+-------------
        1 |           0
     1020 |           1
      207 |           2
       19 |           3
        1 |           4
(5 rows)


#9

 id | firstname | lastname | phonetypeid |   number   
----+-----------+----------+-------------+------------
 30 | fname29   | lname29  | H           | 2064224853
 40 | fname39   | lname39  | H           | 2063598967
 40 | fname39   | lname39  | C           | 2065481941
 40 | fname39   | lname39  | W           | 2067961881
(4 rows)


#10

 id | firstname | lastname | phonetypeid |   number   
----+-----------+----------+-------------+------------
 30 | fname29   | lname29  | NONE        | NONE
 40 | fname39   | lname39  | C           | 2065481941
(2 rows)


#11

 numcustomers 
--------------
          101
(1 row)

 customerid 
------------
          1
          4
          5
          9
         19
         20
         21
         27
         35
         38
         41
         43
         46
         51
         59
         60
         61
         63
         71
         72
         74
         75
         79
         80
         82
         84
         87
         94
        100
(29 rows)

 id  
-----
   2
   3
   6
   7
   8
  10
  11
  12
  13
  14
  15
  16
  17
  18
  22
  23
  24
  25
  26
  28
  29
  30
  31
  32
  33
  34
  36
  37
  39
  40
  42
  44
  45
  47
  48
  49
  50
  52
  53
  54
  55
  56
  57
  58
  62
  64
  65
  66
  67
  68
  69
  70
  73
  76
  77
  78
  81
  83
  85
  86
  88
  89
  90
  91
  92
  93
  95
  96
  97
  98
  99
 101
(72 rows)


#12

  id  |                    title                    
------+---------------------------------------------
  101 | Onyx
  103 | The Host
  104 | Opal
  111 | Ender's Game
  115 | The Hitchhiker's Guide to the Galaxy
  138 | Sleeping Giants
  145 | Hunted
  156 | Barbarian's Touch
  158 | Claimings, Tails, and Other Alien Artifacts
  165 | The Fate of Ten
  167 | Lauren's Barbarian
  178 | Skyward
  179 | The Corsair's Captive
  182 | Dark Planet Warriors: The Complete Serial
  190 | Cottonwood
  191 | Found
  192 | Tempting Rever
  202 | Dreamcatcher
  213 | Ecstasy in Darkness
  226 | Monsters of Men
  229 | Abducted
  236 | Last Kiss Goodnight
  242 | Ynyr
  247 | Saga, Vol. 4
  248 | Planet X
  269 | Burning Up Flint
  270 | The Invasion
  278 | Close Obsession
  294 | Sweep of the Blade
  319 | Hold
  332 | Enticed By The Corsair
  333 | United
  355 | Nine's Legacy
  368 | Honor Among Thieves
  378 | Ambushing Ariel
  379 | The Visitor
  383 | Pythen
  399 | Twin Dragons
  401 | Saved by Venom
  415 | Wanderlust
  437 | Sweep with Me
  449 | Alpha Trine
  457 | Semiosis
  463 | Alien Rule
  476 | Kiss of Midnight
  488 | The Android's Dream
  510 | Challenging Saber
  512 | The Forgotten Ones
  513 | The Last Days of Lorien
  527 | Alien Proliferation
  541 | Stars Above
  548 | Tribe Protector
  563 | We Are Legion (We Are Bob
  569 | Earth & Sky
  577 | Freedom's Landing
  594 | The Legacies
  607 | The Krinar Captive
  612 | Warrior's Woman
  621 | Dangerous
  634 | The Khyma: Taken Part One
  638 | Alien Lord's Captive
  657 | Inheritance
  678 | Classified Planet: Turongal
  699 | Provenance
  701 | Unknown
  705 | Forgotten
  712 | Daughters of Terra
  716 | A Deepness in the Sky
  717 | The Andalite Chronicles
  732 | The Calling
  735 | The Hunt
  741 | Gateway
  744 | Alien III
  749 | Creeg
  750 | Princess SOS
  751 | Shifter Planet
  827 | The Decision
  831 | The Escape
  854 | The Last Girl on Earth
  865 | Captive Surrender
  868 | Enslaved
  872 | Details of the Hunt
  877 | The Secret
  894 | The End of All Things
  903 | Taken by Midnight
  933 | Fractured Suns
  960 | Viper's Hope
  961 | Double Down
  963 | Sold
  969 | Holiday Abduction
  976 | Alien in the House
  988 | The Uplift War
 1006 | Zero Repeat Forever
 1029 | Glitches
 1047 | Perelandra
 1052 | The City in the Middle of the Night
 1083 | Saving Sara
 1087 | Taken by the Storm
 1089 | Rocannon's World
 1095 | The Pleasure Slave
 1098 | The Conspiracy
 1113 | Crave The Night
 1116 | Kraving Khiva
 1140 | Amorous Overnight
 1146 | Lyon's Price
 1147 | Never A Slave
 1156 | Downbelow Station
 1182 | Alien Mate
 1188 | Bondmate
 1197 | Light
 1204 | Breeding Ground
 1211 | Eifelheim
 1213 | Aliens: Nightmare Asylum
 1216 | Taken to Voraxia
 1225 | Salvation
 1232 | Generation One
 1235 | Reader Abduction
 1238 | Alien General's Bride
 1240 | Breeding Stations
 1243 | Precious Starlight
 1248 | The Pirate Prince
 1259 | Aliens: Labyrinth
 1266 | The Day of the Triffids
 1273 | Guardian Alien
 1284 | Captured and Claimed
 1288 | Alpha Bonds
 1297 | Taming the Giant
 1304 | Dazz
 1311 | Frost Station Alpha: The Complete Series
 1313 | The Degan Paradox
 1327 | Toys in Space
(131 rows)

*/
