-- Customer Journey

-- Based on the 8 sample customers (1,2,11,13,15,16,18,19) from the subscriptions table, 
-- Write a brief description of each customer’s onboarding journey.
SELECT customer_id, plans.plan_name, start_date
FROM subscriptions
    JOIN plans ON plans.plan_id = subscriptions.plan_id
WHERE customer_id IN (1,2,11,13,15,16,18,19) -- sample 8 customers ID
ORDER BY 1;


-- Data Analysis

-- 1. How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT(customer_id)) AS unique_customers
FROM subscriptions;


-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value?
SELECT MONTHNAME(start_date) AS month,
	   COUNT(*) AS total_plans
FROM subscriptions
JOIN plans ON plans.plan_id = subscriptions.plan_id
WHERE plan_name = 'trial'
GROUP BY 1
ORDER BY 2 DESC;


-- 3. Which plan's start_date values occur after the year 2020 for our dataset? Show the breakdown by a count of events for each plan_name.
SELECT plan_name, COUNT(*) AS event_2021
FROM plans
JOIN subscriptions ON plans.plan_id = subscriptions.plan_id
WHERE start_date > '2020-12-31'
GROUP BY 1;


-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
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


-- 5. How many customers have churned straight after their initial free trial — what's the percentage rounded to the nearest whole number?
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


-- 6. What is the number and percentage of customer choosing plans after their initial free trial?
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


-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
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


-- 8. How many customers have upgraded to an annual plan in 2020?
SELECT COUNT(DISTINCT customer_id) AS customers
FROM subscriptions
JOIN plans ON plans.plan_id = subscriptions.plan_id
WHERE plan_name = 'pro annual'
    AND YEAR(start_date) <=2020;


-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
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

-- WITH cte AS (
--     SELECT customer_id, 
--         CASE WHEN plan_id = 0 THEN start_date END AS trial_date,
--         CASE WHEN plan_id = 3 THEN start_date END AS annual_date
--     FROM subscriptions
-- )
-- SELECT customer_id, DATEDIFF(annual_date, trial_date) AS days
-- FROM cte
-- WHERE annual_date IS NOT NULL
--     AND trial_date IS NOT NULL;

-- 10. Can you further breakdown this average value into 30-day periods (i.e. 0-30 days, 31-60 days, etc)
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


-- 11. How many customers were downgraded from a pro monthly to a basic monthly plan in 2020?
-- WITH basic_monthly_plan AS (
--     SELECT customer_id, 
--            CASE WHEN plan_id = 1 THEN start_date END AS basic_monthly_date
--     FROM subscriptions
-- ),
-- pro_monthly_plan AS (
--     SELECT customer_id, 
--            CASE WHEN plan_id = 2 THEN start_date END AS pro_monthly_date
--     FROM subscriptions
-- )
-- SELECT basic_monthly_date, pro_monthly_date
-- FROM basic_monthly_plan
-- JOIN pro_monthly_plan ON basic_monthly_plan.customer_id = pro_monthly_plan.customer_id;

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

-- Payment Questions

--Use a recursive CTE to increment rows for all monthly paid plans until customers change the plan, except 'pro annual'
WITH dateRecursion AS (
  SELECT 
    s.customer_id,
    s.plan_id,
    p.plan_name,
    s.start_date AS payment_date,
    --column last_date: last day of the current plan
    CASE 
      --if a customer kept using the current plan, last_date = '2020-12-31'
      WHEN LEAD(s.start_date) OVER(PARTITION BY s.customer_id ORDER BY s.start_date) IS NULL THEN '2020-12-31'
      --if a customer changed the plan, last_date = (month difference between start_date and changing date) + start_date
      ELSE DATEADD(MONTH, 
		   DATEDIFF(MONTH, start_date, LEAD(s.start_date) OVER(PARTITION BY s.customer_id ORDER BY s.start_date)),
		   start_date) END AS last_date,
    p.price AS amount
  FROM subscriptions s
  JOIN plans p ON s.plan_id = p.plan_id
  --exclude trials because they didn't generate payments 
  WHERE p.plan_name NOT IN ('trial')
    AND YEAR(start_date) = 2020
  UNION ALL
  SELECT 
    customer_id,
    plan_id,
    plan_name,
    --increment payment_date by monthly
    DATEADD(MONTH, 1, payment_date) AS payment_date,
    last_date,
    amount
  FROM dateRecursion
  --stop incrementing when payment_date = last_date
  WHERE DATEADD(MONTH, 1, payment_date) <= last_date
    AND plan_name != 'pro annual'
)
--Create a new table [payments]
SELECT 
  customer_id,
  plan_id,
  plan_name,
  payment_date,
  amount,
  ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY payment_date) AS payment_order
INTO payments
FROM dateRecursion
--exclude churns
WHERE amount IS NOT NULL
ORDER BY customer_id
OPTION (MAXRECURSION 365);

-- DROP TABLE payments
-- CREATE TABLE payments (
--   customer_id INTEGER,
--   plan_id INTEGER,
--   plan_name VARCHAR(64),
--   payment_date DATE,
--   amount FLOAT,
--   payment_order INTEGER
-- )

WITH dateRecursion AS (
  SELECT 
    s.customer_id,
    s.plan_id,
    p.plan_name,
    s.start_date AS payment_date,
    CASE 
      WHEN LEAD(s.start_date) OVER(PARTITION BY s.customer_id ORDER BY s.start_date) IS NULL 
        THEN '2020-12-31' 
      ELSE DATE_ADD(start_date, INTERVAL DATEDIFF(start_date, LEAD(s.start_date) OVER(PARTITION BY s.customer_id ORDER BY s.start_date)) MONTH) 
    END AS last_date,
    p.price AS amount
  FROM subscriptions s
  JOIN plans p ON s.plan_id = p.plan_id
  WHERE p.plan_name NOT IN ('trial')
    AND YEAR(start_date) = 2020
  UNION ALL
  SELECT 
    customer_id,
    plan_id,
    plan_name,
    DATE_ADD(payment_date, INTERVAL 1 MONTH) AS payment_date,
    last_date,
    amount
  FROM dateRecursion
  WHERE DATE_ADD(payment_date, INTERVAL 1 MONTH) <= last_date
    AND plan_name != 'pro annual'
)
SELECT 
  customer_id,
  plan_id,
  plan_name,
  payment_date,
  amount,
  ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY payment_date) AS payment_order
-- INTO payments
FROM dateRecursion
WHERE amount IS NOT NULL
ORDER BY customer_id;

-- WITH dateRecursion AS (
--   SELECT 
--     s.customer_id,
--     s.plan_id,
--     p.plan_name,
--     s.start_date AS payment_date,
--     CASE 
--     WHEN LEAD(s.start_date) OVER(PARTITION BY s.customer_id ORDER BY s.start_date) IS NULL 
--     THEN '2020-12-31' 
--     ELSE DATE_ADD(start_date, INTERVAL DATEDIFF(start_date, LEAD(s.start_date) OVER(PARTITION BY s.customer_id ORDER BY s.start_date)) MONTH) 
--     END AS last_date,
--     p.price AS amount
--   FROM subscriptions s
--   JOIN plans p ON s.plan_id = p.plan_id
--   WHERE p.plan_name NOT IN ('trial')
--     AND YEAR(start_date) = 2020
--   UNION ALL
--   SELECT 
--     customer_id,
--     plan_id,
--     plan_name,
--     DATE_ADD(payment_date, INTERVAL 1 MONTH) AS payment_date,
--     last_date,
--     amount
--   FROM dateRecursion
--   WHERE DATE_ADD(payment_date, INTERVAL 1 MONTH) <= last_date
--     AND plan_name != 'pro annual'
-- )
-- SELECT 
--   customer_id,
--   plan_id,
--   plan_name,
--   payment_date,
--   amount,
--   ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY payment_date) AS payment_order
-- -- INTO payments
-- FROM dateRecursion
-- WHERE amount IS NOT NULL
-- ORDER BY customer_id

-- SELECT 
-- 	customer_id,
-- 	plan_id,
-- 	plan_name,
-- 	payment_date,
-- 	amount,
-- 	RANK() OVER(PARTITION BY customer_id ORDER BY customer_id, plan_id, payment_date) payment_order
-- FROM Date_CTE
-- WHERE YEAR(payment_date) = 2020
-- ORDER BY customer_id, plan_id, payment_date;
-- Create payments_2020 table
-- CREATE TABLE payments_2020 (
--     payment_id INT  PRIMARY KEY,
--     customer_id INT NOT NULL,
--     plan_id INT NOT NULL,
--     plan_name VARCHAR(50) NOT NULL,
--     payment_date DATE NOT NULL,
--     amount DECIMAL(10,2) NOT NULL,
--     payment_order INT NOT NULL
-- );

-- Insert payment data into the payments_2020 table
WITH join_table AS -- create a base table
(
	SELECT 
	        s.customer_id,
		s.plan_id,
		p.plan_name,
		s.start_date AS payment_date,
		s.start_date,
		LEAD(s.start_date, 1) OVER(PARTITION BY s.customer_id ORDER BY s.start_date, s.plan_id) AS next_date,
		p.price AS amount
	FROM subscriptions s
	LEFT JOIN plans p 
	ON p.plan_id = s.plan_id
),
new_join AS -- filter table (deselect trial and churn)
(
	SELECT 
		customer_id,
		plan_id,
		plan_name,
		payment_date,
		start_date,
		CASE WHEN next_date IS NULL or next_date > '2020-12-31' THEN '2020-12-31' ELSE next_date END next_date,
		amount
	FROM join_table
	WHERE plan_name NOT IN ('trial', 'churn')
),
new_join1 AS -- add a new column, 1 month before next_date
(
	SELECT 
		customer_id,
		plan_id,
		plan_name,
		payment_date,
		start_date,
		next_date,
		DATE_ADD(next_date, INTERVAL -1 MONTH) AS next_date1,
		amount
	FROM new_join
),
Date_CTE  AS -- recursive function (for payment_date)
(
	SELECT 
		customer_id,
		plan_id,
		plan_name,
		start_Date,
		payment_date = (SELECT start_Date 
                    FROM new_join1 
                    WHERE customer_id = a.customer_id 
                      AND plan_id = a.plan_id 
                    LIMIT 1),
		next_date, 
		next_date1,
		amount
	FROM new_join1 a
	UNION ALL 
	SELECT 
		customer_id,
		plan_id,
		plan_name,
		start_Date, 
		DATE_ADD(payment_date, INTERVAL 1 MONTH) AS payment_date,
		next_date, 
		next_date1,
		amount
	FROM Date_CTE b
	WHERE payment_date < next_date1 AND plan_id != 3
)
-- INSERT INTO payments_2020 (customer_id, plan_id, plan_name, payment_date, amount, payment_order)
SELECT 
	customer_id,
	plan_id,
	plan_name,
	payment_date,
	amount,
	RANK() OVER(PARTITION BY customer_id ORDER BY customer_id, plan_id, payment_date) AS payment_order
FROM Date_CTE
WHERE YEAR(payment_date) = 2020
ORDER BY customer_id, plan_id, payment_date;
