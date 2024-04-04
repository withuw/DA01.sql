--1. so luong don hang va so luong khach hang moi thang

select
format_date('%Y-%m', created_at) AS month_year,
sum (user_id) as total_user,
sum(order_id) as total_order
from bigquery-public-data.thelook_ecommerce.order_items
where  status = 'Complete'
and created_at between '2019-01-01' and '2022-04-30'
group by month_year order by month_year
;

Insights: 
  - Nhìn chung, số lượng đơn hàng và số lượng khách hàng mỗi tháng tăng mạnh theo thời gian, từ 1/2019 - 4/2022 (tăng 127 lần)
  - Số lượng đơn hàng và số lượng khách hàng mỗi tháng có mối tương quan với nhau, SL khách hàng giảm thì SL đơn hàng giảm và ngược lại
  - Peak: 2/2022

--2.Giá trị đơn hàng trung bình (AOV) và số lượng khách hàng mỗi tháng
select
format_date('%Y-%m', created_at) AS month_year,
count (distinct user_id) as distinct_users,
sum(sale_price)/count(order_id) as average_order_value,
from bigquery-public-data.thelook_ecommerce.order_items
where created_at between '2019-01-01' and '2022-04-30'
group by month_year order by month_year
;

Insight:
  - Nhìn chung, giá trị đơn hàng trung bình và số lượng khách hàng mỗi tháng tăng nhưng không đều
  - Những tháng trong 1 năm gần đây, giá trị đơn hàng tăng, giảm liên tục theo từng tháng, nhưng dao động trong khoảng ~58 - ~61
  - Peak distinct user vào tháng 3/2022, nhưng giá trị đơn hàng trung bình không cao so với những tháng trước

--3. Nhóm khách hàng theo độ tuổi

with base as (
select first_name, last_name, gender, age,
case when age =(select max(age) from bigquery-public-data.thelook_ecommerce.users) then 'oldest' else 'youngest' end as tag
from bigquery-public-data.thelook_ecommerce.users
where gender = 'F'
and created_at between '2019-01-01' and '2022-04-30'
and (age = (select max(age) from bigquery-public-data.thelook_ecommerce.users)
or age = (select min(age) from bigquery-public-data.thelook_ecommerce.users))


UNION ALL

select first_name, last_name, gender, age,
case when age =(select max(age) from bigquery-public-data.thelook_ecommerce.users) then 'oldest' else 'youngest' end as tag
from bigquery-public-data.thelook_ecommerce.users
where gender = 'M'
and created_at between '2019-01-01' and '2022-04-30'
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



  
--4.Top 5 sản phẩm mỗi tháng

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
where c.created_at between '2019-01-01' and '2022-04-30'
group by a.name, a.id,a.retail_price, a.cost, month_year)

, ranking as (select *,
dense_rank () over (partition by base.month_year order by profit desc) as rank_per_month
from base
)

select * from ranking
where ranking.rank_per_month <=5
order by ranking.month_year


--5.Doanh thu tính đến thời điểm hiện tại trên mỗi danh mục
  
select a.category as product_categories,
format_date('%Y-%m-%d', c.created_at) AS dates,
(a.retail_price*sum(c.num_of_item)) as revenue
from bigquery-public-data.thelook_ecommerce.products as a
JOIN bigquery-public-data.thelook_ecommerce.order_items as b
ON a.id = b.product_id
JOIN bigquery-public-data.thelook_ecommerce.orders as c
ON b.order_id = c.order_id
where c.created_at between '2022-01-15' and '2022-04-15'
group by a.category, dates, a.retail_price

--5.Doanh thu tính đến thời điểm hiện tại trên mỗi danh mục

with total as(select a.category,
sum(c.num_of_item) as total_items,
sum(a.retail_price) as total_sales,
format_date('%Y-%m-%d', c.created_at) AS dates
from bigquery-public-data.thelook_ecommerce.products as a
JOIN bigquery-public-data.thelook_ecommerce.order_items as b
ON a.id = b.product_id
JOIN bigquery-public-data.thelook_ecommerce.orders as c
ON b.order_id = c.order_id
where c.created_at between '2022-01-15' and '2022-04-15'
group by a.category, dates
)


select dates, category as product_categories,
total_sales*total_items as revenue
from total
group by dates,category,revenue
order by dates, category

  
------------

III. Tạo metric trước khi dựng dashboard

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
where b.created_at between '2019-01-01' and '2022-04-30'
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
