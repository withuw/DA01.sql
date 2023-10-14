--EX1
select Name
from STUDENTS
where Marks>75
order by Right(Name,3), ID asc;
--ex2
# Write your MySQL query statement below
SELECT user_id, concat(upper(left(name,1)),lower(substring(name,2))) as name
from Users
order by user_id;
--ex3
SELECT manufacturer,
concat('$',round(sum(total_sales)/1000000),' million') as sale
FROM pharmacy_sales
group by manufacturer
order by sum(total_sales) desc;
--ex4
SELECT extract(month from submit_date) as mnth, product_id as product,
round(avg(stars),2) as avg_stars
FROM reviews
group by extract(month from submit_date), product_id;
--ex5
SELECT sender_id,
count(message_id) as message_count
FROM messages
where sent_date between '2022-08-01' and '2022-09-01'
group by sender_id
order by count(message_id) desc
limit 2;
--ex6
select tweet_id
from Tweets
where length(content)>15;
--ex7
select activity_date as day,
count(distinct(user_id)) as active_users
from Activity
where activity_date between '2019-06-28' and '2019-07-27'
group by activity_date;
--ex8
select count(*) from employees as hired_number
where joining_date between '2022-01-01' and '2022-08-01';
--ex9
select position('a' in first_name) from worker
where first_name='Amitah';
--ex10
select title as wine, substring(title from position ('2' in title) for 4) from winemag_p2 as vintage_years;
