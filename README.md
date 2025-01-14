# Customer Segmentation and Retention in Insurance

This project focuses on segmenting customers based on factors such as age, vehicle age, and discount combinations to identify patterns in premiums and loss ratios. The insights from this segmentation help in developing targeted policies and discount strategies tailored to different customer groups.

Additionally, the project analyzes customer retention by examining churn rates and patterns to inform retention strategies aimed at reducing account terminations and maintaining long-term customer relationships.

> **Note:** The data used in this project is mock data and may not accurately reflect real-world scenarios.

---

# **Process**

## **Session 1: Importing Data Files**
- Imported fixed-width `.txt` files to process credit-ordering data using wildcards, macros, and `FILENAME` statements.  
- Loaded geographic data files.  
- Imported loss payment and vehicle information tables from Access. To optimize storage and processing in SAS, I reduced variable lengths in Access before using `PROC IMPORT` to load the data into SAS.

**Data Cleansing and Validation:**  
- Removed duplicate records.  
- Processed credit files to ensure only principal drivers were included for each policy number.  
- Validated first names, standardized data formats, and renamed variables for consistency.

---

## **Session 2: Data Validation and Manipulation**
- Verified provincial data using `DATA STEP`, `PROC SQL`, and `PROC FREQ`, focusing on Ontario records.  
- Identified premium outliers using `PROC UNIVARIATE` and calculated average premiums with `PROC MEANS`, `PROC SUMMARY`, `PROC SQL`, and `DATA STEP`.  
- Calculated term units and total exposure at both the policy and vehicle levels.  
- Created new variables to represent customer age (`age_band`) and vehicle age (`vehicle_age_band`).  
- Developed logic for targeted discount combinations.

---

## **Session 3: Data Manipulation**  
- Prepared summarized tables for final visualizations and reports.

---

## **Session 4: Data Visualization**  
- Generated churn rate reports for customer retention analysis.  
- Created visualizations to highlight customer segmentation trends.

---

# **Results**

## **Earned Premium and Loss Payment by Discount Combination**  
The chart below shows that the **"OCCU"** discount combination generated the highest earned premium, followed by **"OCCU SENI"**.

![disc_comb](https://github.com/user-attachments/assets/1ccab646-1b1a-48ae-a665-300285ea03ee)

---

## **Earned Premium and Risk by Age Group**  
The graph illustrates that customers aged **45–54** generated the most revenue, followed by those aged **35–44**. In contrast, the **25 and under** group contributed the least. Customers aged **26–34** presented higher risk, suggesting a need for targeted adjustments in policies for this group to reduce potential loss.

![rate_loss_age](https://github.com/user-attachments/assets/5eb8c555-d2f7-492a-ac27-3e4f2e862d28)

---

## **Earned Premium and Risk by Vehicle Age**  
The data shows that the highest revenue came from vehicles **less than 20 years old**. Vehicles aged **20–29 years** had a higher risk, suggesting the potential need for adjusted policy strategies to address this segment.

![rate_loss_car_age](https://github.com/user-attachments/assets/0581a05b-d2e1-429f-94e6-2ec5584bd9f0)

---

## **Earned Premium and Risk by Geographic Area**  
This graph shows that customers in the **K1G** area generated the highest revenue, followed by **K1C** and **K1K**. The **K0A** region had higher risk with lower revenue, indicating an opportunity for growth with targeted strategies.

![rate_loss_geo](https://github.com/user-attachments/assets/21110c8a-15b6-43b8-b4af-7db27dbc9ea1)

---

## **Monthly Account Terminations and Revenue (1996)**  
This graph illustrates monthly account terminations and associated revenue in **1996**. Most account closures occurred in **November** and **December**, with the highest premium values coming from accounts terminated in **October** and **November**.

![gbarlin1](https://github.com/user-attachments/assets/14dc2df7-14b9-40da-8f10-973e6c9abbe3)

---

## **Churn Rate Report**  
Most active accounts were in the **651 and above** credit group. Additionally, the highest churn rates in **November** and **December** suggest increased account terminations, particularly among higher credit groups late in the year.

![churn rate report](https://github.com/user-attachments/assets/8fc131ea-a007-4677-8859-108310c5369d)

---

# **Summary**

- **Key Revenue Segments:**  
  - Customers aged **45–54** and **35–44** contributed most to the company’s revenue.  
  - Vehicles **less than 20 years old** were the most profitable.  
  - The **OCCU** discount combination was the most effective in generating revenue.  

- **Risk Insights:**  
  - Customers aged **26–34** presented higher risk, suggesting targeted policy adjustments to mitigate potential loss.  
  - Vehicles aged **20–29 years** exhibited higher risk but represent an opportunity for tailored products.  
  - Geographic areas like **K0A** have higher risk but potential for growth with the right strategies.  

- **Customer Retention:**  
  - Account terminations peaked in **November** and **December**, particularly among customers with a credit score of **651 and above**.  
  - Targeted retention strategies could focus on high-credit customers to reduce churn.
