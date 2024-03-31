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
select * from bigquery-public-data.thelook_ecommerce.order_items

--2.Giá trị đơn hàng trung bình (AOV) và số lượng khách hàng mỗi tháng
select
format_date('%Y-%m', created_at) AS month_year,
count (distinct user_id) as distinct_users,
sum(sale_price)/count(order_id) as average_order_value,
from bigquery-public-data.thelook_ecommerce.order_items
where created_at between '2019-01-01' and '2022-04-30'
group by month_year order by month_year
;

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
