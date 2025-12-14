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

<img width="832" height="726" alt="image" src="https://github.com/user-attachments/assets/2751dadf-d0f3-44b4-a097-5993e1558cf1" />

[🔗View Live Dashboard](https://lookerstudio.google.com/reporting/afbc812a-137b-4dfc-85ff-7df9fa464cd1)
## 🎯 Business Goals & Problem Solved
**1. Section 1: Excutive Overview**
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
* **Data Analysis:**
* **Visualization & Dashboarding:** 
### 2. The 5-Stage Analysis using in this project
* **A. Exploring Data:** Validating the time range, total volume, and identifying early warnings (e.g., nulls in `CustomerID`, high cancellation rate).
* **B. Profiling Data:** Deeper investigation into data characteristics, such as Basket Size Distribution and identifying non-product codes in top revenue charts.
* **C. Cleaning Data:** Removing invalid records based on profiling results (Cancellations, returns, non-product codes) to create the `Cleaned_Ecommerce` dataset.
* **D. Shaping Data (Modeling):** The critical step involving the **SQL Self-Join** technique to create the product co-occurrence matrix for MBA.
* **E. Analyzing Data:** Deriving strategic insights by calculating **Lift**, identifying Hub Products (Cross-sell potential), and segmenting baskets/countries.
## 🧮 Calculated Metrics​

