CREATE DATABASE Ecommerce_Project;
/* =============================================
   PROJECT: E-COMMERCE PERFORMANCE ANALYSIS
   AUTHOR: [Pham Hong Nhung]
   DATE: [1/12/2025]
   GOAL: Product affinity analysis, cross-sell opportunities, bundle recommendations, purchase pattern discovery
   ============================================= */
------------------------------------------------
USE Ecommerce_Project; 
------------------------------------------------
-- A. EXPLORING DATA 
-- ---------------------------------------------
-- 1. Total invoices, unique products, unique customers
-- GOAL: Get an overview of the dataset volume
SELECT 
    COUNT(DISTINCT InvoiceNo) AS Total_Invoice,
    COUNT(DISTINCT CustomerID) AS Unique_Customer,
    COUNT(DISTINCT StockCode) AS Unique_Product
FROM ecommerce_project;

/*----------------------------------------------
QUICK INSIGHTS:
   - Fact: 25,900 Invoices, 4,372 Customers, 3,958 Products.

   - Insight: The Order-to-Customer ratio is ~5.9 (25,900 / 4,372).
     => This indicates a high repeat purchase rate, making this dataset 
        highly suitable for Retention and Cohort Analysis.

   - Action: Proceed to data profiling and cleaning to handle cancellation 
     and missing values before analysing.
     -------------------------------------------*/

-- 2. Date range validation
-- GOAL: Identify the time period to check the seasonality and missing month. 
SELECT
    MIN(InvoiceDate) AS First_Date,
    MAX(InvoiceDate) AS Last_Date,
    DATEDIFF(day, MIN(InvoiceDate), MAX(InvoiceDate)) AS Total_Days
FROM ecommerce_project;

/*----------------------------------------------
QUICK INSIGHTS:

    - Fact: Data cover from 2010-12-01 to 2011-12-09 (Total 373 days).

    - Insight: The dataset covers a full year, allowing to discover
      the seasonality (holiday like Christmas).

    => Warning: The dataset end at Dec 09 (incomplete) so compare between 
       2010 Dec and 2011 Dec would be misleading.
       -----------------------------------------*/

-- 3. Check for nulls in CustomerID
-- GOAL: Identify how many missing value in the dataset
SELECT 
    COUNT(*) AS Total_Rows,
    COUNT(CustomerID) AS Total_Customer,
    COUNT(*) - COUNT(CustomerID) AS Null_Values,
    CAST((COUNT(*) - COUNT(CustomerID))*100.0 / COUNT(*) AS DECIMAL(10,2)) AS Per_Null_Values
FROM ecommerce_project;

/*----------------------------------------------
QUICK INSIGHTS:

    - Fact: ~25% missing value .

    - Insight: The mising value could be represent system errors or other reasons.

    - Action: Must exclude the missing value in the cleaning phase to avoid tracking 
      user without ID when doing the Customer Retention/Cohort Analysis.
      ------------------------------------------*/

-- 4. Identify cancellations (InvoiceNo starting with 'C')
-- GOAL: Check how many transactions have been cancelled.
SELECT 
    COUNT(*) AS Total_Trans,
    SUM(CASE WHEN InvoiceNo LIKE 'C%' THEN 1 ELSE 0 END) AS Total_Cancellations,
    CAST(SUM(CASE WHEN InvoiceNo LIKE 'C%' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)
    AS DECIMAL(10,2)) AS Cancel_Per
FROM ecommerce_project;

/*----------------------------------------------
QUICK INSIGHTS:

    - Fact: Cancellation rate is ~1.7%.

    - Insight: This rate is relatively low for e-commerce but it 
      include negative quantities, which will offset the Total Revenue.

    - Action: Excude the 'C' Invoices in the cleaning phase to avoide
      misleading while calculating metrics.
    -------------------------------------------*/
GO
------------------------------------------------
-- B. PROFILING DATA
-- ---------------------------------------------
-- 1. Basket size distribution
-- GOAL: Calculate the average number of item buying per order to detect B2B, Wholesales 
; WITH Basket_Stats AS (
    SELECT 
      InvoiceNo,
      SUM(Quantity) AS Total_Items
    FROM ecommerce_project
    WHERE InvoiceNo NOT LIKE 'C%'
    GROUP BY InvoiceNo
)
SELECT 
    AVG(Total_Items) AS Avg_Basket_Size,
    MIN(Total_Items) AS Min_Basket_Size,
    MAX(Total_Items) AS Max_Basket_Size
FROM Basket_Stats;

/*----------------------------------------------
QUICK INSIGHTS:
.
    - Fact: Max basket size distribution is 80955 and the average is 247
          : Min basket size distribution is negative even when already 
            have the NOT LIKE 'C%' filter.

    - Insight:
        1. The masive max value (80995) prove the presence of B2B, Wholesales that
           significantly skew the average metric.
        2. The min value is negative show that the 'C%' filter is not enough.
           There are still have another adjustment or error.

    - Action: To prevent misleading, in the Cleaning section we need to add more
              filter: Quantity > 0.
            : Segment these B2B customers or treat them as outliers in Cleaning section
              to avoid skewing the average customer metrics.
    -------------------------------------------*/

-- 2. Most frequently purchased products
-- GOAL: Identify the most popular products based on transactions count,
SELECT TOP 10
   StockCode,
   Description,
   COUNT(*) as frequency
FROM ecommerce_project
WHERE InvoiceNo NOT LIKE 'C%'
GROUP BY StockCode, Description
ORDER BY frequency DESC;

/*----------------------------------------------
QUICK INSIGHTS:

  - Fact: The 'WHITE HANGING HEART T-LIGHT HOLDER' is the most frequently 
          purchased products (2327 products).
        : The 'RED RETROSPOT' item appear in multiple frequently purchased (2,5,8).

  - Insight: 
    1. Business Type: Most of the bestselller are Home Decor and Party Item 
                      (holder, cakestand, party bunting...), confirming the Lifestyle/Gift Shop.
    2. Trend: The red retrospot item seem like a favourite pattern in the shop.
    3. Occassion: High volume of baking/party item suggest that customers 
                often buy stuff here for event preparation.

  - Action: Create a 'party bundle' (ex: cakestand + cake cases) or produce a
            'red retrospot collection' to boost cross-selling.
  -------------------------------------------*/     

-- 3. Revenue distribution by product
-- GOAL: Identify the product producing the most revenue (Cash Cow)
SELECT TOP 10
  StockCode,
  Description,
  CAST(SUM (Quantity * UnitPrice) AS DECIMAL(10,2)) AS Total_Revenue
FROM ecommerce_project
WHERE InvoiceNo NOT LIKE 'C%'
GROUP BY StockCode, Description
ORDER BY Total_Revenue DESC;

/*----------------------------------------------
QUICK INSIGHTS:

  - Fact: The most revenue comes from 'DOTCOM POSTAGE' (206248.77)	
        : Some non-product like 'Manual' and 'Postage' are also in the top 10 revenue. 
        : 'REGENCY CAKESTAND 3 TIER' is the #1 physical product in revenue (174484.74).

  - Insight: 
    1. Data Distortion: A huge amount of revunue is actually come from postage and
       manual action, not the product sales.
    2. Product Performance: 
      - 'Cakestand' is a Superstar: High Frequency (Top 3) AND High Revenue (Top 1).
      - 'PAPER CRAFT, LITTLE BIRDIE': Not in Top 10 Frequency but #3 in Revenue.
       => This is a "High-Ticket Item" (High Price/High Volume per order).

  - Action: Exclude non-product like 'Manual' and 'Postage' (DOT, M,) in the Clea.ning 
    section to calculate true product revenue
  -------------------------------------------*/     

-- 4. Order frequency by day of week, hour
-- GOAL: Identify the peak trading time
SELECT 
  DATENAME(weekday, InvoiceDate) day_of_week,
  DATEPART(hour, InvoiceDate) as Hour_of_day,
  COUNT (DISTINCT InvoiceNo) AS Total_Order
FROM ecommerce_project
WHERE InvoiceNo NOT LIKE 'C%'
GROUP BY
  DATENAME(weekday, InvoiceDate),
  DATEPART(hour, InvoiceDate)
ORDER BY Total_Order DESC;

/*----------------------------------------------
QUICK INSIGHTS:

  - Fact: The most frequent orders are from Wednesday at noon (668).
        : Top 10 slots are Mid-week (Tue-Thu) and Lunchtime (11 AM - 3 PM).

  - Insight: 
    1. Customers shopping mostly during work hours/lunch breaks.
    2. The absence of Weekend slots in Top 10 reinforces the B2B/Wholesaler 
       nature of the business (Businesses are closed on weekends).

  - Action: 
    1. Marketing: Schedule Email Campaigns/Auto Message to be sent at 10:00 AM - 11:00 AM 
       (1 hour before peak) to maximize Open Rates during lunch.
    2. Tech: Avoid system maintenance during 12:00 PM - 3:00 PM on weekdays.
  -------------------------------------------*/   
GO
  ------------------------------------------------
-- C. CLEANING DATA
-- GOAL: Remove invalid records to prepare clean dataset for analysis
-- METHOD: Create a new table 'Cleaned_Ecommerce' to store clean data
-- ---------------------------------------------
-- 1. Remove cancellations
-- 2. Remove returns
-- 3. Remove non-product codes
-- 4. Standardize product descriptions
IF OBJECT_ID('Cleaned_Ecommerce', 'U') IS NOT NULL 
   DROP TABLE Cleaned_Ecommerce; 
GO
SELECT *
INTO Cleaned_Ecommerce
FROM ecommerce_project
WHERE 
  InvoiceNo NOT LIKE 'C%'
  AND Quantity > 0
  AND StockCode NOT IN (
    'POST', 'DOT', 'M', 'C2', 'D', 'S', 
    'BANK CHARGES', 'AMAZONFEE', 'CRUK', 'B')
  AND StockCode NOT LIKE 'gift_%'
  AND Description IS NOT NULL
  AND CustomerID IS NOT NULL

/* -----------------------------------------------------------
CLEANING REPORT: 
GO
   SELECT 
    (SELECT COUNT(*) FROM ecommerce_project) AS Original_Rows,
    (SELECT COUNT(*) FROM Cleaned_Ecommerce) AS Cleaned_Rows,
    (SELECT COUNT (*) FROM ecommerce_project) - (SELECT COUNT(*) FROM Cleaned_Ecommerce) AS Removed_Rows,
    CAST(((SELECT COUNT (*) FROM ecommerce_project) - (SELECT COUNT(*) FROM Cleaned_Ecommerce)) 
    * 100.0 / (SELECT COUNT (*) FROM ecommerce_project) AS DECIMAL(10,2)) AS Perc;
  --------------------------------------------------------------
  1. Original rows : 541,909 rows
  2. Cleaned rows  : 396,374 rows
  3. Removed       : 145,535 rows
  --------------------------------------------------------
   => INSIGHT: The cleaning process eliminated 26.86% of the raw data.
      This ensures that subsequent analysis is performed only on 
      high-quality records.
  ----------------------------------------------------------- */
GO
------------------------------------------------
-- D. SHAPING DATA (MARKET BASKET ANALYSIS)
-- GOAL: Find products that are frequently bought together.
-- METHOD: Self-Join technique to calculate Co-occurrences.
---------------------------------------------
-- 1. Create order-product matrix
-- 2. Calculate product pair co-occurrences by joining orders on InvoiceNo
-- *For example, if an order contains products A, B, and C, joining on InvoiceNo generates pairs (A, B), (A, C), and (B, C) for that transaction.*
; WITH Order_item AS (
    SELECT DISTINCT
      InvoiceNo,
      StockCode
    FROM Cleaned_Ecommerce
),
Product_pair AS (
  SELECT
    t1.StockCode AS Product_A,
    t2.StockCode AS Product_B,
    COUNT(*) AS Frequency -- count how many time 2 product appear at the same time
  FROM Order_item t1
  JOIN Order_item t2 ON t1.InvoiceNo = t2.InvoiceNo
  WHERE t1.StockCode < t2.StockCode
  GROUP BY t1.StockCode, t2.StockCode
)
SELECT TOP 20
  Product_A,
   (SELECT MAX(Description) FROM Cleaned_Ecommerce WHERE StockCode = P.Product_A) AS Desc_A,
  Product_B,
  (SELECT MAX(Description) FROM Cleaned_Ecommerce WHERE StockCode = P.Product_B) AS Desc_B,
  P.Frequency
FROM Product_pair P
ORDER BY Frequency DESC;

/*----------------------------------------------
QUICK INSIGHTS:

  - Fact: The top 20 are product variant (same product-different color).
    For example: 'JUMBO BAG PINK POLKADOT' and  'JUMBO BAG RED RETROSPOT' (546).

  - Insight: 
    1. Collection behavior: Customer prefer buying full set of the same product
       instead of functional item (Grean Teacup & Roses Teacup).
    2. Lunch bag hub: Lunch bag appear multiple times in top 20, indicating a 
       strong addictive product line.

  - Action: 
    1. Business action: Shift from 'cross-selling' to 'bundling'.
       Create 'Collection packs' like 'full set of alarm clock'.
    2. Technical action: Frequency is high but we must calculate Support, Confidence, Lift 
      metric to ensure this is statistically significant, not just due to high volume.
  -------------------------------------------*/   
GO
-- 3. Calculate Support, Confidence, Lift for top pairs
-- Support: The popularity of the item pair across the entire set of invoices/transactions.
-- Confidence: If A is purchased, what is the % chance that B is purchased? (Conditional probability).
-- Lift (Most Important): The strength of the association.
---- Lift > 1: Golden pair (Should be bundled/cross-sold).
---- Lift = 1: No relationship (Independent).
---- Lift < 1: Negative correlation/Substitutes (Buying this implies avoiding that).
-- GOAL: Measure the strength of the relationship

IF OBJECT_ID('tempdb..#Product_Stats') IS NOT NULL DROP TABLE #Product_Stats;
IF OBJECT_ID('tempdb..#Pair_Stats') IS NOT NULL DROP TABLE #Pair_Stats;

--Calculate Total Orders
DECLARE @Total_Orders DECIMAL(10,2); 
SELECT @Total_Orders = COUNT(DISTINCT InvoiceNo) FROM Cleaned_Ecommerce;

-- Calculate Frequency Individual and store in temp table #Product_Stats
SELECT 
    StockCode, 
    COUNT(DISTINCT InvoiceNo) AS Freq_Individual
INTO #Product_Stats 
FROM Cleaned_Ecommerce
GROUP BY StockCode;

--Calculate Pairing number and store in temp table #Freq_Pair
; WITH Order_List AS (
    SELECT DISTINCT InvoiceNo, StockCode
    FROM Cleaned_Ecommerce 
)
SELECT 
    T1.StockCode AS Product_A,
    T2.StockCode AS Product_B,
    COUNT(*) AS Freq_Pair 
INTO #Pair_Stats 
FROM Order_List T1
JOIN Order_List T2 ON T1.InvoiceNo = T2.InvoiceNo 
WHERE T1.StockCode < T2.StockCode 
GROUP BY T1.StockCode, T2.StockCode
HAVING COUNT(*) >= 20; 

-- Calculate the Support, Confidence and Lift Metrics
SELECT TOP 100
    P.Product_A,
    (SELECT MAX(Description) FROM Cleaned_Ecommerce WHERE StockCode = P.Product_A) as Name_A, 
    P.Product_B,
    (SELECT MAX(Description) FROM Cleaned_Ecommerce WHERE StockCode = P.Product_B) as Name_B, 
    CAST((P.Freq_Pair * 100.0 / @Total_Orders) AS DECIMAL (10,2)) AS [Support %],
    CAST((P.Freq_Pair * 100.0 / S1.Freq_Individual) AS DECIMAL (10,2)) AS [Confidence %],
    CAST((P.Freq_Pair * 100.0 / S1.Freq_Individual) / (S2.Freq_Individual * 100.0 / @Total_Orders) 
    AS DECIMAL(10,2)) AS Lift
FROM #Pair_Stats P
JOIN #Product_Stats S1 ON P.Product_A = S1.StockCode
JOIN #Product_Stats S2 ON P.Product_B = S2.StockCode
ORDER BY Lift DESC;

/*----------------------------------------------
QUICK INSIGHTS:

  - Fact: Top 20 are extremely high Lift score (>250) and high Confidence (>50%).
    Example('PINK KNITTED EGG COSY' + 'BLUE KNITTED EGG COSY' have 88% Confidence and Lift at 647.86).

  - Insight: 
    1. Inseparable product: A Lift of reaching ~ 650 are extremely rare. Indicating these purchase are
       excusively purchasing together rather than individually.
    2. Collection behavior: The strongest connection are appear in Kitchen Tools and Wall art, confirming
       the full combo collection psychology.

  - Action: 
    1. Merchandising: Create a bundling (example: Pantry full combo set) to increase AOV.
    2. UX Optimization: Implement "Smart Recommendations" in the cart.
      Suggesting Item B when A is added is a guaranteed way to boost conversion without being intrusive.
  -------------------------------------------*/   
GO 
-- E. ANALYZING DATA
-- GOAL: Extract key product, customer, and geographical insights to drive business strategy.
-- METHOD: Apply Association Rule Mining metrics (Lift, Confidence and Support) and perform customer segmentation.
---------------------------------------------
-- 1. Identify top 10 product pairs by Lift
DECLARE @Total_Orders DECIMAl (10,2)
SELECT @Total_Orders = COUNT (DISTINCT InvoiceNo) FROM Cleaned_Ecommerce;

SELECT TOP 10
  P.Product_A,
  (SELECT MAX(Description) FROM Cleaned_Ecommerce WHERE StockCode = P.Product_A) as Name_A, 
  P.Product_B,
  (SELECT MAX(Description) FROM Cleaned_Ecommerce WHERE StockCode = P.Product_B) as Name_B, 
  CAST((P.Freq_Pair * 100.0 / S1.Freq_Individual) AS DECIMAL (10,2)) AS [Confidence %],
  CAST((P.Freq_Pair * 100.0 / S1.Freq_Individual) / (S2.Freq_Individual * 100.0 / @Total_Orders) 
  AS DECIMAL(10,2)) AS Lift
FROM #Pair_Stats P
JOIN #Product_Stats S1 ON P.Product_A = S1.StockCode
JOIN #Product_Stats S2 ON P.Product_B = S2.StockCode
ORDER BY Lift DESC;

  /* -----------------------------------------------------------
   QUICK INSIGHTS (LIFT ANALYSIS - TOP PAIRS):

   - Fact: 
     1. Top 10 have high LIFT scores (>300) and very high Confidence (>60%).
     2. The #1 pair 'PINK/BLUE KNITTED EGG COSY' has a Lift of ~648 and 88% Confidence.
     3. Other top pairs are mostly "Series Collections" (e.g., Pantry Hooks, Wall Art Gents/Ladies).
     
   - Insight: 
     1. "The Variation Effect": Customers are NOT cross-shopping different categories 
        (e.g., Beer + Diapers). They are buying variations of the same item.
     2. "Set Completion Psychology": The high Lift in 'Pantry Hooks' (Rows 2,3,4) proves 
        customers feel compelled to collect the full functional set for aesthetic consistency.
        
   - Action: 
     1. Product Strategy: Create "Variant Bundles" immediately. 
        (Ex: Sell "Twin Pack Egg Cosy" or "Full Kitchen Tool Set" instead of single items).
     2. UX Recommendation: On the product page of "Pantry Hook Spatula", add a 
        "Complete the Look" section showing the Strainer and Whisk.
   ----------------------------------------------------------- */

-- 2. Find products with highest cross-sell potential
SELECT TOP 10
  Product_A AS Driven_Product,
  (SELECT MAX(Description) FROM Cleaned_Ecommerce WHERE P.Product_A = StockCode) AS Product_name,
  COUNT( DISTINCT Product_B) AS Number_of_connection
FROM #Pair_Stats P
GROUP BY Product_A
ORDER BY Number_of_connection DESC;

/* -----------------------------------------------------------
   QUICK INSIGHTS (CROSS-SELL POTENTIAL - HUB PRODUCTS):
   
   - Fact: 
     1. 'LUNCH BAG RED SPOTTY' is the #1 products with highest cross-sell potential
         (with 724 different types of items).
     2. The "Lunch Bag" category dominates the Top 10 list (occupying 4 positions).
     
   - Insight: 
     1. "The Gateway Product": Lunch Bags are versatile and low-cost. 
        They act as universal add-ons that customers easily throw into the cart 
        regardless of what else they are buying (Home decor, Stationery, or Gifts).
     2. "Pattern Consistency": The presence of 'RETROSPOT CAKE CASES' (#2) and 
        'RED SPOTTY BOWLS' (#6) confirms that the "Red Spotty" pattern is a 
        massive cross-category connector.
        
   - Action: 
     1. Traffic Driver: Feature the "Lunch Bag Collection" on the Homepage as a 
        traffic anchor (since they appeal to the widest range of baskets).
     2. Checkout Optimization: Use these Top 10 items as "Cart Fillers". 
        If a customer is close to the Free Shipping threshold, suggest a Lunch Bag 
        (high probability of acceptance due to its universal compatibility).
   ----------------------------------------------------------- */

-- 3. Segment baskets: small (1-2 items), medium (3-5), large (6+)
-- GOAL: Understand customer buying habits (Do they buy just 1 item or a whole cart?)
; WITH Basket_Stats AS (
    SELECT 
      InvoiceNo, 
      COUNT(DISTINCT StockCode) AS Unique_Items, 
      SUM(Quantity * UnitPrice) AS Basket_Value  
    FROM Cleaned_Ecommerce
    GROUP BY InvoiceNo
)
SELECT 
    CASE 
      WHEN Unique_Items BETWEEN 1 AND 2 THEN 'Small (1-2 items)'
      WHEN Unique_Items BETWEEN 3 AND 5 THEN 'Medium (3-5 items)'
      ELSE 'Large (6+ items)' 
    END AS Basket_Size,
    COUNT(InvoiceNo) AS Total_Orders,
    CAST(COUNT(InvoiceNo) * 100.0 / (SELECT COUNT(*) FROM Basket_Stats) AS DECIMAL(10,2)) AS [Percent %],
    CAST(AVG(Basket_Value) AS DECIMAL(10,2)) AS Avg_Basket_Value
FROM Basket_Stats
GROUP BY 
    CASE 
      WHEN Unique_Items BETWEEN 1 AND 2 THEN 'Small (1-2 items)'
      WHEN Unique_Items BETWEEN 3 AND 5 THEN 'Medium (3-5 items)'
      ELSE 'Large (6+ items)' 
    END
ORDER BY Avg_Basket_Value DESC; 

/* -----------------------------------------------------------
   QUICK INSIGHTS (BASKET SIZE SEGMENTATION):
   
   - Fact: 
     1. "Large Baskets" (6+ unique items) dominate the business, accounting for 
        ~78.5% of total orders (14,446 orders).
     2. "Small" & "Medium" baskets only contribute ~21% combined.
     3. Large Baskets have the highest AOV (~513), which is ~50% higher than 
        Small/Medium baskets (~333-348).
     
   - Insight: 
     1. "The Wholesale Proof": In typical B2C retail, small baskets (1-2 items) 
        are the majority. Here, the dominance of Large Baskets (78%) confirms 
        customers are mostly Resellers or Event Organizers stocking up on variety.
     2. "Variety Drives Value": The high AOV in Large Baskets suggests that 
        encouraging customers to explore more categories (cross-selling) is 
        more effective than just increasing quantity of a single item (upselling).
          
   - Action: 
     1. UI/UX Strategy: Optimize for "Bulk Ordering". 
        Add features like "Quick Order Form" or "Reorder Previous Basket" 
        to help these large-basket customers checkout faster.
     2. Promotion: Stop "Buy 1 Get 1". Switch to "Spend & Save" (e.g., Save $50 
        on orders with 10+ distinct items) to reward the natural behavior of buying variety.
   ----------------------------------------------------------- */

-- 4. Compare patterns between countries
SELECT TOP 10
  Country,
  COUNT(DISTINCT InvoiceNo) AS Total_Orders,
  CAST(SUM(Quantity * UnitPrice) AS DECIMAL(10,2)) AS Total_Revenue,
  CAST(SUM(Quantity * UnitPrice) / COUNT(DISTINCT InvoiceNo) AS DECIMAL (10,2)) AS AOV
FROM Cleaned_Ecommerce
GROUP BY Country
ORDER BY Total_Revenue desc;

/*----------------------------------------------
QUICK INSIGHTS:

  - Fact: 
    1. The UK dominates in volume (16,581 orders) but has a relatively LOW 
       Average Order Value (AOV ~ 438).
     2. International markets have fewer orders but massive AOV.

  - Insight: 
    1. "Retail vs. Wholesale" Behavior: 
        - UK Market = B2C (Retail): Locals buy smaller amounts frequently 
          because shipping is cheap/fast.
        - International Market = B2B (Wholesale): Customers buy in bulk 
          to justify high cross-border shipping costs.

  - Action: 
    1. UK Strategy: Focus on "Retention" (Loyalty Programs) to increase purchase frequency.
    2. International Strategy: Focus on "Logistics Support" & "Bulk Discounts" 
       to incentivize these high-value partners to import even more.
  -------------------------------------------*/   
GO
------------------------------------------------
-- F. DASHBOARD DATA SOURCES (FINAL OUTPUT)
-- GOAL: Create the final, consolidated Data Source queries for Scorecards and 
     --  Dashboard Charts that have not include in the queries above
---------------------------------------------
-- 1. Total Revenue (Scorecard Metric)
SELECT 
    SUM(Quantity * UnitPrice) AS Total_Revenue
FROM Cleaned_Ecommerce;

-- 2. Overall AOV (Scorecard Metric)
SELECT
    SUM(Quantity * UnitPrice) / COUNT(DISTINCT InvoiceNo) AS Overall_AOV
FROM Cleaned_Ecommerce;

-- 3. Core Volume Metrics (Scorecard Metrics)
SELECT
    SUM(Quantity) AS Total_Unit_Sold,
    COUNT(DISTINCT StockCode) AS Unique_Product,
    COUNT(DISTINCT InvoiceNo) AS Total_Order
FROM Cleaned_Ecommerce;

-- 4. Revenue Trend and Daily Metrics
 SELECT
    CAST(InvoiceDate AS DATE) AS Date,
    Country,
    COUNT(DISTINCT InvoiceNo) AS Total_Orders,
    COUNT(DISTINCT CustomerID) AS Active_Customers,
    SUM(Quantity * UnitPrice) AS Revenue,
    SUM(Quantity * UnitPrice) / COUNT(DISTINCT InvoiceNo) AS AOV
FROM Cleaned_Ecommerce
GROUP BY CAST(InvoiceDate AS DATE), Country
ORDER BY 1 DESC;

-- 5. Top 10 Best Seller
SELECT TOP 10
    StockCode,
    Description,
    SUM(Quantity) AS Item_Sold
FROM Cleaned_Ecommerce
GROUP BY StockCode, Description
ORDER BY Item_Sold DESC;

-- 6. Products Sales By Month (Seasonal Line Chart)
SELECT 
    DATEPART(Month, InvoiceDate) AS Month,
    Description,
    SUM(Quantity) AS Item_Sold
FROM Cleaned_Ecommerce
GROUP BY DATEPART(Month, InvoiceDate), Description
ORDER BY Item_Sold DESC;

