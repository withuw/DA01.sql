--ex1
with first as (
select customer_id, customer_pref_delivery_date,
min(order_date) over (partition by customer_id) as first_order
from Delivery
group by customer_id
)

select
round(sum(case when first_order=customer_pref_delivery_date
then 1 else 0 end)*100/count(first_order), 2) as immediate_percentage
from first

--ex2
with first as (
select customer_id, customer_pref_delivery_date,
min(order_date) as first_order
from Delivery
group by customer_id
)

select
round(sum(case when first_order=customer_pref_delivery_date
then 1 else 0 end)*100/count(first_order), 2) as immediate_percentage
from first

--ex3
select
case when id= (select max(id) from seat) and id %2=1 then id
when id % 2 = 1 then id +1
else id -1 end as id, student
from seat
order by id

--ex4
with base as (
select visited_on,
sum(amount) as total_amount,
row_number () over (order by visited_on) as stt
from Customer
group by visited_on
order by visited_on
)

select visited_on,
sum(total_amount) over (order by visited_on) as amount
from base
where visited_on <= interval '6 days'

--ex5
SELECT    
user_id,    
tweet_date,   
ROUND(AVG(tweet_count) OVER (PARTITION BY user_id ORDER BY tweet_date     
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) ,2) AS rolling_avg_3d
FROM tweets;

--ex6
















