-- Assigning Primary Keys
ALTER TABLE categories
ADD PRIMARY KEY (categoryID);

-- Fixing datatypes
ALTER TABLE customers 
CHANGE COLUMN companyName companyName VARCHAR(40) NOT NULL,
CHANGE COLUMN contactName contactName VARCHAR(25) NOT NULL,
CHANGE COLUMN country country VARCHAR(15) NOT NULL;

ALTER TABLE employees 
CHANGE COLUMN employeeName employeeName VARCHAR(30) NULL DEFAULT NULL,
CHANGE COLUMN title title VARCHAR(30) NULL DEFAULT NULL,
CHANGE COLUMN city city VARCHAR(15) NULL DEFAULT NULL,
CHANGE COLUMN country country VARCHAR(15) NULL DEFAULT NULL,
CHANGE COLUMN reportsTo reportsTo INT NULL DEFAULT NULL;

-- Changing to DATE datatype and assigning NULL to blank entries
UPDATE orders
SET shippedDate = IF(shippedDate = '', NULL, shippedDate);

ALTER TABLE `project_northwind`.`orders` 
CHANGE COLUMN `customerID` `customerID` VARCHAR(5) NULL DEFAULT NULL ,
CHANGE COLUMN `orderDate` `orderDate` DATE NULL DEFAULT NULL ,
CHANGE COLUMN `requiredDate` `requiredDate` DATE NULL DEFAULT NULL ,
CHANGE COLUMN `shippedDate` `shippedDate` DATE NULL DEFAULT NULL ;

-- Adding a unitCost column in order_details table
ALTER TABLE order_details
ADD unitCost double;

-- Populating the unitCost column with random values
UPDATE order_details
SET unitCost = ROUND(unitPrice * (0.6 + (RAND() * 0.2)), 2);

-- Creating the OrdersMain table
DROP TABLE OrdersMain;

CREATE TABLE OrdersMain (
	orderID int,
    customerID varchar(5),
    clientName varchar(40),
	employeeID int,
	productID int,
	unitPrice double,
	unitCost double,
	quantity int,
	discount int,
	revenue double,
	costOfGoods double,
	freight double,
	orderDate date,
    requiredDate date, 
	shippedDate date, 
    shippersName varchar(40),
    clientContact varchar(25),
	contactTitle varchar(30),
	clientCity varchar(15),
	clientCountry varchar(15)
);
/* Joining orders, order_details, and shippers tables
Inserting data into the OrdersMain table */
INSERT INTO OrdersMain
SELECT
	o.orderID,
	o.customerID,
	c.companyName AS clientName,
	o.employeeID,
	od.productID,
	od.unitPrice,
	od.unitCost,
	od.quantity,
	od.discount,
	od.unitPrice*od.quantity AS revenue,
	unitCost*od.quantity AS costOfGoods,
	o.freight,
    -- Added 7 years to all dates to reflect more recent date stamps
	DATE_ADD(o.orderDate, INTERVAL 7 YEAR) AS orderDate,
	DATE_ADD(o.requiredDate, INTERVAL 7 YEAR) AS requiredDate,
	DATE_ADD(o.shippedDate, INTERVAL 7 YEAR) AS shippedDate,
	s.companyName AS shippersName,
	c.contactName AS clientContact,
	c.contactTitle,
	c.city AS clientCity,
	c.country AS clientCountry
FROM orders o
INNER JOIN `order_details` od ON o.orderID = od.orderID
INNER JOIN `shippers` s ON o.shipperID = s.shipperID
INNER JOIN `customers` c ON o.customerID = c.customerID;

-- Creating the OrdersMain table
CREATE TABLE ProductsMain (
	productID int,
	productName nvarchar(40),
	categoryID int,
	categoryName varchar(20),
	description text,
	unitPrice decimal(6,2),
	discontinued bit(1)
	);
/* Joining products and categories tables
Inserting data into the ProductsMain table */
INSERT INTO ProductsMain
SELECT
	p.productID,
	p.productName,
	p.categoryID,
	c.categoryName,
	c.description,
	p.unitPrice,
	p.discontinued
FROM `products` p
INNER JOIN `categories` c ON p.categoryID = c.categoryID;

/* Added a freightByProduct column that divides the freight value with how many orderIDs there are */
SELECT * FROM OrdersMain;

ALTER TABLE OrdersMain
ADD COLUMN freightByProduct DOUBLE;

UPDATE OrdersMain o
JOIN (
    SELECT orderID, COUNT(*) AS numberOfOrders
    FROM OrdersMain
    GROUP BY orderID
) AS c ON o.orderID = c.orderID
SET o.freightByProduct = o.freight / c.numberOfOrders;