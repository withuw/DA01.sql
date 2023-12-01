---ex1
with duplicate AS
(
select company_id, title, description,
COUNT (job_id) AS job_count
FROM job_listings
group by company_id, title, description
)
select
count (job_count) as duplicate_companies
from duplicate
where job_count>1

---ex2
  
---ex3
with member_calls as
(
SELECT policy_holder_id,
count(case_id) as calls
FROM callers
group by policy_holder_id
)

select count(calls) as member_count
from member_calls
where calls>=3;

--ex4
SELECT a.page_id
FROM pages AS a  
LEFT JOIN page_likes as b 
ON a.page_id=b.page_id
WHERE b.page_id is null
ORDER BY a.page_id ASC;

--ex5

--ex6
select left(trans_date,7) as month, country,
count(id) as trans_count,
sum(case when state='approved' then 1 else 0 end) as approved_count,
sum(amount) as trans_total_amount,
sum(case when state='approved' then amount else 0 end) as approved_total_amount
from Transactions
group by month, country;

--ex7
select product_id, min(year) as first_year, quantity, price
from Sales
group by product_id

--ex8
SELECT  customer_id 
FROM Customer 
GROUP BY customer_id
HAVING COUNT(distinct product_key) = (SELECT COUNT(product_key) FROM Product)

--ex9
select employee_id 
from Employees 
where salary <30000
and manager_id not in (select employee_id from Employees)
order by employee_id

--ex10
with duplicate AS
(
select company_id, title, description,
COUNT (job_id) AS job_count
FROM job_listings
group by company_id, title, description
)
select
count (job_count) as duplicate_companies
from duplicate
where job_count>1

--ex11



















