# Case Study #3: Foodie-Fi

## Customer Journey

*Based off the 8 sample customers (1,2,11,13,15,16,18,19) from the subscriptions table, write a brief description about each customer’s onboarding journey.*

```sql
SELECT customer_id, 
       plans.plan_name, 
       start_date
FROM subscriptions
JOIN plans ON plans.plan_id = subscriptions.plan_id
WHERE customer_id IN (1,2,11,13,15,16,18,19) -- sample 8 customers ID
ORDER BY 1;
```

|customer_id|plan_name    |start_date|
|-----------|-------------|----------|
|1          |trial        |2020-08-01|
|1          |basic monthly|2020-08-08|
|2          |trial        |2020-09-20|
|2          |pro annual   |2020-09-27|
|11         |trial        |2020-11-19|
|11         |churn        |2020-11-26|
|13         |trial        |2020-12-15|
|13         |basic monthly|2020-12-22|
|13         |pro monthly  |2021-03-29|
|15         |trial        |2020-03-17|
|15         |pro monthly  |2020-03-24|
|15         |churn        |2020-04-29|
|16         |trial        |2020-05-31|
|16         |basic monthly|2020-06-07|
|16         |pro annual   |2020-10-21|
|18         |trial        |2020-07-06|
|18         |pro monthly  |2020-07-13|
|19         |trial        |2020-06-22|
|19         |pro monthly  |2020-06-29|
|19         |pro annual   |2020-08-29|

### Brief description on the customers journey based on the results from the above query:

 - Customer 1 starts with a free trial plan on 2020-08-01 and when the trial ends, upgrades to basic monthly plan on 2020-08-08

 - Customer 2 starts with a free trial plan on 2020-09-20 and when the trial ends, upgrades to pro annual plan on 2020-09-27

 - Customer 11 starts with free trial plan on 2020-11-19 and churns at the end of the free trial plan on 2020-11-26

 - Customer 13 starts with free trial plan on 2020-15-12 and when the trial ends subscribes to a basic monthly plan on the
2020-12-22, and 3 months later upgrades to a pro monthly plan on 2021-03-29

 - Customer 15 starts with a free trial plan on 2020-03-17, and when the trail ends automatically upgrades to the pro monthly plan on
2020-03-24 and then churns one month later on 2020-04-29

 - Customer 16 starts with a free trial plan on 2020-05-31, and when the trial ends, subscribes to a basic monthly plan on 2020-06-07 
and 4 months later upgrades to a pro annual plan on 2020-10-21

 - Customer 18 starts with a free trial plan on 2020-07-06 and when the trial ends, automatically upgrades to pro monthly plan on
the 2020-07-13

 - Customer 19 starts with a free trial plan on 2020-06-22, automatically ugrades to pro monthly on 2020-06-29, and 2 months later
upgrades to pro annual plan on 2020-08-29
