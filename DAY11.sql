--EX1
SELECT Country.Continent, FLOOR(AVG(City.Population))
FROM Country INNER JOIN City 
WHERE Country.Code = City.CountryCode 
GROUP BY Country.Continent;

--EX2
SELECT
round(cast(SUM(CASE WHEN texts.signup_action='Confirmed' then 1 else 0 END) as decimal)
/COUNT(distinct emails.email_id), 2) AS activation_rate
FROM emails
LEFT JOIN texts
  ON emails.email_id = texts.email_id;
--EX3
SELECT 
b.age_bucket,
round(SUM(CASE WHEN a.activity_type= 'send' THEN time_spent ELSE 0 END)*100.0
/SUM(a.time_spent),2)
AS send_perc,
round(SUM(CASE WHEN a.activity_type= 'open' THEN time_spent ELSE 0 END)*100.0
/SUM(a.time_spent),2)
AS open_perc
FROM activities AS a
INNER JOIN age_breakdown AS b
ON a.user_id=b.user_id
GROUP BY b.age_bucket; --cau nay em submit thi bi sai nhung em ko biet sai o dau a :<
--EX4
