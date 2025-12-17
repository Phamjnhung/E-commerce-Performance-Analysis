# E-commerce-Performance-Analysis
Data analysis project focusing on Market Basket Analysis, cross-selling and bundling strategy using SQL and Looker Studio for visualization   
## 📊 About Dataset
This is Online Transactional Data from company primarily based in the United Kingdom (UK).
- **Link Dataset (Original Source):** [Dataset](https://drive.google.com/file/d/18WGYMmuTrGOCmhVGXZ35i8FE2WNwQ96N/view?usp=sharing)
- **Rows (Raw):** 541,909
- **Column Details**: The dataset contains 8 core columns, categorized as follows:
    * **`InvoiceNo`** (6-digit string): Invoice number. If the code starts with 'C', it indicates a cancellation or refund.
    * **`StockCode`** (5-digit string): Product code used as the primary identifier per product.
    * **`Description`** (Text): The product name.
    * **`Quantity`** (Integer): The number of units purchased. Negative values represent returns.
    * **`UnitPrice`** (Decimal): The price per unit (assumed to be in US Dollars for final reporting).
    * **`InvoiceDate`** (Timestamp): The date and time the transaction occurred (Format: MM/DD/YYYY HH:MM).
    * **`CustomerID`** (5-digit integer): Customer identifier.
    * **`Country`** (Text): The customer's country of residence.
-   **Time Range:** 2010/12/01 - 2011/12/09 (Total 373 days)
## 📈 Interactive Dashboard
This project also include an interactive dashboard for exploring data.  
You can preview it right below and click into the link for a live version.

<img width="973" height="839" alt="image" src="https://github.com/user-attachments/assets/bb80e7ce-6313-46fb-ae19-e1b1b117755b" />

[🔗View Live Dashboard](https://lookerstudio.google.com/reporting/afbc812a-137b-4dfc-85ff-7df9fa464cd1)
## 🎯 Business Goals & Problem Solved
**1. Section 1: Executive Overview**  
**2. Section 2: Product Ecosystem & Bundling**
- **Size:** What is the average basket size (items per order)?
- **Rank:** Which product pairs have the most repeated purchased rates?
- **Explain:** What drives customers to buy specific products together?
- **Compare:** How do purchase patterns vary by country or time period?
- **Recommend:** Which 5 product bundles should we create to maximize Average Order Value (AOV)?
## ⚙️ Methodology
The project have **5-Stage Analysis** using a structured data pipeline:

### 1. Data Pipeline & Tools
* **Data Extraction & Preparation:**
   * **SQL Server 2019 (T-SQL):** Querying, cleaning, and aggregating raw e-commerce data.
   * **Azure Data Studio:** Environment for executing queries and managing the database.
* **Data Analysis:**
   * **T-SQL:** Exploratory Data Analysis (EDA) and ad-hoc queries
   * **Excel / Google Sheets:** Performing additional data validation and quick quality checks.
* **Data Visualization:**
   * **Azure Data Studio (Chart Viewer):** Quick visual insights and ad-hoc data profiling during the EDA phase.
   * Looker Studio:** Creating interactive dashboards for business stakeholders to track. 
### 2. The 5-Stage Analysis using in this project
* **A. Exploring Data:** Validating the time range, total volume, and identifying early warnings (e.g., nulls in `CustomerID`, high cancellation rate).
* **B. Profiling Data:** Deeper investigation into data characteristics, such as Basket Size Distribution and identifying non-product codes in top revenue charts.
* **C. Cleaning Data:** Removing invalid records based on profiling results (Cancellations, returns, non-product codes) to create the `Cleaned_Ecommerce` dataset.
* **D. Shaping Data:** The critical step involving the **SQL Self-Join** technique to create the product co-occurrence matrix for MBA.
* **E. Analyzing Data:** Deriving strategic insights by calculating **Lift**, identifying Hub Products (Cross-sell and bundling potential), and segmenting baskets/countries.
## 🧮 Calculated Metrics
* **Line Total (Revenue):** `Quantity` * `UnitPrice`
* **Total Revenue:** SUM(`Quantity` * `UnitPrice`)
* **Average Order Value (AOV):** Total Revenue / COUNT(DISTINCT `InvoiceNo`)
* **Orders per Customer:** COUNT(DISTINCT `InvoiceNo`) / COUNT(DISTINCT `CustomerID`)
* **Support (A):** Orders containing Product A / Total Orders
* **Support (A, B):** Orders containing both A and B / Total Orders
* **Confidence (A → B):** Support(A, B) / Support(A)
* **Lift (A, B):** Support(A, B) / (Support(A) * Support(B))
   * **Lift > 1:** Positive association (Items bought together more than expected).
   * **Lift = 1:** No association.
   * **Lift < 1:** Negative association (Substitutes).
(For eg: Lift (A, B) = 5 means the customer buying product A have 5 times higher potential to buy product B than normal customer)​
## 📝Dashboard Analysis and Recommendations.
### I. Executive Overview  
#### Overall business health based on core KPIs
<img width="1631" height="104" alt="image" src="https://github.com/user-attachments/assets/83c2c773-0875-41e2-8dbd-cf3dac2f2661" />
The business stand a strong financial position with a a total revenue of £8.76M. The overall efficiency is driven by a high Average Order Value of £467 and strong 8.5 orders per customer. This KPIs indicate a strong position of a business in the market with a high engaged of customer.  

* **Total Revenue**: £8.76M generated from 18.1K total orders. <br>
* **Customer Engagement**: The high orders per customer of 8.5 indicates the loyalty of customer to the brand. <br>
* **Basket Value**: An AOV of £476 reflects strong purchasing power or effective product bundling strategies. <br>

#### Revenue Composition: New vs Returning Customers
<img width="572" height="438" alt="image" src="https://github.com/user-attachments/assets/88d17853-09cc-4c40-8522-146c5d66e1e5" />

While the card tell about the average of 8.5 orders, the pie chart tell us a deeper story with 79.2% of total revenue are returning customer - a true engine of growth.  

* **Retention Strength**: Returning customers accounted for 292,649 orders, generating £6.93M in revenue.
* **New Customer**: New customers contributed £1.82M through 103,725 orders, serving as the essential entry point for the returning.
* **The "8.5" Reality**: This high average is heavily skewed by a repeated buyers. New customers naturally start at a score of 1.0, while the high volume of returning transactions pulls the overall average upward.

#### Geographic Performance 
<img width="1040" height="438" alt="image" src="https://github.com/user-attachments/assets/1094c072-2d84-41ba-b0fa-cef2afc42fff" />

While the United Kingdom lead in revenue and order volume, international markets like the Netherlands and Australia have a massive opportunity due to their significantly higher Average Order Value (AOV). This indicates that while we have volume in the UK, our international customers are the bigger spender.

* **Market Dominance**: The United Kingdom remains the primary market, contributing £7.3M (over 80% of total revenue) through 16.6K orders.
* **The bigger spender**: Netherlands and Australia lead in AOV with £3K and £2.5K respectively - nearly 6x higher than the UK average of £438.2.
* **Efficiency Gaps**: Markets like Japan (£2K AOV) and Switzerland (£1.1K AOV) show high potential but suffer from low order volume (under 50 orders), indicating a need for better localized marketing.

#### Revenue Seasonality & Growth Trends
<img width="943" height="587" alt="image" src="https://github.com/user-attachments/assets/10c8231e-31df-4b6a-adda-14bf635f78a0" />

The business shows a clear upward trend and experience a revenue peak during the final quarter (Q4). While the first half of the year remained relatively stable near the monthly average, the Q4 performance are outstanding, suggesting seasonal fit product or a year - end succesful campaigns.

* **Year-End growth**: Revenue grew dramatically starting in August 2011, reaching an all-time peak of over £1.1M in November 2011. This indicates that customer most likely to purchase actively during this holiday phase.
* **Performance vs Baseline**: Monthly revenue remained below the average of £673,928 for most of the first half of the year, with a notable dip in April 2011.

#### Peak Order Volume Hour
<img width="673" height="588" alt="image" src="https://github.com/user-attachments/assets/d2a2c6dc-e633-4815-91c5-891c88bc5f21" /> <img width="677" height="584" alt="image" src="https://github.com/user-attachments/assets/1f8b77af-e66d-40ec-9a12-9ec201d5953e" />

The order volume likely to peak at mid-day and mid-weak. Unlike typical B2C retail that peaks in the evenings or weekends, the business sees a massive purchasing power during standard business hours, on Thursday afternoons, suggesting a strong B2B or professional buyer persona.

* **Weekly Peak Performance**: Thursday is the highest-volume day with 4,690 orders, followed by Wednesday (4,142) and Tuesday (3,973). While Sunday shows the lowest engagement with only 2,207 orders, nearly 50% lower than mid-week peaks.
* **Hourly Peak Performance**: Volume increase significantly between 10 AM and 3 PM, with 12 PM marking the absolute daily peak at 3,464 orders.
* **Evening Drop-off**: Activity nearly vanishes after 5 PM, with orders dropping from 901 to just 18 by 8 PM.

#### 🔑 Recommendation for better business performance
Based on the complete dashboard analysis, I recommend the following four-pillar strategy to maximize business performance:

**1. Take advantage of peak hour window:**
Since orders peak in the mid-day hour, between 10 AM – 3 PM (Tuesday to Thursday), all promotional emails, "Flash Sale" announcements, and customer support staff should be concentrated in this window. Avoid technical maintainance and customer support error at this window. 

**2. Target the country with high AOV for Seasonal Peaks**
With a huge revenue surge in November (£1.1M+), we should launch a discount or bulk buying campaigns in the bigger spender country like the Netherlands (£3K AOV) and Australia (£2.5K AOV) starting in September to maximizing the total revenue.

**3. Protect the "UK Core" through Retention**
The United Kingdom lead in volume  with 16.6K orders and given high 8.5 Order/Customer frequency that must be protected this base. I recommend a to make a loyalty program for UK customers that rewards them for reaching the "8th order" milestone to solidify this behavior.

**4. Turn New Shoppers into Loyal Customer**
Right now, the most loyal customers are the main engine, bringing in £6.9M compared to a much smaller amount from first-time buyers. To keep the business growing, the business need to use the busy end-of-year shopping season to attract new people and immediately give them a reason to come back. By offering voucher  like a 30-day "Thank You" discount right after their first purchase, the business can turn a one-time shopper into a regular customer, which is where the profits increase.

### II. Product Ecosystem & Bundling
#### Product core KIPs
<img width="701" height="138" alt="image" src="https://github.com/user-attachments/assets/3a1a6a0e-dec3-4298-85d0-85c6c8cb0455" />

The product ecosystem shows a high-volume, high-variety operation. With millions of units moving across thousands of unique products, the business demonstrates significant operational scale and a deep catalog that caters to a wide range of customer needs.

* **Total Units Sold (5.2M)**: This massive volume reflects the sheer scale of the operation and suggests a high inventory turnover rate.
* **Product Diversity (3.7K Unique Products)**: Offering 3,700 unique items indicates a broad market appeal and a complex supply chain capable of managing a diverse SKU portfolio.
* **Average Items Per Order (AIPO - 281)**: A staggering 281 items per order strongly confirms our previous hypothesis of a B2B (Business-to-Business) or wholesale model. These are not individual consumers; these are likely distributors or retailers buying in bulk.

#### Top 10 Revenue Contributors
<img width="778" height="406" alt="image" src="https://github.com/user-attachments/assets/ccbcab35-fab8-4389-904d-6608ad6bc1e1" />

The product ecosystem is led by a few high-performance items that generate significant portions of the £8.76M total revenue. While our catalog is diverse, revenue is concentrated in key decorative and household categories, led by a single outlier in paper crafts.

* **The Revenue Leader**: "PAPER CRAFT, LITTLE BIRDIE" is our top-performing item, generating £168.5K from 80,995 units sold.
* **High-Margin Favorites**: The "REGENCY CAKESTAND 3 TIER" follows closely with £142.6K, despite moving significantly fewer units (12,412) than other top items, indicating a much higher price point per unit.
* **Volume Drivers**: Items like the "WHITE HANGING HEART T-LIGHT HOLDER" (£100.4K) and "JUMBO BAG RED RETROSPOT" (£85.2K) maintain high visibility, with the latter moving 46,181 units.
* **The Long Tail of Success**: The top 10 list concludes with the "PAPER CHAIN KIT 50'S CHRISTMAS" at £42.7K, showing that even seasonal or specific kit items contribute substantially to our revenue goals.

#### Revenue Distribution
<img width="583" height="409" alt="image" src="https://github.com/user-attachments/assets/aa478271-af2c-45b9-9c4d-926b62bb367c" />

The donut chart reveals that our revenue is not top-heavy; instead, it relies on a broad base of products. While "Star" products drive individual success, the sheer volume of our extended catalog is the primary engine for the £8.76M total revenue.
* **Group C (Low Value/Tail) – 54.5%**: This group is the dominant revenue contributor, representing more than half of our total sales. It highlights a high-volume, low-margin wholesale model where profitability comes from moving vast quantities of smaller items.
* **Group B (Steady Support) – 36.9%**: This segment provides a solid foundation of reliable revenue, likely consisting of evergreen staples that keep customers returning to the platform.
* **Group A (Strategic Core) – 8.6%**: While this group represents the smallest revenue share, these are likely our highest-margin "hero" products, such as the Regency Cakestand, which drive brand prestige and high-ticket sales.

#### Bundling Opportunities
<img width="1241" height="512" alt="image" src="https://github.com/user-attachments/assets/6e72742a-a6d3-4246-ab5b-353f3feb851d" />

The first chart is a Market Basket Analysis visualization. It hepls to make decide of which product should be bundled together or place near each other bassed on customer behavior to boost revenue. This chart use three key metrics - **Confidence** (how often item B follows item A) with **Lift** (the strength of the relationship) and the bubble size represents **Support** (total transaction frequency), they are categorized into four distinct quadrants.


* **Golden Pairs (High Confidence/High Lift)**: These are the strongest associations => Protect these margins. Use them as the foundation for bundles combo that frequency bought together.
* **Hidden Gems (Low Confidence/High Lift)**: Strong logical ties but low current conversion => High-potential cross-sell area. Provide a marketing strategy through targeted "You May Also Like" recommendations.
* **Opportunity (High Confidence/Low Lift)**: Common pairings, often involving staples => Use these for volume-based promotions or to drive traffic to specific aisles.
* **Low Priority (Low Confidence/Low Lift)**: Weak associations => Avoid bundling these; they do not statistically influence each other’s sales.

The table beside is a recommendation for Top 10 High-Lift pairs product that can be consider bundling based on their High Lift and High Confidence percentage. One interesting finding is customer likely to collect the full set of a product (For eg: same product in different color or different size) so create a bundling set is the great strategy to fullfill collecting behavior of the buyer.
#### 🔑 Recommendation for maximizing revenue
Based on the complete dashboard analysis, I recommend the following three-pillar strategy to maximize business performance:

* **1. Scalable Bundling for Wholesale Volume:**
With an Average Items Per Order (AIPO) of 281, customers are already buying in bulk. To make it even better, creating bundles combo for the top 5 pairs (As recommended in the table) and offering a 10% discount on these bundles will simplify the checkout process for high-volume B2B buyers and increase the velocity of "Golden Pairs."

* **2. Data-Driven user experience:**
To convert "Hidden Gems" into "Golden Pairs," add a 'Frequently Bought Together' section on product pages showing the best combinations. Additionally, optimize the homepage layout to place products with higher Lift near each other to make customer have an urge to by pairing them. Moreover, a recommending emails right before the peak hour window would be a great idea to keep the brand in customer mind during busy mid-week.
  
* **3. Margin Optimization through A/B Testing:**
While Group C (Low Value) drives 54.5% of the revenue, the business must protect the margins of Group A. During the November peak (£1.1M surge), the business should A/B test bundle pricing to find the optimal discount that maximizes total revenue. This ensures we aren't "leaving money on the table" during the highest-traffic months.
# Conclusion

In this project I turn a basic number, transforming over 500,000 raw transactional records into business insight that usefull for making decision. Through the Market Basket Analysis (MBA) and a structured 5-stage data pipeline, I have demonstrated the ability to:

* **Bridge the gap between Data and Story:** I dont treat number as it surface but dig deeper to understand what the story present for that and I am not just reporting the plain number, but explaining why and recommend what to do next.
* **Optimize Revenue Channels:** To be specific, by this data source I found out the meaning behind every number and recommendations for bundling strategies and peak-hour marketing to 'High-Ticket' Country that directly impact AOV and customer retention.
* **Good use in Technical Workflows:** 
   * **SQL:** Efficiently handled large datasets using T-SQL (Self-joins, CTEs, and Data Cleaning).
   * **Visualization:** Developed an interactive Looker Studio that help Stakeholder give better decision by transforming complex datasets into intuitive strategic landscapes, allowing stakeholders to shift from just viewing data to identify the context.
   * **Storytelling:** Translating complex findings into simple, actionable insights. I focus on making data easy to understand for everyone (even non-business person), ensuring that the findings lead to clear business decisions rather than just being a collection of charts.
