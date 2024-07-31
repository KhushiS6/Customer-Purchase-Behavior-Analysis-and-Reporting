# Creating database "Construct_Week_Project"
CREATE database Construct_Week_Project;

USE Construct_Week_Project;


# Creating table to insert data into database
CREATE TABLE Customer_Purchase_Data (
 TransactionID INT,
 CustomerID INT,
 CustomerName VARCHAR(100),
 ProductID INT,
 ProductName VARCHAR(200),
 ProductCategory VARCHAR(100),
 PurchaseQuantity INT,
 PurchasePrice DECIMAL(10,2),
 PurchaseDate DATE,
 Country VARCHAR(100)
 );
 
 
# Inserting data into the table
LOAD DATA INFILE 'C:\\Program Files\\MySQL\\customer_purchase_data.csv'
INTO TABLE Customer_Purchase_Data
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(TransactionID, CustomerID, CustomerName, ProductID, ProductName, 
ProductCategory, PurchaseQuantity, PurchasePrice, PurchaseDate, Country)
SET PurchaseDate = STR_TO_DATE(PurchaseDate, '%Y-%m-%d');


# Reading the dataset
SELECT * FROM Customer_Purchase_Data;


# Dividing the database into different tables

# Creating Customers Table and Assigning Unique IDs
-- Assuming that all the customers who made purchases are unique and have made purchase only once.
-- So, accordingly I have given unique IDs to all the customers in the dataset.
-- Reason: According to the data provided, even customers with the same name are from different countries.
-- Because of that, I have assumed that they are from different customers with same name.

CREATE TABLE Customers AS
WITH CTE AS(
SELECT DISTINCT CustomerName, Country, PurchaseDate FROM Customer_Purchase_Data)
SELECT ROW_NUMBER() OVER(ORDER BY PurchaseDate) as CustomerID, CustomerName, Country 
FROM CTE;

# Creating Products Table and Assigning Unique IDs
CREATE TABLE Products AS
WITH CTE2 AS(
SELECT DISTINCT ProductName, ProductCategory FROM Customer_Purchase_Data)
SELECT ROW_NUMBER() OVER(ORDER BY ProductCategory) as ProductID, ProductName, ProductCategory 
FROM CTE2;

# Creating Purchase Table and Assigning Unique IDs
CREATE TABLE Purchase AS
SELECT TransactionID, c.CustomerID, p.ProductID, PurchaseDate, PurchaseQuantity, PurchasePrice 
FROM Customer_Purchase_Data as d JOIN Customers as c ON d.CustomerName=c.CustomerName AND d.Country=c.Country
JOIN Products as p ON d.ProductName=p.ProductName
ORDER BY TransactionID;


# Checking null values
SELECT * FROM Customers
WHERE CustomerID = NULL OR CustomerName = NULL OR Country = NULL;

SELECT * FROM Products
WHERE ProductID = NULL OR ProductName = NULL OR ProductCategory = NULL;

SELECT * FROM Purchase
WHERE TransactionID = NULL OR CustomerID = NULL OR ProductID = NULL OR PurchaseDate = NULL OR PurchaseQuantity = NULL
	OR PurchaseQuantity = NULL OR PurchasePrice = NULL;


# Creating relationships between tables
ALTER TABLE Customers
ADD CONSTRAINT cpk PRIMARY KEY(CustomerID);

ALTER TABLE Products
ADD CONSTRAINT ppk PRIMARY KEY(ProductID);

ALTER TABLE Purchase
ADD CONSTRAINT pdpk PRIMARY KEY(TransactionID), 
ADD CONSTRAINT pdfk FOREIGN KEY(CustomerID) REFERENCES Customers(CustomerID), 
ADD CONSTRAINT pdfk1 FOREIGN KEY(ProductID) REFERENCES Products(ProductID);


# Advanced queries to aggregate data
# Total purchases per customer
SELECT CustomerID, SUM(PurchaseQuantity) AS Total_Purchases FROM purchase
GROUP BY CustomerID
ORDER BY CustomerID;

# Total sales per product
SELECT ProductID, SUM(PurchasePrice) AS Total_Sales FROM purchase
GROUP BY ProductID
ORDER BY ProductID;

# Total sales per product category
SELECT ProductCategory, SUM(PurchaseQuantity) AS Total_Quantity, SUM(PurchasePrice) AS Total_Sales 
FROM purchase AS pd JOIN products AS p ON pd.ProductID=p.ProductID
GROUP BY ProductCategory
ORDER BY ProductCategory;

# Total sales per country
SELECT Country, SUM(PurchasePrice) AS Total_Sales 
FROM purchase AS pd JOIN customers AS c ON pd.CustomerID=c.CustomerID
GROUP BY Country
ORDER BY Country;

# Count of customers per country
SELECT Country, COUNT(*) AS Num_of_Customers FROM customers
GROUP BY Country
ORDER BY Num_of_Customers DESC;

# Average sales per year
SELECT YEAR(PurchaseDate) AS YEAR, AVG(PurchasePrice) AS Total_Sales FROM purchase
GROUP BY YEAR
ORDER BY YEAR;

# Top 3 Months with high average sales
SELECT monthname(PurchaseDate) AS Month, AVG(PurchasePrice) AS Total_Sales FROM purchase
GROUP BY Month
ORDER BY Total_Sales DESC
LIMIT 3;

# Reading all the tables
SELECT * FROM Customers;
SELECT * FROM Products;
SELECT * FROM Purchase;



