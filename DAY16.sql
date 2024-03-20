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
with base as (
select b.name as Department, a.name as Employee, a.salary as Salary,
dense_rank () over (partition by b.name order by a.salary desc) as stt
from Employee as a
JOIN Department as b
ON a.departmentId=b.id
)
select Department, Employee, Salary from base
where stt <=3

--ex7
with base as(
select *,
rank () over (order by turn) as stt,
sum(weight) over (order by weight) as accumulative
from Queue
)

select person_name from base
where
accumulative > 1000
limit 1

--ex8
select product_id, new_price as price from Products
where (product_id, change_date) in 
(select product_id, max(change_date) from Products
where change_date <= "2019-08-16"
group by product_id)
union
select product_id, 10 as price from Products
where change_date >= "2019-08-16" and 
product_id not in 
(select product_id 
from Products 
where change_date <= "2019-08-16")
group by product_id 















