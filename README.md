# Case Study #3 : Foode-Fi
<p align="center" style="margin-bottom: 0px !important;">
<img src="https://8weeksqlchallenge.com/images/case-study-designs/3.png" width="540" height="540">

---
*This repository hosts the solutions to the 3rd challenge (Week 3) of the 8 Weeks SQL Challenge by DannyMa. [Click here to view the full challenge](https://8weeksqlchallenge.com/case-study-3/)*

---
##  Table of Contents
- [Business Case](#business-case)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Available Data](#available-data)
- [Case Study Questions](#case-study-solutions)
- [Resources](#resources)

   
## Business Case
Subscription-based businesses are super popular and Danny realized that there was a large gap in the market - he wanted to create a new streaming service that only had food-related content - something like Netflix but with only cooking shows!

Danny found a few smart friends to launch his new startup Foodie-Fi in 2020 and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world!

Danny created Foodie-Fi with a data-driven mindset and wanted to ensure all future investment decisions and new features were decided using data. 
   
This case study focuses on using Foodie-Fi data; subscription-style digital data to answer important business questions that could help the startup an insight into critical business metrics relating to the customer journey, payment transactions, and overall business performance.
   
   
---
## Entity Relationship Diagram
<p align="center" style="margin-bottom: 0px !important;">
<img src="https://i.pinimg.com/originals/4f/68/13/4f68132267e06b7b6773d0b7addba209.png">
   
   
---
## Available Data
  
<details><summary>
   View
  </summary> 
  
#### ``Table 1: plans``
```Schema```
|Column Name|Data Type|Description              |
|-----------|---------|-------------------------|
|plan_id    |INTEGER  |A unique ID for each Plan|
|plan_name  |VARCHAR  |Name of the Plan         |
|price      |FLOAT    |Price of the Plan        |

```Sample Data```
|plan_id|plan_name    |price|
|-------|-------------|-----|
|0      |trial        |0    |
|1      |basic monthly|9.90 |
|2      |pro monthly  |19.90|
|3      |pro annual   |199  |
|4      |churn        |null |

#### ``Table 2: subscriptions``
```Schema```
|Column Name|Data Type|Description                          |
|-----------|---------|-------------------------------------|
|customer_id|INTEGER  |A unique ID for each Customer        |
|plan_id    |INTEGER  |An ID of the plan (can be duplicates)|
|start_date |DATE     |Date when the plan starts            |

```Sample Data```
| customer_id | plan_id | start_date |
|-------------|---------|------------|
| 1           | 0       | 2020-08-01 |
| 1           | 1       | 2020-08-08 |
| 2           | 0       | 2020-09-20 |
| 2           | 3       | 2020-09-27 |
| 11          | 0       | 2020-11-19 |
| 11          | 4       | 2020-11-26 |
| 13          | 0       | 2020-12-15 |
| 13          | 1       | 2020-12-22 |
| 13          | 2       | 2021-03-29 |
| 15          | 0       | 2020-03-17 |
| 15          | 2       | 2020-03-24 |
| 15          | 4       | 2020-04-29 |
| 16          | 0       | 2020-05-31 |
| 16          | 1       | 2020-06-07 |
| 16          | 3       | 2020-10-21 |
| 18          | 0       | 2020-07-06 |
| 18          | 2       | 2020-07-13 |
| 19          | 0       | 2020-06-22 |
| 19          | 2       | 2020-06-29 |
| 19          | 3       | 2020-08-29 |


  </details>

   
---
## Case Study Solutions
- [Customer Journey](https://github.com/avishek-choudhary/Case-Study-3-Foodie-Fi/blob/main/Customer%20Journey.md)
- [Data Analysis Questions](https://github.com/avishek-choudhary/Case-Study-3-Foodie-Fi/blob/main/Data%20Analysis.md)   
   
 ---
 ## Resources
 - [Article](https://avishek-choudhary.github.io/projects/Foodie-Fi.html)
