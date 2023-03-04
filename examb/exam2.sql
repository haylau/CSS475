\qecho Hayden Lauritzen

-- #1  Compute the average time from shipment to delivery by shipper.  Note capitalization in column 
-- names.
-- Columns  name, avgDelivery
-- Order By shipper.name
\qecho
\qecho #1
\qecho

SELECT shipper.name AS name, AVG(customerorder.deliverydate - customerorder.shipdate) AS "avgDelivery"
FROM customerorder
    JOIN shipper ON (customerorder.shipper = shipper.id)
    JOIN status ON (customerorder.status = status.id)
WHERE status.name = 'Delivered' 
GROUP BY shipper.name
ORDER BY shipper.name
;

-- #2  When we use a dog image on a mug, we need to pay a royalty fee to the licensing company.  For 
-- dogBreed.ID from 1 thru 13 we pay 1 cent.  For dogBreed.id from 14 thru 26 we pay 2 cents.  For 
-- dogBreed.ID 26 thru 40 we pay 10 cents.
-- Create a report that shows what we owe for each group of dogBreed images ( 1-13. 14-26, 27-40)
-- Columns: group, amount
-- Order By :amount
\qecho
\qecho #2
\qecho

SELECT 
    CASE WHEN royalty.group = 1 THEN '1 thru 13'
         WHEN royalty.group = 2 THEN '14 thru 26'
         WHEN royalty.group = 3 THEN '27 thru 40'
    END AS group,
    CASE WHEN royalty.group = 1 THEN SUM(royalty.quantity)::numeric(5,2) * .01
         WHEN royalty.group = 2 THEN SUM(royalty.quantity)::numeric(5,2) * .02
         WHEN royalty.group = 3 THEN SUM(royalty.quantity)::numeric(5,2) * .1
    END AS amount
FROM
(
    SELECT *,
    CASE WHEN dogbreed.id >= 1  AND dogbreed.id <= 13 THEN 1
         WHEN dogbreed.id >= 14 AND dogbreed.id <= 26 THEN 2
         WHEN dogbreed.id >= 27 AND dogbreed.id <= 40 THEN 3
    END AS group
    FROM orderitem
        JOIN imageinfo ON (orderitem.id = imageinfo.dogbreedid)
        JOIN dogbreed ON (imageinfo.dogbreedid = dogbreed.id)
) AS royalty
GROUP BY royalty.group
ORDER BY royalty.group
;

-- #3 Produce a list of all unused SKUs ( note capitalization on column names) 
-- Columns:  Sku, Description
-- Order By : Sku
\qecho
\qecho #3
\qecho
SELECT catalog.sku as "Sku", description AS "Description"
FROM catalog
    LEFT JOIN orderitem ON (catalog.sku = orderitem.sku)
WHERE orderitem.id IS NULL
ORDER BY catalog.sku
;


-- #4 We believe that a bug in our software may have let customers select too many images for some Skus.  
-- Create a query to return any customerOrder.orderNumbers, and Skus which have too many images.
-- Columns: ordernumber, sku
-- Order By: ordernumber
\qecho
\qecho #4
\qecho
SELECT DISTINCT customerorder.ordernumber, orderitem.sku
FROM customerorder
    JOIN orderitem ON (customerorder.id = orderitem.customerorderid)
    JOIN imageinfo ON (orderitem.id = imageinfo.orderitemid)
    JOIN catalog ON (orderitem.sku = catalog.sku)
WHERE imageinfo.displayorder > catalog.maximages
ORDER BY customerorder.ordernumber
;


-- #5  Find customerOrders and associated orderItem with no associated imageInfo records
-- Columns: orderNumber, orderItem.id
-- Order By: orderNumber
\qecho
\qecho #5
\qecho
SELECT customerorder.ordernumber AS "orderNumber", orderitem.id AS "orderItem.id"
FROM customerorder
    JOIN orderitem ON (customerOrder.id = orderitem.customerorderid)
    LEFT JOIN imageinfo ON (orderitem.id = imageinfo.orderitemid)
WHERE imageinfo.id IS NULL
ORDER BY customerOrder.ordernumber
;

-- #6 Find the number of mugs sold per SKU in the database
-- Columns:  SKU,  NumSold
-- Order By Sku
-- Limit 10
\qecho
\qecho #6
\qecho
SELECT catalog.sku AS "SKU", COALESCE(SUM(orderitem.quantity), 0) AS "NumSold"
FROM orderitem
    RIGHT JOIN catalog ON (orderitem.sku = catalog.sku)
GROUP BY catalog.sku
ORDER BY catalog.sku
LIMIT 10
;

-- #7  Todays date is 2022-03-01.  Mark customerOrder ‘Q591942681’ as having been shipped via Amazon 
-- – Tracking number is ‘A1234567890’
\qecho
\qecho #7
\qecho

BEGIN;

UPDATE customerorder
SET status = (SELECT id FROM status WHERE status.name = 'Shipped'),
    trackingnum = 'A1234567890',
    shipdate = '2022-03-01',
    shipper = (SELECT id FROM shipper WHERE shipper.name = 'Amazon')
WHERE ordernumber = 'Q591942681'
;

SELECT * from customerOrder where ordernumber = 'Q591942681';

ROLLBACK;

-- #8  the customerOrder with ordernumber of ‘Q959949502' is corrupt.  Delete it from the system.
\qecho
\qecho #8
\qecho

BEGIN;

DELETE FROM orderitem 
WHERE customerorderid = (SELECT id FROM customerorder WHERE ordernumber = 'Q959949502')
;

DELETE FROM customerorder
WHERE ordernumber = 'Q959949502'
;

-- CHECK QUERY
SELECT count(*) from customerOrder;
SELECT count(*) from orderitem;
SELECT * FROM CustomerOrder where ordernumber = 'Q959949502';

ROLLBACK;

-- Extra Credit.  10 points
-- #9  We want to know how well Skus sell based on the maxImages  value in the Catalog.  IE we want to 
-- know the average number of mugs sold based on the maximages value
-- Columns: imagemax, avg
-- Order By imagemax;
\qecho
\qecho #9
\qecho
SELECT catalog.maximages AS imagemax, AVG(numsku.count)::numeric(4,2)
FROM catalog
    JOIN 
    (
        SELECT catalog.sku, COUNT(*)
        FROM orderitem
            JOIN catalog ON (orderitem.sku = catalog.sku)
        GROUP BY catalog.sku
    ) AS numsku ON (catalog.sku = numsku.sku)
GROUP BY catalog.maximages
ORDER BY imagemax
;

/*
Hayden Lauritzen

#1

  name  |   avgDelivery   
--------+-----------------
 Amazon | 2 days
 FedEx  | 2 days 12:00:00
 UPS    | 3 days
 USPS   | 2 days
(4 rows)


#2

   group    | amount 
------------+--------
 1 thru 13  | 4.1500
 14 thru 26 | 7.3400
 27 thru 40 | 54.400
(3 rows)


#3

    Sku    |          Description          
-----------+-------------------------------
 100000034 | Ask not for whom barks 8 0z
 100000035 | Ask Not for whom barks 12 oz
 100000037 | Life is Better 8 oz
 100000039 | Taknks for rubs and poop 8 oz
 100000043 | Dog Dad 16 oz
 100000044 | Dog Mom  8 oz
 100000045 | Dog Mom 12 oz
 100000050 | Well be watching you  8 oz
 100000058 | Cute Saying 6
 100000060 | Cute Saying 8
 100000065 | Cute Saying 13
 100000071 | Cute Saying 19
 100000077 | Cute Saying 25
 100000079 | Cute Saying 27
 100000084 | Cute Saying 32
 100000088 | Cute Saying 36
 100000093 | Cute Saying 41
 100000095 | Cute Saying 43
 100000101 | Cute Saying 49
 100000102 | Cute Saying 50
 100000105 | Cute Saying 53
 100000106 | Cute Saying 54
 100000117 | Cute Saying 65
 100000118 | Cute Saying 66
 100000125 | Cute Saying 73
(25 rows)


#4

 ordernumber |    sku    
-------------+-----------
 Q123057646  | 100000086
 Q401229064  | 100000074
 Q467152707  | 100000086
 Q535815874  | 100000074
 Q592031859  | 100000074
 Q811282451  | 100000074
(6 rows)


#5

 orderNumber | orderItem.id 
-------------+--------------
 Q630323850  |           27
 Q959949502  |           58
(2 rows)


#6

    SKU    | NumSold 
-----------+---------
 100000031 |       1
 100000032 |       2
 100000033 |       4
 100000034 |       0
 100000035 |       0
 100000036 |       3
 100000037 |       0
 100000038 |       8
 100000039 |       0
 100000040 |       6
(10 rows)


#7

BEGIN
UPDATE 1
 id | ordernumber |      orderdate      |    name     | shipaddress |  city  | state |    email    | soldprice | shipper | trackingnum |      shipdate       | deliverydate | status 
----+-------------+---------------------+-------------+-------------+--------+-------+-------------+-----------+---------+-------------+---------------------+--------------+--------
 36 | Q591942681  | 2022-02-21 00:00:00 | Customer 36 | Ship Ad 36  | City36 | MI    | CustMail136 |      9.98 |       4 | A1234567890 | 2022-03-01 00:00:00 |              |      4
(1 row)

ROLLBACK

#8

BEGIN
DELETE 1
DELETE 1
 count 
-------
   149
(1 row)

 count 
-------
   199
(1 row)

 id | ordernumber | orderdate | name | shipaddress | city | state | email | soldprice | shipper | trackingnum | shipdate | deliverydate | status 
----+-------------+-----------+------+-------------+------+-------+-------+-----------+---------+-------------+----------+--------------+--------
(0 rows)

ROLLBACK

#9

 imagemax | avg  
----------+------
        1 | 2.00
        2 | 4.00
        3 | 2.75
        4 | 2.10
(4 rows)


*/