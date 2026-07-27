/*=========================================================
PROJECT  : Market Insights & Sales Analytics
DATABASE : MarketInsightsDB
SCRIPT   : 05_Advanced_Analysis.sql
AUTHOR   : Temitayo Medubi

DESCRIPTION:
Advanced SQL analysis using CTEs, Window Functions,
Ranking, Running Totals and Business Intelligence techniques.
=========================================================*/

USE MarketInsightsDB;
GO

/*=========================================================
1. TOP 10 CUSTOMERS BY SALES
=========================================================*/

WITH CustomerSales AS
(
    SELECT
        Customer_ID,
        Customer_Name,
        CAST(SUM(Sales) AS DECIMAL(18,2)) AS Total_Sales,
        ROW_NUMBER() OVER
        (
            ORDER BY SUM(Sales) DESC
        ) AS Customer_Rank
    FROM dbo.Superstore
    GROUP BY Customer_ID, Customer_Name
)

SELECT *
FROM CustomerSales
WHERE Customer_Rank <= 10
ORDER BY Customer_Rank;
GO

/*=========================================================
2. TOP 10 CUSTOMERS BY PROFIT
=========================================================*/

WITH CustomerProfit AS
(
    SELECT

        Customer_ID,
        Customer_Name,

        CAST(SUM(Sales) AS DECIMAL(18,2)) AS Total_Profit,

        ROW_NUMBER() OVER
        (
            ORDER BY SUM(Profit) DESC
        ) AS Profit_Rank

    FROM dbo.Superstore

    GROUP BY
        Customer_ID,
        Customer_Name
)

SELECT *

FROM CustomerProfit

WHERE Profit_Rank<=10;
GO

/*=========================================================
3. TOP 10 PRODUCTS BY PROFIT
=========================================================*/

WITH ProductProfit AS
(
    SELECT
        Product_ID,
        Product_Name,
        Category,
        Sub_Category,
        CAST(SUM(Profit) AS DECIMAL(18,2)) AS Total_Profit,
        ROW_NUMBER() OVER
        (
            ORDER BY SUM(Profit) DESC
        ) AS Profit_Rank
    FROM dbo.Superstore
    GROUP BY
        Product_ID,
        Product_Name,
        Category,
        Sub_Category
)

SELECT *
FROM ProductProfit
WHERE Profit_Rank <= 10
ORDER BY Profit_Rank;
GO

/*=========================================================
4. BOTTOM 10 LOSS-MAKING PRODUCTS
=========================================================*/

WITH ProductLoss AS
(
    SELECT
        Product_ID,
        Product_Name,
        Category,
        Sub_Category,
        CAST(SUM(Sales) AS DECIMAL(18,2)) AS Total_Sales,
        CAST(SUM(Profit) AS DECIMAL(18,2)) AS Total_Profit,
        ROW_NUMBER() OVER
        (
            ORDER BY SUM(Profit) ASC
        ) AS Loss_Rank
    FROM dbo.Superstore
    GROUP BY
        Product_ID,
        Product_Name,
        Category,
        Sub_Category
    HAVING SUM(Profit) < 0
)

SELECT *
FROM ProductLoss
WHERE Loss_Rank <= 10
ORDER BY Loss_Rank;
GO

/*=========================================================
5. ANNUAL SALES WITH YEAR-OVER-YEAR GROWTH
=========================================================*/

WITH AnnualSales AS
(
    SELECT
        YEAR(Order_Date) AS Order_Year,
        CAST(SUM(Sales) AS DECIMAL(18,2)) AS Total_Sales,
        CAST(SUM(Profit) AS DECIMAL(18,2)) AS Total_Profit
    FROM dbo.Superstore
    GROUP BY YEAR(Order_Date)
),

SalesGrowth AS
(
    SELECT
        Order_Year,
        Total_Sales,
        Total_Profit,
        LAG(Total_Sales) OVER
        (
            ORDER BY Order_Year
        ) AS Previous_Year_Sales
    FROM AnnualSales
)

SELECT
    Order_Year,
    Total_Sales,
    Total_Profit,
    Previous_Year_Sales,
    CAST(
        (
            Total_Sales - Previous_Year_Sales
        ) * 100.0
        / NULLIF(Previous_Year_Sales, 0)
        AS DECIMAL(10,2)
    ) AS Sales_Growth_Percent
FROM SalesGrowth
ORDER BY Order_Year;
GO

/*=========================================================
6. MONTHLY SALES RUNNING TOTAL
=========================================================*/

WITH MonthlySales AS
(
    SELECT
        YEAR(Order_Date) AS Order_Year,
        MONTH(Order_Date) AS Order_Month,
        CAST(SUM(Sales) AS DECIMAL(18,2)) AS Monthly_Sales
    FROM dbo.Superstore
    GROUP BY
        YEAR(Order_Date),
        MONTH(Order_Date)
)

SELECT
    Order_Year,
    Order_Month,
    Monthly_Sales,
    CAST(
        SUM(Monthly_Sales) OVER
        (
            PARTITION BY Order_Year
            ORDER BY Order_Month
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        )
        AS DECIMAL(18,2)
    ) AS Running_Total_Sales
FROM MonthlySales
ORDER BY
    Order_Year,
    Order_Month;
GO

/*=========================================================
7. PARETO (80/20) CUSTOMER ANALYSIS
=========================================================*/

WITH CustomerSales AS
(
    SELECT
        Customer_ID,
        Customer_Name,
        CAST(SUM(Sales) AS DECIMAL(18,2)) AS Total_Sales
    FROM dbo.Superstore
    GROUP BY
        Customer_ID,
        Customer_Name
),

Pareto AS
(
    SELECT
        Customer_ID,
        Customer_Name,
        Total_Sales,

        SUM(Total_Sales) OVER
        (
            ORDER BY Total_Sales DESC
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS Running_Sales,

        SUM(Total_Sales) OVER () AS Grand_Total
    FROM CustomerSales
)

SELECT
    Customer_ID,
    Customer_Name,
    Total_Sales,
    Running_Sales,

    CAST(
        Running_Sales * 100.0 / Grand_Total
        AS DECIMAL(6,2)
    ) AS Cumulative_Sales_Percent

FROM Pareto
ORDER BY Total_Sales DESC;
GO

/*=========================================================
7B. NUMBER OF CUSTOMERS GENERATING 80% OF SALES
=========================================================*/

WITH CustomerSales AS
(
    SELECT
        Customer_ID,
        Customer_Name,
        CAST(SUM(Sales) AS DECIMAL(18,2)) AS Total_Sales
    FROM dbo.Superstore
    GROUP BY
        Customer_ID,
        Customer_Name
),

Pareto AS
(
    SELECT
        Customer_ID,
        Customer_Name,
        Total_Sales,

        SUM(Total_Sales) OVER
        (
            ORDER BY Total_Sales DESC
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS Running_Sales,

        SUM(Total_Sales) OVER () AS Grand_Total,

        ROW_NUMBER() OVER
        (
            ORDER BY Total_Sales DESC
        ) AS Customer_Position
    FROM CustomerSales
),

CumulativeAnalysis AS
(
    SELECT
        Customer_ID,
        Customer_Name,
        Total_Sales,
        Customer_Position,

        CAST(
            Running_Sales * 100.0 / Grand_Total
            AS DECIMAL(6,2)
        ) AS Cumulative_Sales_Percent
    FROM Pareto
)

SELECT TOP 1
    Customer_Position AS Customers_Required,
    Cumulative_Sales_Percent,
    CAST(
        Customer_Position * 100.0 /
        (SELECT COUNT(*) FROM CustomerSales)
        AS DECIMAL(6,2)
    ) AS Percentage_of_Customers
FROM CumulativeAnalysis
WHERE Cumulative_Sales_Percent >= 80
ORDER BY Customer_Position;
GO