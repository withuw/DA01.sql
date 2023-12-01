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
