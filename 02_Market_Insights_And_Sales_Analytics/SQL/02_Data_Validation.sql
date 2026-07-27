USE MarketInsightsDB;
GO
SELECT TOP 10 *
FROM Superstore;
/*=========================================================
  PROJECT: Market Insights & Sales Analytics
  SCRIPT : 02_Data_Validation.sql
  AUTHOR : Temitayo Medubi
  PURPOSE: Validate dataset before business analysis
=========================================================*/

USE MarketInsightsDB;
GO

----------------------------------------------------------
-- 1. Check Total Number of Records
----------------------------------------------------------

SELECT COUNT(*) AS Total_Records
FROM Superstore;

----------------------------------------------------------
-- 2. Check Date Range
----------------------------------------------------------

SELECT
    MIN(Order_Date) AS First_Order,
    MAX(Order_Date) AS Last_Order
FROM Superstore;

----------------------------------------------------------
-- 3. Count Unique Customers
----------------------------------------------------------

SELECT COUNT(DISTINCT Customer_ID) AS Total_Customers
FROM Superstore;

----------------------------------------------------------
-- 4. Count Unique Products
----------------------------------------------------------

SELECT COUNT(DISTINCT Product_ID) AS Total_Products
FROM Superstore;

----------------------------------------------------------
-- 5. Count Unique Customers
-- Purpose: Determine the number of customers in the dataset
----------------------------------------------------------

SELECT
    COUNT(DISTINCT Customer_ID) AS Total_Customers
FROM Superstore;
GO


----------------------------------------------------------
-- 6. Count Unique Products
-- Purpose: Determine the number of distinct products sold
----------------------------------------------------------

SELECT
    COUNT(DISTINCT Product_ID) AS Total_Products
FROM Superstore;
GO


----------------------------------------------------------
-- 7. Check for Missing Values in Important Fields
-- Purpose: Identify NULL values that may affect analysis
----------------------------------------------------------

SELECT
    SUM(CASE WHEN Order_ID IS NULL THEN 1 ELSE 0 END)
        AS Missing_Order_ID,

    SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END)
        AS Missing_Order_Date,

    SUM(CASE WHEN Customer_ID IS NULL THEN 1 ELSE 0 END)
        AS Missing_Customer_ID,

    SUM(CASE WHEN Product_ID IS NULL THEN 1 ELSE 0 END)
        AS Missing_Product_ID,

    SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END)
        AS Missing_Sales,

    SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END)
        AS Missing_Quantity,

    SUM(CASE WHEN Discount IS NULL THEN 1 ELSE 0 END)
        AS Missing_Discount,

    SUM(CASE WHEN Profit IS NULL THEN 1 ELSE 0 END)
        AS Missing_Profit
FROM Superstore;
GO


----------------------------------------------------------
-- 8. Check Repeated Order IDs
-- Purpose: Identify orders containing multiple line items
-- Note: Repeated Order IDs are expected because one order
-- may contain more than one product
----------------------------------------------------------

SELECT
    Order_ID,
    COUNT(*) AS Number_of_Line_Items
FROM Superstore
GROUP BY Order_ID
HAVING COUNT(*) > 1
ORDER BY Number_of_Line_Items DESC;
GO


----------------------------------------------------------
-- 9. Check for Exact Duplicate Rows
-- Purpose: Detect records duplicated across all key fields
----------------------------------------------------------

SELECT
    Order_ID,
    Product_ID,
    Customer_ID,
    Order_Date,
    Sales,
    Quantity,
    Discount,
    Profit,
    COUNT(*) AS Duplicate_Count
FROM Superstore
GROUP BY
    Order_ID,
    Product_ID,
    Customer_ID,
    Order_Date,
    Sales,
    Quantity,
    Discount,
    Profit
HAVING COUNT(*) > 1
ORDER BY Duplicate_Count DESC;
GO


----------------------------------------------------------
-- 10. Sales Summary Statistics
-- Purpose: Understand the range and average sales value
----------------------------------------------------------

SELECT
    MIN(Sales) AS Minimum_Sales,
    MAX(Sales) AS Maximum_Sales,
    AVG(Sales) AS Average_Sales,
    SUM(Sales) AS Total_Sales
FROM Superstore;
GO


----------------------------------------------------------
-- 11. Profit Summary Statistics
-- Purpose: Understand profitability and possible losses
----------------------------------------------------------

SELECT
    MIN(Profit) AS Minimum_Profit,
    MAX(Profit) AS Maximum_Profit,
    AVG(Profit) AS Average_Profit,
    SUM(Profit) AS Total_Profit
FROM Superstore;
GO


----------------------------------------------------------
-- 12. Discount Summary Statistics
-- Purpose: Review the range and average discount offered
----------------------------------------------------------

SELECT
    MIN(Discount) AS Minimum_Discount,
    MAX(Discount) AS Maximum_Discount,
    AVG(Discount) AS Average_Discount
FROM Superstore;
GO


----------------------------------------------------------
-- 13. Quantity Summary Statistics
-- Purpose: Review the number of units sold per line item
----------------------------------------------------------

SELECT
    MIN(Quantity) AS Minimum_Quantity,
    MAX(Quantity) AS Maximum_Quantity,
    AVG(CAST(Quantity AS DECIMAL(10,2)))
        AS Average_Quantity,
    SUM(Quantity) AS Total_Quantity
FROM Superstore;
GO


----------------------------------------------------------
-- 14. Validate Categories and Sub-Categories
-- Purpose: Confirm available product classifications
----------------------------------------------------------

SELECT DISTINCT
    Category,
    Sub_Category
FROM Superstore
ORDER BY Category, Sub_Category;
GO


----------------------------------------------------------
-- 15. Validate Regions and Customer Segments
-- Purpose: Confirm geographical and customer group values
----------------------------------------------------------

SELECT DISTINCT
    Region,
    Segment
FROM Superstore
ORDER BY Region, Segment;
GO


----------------------------------------------------------
-- 16. Check for Invalid Numerical Values
-- Purpose: Identify impossible or suspicious values
----------------------------------------------------------

SELECT
    SUM(CASE WHEN Sales < 0 THEN 1 ELSE 0 END)
        AS Negative_Sales_Records,

    SUM(CASE WHEN Quantity <= 0 THEN 1 ELSE 0 END)
        AS Invalid_Quantity_Records,

    SUM(CASE
        WHEN Discount < 0 OR Discount > 1
        THEN 1 ELSE 0
    END) AS Invalid_Discount_Records
FROM Superstore;
GO


----------------------------------------------------------
-- 17. Check Order and Shipping Date Consistency
-- Purpose: Identify records where shipping occurred before
-- the order date
----------------------------------------------------------

SELECT
    COUNT(*) AS Invalid_Shipping_Date_Records
FROM Superstore
WHERE Ship_Date < Order_Date;
GO


/*=========================================================
END OF SCRIPT
=========================================================*/