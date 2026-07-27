/*=========================================================
PROJECT  : Market Insights & Sales Analytics
DATABASE : MarketInsightsDB
SCRIPT   : 03_Business_Questions.sql
AUTHOR   : Temitayo Medubi
DATE     : July 2026

DESCRIPTION:
This script answers key business questions related to
sales performance, profitability, customer behaviour,
regional performance and product analysis.
=========================================================*/

USE MarketInsightsDB;
GO

----------------------------------------------------------
-- 1. What are the company's total sales and total profit?
-- Management use: Provides an overall performance snapshot
----------------------------------------------------------

SELECT
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM dbo.Superstore;
GO

----------------------------------------------------------
-- 2. Which region generates the highest sales and profit?
-- Management use: Identifies strongest and weakest markets
----------------------------------------------------------

SELECT
    Region,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    ROUND(
        (SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100,
        2
    ) AS Profit_Margin_Percent
FROM dbo.Superstore
GROUP BY Region
ORDER BY Total_Sales DESC;
GO

----------------------------------------------------------
-- 3. Which states generate the highest sales?
-- Management use: Supports geographical investment decisions
----------------------------------------------------------

SELECT TOP 10
    State,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM dbo.Superstore
GROUP BY State
ORDER BY Total_Sales DESC;
GO

----------------------------------------------------------
-- 4. Which cities generate the highest sales?
-- Management use: Identifies important local markets
----------------------------------------------------------

SELECT TOP 10
    City,
    State,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM dbo.Superstore
GROUP BY City, State
ORDER BY Total_Sales DESC;
GO

----------------------------------------------------------
-- 5. What is the monthly sales and profit trend?
-- Management use: Reveals growth, decline, and seasonality
----------------------------------------------------------

SELECT
    YEAR(Order_Date) AS Order_Year,
    MONTH(Order_Date) AS Order_Month,
    DATENAME(MONTH, Order_Date) AS Month_Name,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM dbo.Superstore
GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date),
    DATENAME(MONTH, Order_Date)
ORDER BY
    Order_Year,
    Order_Month;
GO

----------------------------------------------------------
-- 6. Which product category performs best?
-- Management use: Supports category-level resource allocation
----------------------------------------------------------

SELECT
    Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    ROUND(
        (SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100,
        2
    ) AS Profit_Margin_Percent
FROM dbo.Superstore
GROUP BY Category
ORDER BY Total_Profit DESC;
GO

----------------------------------------------------------
-- 7. Which sub-categories perform best and worst?
-- Management use: Identifies growth and problem areas
----------------------------------------------------------

SELECT
    Sub_Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    ROUND(
        (SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100,
        2
    ) AS Profit_Margin_Percent
FROM dbo.Superstore
GROUP BY Sub_Category
ORDER BY Total_Profit DESC;
GO

----------------------------------------------------------
-- 8. Which customer segment generates the most value?
-- Management use: Supports targeting and market positioning
----------------------------------------------------------

SELECT
    Segment,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    COUNT(DISTINCT Customer_ID) AS Total_Customers,
    ROUND(
        SUM(Sales) / NULLIF(COUNT(DISTINCT Customer_ID), 0),
        2
    ) AS Average_Sales_Per_Customer
FROM dbo.Superstore
GROUP BY Segment
ORDER BY Total_Sales DESC;
GO

----------------------------------------------------------
-- 9. Who are the top 10 customers by sales?
-- Management use: Identifies high-value customers
----------------------------------------------------------

SELECT TOP 10
    Customer_ID,
    Customer_Name,
    Segment,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    COUNT(DISTINCT Order_ID) AS Total_Orders
FROM dbo.Superstore
GROUP BY
    Customer_ID,
    Customer_Name,
    Segment
ORDER BY Total_Sales DESC;
GO

----------------------------------------------------------
-- 10. Who are the top 10 customers by profit?
-- Management use: Distinguishes revenue from true value
----------------------------------------------------------

SELECT TOP 10
    Customer_ID,
    Customer_Name,
    Segment,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    COUNT(DISTINCT Order_ID) AS Total_Orders
FROM dbo.Superstore
GROUP BY
    Customer_ID,
    Customer_Name,
    Segment
ORDER BY Total_Profit DESC;
GO

----------------------------------------------------------
-- 11. What are the top 10 products by sales?
-- Management use: Identifies major revenue drivers
----------------------------------------------------------

SELECT TOP 10
    Product_ID,
    Product_Name,
    Category,
    Sub_Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM dbo.Superstore
GROUP BY
    Product_ID,
    Product_Name,
    Category,
    Sub_Category
ORDER BY Total_Sales DESC;
GO

----------------------------------------------------------
-- 12. What are the top 10 products by profit?
-- Management use: Identifies the most profitable products
----------------------------------------------------------

SELECT TOP 10
    Product_ID,
    Product_Name,
    Category,
    Sub_Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM dbo.Superstore
GROUP BY
    Product_ID,
    Product_Name,
    Category,
    Sub_Category
ORDER BY Total_Profit DESC;
GO

----------------------------------------------------------
-- 13. Which products generate losses?
-- Management use: Identifies products requiring intervention
----------------------------------------------------------

SELECT TOP 20
    Product_ID,
    Product_Name,
    Category,
    Sub_Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM dbo.Superstore
GROUP BY
    Product_ID,
    Product_Name,
    Category,
    Sub_Category
HAVING SUM(Profit) < 0
ORDER BY Total_Profit ASC;
GO

----------------------------------------------------------
-- 14. How does discount level affect profit?
-- Management use: Assesses whether discounting is sustainable
----------------------------------------------------------

SELECT
    CASE
        WHEN Discount = 0 THEN 'No Discount'
        WHEN Discount <= 0.10 THEN 'Low Discount'
        WHEN Discount <= 0.20 THEN 'Moderate Discount'
        WHEN Discount <= 0.40 THEN 'High Discount'
        ELSE 'Very High Discount'
    END AS Discount_Band,

    COUNT(*) AS Total_Transactions,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    AVG(Discount) AS Average_Discount,
    ROUND(
        (SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100,
        2
    ) AS Profit_Margin_Percent

FROM dbo.Superstore
GROUP BY
    CASE
        WHEN Discount = 0 THEN 'No Discount'
        WHEN Discount <= 0.10 THEN 'Low Discount'
        WHEN Discount <= 0.20 THEN 'Moderate Discount'
        WHEN Discount <= 0.40 THEN 'High Discount'
        ELSE 'Very High Discount'
    END
ORDER BY Average_Discount;
GO

----------------------------------------------------------
-- 15. Which sub-categories receive the highest discounts?
-- Management use: Identifies areas exposed to margin pressure
----------------------------------------------------------

SELECT
    Sub_Category,
    AVG(Discount) AS Average_Discount,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM dbo.Superstore
GROUP BY Sub_Category
ORDER BY Average_Discount DESC;
GO

----------------------------------------------------------
-- 16. Which shipping modes generate the most sales?
-- Management use: Evaluates shipping preferences and value
----------------------------------------------------------

SELECT
    Ship_Mode,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    AVG(DATEDIFF(DAY, Order_Date, Ship_Date) * 1.0)
        AS Average_Shipping_Days
FROM dbo.Superstore
GROUP BY Ship_Mode
ORDER BY Total_Sales DESC;
GO

----------------------------------------------------------
-- 17. Which regions contain loss-making transactions?
-- Management use: Supports regional profitability review
----------------------------------------------------------

SELECT
    Region,
    COUNT(*) AS Loss_Making_Transactions,
    SUM(Profit) AS Total_Loss
FROM dbo.Superstore
WHERE Profit < 0
GROUP BY Region
ORDER BY Total_Loss ASC;
GO

----------------------------------------------------------
-- 18. What proportion of transactions are profitable?
-- Management use: Measures transaction-level profitability
----------------------------------------------------------

SELECT
    CASE
        WHEN Profit > 0 THEN 'Profitable'
        WHEN Profit = 0 THEN 'Break-even'
        ELSE 'Loss-making'
    END AS Profit_Status,
    COUNT(*) AS Total_Transactions,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS Percentage_of_Transactions
FROM dbo.Superstore
GROUP BY
    CASE
        WHEN Profit > 0 THEN 'Profitable'
        WHEN Profit = 0 THEN 'Break-even'
        ELSE 'Loss-making'
    END;
GO

----------------------------------------------------------
-- 19. Which year recorded the highest sales and profit?
-- Management use: Compares annual business performance
----------------------------------------------------------

SELECT
    YEAR(Order_Date) AS Order_Year,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    COUNT(DISTINCT Order_ID) AS Total_Orders
FROM dbo.Superstore
GROUP BY YEAR(Order_Date)
ORDER BY Total_Sales DESC;
GO

----------------------------------------------------------
-- 20. Which category performs best in each region?
-- Management use: Reveals market-specific product strengths
----------------------------------------------------------

WITH Regional_Category_Performance AS
(
    SELECT
        Region,
        Category,
        SUM(Sales) AS Total_Sales,
        SUM(Profit) AS Total_Profit,
        RANK() OVER (
            PARTITION BY Region
            ORDER BY SUM(Sales) DESC
        ) AS Sales_Rank
    FROM dbo.Superstore
    GROUP BY Region, Category
)

SELECT
    Region,
    Category,
    Total_Sales,
    Total_Profit,
    Sales_Rank
FROM Regional_Category_Performance
WHERE Sales_Rank = 1
ORDER BY Region;
GO

/*=========================================================
END OF SCRIPT
=========================================================*/