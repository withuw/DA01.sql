SELECT * FROM public.sales_dataset_rfm_prj;
---Change appropriate data type for columns
ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN orderdate TYPE date USING (trim(orderdate)::date)
ALTER COLUMN quantityordered TYPE numeric USING (trim(quantityordered)::numeric),
ALTER COLUMN priceeach TYPE numeric USING (trim(priceeach)::numeric),
ALTER COLUMN orderlinenumber TYPE numeric USING (trim(orderlinenumber)::numeric),
ALTER COLUMN sales TYPE numeric USING (trim(sales)::numeric),
ALTER COLUMN msrp TYPE numeric USING (trim(quantityordered)::numeric),
ALTER COLUMN city TYPE text USING (trim(city)::text),
ALTER COLUMN state TYPE text USING (trim(state)::text),
ALTER COLUMN country TYPE text USING (trim(country)::text)

--Check for NULL/BLANK (‘’)  in: ORDERNUMBER, QUANTITYORDERED, PRICEEACH, ORDERLINENUMBER, SALES, ORDERDATE.
SELECT * from sales_dataset_rfm_prj
WHERE ordernumber IS NULL OR
quantityordered IS NULL OR
priceeach IS NULL OR
orderlinenumber IS NULL OR
sales IS NULL OR
orderdate IS NULL

---Add column CONTACTLASTNAME, CONTACTFIRSTNAME from CONTACTFULLNAME 
ALTER TABLE public.sales_dataset_rfm_prj
ADD column contactfirstname VARCHAR (50)

UPDATE sales_dataset_rfm_prj
SET contactfirstname = LEFT(contactfullname, POSITION ('-' IN contactfullname) -1)

ALTER TABLE sales_dataset_rfm_prj
ADD column contactlastname VARCHAR (50)

UPDATE sales_dataset_rfm_prj
SET contactlastname = RIGHT(contactfullname, LENGTH(contactfullname) - POSITION ('-' IN contactfullname))

---Update CONTACTLASTNAME, CONTACTFIRSTNAME to capitalize the first letter and make the subsequent letters lowercase. 

UPDATE sales_dataset_rfm_prj
SET contactlastname= INITCAP(contactlastname)

UPDATE sales_dataset_rfm_prj
SET contactfirstname= INITCAP(contactfirstname)

---Find outliers for column QUANTITYORDERED (2 ways)

----1: Using Boxplot

WITH min_max_values AS(
SELECT Q1 - 1.5*IQR AS min_value,
Q3 + 1.5*IQR AS max_value
FROM
(SELECT 
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY quantityordered) AS Q1,
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY quantityordered) AS Q3,
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY quantityordered)
- PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY quantityordered) AS IQR
FROM sales_dataset_rfm_prj) as a)

SELECT * FROM sales_dataset_rfm_prj
WHERE quantityordered < (select min_value from min_max_values)
OR quantityordered > (select max_value from min_max_values)

---2: Using Z-Score

with base as (
select quantityordered,
(select avg(quantityordered) from sales_dataset_rfm_prj as avg),
(select stddev(quantityordered) from sales_dataset_rfm_prj as stddev)
from sales_dataset_rfm_prj)

select *, (quantityordered-avg)/stddev as z_score
from base
where abs((quantityordered-avg)/stddev)>3

----BEGIN ANALYSIS
  
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
  
----Revenue grouped by ProductLine, Year and DealSize?

select 
productline, year_id, dealsize,
sum(sales) as revenue
from clean_database
group by productline, year_id, dealsize

---Which is the month that has most sales?
select
month_id,
sum(sales) as revenue,
count(ordernumber) as order_number
from clean_database
group by month_id
order by revenue desc, order_number desc
limit 1

---Which Product line was sold the most on November?
select productline, month_ID, 
sum(sales) as revenue,
count(ordernumber) as ORDER_NUMBER 
from clean_database
where month_id =11
group by productline, month_ID
order by sum(sales) desc , count(ordernumber) desc 
limit 1

---Which product has the most revenue in UK per year? Rank the revenue per year.
ranking as(
select year_id, productline,
sum(sales) as revenue,
rank() over (partition by year_id order by sum(sales) desc) as rank
from clean_database
where country= 'UK'
group by year_id, productline)

select * from ranking
where rank=1

---RFM Analysis
with RFM_calc as 
(select 
contactfullname,
current_date - max(orderdate) as Recency,
count(distinct ordernumber) as Frequency,
sum(sales) as Monetary
from clean_database
group by contactfullname),

scores as 
(select contactfullname,
ntile(5) over(order by Recency desc) as
R_score,
ntile(5) over(order by Frequency ) as F_score,
ntile(5) over(order by Monetary ) as M_score
from cte),
  
segmentation as
(select contactfullname,
 cast(R_score as varchar)|| cast(R_score as varchar)||cast(R_score as varchar)
 as rfm_score from scores)

 select contactfullname, rfm_score from segmentation as a join public.segment_score as b 
 on a.rfm_score = b.scores
 where segment = 'Champions'
