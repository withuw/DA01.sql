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




