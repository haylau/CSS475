\qecho Hayden Lauritzen

-- #1  (10)
-- How many unique mugs have been sold for each l order  
-- Column Names:  ordernumber, numskus
-- Order by ordernumber
\qecho
\qecho #1
\qecho

SELECT ordernumber, COUNT(*) AS numskus
FROM customerorder 
    JOIN orderitem ON (customerorder.id = orderitem.customerorderid)
GROUP BY customerorder.id 
ORDER BY ordernumber
;

-- #2  (5) 
-- How many unique mugs do we have for all orders?
-- Column names:  totalskus
\qecho
\qecho #2
\qecho

SELECT COUNT(countSKUs.count) AS totalskus
FROM 
(
    SELECT COUNT(*)
    FROM orderitem
    GROUP BY sku
) AS countSKUs
;

-- #3  (10)
-- Print the orderNum for any orders with no image info.
-- Column Name orderNumber
--   Order by orderNumber;
\qecho
\qecho #3
\qecho

SELECT customerorder.ordernumber AS "orderNumber"
FROM customerorder
    JOIN orderitem ON (customerorder.id = orderitem.customerorderid)
    LEFT JOIN imageinfo ON (orderitem.id = imageinfo.orderitemid) 
WHERE orderitemid IS NULL
;

-- #4 (5) How many orders do we have in each state? 
-- Column Name id, name, numorders
-- Order by id
\qecho
\qecho #4
\qecho

SELECT id, name, COALESCE(stateCount.count, 0) AS numorders
FROM state
    LEFT JOIN 
    (
        SELECT state, COUNT(*)
        FROM customerorder
        GROUP BY state
    ) AS stateCount ON (state.id = stateCount.state)
ORDER BY state.id
;

-- #5 (10) Using query 4 as a base.  Print a report that shows how you are doing in each state
--  If we have 0 sales print ‘VERY LOW’  
--  1 to 7 sales print ‘Making Progress’
--  8-11 sales print ‘Almost There’
--  Over 12 print ‘Doing Fine’
-- Column Name: state, results
-- Order by state.id
\qecho
\qecho #5
\qecho

SELECT name AS state, 
    CASE WHEN ordersByState.numorders = 0                                    THEN 'VERY LOW'
         WHEN ordersByState.numorders >= 1 AND ordersByState.numorders <= 7  THEN 'Making Progress'
         WHEN ordersByState.numorders >= 8 AND ordersByState.numorders <= 11 THEN 'Almost There'
         WHEN ordersByState.numorders > 12                                   THEN 'Doing Fine'
    END AS results
FROM 
(
    SELECT id, name, COALESCE(stateCount.count, 0) AS numorders
    FROM state
        LEFT JOIN 
        (
            SELECT state, COUNT(*)
            FROM customerorder
            GROUP BY state
        ) AS stateCount ON (state.id = stateCount.state)
    ORDER BY state.id
) AS ordersByState
;

-- #6 (10) 
-- You are out of stock on Sku # 100000067  What orders will be delayed.  What is the email for those 
-- customers?
-- Column Name: orderNumber, email, orderdate
--               Order By orderdate, ordetnumber

\qecho
\qecho #6
\qecho

SELECT orderNumber AS "orderNumber", email, orderdate
FROM orderitem
    JOIN customerorder ON (orderitem.customerorderid = customerorder.id)
    JOIN status ON (customerorder.status = status.id)
WHERE sku = '100000067'
    AND 
    (
           status.name = 'Created'
        OR status.name = 'In Manufacturing'
        OR status.name = 'Ready to Ship'
    ) 
ORDER BY orderdate, ordernumber
; 

-- #7  (10)
-- Your site has been hacked and the dog image for the ‘German Shepherd’ has been replace by an 
-- inappropriate picture.  You need to contact your shippers to stop any shipment with this image.  What 
-- are the shipper name/ tracking numbers of interest
-- Column Name: name, trackingnum, shipdate
-- Order By : name, trackingnum

\qecho
\qecho #7
\qecho

SELECT shipper.name AS name, trackingnum, shipdate
FROM customerorder
    JOIN orderitem ON (customerorder.id = orderitem.customerorderid)
    JOIN imageinfo ON (orderitem.id = imageinfo.orderitemid)
    JOIN dogbreed ON (imageinfo.dogbreedid = dogbreed.id)
    JOIN shipper ON (customerorder.shipper = shipper.id)
WHERE dogbreed.name = 'German Shepherd'
ORDER BY name, trackingnum
;

-- #8  (5)
-- You want to expedite shipping on stale orders.  You can do this by asking the shipping company to 
-- expedite.  You want to rush all orders whose date is < 2022-03-05
-- Column Name: name, trackingNum, shipdate

\qecho
\qecho #8
\qecho

SELECT shipper.name, trackingnum AS "trackingNum", shipdate
FROM customerorder
    JOIN shipper ON (customerorder.shipper = shipper.id)
    JOIN status ON (customerorder.status = status.id)
WHERE status.name = 'Shipped'
    AND shipdate < '2022-03-05'
ORDER BY name, trackingnum
;

-- #9 (10)
--  Combine #7 and #8 above.  IE
-- You want a single list of what to ask the shippers to do with late and inappropriate orders.  
-- Column name: name, trackingNum, shipdate, action  ( Action is ‘Cancel Shipment’ or ‘Expedite;
-- Order by name, trackingNumFor inappropriate orders 

\qecho
\qecho #9
\qecho

SELECT shipper.name AS name, trackingnum, shipdate, 'Expedite' AS action
FROM customerorder
    JOIN orderitem ON (customerorder.id = orderitem.customerorderid)
    JOIN imageinfo ON (orderitem.id = imageinfo.orderitemid)
    JOIN dogbreed ON (imageinfo.dogbreedid = dogbreed.id)
    JOIN shipper ON (customerorder.shipper = shipper.id)
WHERE dogbreed.name = 'German Shepherd'
UNION
SELECT shipper.name, trackingnum, shipdate, 'Cancel Shipment' AS action
FROM customerorder
    JOIN shipper ON (customerorder.shipper = shipper.id)
    JOIN status ON (customerorder.status = status.id)
WHERE status.name = 'Shipped'
    AND shipdate < '2022-03-05'
ORDER BY name, trackingnum
;

-- #10  (10)
-- Give all orders that are older than 2022-03-01 a 10% discount in their soldprice

\qecho
\qecho #10
\qecho

BEGIN;

UPDATE customerorder
SET soldprice = (soldprice - soldprice * 0.1)::numeric(16, 2)
FROM status
WHERE customerorder.status = status.id 
    AND orderdate < '2022-03-01'
;

-- CHECK QUERY
SELECT ordernumber, orderDate, soldPrice 
FROM customerOrder 
WHERE  orderDate < '2022-03-04'
ORDER BY orderDate, ordernumber;
-- #10 NOTE -  If you run #10 twice, you will have the wrong answer.  You can restore the original values 
-- for #10 by running the following update command:
-- UPDATE Customerorder 
-- set soldPrice = T1.totalPrice
-- FROM (
--   -- Query to get price per orderItemID
--   SELECT customerorderid as coid , sum(X.oiPrice) as totalPrice
--   FROM orderItem
--       -- Query to get price per order item
--       JOIN (
--          -- Query to get price per orderItem
--          SELECT orderitem.id, quantity * currentPrice AS oiPrice
--          FROM OrderItem 
--              JOIN catalog ON ( catalog.sku = orderItem.sku)
--        ) AS X ON ( X.id = orderItem.id)
--   GROUP BY coid ) AS T1
-- WHERE  id = T1.coid ;

ROLLBACK;

-- # 11 (5)
-- The USA has added a new state to the country.  Portlandia ( abbreviation ‘PT’
-- Add Portlandia into the state table

\qecho
\qecho #11
\qecho

BEGIN;

INSERT INTO state
VALUES ('PT', 'Portlandia')
;

-- CHECK QUERY
Select * FROM State where id = 'PT';

ROLLBACK;

-- #12 (5)
-- Who has ordered more than one order from our website. ( email different)
-- Column Names: email, numorders
-- Order By email

\qecho
\qecho #12
\qecho

SELECT email, COUNT(*) AS numorders
FROM customerorder
GROUP BY email
HAVING COUNT(*) > 1
;

-- #13 (5)
-- Change status of order Q981737859 to status of ‘3’ ( ready to ship)

\qecho
\qecho #13
\qecho

BEGIN;

UPDATE customerorder
SET status = (SELECT id FROM status WHERE name = 'Ready to Ship')
WHERE ordernumber = 'Q981737859'
;

-- CHECK QUERY
SELECT status 
FROM customerorder 
WHERE  ordernumber = 'Q981737859';

ROLLBACK;

-- #14  (10)
-- Order Q981737859'is being shiped Via Amazon  The tracking number is '1234567890'  UPdate 
-- appropriately

\qecho
\qecho #14
\qecho

BEGIN;

UPDATE customerorder
SET trackingnum = '1234567890', 
    shipper = (SELECT id FROM shipper WHERE name = 'Amazon'), 
    status = (SELECT id FROM status WHERE name = 'Shipped')
WHERE ordernumber = 'Q981737859'
;

-- CHECK QUERY

SELECT shipper.name, status.name, customerorder.trackingnum
FROM customerOrder
    JOIN status  on status.id = customerOrder.status
    JOIN shipper ON shipper.id = customerOrder.shipper
WHERE customerOrder.orderNumber =  'Q981737859';

ROLLBACK;

/*
Hayden Lauritzen

#1

 ordernumber | numskus 
-------------+---------
 Q100834991  |       1
 Q102971811  |       1
 Q107961041  |       2
 Q108744843  |       2
 Q109379079  |       1
 Q120507349  |       1
 Q121841485  |       1
 Q123057646  |       3
 Q123128879  |       3
 Q124924216  |       1
 Q136265992  |       3
 Q140062298  |       1
 Q152892390  |       1
 Q174159354  |       1
 Q176312615  |       2
 Q176769020  |       2
 Q182729954  |       1
 Q193486396  |       1
 Q193955905  |       2
 Q206656838  |       1
 Q207063966  |       1
 Q212796061  |       1
 Q217729200  |       1
 Q218606169  |       1
 Q226109116  |       2
 Q227595334  |       1
 Q236814156  |       2
 Q238377908  |       1
 Q266305374  |       1
 Q268528974  |       1
 Q272253409  |       2
 Q303332985  |       1
 Q305372176  |       3
 Q308841421  |       1
 Q316510728  |       1
 Q321903682  |       1
 Q322795413  |       1
 Q325972302  |       1
 Q331207580  |       1
 Q333066972  |       2
 Q347076278  |       1
 Q372417056  |       1
 Q376541071  |       1
 Q388972493  |       2
 Q390674154  |       1
 Q401229064  |       2
 Q418238894  |       1
 Q427346047  |       1
 Q442774734  |       1
 Q443493360  |       3
 Q448344356  |       1
 Q456936068  |       1
 Q459519071  |       1
 Q467152707  |       2
 Q470935032  |       2
 Q475702917  |       1
 Q476894247  |       1
 Q492576628  |       2
 Q515745274  |       1
 Q516075594  |       1
 Q516662838  |       2
 Q521486779  |       1
 Q530169791  |       1
 Q533682520  |       1
 Q535815874  |       2
 Q543844592  |       1
 Q556888796  |       1
 Q562388098  |       1
 Q565169840  |       1
 Q568019877  |       1
 Q576395984  |       1
 Q578833236  |       1
 Q579334283  |       4
 Q586177425  |       2
 Q586946753  |       1
 Q591712111  |       1
 Q591942681  |       1
 Q592031859  |       2
 Q599961998  |       1
 Q607777625  |       1
 Q608869279  |       1
 Q616070633  |       3
 Q617701941  |       1
 Q620271761  |       1
 Q630323850  |       1
 Q637323929  |       1
 Q641314826  |       1
 Q645308140  |       2
 Q654248876  |       1
 Q666339234  |       1
 Q668035436  |       1
 Q677510732  |       1
 Q686796683  |       1
 Q689369323  |       1
 Q693101599  |       1
 Q719393634  |       1
 Q727524177  |       2
 Q728753238  |       1
 Q734350030  |       1
 Q739322542  |       1
 Q744745838  |       4
 Q763622786  |       1
 Q763640185  |       1
 Q764138812  |       2
 Q764737048  |       1
 Q773725028  |       1
 Q776234989  |       1
 Q776368937  |       1
 Q782936011  |       1
 Q800073321  |       2
 Q808010184  |       1
 Q810345062  |       1
 Q811282451  |       1
 Q831272134  |       2
 Q835306607  |       3
 Q855010576  |       2
 Q858612230  |       1
 Q858944276  |       1
 Q861868542  |       2
 Q869105900  |       1
 Q879829344  |       1
 Q881442325  |       1
 Q881602213  |       1
 Q881637420  |       1
 Q884471740  |       1
 Q894125318  |       3
 Q900190146  |       1
 Q905503486  |       1
 Q909058933  |       1
 Q910934386  |       1
 Q911725606  |       1
 Q926334672  |       1
 Q927227386  |       1
 Q928488771  |       1
 Q933566579  |       2
 Q935064536  |       1
 Q940367312  |       1
 Q943721810  |       1
 Q948976062  |       1
 Q958302895  |       1
 Q959949502  |       1
 Q961562422  |       2
 Q961833331  |       1
 Q976691987  |       1
 Q981497949  |       1
 Q981737859  |       1
 Q982989726  |       1
 Q985242060  |       2
 Q987718113  |       1
 Q998387350  |       1
(150 rows)


#2

 totalskus 
-----------
        75
(1 row)


#3

 orderNumber 
-------------
 Q630323850
 Q959949502
(2 rows)


#4

 id |      name      | numorders 
----+----------------+-----------
 AK | Alaska         |         0
 AL | Alabama        |         2
 AR | Arkansas       |         2
 AZ | Arizona        |         2
 CA | California     |         9
 CO | Colorado       |         2
 CT | Connecticut    |         2
 DC | Dist of Col    |         4
 DE | Delaware       |         7
 FL | Floridia       |         2
 GA | Georgia        |         0
 HI | Hiwaii         |         0
 IA | Iowa           |         2
 ID | Idaho          |         0
 IL | Illinois       |         2
 IN | Indiana        |         2
 KS | Kansas         |         1
 KY | Kentucky       |         0
 LA | Louisiana      |         0
 MA | Massachusetts  |        15
 MD | Maryland       |         0
 ME | Maine          |         0
 MI | Michigan       |         8
 MN | Minnesota      |         6
 MO | Missouri       |         7
 MS | Mississippi    |        18
 MT | Montanma       |         0
 NC | North Carolina |         0
 ND | North Dakota   |         0
 NE | Nebraska       |         0
 NH | New Hampshire  |         0
 NJ | New Jersey     |         0
 NM | New Mexico     |         0
 NV | Nevada         |         0
 NY | New York       |         0
 OH | Ohio           |         0
 OK | Oklahoma       |         7
 OR | Oregon         |         8
 PA | Pennsylvania   |         0
 RI | Rhode Island   |         0
 SC | South Carolina |         0
 SD | South Dakota   |         0
 TN | Tennessee      |         5
 TX | Texas          |         6
 UT | Utah           |         6
 VA | Virginia       |         0
 VT | Vermont        |         5
 WA | Washington     |         8
 WI | Wisconsin      |         6
 WV | West Vrginia   |         6
 WY | Wyoming        |         0
(51 rows)


#5

     state      |     results     
----------------+-----------------
 Alaska         | VERY LOW
 Alabama        | Making Progress
 Arkansas       | Making Progress
 Arizona        | Making Progress
 California     | Almost There
 Colorado       | Making Progress
 Connecticut    | Making Progress
 Dist of Col    | Making Progress
 Delaware       | Making Progress
 Floridia       | Making Progress
 Georgia        | VERY LOW
 Hiwaii         | VERY LOW
 Iowa           | Making Progress
 Idaho          | VERY LOW
 Illinois       | Making Progress
 Indiana        | Making Progress
 Kansas         | Making Progress
 Kentucky       | VERY LOW
 Louisiana      | VERY LOW
 Massachusetts  | Doing Fine
 Maryland       | VERY LOW
 Maine          | VERY LOW
 Michigan       | Almost There
 Minnesota      | Making Progress
 Missouri       | Making Progress
 Mississippi    | Doing Fine
 Montanma       | VERY LOW
 North Carolina | VERY LOW
 North Dakota   | VERY LOW
 Nebraska       | VERY LOW
 New Hampshire  | VERY LOW
 New Jersey     | VERY LOW
 New Mexico     | VERY LOW
 Nevada         | VERY LOW
 New York       | VERY LOW
 Ohio           | VERY LOW
 Oklahoma       | Making Progress
 Oregon         | Almost There
 Pennsylvania   | VERY LOW
 Rhode Island   | VERY LOW
 South Carolina | VERY LOW
 South Dakota   | VERY LOW
 Tennessee      | Making Progress
 Texas          | Making Progress
 Utah           | Making Progress
 Virginia       | VERY LOW
 Vermont        | Making Progress
 Washington     | Almost There
 Wisconsin      | Making Progress
 West Vrginia   | Making Progress
 Wyoming        | VERY LOW
(51 rows)


#6

 orderNumber |    email     |      orderdate      
-------------+--------------+---------------------
 Q668035436  | CustMail1146 | 2022-02-26 00:00:00
 Q763640185  | CustMail1102 | 2022-02-26 00:00:00
 Q861868542  | CustMail1127 | 2022-03-02 00:00:00
 Q645308140  | CustMail1117 | 2022-03-03 00:00:00
 Q719393634  | CustMail196  | 2022-03-08 00:00:00
(5 rows)


#7

 name  | trackingnum |      shipdate       
-------+-------------+---------------------
 FedEx | 0468245768  | 2022-03-26 00:00:00
 FedEx | 0849573649  | 2022-03-01 00:00:00
 UPS   | 4563890553  | 2022-03-02 00:00:00
 UPS   | 8088045633  | 2022-03-01 00:00:00
 USPS  | 0012345678  | 2022-02-23 00:00:00
(5 rows)


#8

 name  | trackingNum |      shipdate       
-------+-------------+---------------------
 FedEx | 0849573649  | 2022-03-01 00:00:00
 FedEx | 9752038126  | 2022-03-02 00:00:00
 UPS   | 4563890553  | 2022-03-02 00:00:00
 UPS   | 8088045633  | 2022-03-01 00:00:00
 USPS  | 0012345678  | 2022-02-23 00:00:00
(5 rows)


#9

 name  | trackingnum |      shipdate       |     action      
-------+-------------+---------------------+-----------------
 FedEx | 0468245768  | 2022-03-26 00:00:00 | Expedite
 FedEx | 0849573649  | 2022-03-01 00:00:00 | Expedite
 FedEx | 0849573649  | 2022-03-01 00:00:00 | Cancel Shipment
 FedEx | 9752038126  | 2022-03-02 00:00:00 | Cancel Shipment
 UPS   | 4563890553  | 2022-03-02 00:00:00 | Expedite
 UPS   | 4563890553  | 2022-03-02 00:00:00 | Cancel Shipment
 UPS   | 8088045633  | 2022-03-01 00:00:00 | Expedite
 UPS   | 8088045633  | 2022-03-01 00:00:00 | Cancel Shipment
 USPS  | 0012345678  | 2022-02-23 00:00:00 | Cancel Shipment
 USPS  | 0012345678  | 2022-02-23 00:00:00 | Expedite
(10 rows)


#10

BEGIN
UPDATE 59
 ordernumber |      orderdate      | soldprice 
-------------+---------------------+-----------
 Q120507349  | 2022-02-18 00:00:00 |      4.49
 Q272253409  | 2022-02-18 00:00:00 |     10.33
 Q586946753  | 2022-02-18 00:00:00 |     21.56
 Q617701941  | 2022-02-18 00:00:00 |     11.68
 Q948976062  | 2022-02-18 00:00:00 |      5.84
 Q470935032  | 2022-02-19 00:00:00 |     14.37
 Q475702917  | 2022-02-19 00:00:00 |     10.78
 Q565169840  | 2022-02-19 00:00:00 |     17.96
 Q763622786  | 2022-02-19 00:00:00 |      4.49
 Q959949502  | 2022-02-19 00:00:00 |     17.52
 Q140062298  | 2022-02-20 00:00:00 |     11.68
 Q492576628  | 2022-02-20 00:00:00 |     30.55
 Q586177425  | 2022-02-20 00:00:00 |     14.37
 Q773725028  | 2022-02-20 00:00:00 |      4.49
 Q782936011  | 2022-02-20 00:00:00 |      5.84
 Q107961041  | 2022-02-21 00:00:00 |     39.53
 Q591942681  | 2022-02-21 00:00:00 |      8.98
 Q800073321  | 2022-02-21 00:00:00 |     14.82
 Q858944276  | 2022-02-21 00:00:00 |      5.84
 Q910934386  | 2022-02-21 00:00:00 |      8.98
 Q217729200  | 2022-02-22 00:00:00 |     13.47
 Q427346047  | 2022-02-22 00:00:00 |     23.36
 Q576395984  | 2022-02-22 00:00:00 |     17.52
 Q734350030  | 2022-02-22 00:00:00 |     17.52
 Q881637420  | 2022-02-22 00:00:00 |     16.17
 Q176769020  | 2022-02-23 00:00:00 |     26.96
 Q376541071  | 2022-02-23 00:00:00 |      5.39
 Q579334283  | 2022-02-23 00:00:00 |     58.84
 Q764138812  | 2022-02-23 00:00:00 |     22.01
 Q858612230  | 2022-02-23 00:00:00 |     23.36
 Q182729954  | 2022-02-24 00:00:00 |     10.78
 Q218606169  | 2022-02-24 00:00:00 |      4.49
 Q608869279  | 2022-02-24 00:00:00 |      8.98
 Q905503486  | 2022-02-24 00:00:00 |      4.49
 Q193955905  | 2022-02-25 00:00:00 |     10.78
 Q418238894  | 2022-02-25 00:00:00 |     10.78
 Q467152707  | 2022-02-25 00:00:00 |     26.06
 Q607777625  | 2022-02-25 00:00:00 |      8.98
 Q911725606  | 2022-02-25 00:00:00 |      4.49
 Q982989726  | 2022-02-25 00:00:00 |     11.68
 Q325972302  | 2022-02-26 00:00:00 |      5.84
 Q668035436  | 2022-02-26 00:00:00 |     17.96
 Q763640185  | 2022-02-26 00:00:00 |      4.49
 Q831272134  | 2022-02-26 00:00:00 |     33.25
 Q935064536  | 2022-02-26 00:00:00 |      8.98
 Q961833331  | 2022-02-26 00:00:00 |      4.49
 Q981497949  | 2022-02-26 00:00:00 |     21.56
 Q206656838  | 2022-02-27 00:00:00 |      5.84
 Q347076278  | 2022-02-27 00:00:00 |      8.98
 Q516075594  | 2022-02-27 00:00:00 |      8.98
 Q693101599  | 2022-02-27 00:00:00 |     11.68
 Q855010576  | 2022-02-27 00:00:00 |     17.96
 Q869105900  | 2022-02-27 00:00:00 |     10.78
 Q926334672  | 2022-02-27 00:00:00 |     10.78
 Q456936068  | 2022-02-28 00:00:00 |      8.98
 Q556888796  | 2022-02-28 00:00:00 |      8.98
 Q616070633  | 2022-02-28 00:00:00 |     33.70
 Q654248876  | 2022-02-28 00:00:00 |      5.84
 Q976691987  | 2022-02-28 00:00:00 |     17.96
 Q100834991  | 2022-03-01 00:00:00 |     23.96
 Q102971811  | 2022-03-01 00:00:00 |      5.99
 Q152892390  | 2022-03-01 00:00:00 |      9.98
 Q516662838  | 2022-03-01 00:00:00 |     11.48
 Q727524177  | 2022-03-01 00:00:00 |     19.96
 Q136265992  | 2022-03-02 00:00:00 |     50.41
 Q266305374  | 2022-03-02 00:00:00 |      4.99
 Q390674154  | 2022-03-02 00:00:00 |      9.98
 Q630323850  | 2022-03-02 00:00:00 |      4.99
 Q810345062  | 2022-03-02 00:00:00 |     14.97
 Q861868542  | 2022-03-02 00:00:00 |     26.45
 Q884471740  | 2022-03-02 00:00:00 |      9.98
 Q331207580  | 2022-03-03 00:00:00 |     25.96
 Q645308140  | 2022-03-03 00:00:00 |     33.94
 Q677510732  | 2022-03-03 00:00:00 |      6.49
 Q811282451  | 2022-03-03 00:00:00 |     11.98
 Q998387350  | 2022-03-03 00:00:00 |     19.47
(76 rows)

ROLLBACK

#11

BEGIN
INSERT 0 1
 id |    name    
----+------------
 PT | Portlandia
(1 row)

ROLLBACK

#12

    email     | numorders 
--------------+-----------
 CustMail1113 |         4
 CustMail14   |         6
 CustMail194  |         4
(3 rows)


#13

BEGIN
UPDATE 1
 status 
--------
      3
(1 row)

ROLLBACK

#14

BEGIN
UPDATE 1
  name  |  name   | trackingnum 
--------+---------+-------------
 Amazon | Shipped | 1234567890
(1 row)

ROLLBACK

*/