# Case Study #3: Foodie-Fi
## Data Analysis
<br>

### 1. How many customers has Foodie-Fi ever had?
```sql
SELECT COUNT(DISTINCT(customer_id)) AS unique_customers
FROM subscriptions;
```

|unique_customers|
|----------------|
|1000            |

*Foodie-Fi had 1,000 unique customers.*

---
### 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value?
```sql
SELECT MONTHNAME(start_date) AS month,
	   COUNT(*) AS total_plans
FROM subscriptions
JOIN plans ON plans.plan_id = subscriptions.plan_id
WHERE plan_name = 'trial'
GROUP BY 1
ORDER BY 2 DESC;
```
|month    |total_plans|
|---------|-----------|
|March    |94         |
|July     |89         |
|August   |88         |
|January  |88         |
|May      |88         |
|September|87         |
|December |84         |
|April    |81         |
|June     |79         |
|October  |79         |
|November |75         |
|February |68         |

*March has the highest number of trial plans, whereas February has the lowest number of trial plans.*

---
### 3. Which plan's start_date values occur after the year 2020 for our dataset? Show the breakdown by a count of events for each plan_name.
```sql
SELECT plan_name, COUNT(*) AS event_2021
FROM plans
JOIN subscriptions ON plans.plan_id = subscriptions.plan_id
WHERE start_date > '2020-12-31'
GROUP BY 1;
```
|plan_name    |event_2021|
|-------------|----------|
|churn        |71        |
|pro monthly  |60        |
|pro annual   |63        |
|basic monthly|8         |

*The data shows there is no trial period recorded after the year 2020.*

---
### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
```sql
WITH churn_count AS (
    SELECT COUNT(*) as churned
    FROM subscriptions
    JOIN plans ON plans.plan_id = subscriptions.plan_id
    WHERE plan_name = 'churn'
)
SELECT churned, CONCAT(ROUND((100 * churned / unique_customers), 1), '%') AS churn_rate
FROM churn_count, 
     (SELECT COUNT(DISTINCT(customer_id)) AS unique_customers 
      FROM subscriptions) AS total;
```
|churned|churn_rate|
|-------|----------|
|307    |30.7%     |

*307 customers, or 30.7% of the total customers, have churned from Food-fi during the period of analysis.*

---
### 5. How many customers have churned straight after their initial free trial — what's the percentage rounded to the nearest whole number?
```sql
WITH previous_plan_cte AS (
    SELECT *, LAG(plan_id) OVER(PARTITION BY customer_id ORDER BY plan_id) AS previous_plan
    FROM subscriptions
)
SELECT COUNT(*) AS churned,
       CONCAT(ROUND(100 * COUNT(*) / unique_customers), '%') AS churn_rate
FROM previous_plan_cte, 
     (SELECT COUNT(DISTINCT(customer_id)) AS unique_customers 
      FROM subscriptions) AS total
WHERE plan_id = 4 AND previous_plan = 0;
```
|churned|churn_rate|
|-------|----------|
|92		|9%		   |

*92 customers, or 9% of the total customers, have churned straight after their initial free trial.*

---
### 6. What is the number and percentage of customer choosing plans after their initial free trial?
```sql
WITH next_plan_cte AS (
    SELECT *, 
           LEAD(plan_id) OVER(PARTITION BY customer_id ORDER BY plan_id) AS next_plan
    FROM subscriptions
),
customer_count AS (
    SELECT plan_name, COUNT(*) AS customers
    FROM next_plan_cte
    JOIN plans ON plans.plan_id = next_plan_cte.next_plan
    WHERE next_plan_cte.plan_id = 0
    GROUP BY next_plan
)
SELECT plan_name, customers,
       CONCAT(ROUND((100 * customers / unique_customers), 1), '%') AS percentage
FROM customer_count, 
     (SELECT COUNT(DISTINCT(customer_id)) AS unique_customers 
      FROM subscriptions) AS total;
```
|plan_name    |customers|percentage|
|-------------|---------|---------|
|basic monthly|546      |54.%     |
|pro monthly  |325      |32.%     |
|pro annual   |37       |3.%      |
|churn        |92       |9.%      |

*More than 80% of customers are on paid plans, with a small 3.7% on plan 3 (pro annual $199). Foodie-fi has to rethink its customer acquisition strategy for customers who are willing to spend more.*

---
### 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
```sql
WITH next_date_cte AS (
    SELECT *, 
           LEAD(start_date) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_date
    FROM subscriptions
    WHERE start_date <= '2020-12-31'
),
customer_count AS (
    SELECT plan_name, COUNT(*) AS customers
    FROM next_date_cte
    JOIN plans ON plans.plan_id = next_date_cte.plan_id
    WHERE next_date IS NULL
    GROUP BY 1
)
SELECT plan_name, customers,
       CONCAT(ROUND((100 * customers / unique_customers), 1), '%') AS percentage
FROM customer_count, 
     (SELECT COUNT(DISTINCT(customer_id)) AS unique_customers 
      FROM subscriptions) AS total;
```
|plan_name    |customers|percentage|
|-------------|---------|---------|
|trial        |19       |1.%      |
|basic monthly|224      |22.%     |
|pro monthly  |326      |32.%     |
|pro annual   |195      |19.%     |
|churn        |236      |23.%     |

*On December 31, 2020, more people subscribed or upgraded to the pro monthly plan, but fewer people signed up for the trial plan. Could it be that some new customers signed up for paid plans immediately? If not, Foodie-Fi needs to scale up its marketing strategies for acquiring new sign-ups during this period as it’s a holiday period, and as an entertainment platform, it's supposed to have more customers testing out the platform.*

---
### 8. How many customers have upgraded to an annual plan in 2020?
```sql
SELECT COUNT(DISTINCT customer_id) AS customers
FROM subscriptions
JOIN plans ON plans.plan_id = subscriptions.plan_id
WHERE plan_name = 'pro annual'
    AND YEAR(start_date) <=2020;
```
|customers|
|---------|
|195	  |

*195 customers upgraded to an annual plan in 2020.*

---
### 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
```sql
WITH trial_plan AS (
    SELECT customer_id, start_date AS trial_date
    FROM subscriptions
    JOIN plans ON plans.plan_id = subscriptions.plan_id
    WHERE plan_name = 'trial'
),
annual_plan AS (
    SELECT customer_id, start_date AS annual_date
    FROM subscriptions
    JOIN plans ON plans.plan_id = subscriptions.plan_id
    WHERE plan_name = 'pro annual'
)
SELECT ROUND(AVG(DATEDIFF(annual_date, trial_date))) AS avg_days_to_convert
FROM trial_plan
JOIN annual_plan ON trial_plan.customer_id = annual_plan.customer_id;
```
|avg_days_to_upgrade|
|-------------------|
|105                |

*On average, customers take approximately 105 days from the day they join Foodie-Fi to upgrade to an annual plan.*

---
### 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
```sql
WITH trial_plan AS (
    SELECT customer_id, start_date AS trial_date
    FROM subscriptions
    JOIN plans ON plans.plan_id = subscriptions.plan_id
    WHERE plan_name = 'trial'
),
annual_plan AS (
    SELECT customer_id, start_date AS annual_date
    FROM subscriptions
    JOIN plans ON plans.plan_id = subscriptions.plan_id
    WHERE plan_name = 'pro annual'
)
SELECT
    CONCAT(FLOOR(DATEDIFF(annual_date, trial_date) / 30) * 30, '-', 
           FLOOR(DATEDIFF(annual_date, trial_date) / 30) * 30 + 30, ' days') AS period,
    COUNT(*) AS total_customers,
    ROUND(AVG(DATEDIFF(annual_date, trial_date)), 0) AS avg_days_to_upgrade
FROM trial_plan tp
JOIN annual_plan ap ON tp.customer_id = ap.customer_id
WHERE ap.annual_date IS NOT NULL
GROUP BY FLOOR(DATEDIFF(annual_date, trial_date) / 30);
```
|period      |total_customers|avg_days_to_upgrade|
|------------|---------------|------------------|
|0-30 days   |48             |0                 |
|30-60 days  |25             |2                 |
|60-90 days  |33             |1                 |
|90-120 days |35             |00                |
|120-150 days|43             |33                |
|150-180 days|35             |62                |
|180-210 days|27             |90                |
|210-240 days|4              |24                |
|240-270 days|5              |57                |
|270-300 days|1              |85                |
|300-330 days|1              |27                |
|330-360 days|1              |46                |

* *The majority of customers opt to subscribe or upgrade to an annual plan within the first 30 days.*
* *A smaller percentage of customers make the decision to subscribe or upgrade after 210 days.*
* *After 270 days, there is almost no customer activity in terms of purchasing a plan.*

---
### 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
```sql
WITH plan_list AS (
  SELECT *,
         LEAD(plan_id) 
          OVER(PARTITION BY customer_id ORDER BY start_date) AS next_plan_id
  FROM subscriptions
  WHERE YEAR(start_date) = 2020
)
SELECT COUNT(*) AS downgraded
FROM plan_list
WHERE plan_id = 2
  AND next_plan_id = 1;
```
|downgraded|
|----------|
|0		   |

*No customer has downgraded from pro monthly to basic monthly in 2020.*

---