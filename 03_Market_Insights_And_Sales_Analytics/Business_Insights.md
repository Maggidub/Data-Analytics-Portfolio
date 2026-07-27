# Market Insights & Sales Analytics

## Executive Business Insights

**Author:** Temitayo Medubi

---

# Project Overview

This project analyzes sales transactions from the Superstore dataset to evaluate business performance across products, customers, regions and time.

The objective is to identify opportunities to improve revenue, profitability and customer value using SQL, Python, Power BI and Tableau.

---

# Executive Summary

The business generated over **$2.29 million** in sales from **5,009 customer orders**, resulting in approximately **$286,397** in profit and an overall **profit margin of 12.47%**.

While the business is profitable, the average discount of **15.62%** indicates opportunities to optimize pricing strategies without negatively affecting sales.

Average shipping time of approximately **4 days** suggests relatively efficient order fulfilment.

## Table of Contents

- Executive Summary
- Key Performance Indicators
- Business Questions, Insights & Recommendations
- Executive Recommendations
- Conclusion

---

# Key Performance Indicators

| KPI | Value |
|------|-------:|
| Total Sales | $2,297,200.86 |
| Total Profit | $286,397.02 |
| Profit Margin | 12.47% |
| Total Orders | 5,009 |
| Total Customers | 793 |
| Average Order Value | $458.61 |
| Total Quantity Sold | 37,873 |
| Average Discount | 15.62% |
| Average Shipping Days | 3.96 Days |

---

# Executive Business Insights & Recommendations

## Business Question 1

### Business Question

What are the company's total sales and total profit?

### SQL Result

- Total Sales: **$2,297,200.86**
- Total Profit: **$286,397.02**

### Business Insight

The company generated approximately **$2.3 million** in revenue while earning **$286,397** in profit. This indicates that the business is profitable and has a healthy sales volume.

### Recommendation

Management should continue investing in high-performing product lines while exploring opportunities to improve profitability by optimizing discounts and operational costs.

---

## Business Question 5

### Business Question

Are the customers generating the highest sales also the most profitable?

### SQL Result

The Top 10 customers by Sales and the Top 10 customers by Profit were compared using SQL window functions (`ROW_NUMBER()`).

### Business Insight

The customers generating the highest revenue are not exactly the same as those generating the highest profit. While several customers appear in both rankings, their positions differ, indicating that high sales do not always translate into high profitability. This suggests that discounts, product mix, and purchasing patterns influence customer profitability.

### Recommendation

Management should evaluate customer performance using both sales and profit rather than revenue alone. Customer loyalty initiatives should prioritize highly profitable customers, while high-sales but lower-margin customers should be reviewed for pricing and discount optimization.

## Business Question 6

### Business Question

Does a small percentage of customers generate most of the company's sales?

### SQL Result

- Customers required to generate 80% of sales: **396**
- Percentage of customer base: **49.94%**
- Cumulative Sales Contribution: **80.06%**

### Business Insight

The business does not follow the traditional 80/20 Pareto distribution. Approximately half of the customer base is required to generate 80% of total sales, indicating that revenue is broadly distributed rather than concentrated among a small number of customers.

### Recommendation

Management should continue investing in broad customer acquisition and retention strategies while still identifying and nurturing the most profitable customer relationships.

# Conclusion

The analysis shows that the business achieved strong sales performance and maintained profitability throughout the reporting period. However, opportunities exist to improve profit margins through better discount management, product mix optimization, and targeted regional strategies.

The insights generated in this project provide a solid foundation for strategic decision-making and demonstrate how business intelligence tools can transform raw transactional data into actionable recommendations.