--Q1
select distinct replacement_cost
from film
order by replacement_cost asc
limit 1

--Q2
select 
sum(case when replacement_cost
	 between '9.99' and '19.99' then 1 else 0
	 end) as low
from film

--Q3

--Q4
select name,
count(name)
from category as a
inner join film_category as b
on a.category_id=b.category_id
group by name
order by count desc
limit 1

--Q5
SELECT concat(first_name, ' ', last_name) AS actor_name, 
count(*) AS total
FROM actor as a
INNER JOIN film_actor as b
ON a.actor_id=b.actor_id
GROUP BY actor_name
ORDER BY total DESC
LIMIT 1

-- Q6
select
count (*)
from address as a
left join customer as b
on a.address_id=b.address_id
where b.address_id is null

--Q7
