SELECT * 
FROM blinkit_data;

SELECT COUNT(*) 
FROM blinkit_data;

------------------------------------------
-- ALTER
------------------------------------------
ALTER TABLE blinkit_data 
CHANGE `Item Fat Content` `Item_Fat_Content` VARCHAR(50);

ALTER TABLE blinkit_data 
CHANGE `Item Identifier` `Item_Identifier` VARCHAR(50);

ALTER TABLE blinkit_data 
CHANGE `Item Type` `Item_Type` VARCHAR(50);

ALTER TABLE blinkit_data 
CHANGE `Outlet Establishment Year` `Outlet_Establishment_Year` INT;
ALTER TABLE blinkit_data 
CHANGE `Outlet_Establishment_Year` `Outlet_Establishment_Year` INT;

ALTER TABLE blinkit_data 
CHANGE `Item Type` `Item_Type` VARCHAR(50);

ALTER TABLE blinkit_data 
CHANGE `Outlet Identifier` `Outlet_Identifier` VARCHAR(50);

ALTER TABLE blinkit_data 
CHANGE `Outlet Location Type` `Outlet_Location_Type` VARCHAR(50);

ALTER TABLE blinkit_data 
CHANGE `Outlet Size` `Outlet_Size` VARCHAR(50);

ALTER TABLE blinkit_data 
CHANGE `Outlet Type` `Outlet_Type` VARCHAR(50);

ALTER TABLE blinkit_data 
CHANGE `Item Visibility` `Item_Visibility` FLOAT;
ALTER TABLE blinkit_data 
CHANGE `Item_Visibility` `Item_Visibility` FLOAT;

ALTER TABLE blinkit_data 
CHANGE `Item Weight` `Item_Weight` FLOAT;
ALTER TABLE blinkit_data 
CHANGE `Item_Weight` `Item_Weight` FLOAT;

ALTER TABLE blinkit_data 
CHANGE `Sales` `Sales` FLOAT;

ALTER TABLE blinkit_data 
CHANGE `Rating` `Rating` FLOAT;


------------------------------------------
-- Data Cleaning 
------------------------------------------
SET SQL_SAFE_UPDATES = 0; -- since because of ERROR 1175

UPDATE blinkit_data
SET Item_Fat_Content = 
CASE
WHEN Item_Fat_Content IN ('LF', 'low fat') THEN 'Low Fat'
WHEN Item_Fat_Content = 'reg' THEN 'Regular'
ELSE Item_Fat_Content
END

SELECT DISTINCT(Item_Fat_Content)
FROM blinkit_data;

------------------------------------------
-- KPI 1 - Total sales
------------------------------------------
 SELECT SUM(Sales) AS 'Total_Sales'
 FROM blinkit_data

 SELECT CAST(SUM(Sales)/1000000 AS DECIMAL(10,2)) AS 'Total_Sales_Million '
 FROM blinkit_data
 
 SELECT CAST(SUM(Sales)/1000000 AS DECIMAL(10,2)) AS 'Total_Sales_Million_Low Fat'
 FROM blinkit_data
 WHERE Item_Fat_Content = 'Low Fat'
 
-------------------------------------------
-- KPI 2 - Average sales
-------------------------------------------
 SELECT CAST(AVG(Sales) AS DECIMAL(10,2)) AS 'Average_Sales'
 FROM blinkit_data

 SELECT CAST(AVG(Sales) AS DECIMAL(10,2)) AS 'Average_Sales'
 FROM blinkit_data
 WHERE Outlet_Establishment_Year = 2022
-------------------------------------------
-- KPI 3 - Number of items
-------------------------------------------
SELECT COUNT(*) AS 'No_of_Items'
FROM blinkit_data 

SELECT COUNT(*) AS 'No_of_Items'
FROM blinkit_data 
WHERE Outlet_Establishment_Year = 2022

-------------------------------------------
-- KPI 4 - Average Rating
-------------------------------------------
SELECT CAST(AVG(Rating) AS Decimal(10,2)) AS 'Average_Rating'
FROM blinkit_data
WHERE Item_Fat_Content = 'Low Fat';

-------------------------------------------
-- GR 1 - Total Sales by Fat Content
-------------------------------------------
SELECT Item_Fat_Content,
       CAST(SUM(Sales) AS DECIMAL (10,2)) AS 'Total_Sales',
       CAST(AVG(Sales) AS DECIMAL(10,2)) AS 'Average_Sales',
       COUNT(*) AS 'No_of_Items',
       CAST(AVG(Rating) AS Decimal(10,2)) AS 'Average_Rating'
FROM blinkit_data
WHERE Outlet_Establishment_Year = 2022
GROUP BY Item_Fat_Content
ORDER BY Total_Sales DESC;

-------------------------------------------
-- GR 2 - Total Sales by Item Type
-------------------------------------------
SELECT Item_Type,
       COUNT(*) AS 'Total Sales by Item Type',
	   CAST(SUM(Sales) AS DECIMAL (10,2)) AS 'Total_Sales',
       CAST(AVG(Sales) AS DECIMAL(10,2)) AS 'Average_Sales',
       CAST(AVG(Rating) AS Decimal(10,2)) AS 'Average_Rating'
FROM blinkit_data
GROUP BY Item_Type
ORDER BY Total_Sales DESC
LIMIT 5;

-------------------------------------------------
-- GR 3 - Fat content by outlet for total sales
-------------------------------------------------
SELECT Item_Fat_Content,
       Outlet_Location_Type,
       COUNT(*) AS 'Total Sales by Item Type',
	   CAST(SUM(Sales) AS DECIMAL (10,2)) AS 'Total_Sales',
       CAST(AVG(Sales) AS DECIMAL(10,2)) AS 'Average_Sales',
       CAST(AVG(Rating) AS Decimal(10,2)) AS 'Average_Rating'
FROM blinkit_data
GROUP BY Outlet_Location_Type, Item_Fat_Content
ORDER BY Total_Sales DESC

-------------------------------------------------
-- GR 3 - Fat content by outlet for total sales using PIVOT (transform rows to coloumn)
-------------------------------------------------
SELECT 
    Outlet_Location_Type,
    ISNULL([Low Fat], 0) AS Low_Fat,
    ISNULL([Regular], 0) AS Regular
FROM 
(
    SELECT 
        Outlet_Location_Type, 
        Item_Fat_Content,
        CAST(SUM(Sales) AS DECIMAL(10,2)) AS Sales
    FROM blinkit_data
    GROUP BY Outlet_Location_Type, Item_Fat_Content
) AS SourceTable
PIVOT 
(
    SUM(Sales)
    FOR Item_Fat_Content IN ([Low Fat], [Regular])
) AS PivotTable
ORDER BY Outlet_Location_Type;

-------------------------------------------------
-- GR 3 - Fat content by outlet for total sales using CASE WHEN (transform rows to coloumn)
-------------------------------------------------
SELECT 
    Outlet_Location_Type,
    ROUND(SUM(CASE WHEN Item_Fat_Content = 'Low Fat' THEN Sales ELSE 0 END), 2) AS Low_Fat,
    ROUND(SUM(CASE WHEN Item_Fat_Content = 'Regular' THEN Sales ELSE 0 END), 2) AS Regular
FROM blinkit_data
GROUP BY Outlet_Location_Type
ORDER BY Outlet_Location_Type;

-------------------------------------------------
-- GR 4 - Total sales by outlet establishment year
-------------------------------------------------
SELECT Outlet_Establishment_Year,
	   CAST(SUM(Sales) AS DECIMAL (10,2)) AS 'Total_Sales',
       COUNT(*) AS 'Total Sales by Item Type',
       CAST(AVG(Sales) AS DECIMAL(10,2)) AS 'Average_Sales',
       CAST(AVG(Rating) AS Decimal(10,2)) AS 'Average_Rating'
FROM blinkit_data
GROUP BY Outlet_Establishment_Year
ORDER BY Total_Sales DESC

-------------------------------------------------
-- GR 5 - Percentage of sales by outlet size
-------------------------------------------------
SELECT Outlet_Size,
	   CAST(SUM(Sales) AS DECIMAL (10,2)) AS 'Total_Sales',
       CAST((SUM(Sales) * 100 / SUM(SUM(Sales)) OVER()) AS DECIMAL (10,2)) AS '% Sales',
	   COUNT(*) AS 'Total Sales by Item Type',
       CAST(AVG(Sales) AS DECIMAL(10,2)) AS 'Average_Sales',
       CAST(AVG(Rating) AS Decimal(10,2)) AS 'Average_Rating'
FROM blinkit_data
GROUP BY  Outlet_Size
ORDER BY Total_Sales DESC

-------------------------------------------------
-- GR 6 - Sales by outlet location
-------------------------------------------------
SELECT Outlet_Location_Type,
	   CAST(SUM(Sales) AS DECIMAL (10,2)) AS 'Total_Sales',
       COUNT(*) AS 'Total Sales by Item Type',
       CAST(AVG(Sales) AS DECIMAL(10,2)) AS 'Average_Sales',
       CAST(AVG(Rating) AS Decimal(10,2)) AS 'Average_Rating'
FROM blinkit_data
GROUP BY Outlet_Location_Type
ORDER BY Total_Sales DESC

-------------------------------------------------
-- GR 7 - Sales by outlet location
-------------------------------------------------
SELECT Outlet_Type,
	   CAST(SUM(Sales) AS DECIMAL (10,2)) AS 'Total_Sales',
	   CAST((SUM(Sales) * 100 / SUM(SUM(Sales)) OVER()) AS DECIMAL (10,2)) AS '% Sales',
       COUNT(*) AS 'Total Sales by Item Type',
       CAST(AVG(Sales) AS DECIMAL(10,2)) AS 'Average_Sales',
       CAST(AVG(Rating) AS Decimal(10,2)) AS 'Average_Rating'
FROM blinkit_data
GROUP BY Outlet_Type
ORDER BY Total_Sales DESC