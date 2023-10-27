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
select c.title,c.length,a.name 
from category as a
inner join film_category as b
on a.category_id=b.category_id
inner join film as c
on b.film_id=c.film_id
where a.name='Sports' or a.name='Drama'
order by length desc
limit 1
	
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
select city.city, sum(payment.amount) as sum
from payment
inner join customer
on payment.customer_id=customer.customer_id
inner join address
on
customer.address_id=address.address_id
inner join city
on address.city_id=city.city_id
group by city.city
order by sum desc
limit 1

--Q8
select concat(city.city,', ',country.country),
sum(payment.amount) as sum
from payment
inner join customer
on payment.customer_id=customer.customer_id
inner join address
on
customer.address_id=address.address_id
inner join city
on address.city_id=city.city_id
inner join country
on city.country_id=country.country_id
group by city.city, country.country
order by sum asc
limit 1
