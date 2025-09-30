-----------------------------------------------------------
-- AdventureWorksDW2022 EDA Portfolio
-- SQL-only Exploratory Data Analysis
-----------------------------------------------------------

/*=============================
 1️⃣ Customer Analysis
==============================*/

-- Total Customers
SELECT COUNT(*) AS TotalCustomers
FROM DimCustomer;

-- Customers by Gender
SELECT Gender, COUNT(*) AS Total
FROM DimCustomer
GROUP BY Gender;

-- Age Range: Oldest & Youngest Customers
SELECT MIN(BirthDate) AS OldestBirthDate,
       MAX(BirthDate) AS YoungestBirthDate
FROM DimCustomer;

-- Income Segmentation
SELECT CASE 
         WHEN YearlyIncome < 40000 THEN '<40K'
         WHEN YearlyIncome BETWEEN 40000 AND 79999 THEN '40K-79K'
         WHEN YearlyIncome BETWEEN 80000 AND 119999 THEN '80K-119K'
         ELSE '120K+' END AS IncomeRange,
       COUNT(*) AS Customers
FROM DimCustomer
GROUP BY CASE 
         WHEN YearlyIncome < 40000 THEN '<40K'
         WHEN YearlyIncome BETWEEN 40000 AND 79999 THEN '40K-79K'
         WHEN YearlyIncome BETWEEN 80000 AND 119999 THEN '80K-119K'
         ELSE '120K+' END
ORDER BY Customers DESC;

-- Customers by Country
SELECT g.EnglishCountryRegionName AS Country,
       COUNT(*) AS TotalCustomers
FROM DimCustomer c
JOIN DimGeography g ON c.GeographyKey = g.GeographyKey
GROUP BY g.EnglishCountryRegionName
ORDER BY TotalCustomers DESC;

-----------------------------------------------------------
-- 2️⃣ Product Analysis
-----------------------------------------------------------

-- Total Products
SELECT COUNT(*) AS TotalProducts
FROM DimProduct;

-- Products by Category
SELECT pc.EnglishProductCategoryName AS Category,
       COUNT(p.ProductKey) AS TotalProducts
FROM DimProduct p
JOIN DimProductSubcategory sc ON p.ProductSubcategoryKey = sc.ProductSubcategoryKey
JOIN DimProductCategory pc ON sc.ProductCategoryKey = pc.ProductCategoryKey
GROUP BY pc.EnglishProductCategoryName
ORDER BY TotalProducts DESC;

-- Top 10 Products by Revenue
SELECT TOP 10 p.EnglishProductName,
       SUM(f.SalesAmount) AS TotalRevenue
FROM FactInternetSales f
JOIN DimProduct p ON f.ProductKey = p.ProductKey
GROUP BY p.EnglishProductName
ORDER BY TotalRevenue DESC;

-----------------------------------------------------------
-- 3️⃣ Sales Analysis
-----------------------------------------------------------

-- Total Revenue
SELECT SUM(SalesAmount) AS TotalRevenue
FROM FactInternetSales;

-- Revenue by Country
SELECT g.EnglishCountryRegionName AS Country,
       SUM(f.SalesAmount) AS TotalRevenue
FROM FactInternetSales f
JOIN DimCustomer c ON f.CustomerKey = c.CustomerKey
JOIN DimGeography g ON c.GeographyKey = g.GeographyKey
GROUP BY g.EnglishCountryRegionName
ORDER BY TotalRevenue DESC;

-- Revenue by Year
SELECT d.CalendarYear, SUM(f.SalesAmount) AS TotalRevenue
FROM FactInternetSales f
JOIN DimDate d ON f.OrderDateKey = d.DateKey
GROUP BY d.CalendarYear
ORDER BY d.CalendarYear;

-- Top 5 Customers by Spending
SELECT TOP 5 c.CustomerKey, c.FirstName, c.LastName,
       SUM(f.SalesAmount) AS TotalSpent
FROM FactInternetSales f
JOIN DimCustomer c ON f.CustomerKey = c.CustomerKey
GROUP BY c.CustomerKey, c.FirstName, c.LastName
ORDER BY TotalSpent DESC;

-----------------------------------------------------------
-- 4️⃣ Advanced Analysis
-----------------------------------------------------------

-- RFM-like Summary
SELECT c.CustomerKey, c.FirstName, c.LastName,
       MAX(d.FullDateAlternateKey) AS LastPurchaseDate,
       COUNT(f.SalesOrderNumber) AS TotalOrders,
       SUM(f.SalesAmount) AS TotalSpent
FROM FactInternetSales f
JOIN DimCustomer c ON f.CustomerKey = c.CustomerKey
JOIN DimDate d ON f.OrderDateKey = d.DateKey
GROUP BY c.CustomerKey, c.FirstName, c.LastName
ORDER BY TotalSpent DESC;

-- Cohort Analysis: First Purchase Year vs Revenue
WITH FirstPurchase AS (
    SELECT CustomerKey, MIN(d.CalendarYear) AS FirstYear
    FROM FactInternetSales f
    JOIN DimDate d ON f.OrderDateKey = d.DateKey
    GROUP BY CustomerKey
)
SELECT fp.FirstYear, SUM(f.SalesAmount) AS Revenue
FROM FactInternetSales f
JOIN FirstPurchase fp ON f.CustomerKey = fp.CustomerKey
JOIN DimDate d ON f.OrderDateKey = d.DateKey
GROUP BY fp.FirstYear
ORDER BY fp.FirstYear;

-- Product Category Revenue by Country
SELECT g.EnglishCountryRegionName AS Country,
       pc.EnglishProductCategoryName AS Category,
       SUM(f.SalesAmount) AS TotalRevenue
FROM FactInternetSales f
JOIN DimCustomer c ON f.CustomerKey = c.CustomerKey
JOIN DimGeography g ON c.GeographyKey = g.GeographyKey
JOIN DimProduct p ON f.ProductKey = p.ProductKey
JOIN DimProductSubcategory sc ON p.ProductSubcategoryKey = sc.ProductSubcategoryKey
JOIN DimProductCategory pc ON sc.ProductCategoryKey = pc.ProductCategoryKey
GROUP BY g.EnglishCountryRegionName, pc.EnglishProductCategoryName
ORDER BY TotalRevenue DESC;
