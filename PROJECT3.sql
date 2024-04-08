--clean_database
with base as (
select *,
(select avg(quantityordered) from sales_dataset_rfm_prj as avg),
(select stddev(quantityordered) from sales_dataset_rfm_prj as stddev)
from sales_dataset_rfm_prj),

clean_database as(
select *, (quantityordered-avg)/stddev as z_score
from base
where abs((quantityordered-avg)/stddev)<=3)
  
----Doanh thu theo từng ProductLine, Year  và DealSize?

select 
productline, year_id, dealsize,
sum(sales) as revenue
from clean_database
group by productline, year_id, dealsize

---Đâu là tháng có bán tốt nhất mỗi năm?
select
month_id,
sum(sales) as revenue,
count(ordernumber) as order_number
from clean_database
group by month_id
order by revenue desc, order_number desc
limit 1

---Product line nào được bán nhiều ở tháng 11?
select productline, month_ID, 
sum(sales) as revenue,
count(ordernumber) as ORDER_NUMBER 
from clean_database
where month_id =11
group by productline, month_ID
order by sum(sales) desc , count(ordernumber) desc 
limit 1

---Đâu là sản phẩm có doanh thu tốt nhất ở UK mỗi năm? Xếp hạng các các doanh thu đó theo từng năm.
ranking as(
select year_id, productline,
sum(sales) as revenue,
rank() over (partition by year_id order by sum(sales) desc) as rank
from clean_database
where country= 'UK'
group by year_id, productline)

select * from ranking
where rank=1

---Ai là khách hàng tốt nhất, phân tích dựa vào RFM 
with RFM_calc as 
(select 
contactfullname,
current_date - max(orderdate) as R,
count(distinct ordernumber) as F,
sum(sales) as M 
from clean_database
group by contactfullname),

scores as 
(select contactfullname,
ntile(5) over(order by R desc) as
R_score,
ntile(5) over(order by F ) as F_score,
ntile(5) over(order by M ) as M_score
from cte),
  
segmentation as
(select contactfullname,
 cast(R_score as varchar)|| cast(R_score as varchar)||cast(R_score as varchar)
 as rfm_score from scores)

 select contactfullname, rfm_score from segmentation as a join public.segment_score as b 
 on a.rfm_score = b.scores
 where segment = 'Champions'

