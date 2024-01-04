--ex1
SELECT
extract (year from transaction_date) as year, product_id,
sum(spend) as curr_year_spend,
lag(sum(spend)) over(partition by product_id order by product_id) as prev_year_spend,
round((sum(spend)-(lag(sum(spend)) over(partition by product_id order by product_id)))*100/(lag(sum(spend)) over(partition by product_id order by product_id)),2) as yoy_rate
from user_transactions
group by product_id, extract (year from transaction_date)

--ex2
WITH launch AS (
  SELECT card_name, issued_amount,
  CONCAT(issue_year, issue_month) AS issue_date,
  MIN(CONCAT(issue_year, issue_month)) OVER (PARTITION BY card_name) AS launch_date
  FROM monthly_cards_issued
)

SELECT 
  card_name, 
  issued_amount
FROM launch
WHERE issue_date=launch_date
ORDER BY issued_amount DESC;

--ex3
with third AS (select user_id, spend, transaction_date,
row_number() over (partition by user_id order by transaction_date)
as stt
from transactions
)

SELECT user_id, spend, transaction_date
FROM third
where stt=3

--ex4
with purchase as(
SELECT product_id, user_id, spend, transaction_date,
first_value (transaction_date) 
over (partition by user_id order by transaction_date desc) as first_purchase
FROM user_transactions
)

select transaction_date, user_id, count(product_id) as product_count
from purchase
where transaction_date=first_purchase
group by transaction_date, user_id

--ex6
with repeated as(
select merchant_id, credit_card_id, amount, transaction_timestamp,
lead(transaction_timestamp) over (partition by merchant_id, credit_card_id, amount)
as repeated_transaction
from transactions
)

select count (*) as payment_count
from repeated
where repeated_transaction - transaction_timestamp <= interval '10 minutes'

--ex7
with ranking as(
select category, product, sum(spend) as total_spend,
row_number() over (partition by category order by sum(spend) desc) as stt
from product_spend
where extract (year from transaction_date)=2022
group by product, category)

select category, product, total_spend
from ranking
where stt <=2

--ex8
with ranking as(
SELECT artist_name, count (artist_name) as appearance,
dense_rank() over(order by count (artist_name) desc) as artist_rank
FROM artists as a
inner join songs as b on a.artist_id=b.artist_id
inner join global_song_rank as c on b.song_id=c.song_id
where c.rank <=10
group by artist_name
)

select artist_name, artist_rank
from ranking
where artist_rank <=5

