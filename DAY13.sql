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
with appliance_ranking AS
(
select category, product,
sum(spend) as total_spend
from product_spend
where category = 'appliance'
and extract(year from transaction_date)=2022
group by category, product
order by total_spend DESC
limit 2
),

electronics_ranking AS
(
select category, product,
sum(spend) as total_spend
from product_spend
where category = 'electronics'
and extract(year from transaction_date)=2022
group by category, product
order by total_spend DESC
limit 2
)

select category, product, total_spend
from appliance_ranking
UNION
select category, product, total_spend
from electronics_ranking


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

with mau_count AS
(
SELECT user_id as mau
from user_actions
where extract(month from event_date)= 06 or extract(month from event_date)= 07
AND extract(year from event_date)= 2022
group by user_id
having count(distinct extract(month from event_date))= 2
)

select '7' as month, count(mau) as monthly_active_users from mau_count


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
with top_name AS
(
select a.name,
count(b.user_id) as user_id_count
from Users as a
JOIN MovieRating as b
ON a.user_id = b.user_id
group by b.user_id
order by user_id_count desc, a.name asc
limit 1
),

top_movie as
(
select c.title,
avg(b.rating) as rating_average
from Movies as c
JOIN MovieRating as b
ON b.movie_id = c.movie_id
where created_at between '2020-01-31' and '2020-02-29'
group by c.movie_id
order by rating_average desc, c.title asc
limit 1
)

select name as results from top_name
UNION ALL
select title as results from top_movie

--ex12


















