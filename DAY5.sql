--EX1
select distinct CITY from STATION
where ID%2=0;
--EX2
SELECT COUNT(CITY)-COUNT(DISTINCT CITY) FROM STATION;
--EX4
SELECT round(CAST(SUM(item_count*order_occurrences)/SUM(order_occurrences) as decimal),1) AS mean
FROM items_per_order;
--EX 5
SELECT candidate_id FROM candidates
WHERE skill in ('Python', 'Tableau','PostgreSQL')
group by candidate_id
having count(skill)=3;
--EX6
SELECT  user_id,
date(max(post_date))-date(min(post_date)) as days_between
from posts
where post_date>='2021-01-01' and post_date<'2022-01-01'
group by user_id
having count(post_id)>=2;
--EX 7
select card_name,
max(issued_amount)-min(issued_amount) as difference
from monthly_cards_issued
group by card_name
order by difference desc;
--EX 8
SELECT manufacturer,
abs(sum(cogs-total_sales)) as total_loss,
count(drug) as drug_count
from pharmacy_sales
where cogs>total_sales
group by manufacturer
order by total_loss desc;
--EX9
Select * from Cinema
where id%2!=0
and not description='boring'
order by rating desc;
--EX10
select teacher_id,
count(distinct subject_id) as cnt
from Teacher
group by teacher_id;
--EX 11
SELECT user_id,
count(follower_id) as followers_count
from Followers
group by user_id
order by user_id asc;
--EX 12
SELECT class from Courses
group by class
having count(student)>=5;
