---Calculating the number of orders and customers each month

select
format_date('%Y-%m', created_at) AS month_year,
sum (user_id) as total_user,
sum(order_id) as total_order
from bigquery-public-data.thelook_ecommerce.order_items
where  status = 'Complete'
group by month_year order by month_year
;

Insights: 
  - Nhìn chung, số lượng đơn hàng và số lượng khách hàng mỗi tháng tăng mạnh theo thời gian, từ 1/2019 - 4/2022 (tăng 127 lần)
  - Số lượng đơn hàng và số lượng khách hàng mỗi tháng có mối tương quan với nhau, SL khách hàng giảm thì SL đơn hàng giảm và ngược lại
  - Peak: 2/2022

---Calculating average order value (AOV)
select
format_date('%Y-%m', created_at) AS month_year
sum(sale_price)/count(order_id) as average_order_value,
from bigquery-public-data.thelook_ecommerce.order_items
group by month_year order by month_year
;

Insight:
  - Nhìn chung, giá trị đơn hàng trung bình và số lượng khách hàng mỗi tháng tăng nhưng không đều
  - Những tháng trong 1 năm gần đây, giá trị đơn hàng tăng, giảm liên tục theo từng tháng, nhưng dao động trong khoảng ~58 - ~61
  - Peak distinct user vào tháng 3/2022, nhưng giá trị đơn hàng trung bình không cao so với những tháng trước

---Segment customers by age group

with base as (
select first_name, last_name, gender, age,
case when age =(select max(age) from bigquery-public-data.thelook_ecommerce.users) then 'oldest' else 'youngest' end as tag
from bigquery-public-data.thelook_ecommerce.users
where gender = 'F'
and (age = (select max(age) from bigquery-public-data.thelook_ecommerce.users)
or age = (select min(age) from bigquery-public-data.thelook_ecommerce.users))


UNION ALL

select first_name, last_name, gender, age,
case when age =(select max(age) from bigquery-public-data.thelook_ecommerce.users) then 'oldest' else 'youngest' end as tag
from bigquery-public-data.thelook_ecommerce.users
where gender = 'M'
and (age = (select max(age) from bigquery-public-data.thelook_ecommerce.users)
or age = (select min(age) from bigquery-public-data.thelook_ecommerce.users))
)

select gender, tag,
count (*)
from base
group by gender, tag

  Insights:
  - Độ tuổi nhỏ nhất: 12 (bằng nhau với cả 2 giới)
  + Nam: 485 người
  + Nữ: 516 người
  
  - Độ tuổi lớn nhất: 70 (bằng nhau với cả 2 giới)
  + Nam: 553 người
  + Nữ: 510 người


---Calculating top 5 products each month

with base as (
select
format_date('%Y-%m', c.created_at) AS month_year,
a.id as product_id,a.name as product_name, a.retail_price as sales, a.cost,
(a.retail_price - a.cost) as profit
from bigquery-public-data.thelook_ecommerce.products as a
JOIN bigquery-public-data.thelook_ecommerce.order_items as b
ON a.id = b.product_id
JOIN bigquery-public-data.thelook_ecommerce.orders as c
ON b.order_id = c.order_id
group by a.name, a.id,a.retail_price, a.cost, month_year)

, ranking as (select *,
dense_rank () over (partition by base.month_year order by profit desc) as rank_per_month
from base
)

select * from ranking
where ranking.rank_per_month <=5
order by ranking.month_year

---Calculating revenue up to the current time in each category

with total as(select a.category,
sum(c.num_of_item) as total_items,
sum(a.retail_price) as total_sales,
format_date('%Y-%m-%d', c.created_at) AS dates
from bigquery-public-data.thelook_ecommerce.products as a
JOIN bigquery-public-data.thelook_ecommerce.order_items as b
ON a.id = b.product_id
JOIN bigquery-public-data.thelook_ecommerce.orders as c
ON b.order_id = c.order_id
group by a.category, dates
)


select dates, category as product_categories,
total_sales*total_items as revenue
from total
group by dates,category,revenue
order by dates, category

  
------------

---Creating metrics for building dashboard

create view vw_ecommerce_analyst as (
with base1 as(
select 
format_date('%Y-%m', b.created_at) AS month,
format_date('%Y', b.created_at) AS year,
a.category as product_category,
sum(b.sale_price) as TPV,
count(distinct order_id) as TPO,
sum(a.cost) as total_cost,
sum(b.sale_price) - sum(a.cost) as total_profit,
(sum(b.sale_price) - sum(a.cost))/sum(a.cost) as profit_to_cost_ratio
from bigquery-public-data.thelook_ecommerce.products as a
JOIN bigquery-public-data.thelook_ecommerce.order_items as b
ON a.id = b.product_id
group by month, year, a.category
order by month, year, a.category
),

base2 as
(
select *,
concat(round(100.00* (lead(TPV) over (partition by product_category order by month) - TPV) / TPV,2), '%') as revenue_growth,
concat(round(100.00* (lead(TPO) over (partition by product_category order by month) - TPO) / TPO,2), '%') as order_growth
from base1
order by product_category
)

select * from base2
)

---Customer cohort analysis
  
with main as (SELECT 
user_id, sale_price, created_at,
format_date('%Y-%m', first_purchase_date) as cohort_date,
(extract(year from created_at)-extract(year from first_purchase_date))*12
+(extract(month from created_at)-extract(month from first_purchase_date))+1 as index
FROM(
SELECT user_id, sale_price,
MIN(created_at) over(PARTITION BY user_id) as first_purchase_date,
created_at
from bigquery-public-data.thelook_ecommerce.order_items
))
,index_table as (
SELECT 
cohort_date,
index,
count(distinct user_id) as cnt,
sum(sale_price) as revenue
from main
group by cohort_date, index)
,customer_cohort as (
select
cohort_date,
sum(case when index=1 then cnt else 0 end ) as m1,
sum(case when index=2 then cnt else 0 end ) as m2,
sum(case when index=3 then cnt else 0 end ) as m3,
sum(case when index=4 then cnt else 0 end ) as m4,
sum(case when index=5 then cnt else 0 end ) as m5,
sum(case when index=6 then cnt else 0 end ) as m6,
sum(case when index=7 then cnt else 0 end ) as m7,
sum(case when index=8 then cnt else 0 end ) as m8,
sum(case when index=9 then cnt else 0 end ) as m9,
sum(case when index=10 then cnt else 0 end ) as m10,
sum(case when index=11 then cnt else 0 end ) as m11,
sum(case when index=12 then cnt else 0 end ) as m12,



from index_table
group by cohort_date
order by cohort_date)

select * from customer_cohort

----Customer retention cohort analysis
select
cohort_date,
round(100.00* m1/m1,2)||'%' as m1,
round(100.00* m2/m1,2)|| '%' as m2,
round(100.00* m3/m1,2) || '%' as m3,
round(100.00* m4/m1,2) || '%' as m4,
round(100.00* m5/m1,2) || '%' as m5,
round(100.00* m6/m1,2) || '%' as m6,
round(100.00* m7/m1,2) || '%' as m7,
round(100.00* m8/m1,2) || '%' as m8,
round(100.00* m9/m1,2) || '%' as m9,
round(100.00* m10/m1,2) || '%' as m10,
round(100.00* m11/m1,2) || '%' as m11,
round(100.00* m12/m1,2) || '%' as m12

from customer_cohort


--Nhận xét: 
+ Theo chiều dọc, nhìn chung, số lượng khách hàng mới của công ty tăng dần theo từng tháng.
+ Tuy nhiên, theo chiều ngang tỉ lệ khách hàng quay lại thấp.
+ Công ty cần tạo ra nhiều chiến dịch thu hút khách hàng quay lại, tạo lượng khách hàng trung thành nhất định,
  đồng thời cải thiện chất lượng dịch vụ của mình.

