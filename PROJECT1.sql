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

---Add columns QTR_ID, MONTH_ID, YEAR_ID, which are quarters, months, years extracted from ORDERDATE 

ALTER TABLE sales_dataset_rfm_prj
ADD COLUMN QTR_ID numeric, 
ADD column MONTH_ID numeric, 
ADD column YEAR_ID numeric

UPDATE sales_dataset_rfm_prj
SET QTR_ID= EXTRACT (quarter FROM orderdate),
MONTH_ID= EXTRACT (month FROM orderdate),
YEAR_ID= EXTRACT (year FROM orderdate)

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

