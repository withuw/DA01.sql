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
SELECT a.customer_id
FROM customer_contracts AS a
LEFT JOIN products AS b 
ON a.product_id=b.product_id
GROUP BY a.customer_id
HAVING COUNT (DISTINCT b.product_category)
=(SELECT COUNT(DISTINCT product_category) from products)
;
--EX5
select emp.reports_to AS employee_id, mng.name,
COUNT(*) AS reports_count,
ceiling(AVG(emp.age)) AS average_age
FROM Employees AS emp
INNER JOIN Employees AS mng
ON emp.reports_to=mng.employee_id
GROUP BY emp.reports_to
ORDER BY emp.reports_to;

--EX6
select a.product_name, SUM(unit) AS unit
FROM Products as a
LEFT JOIN Orders as b
ON a.product_id=b.product_id
WHERE b.order_date BETWEEN '2020-02-01' AND '2020-02-29'
GROUP BY a.product_name
HAVING SUM(unit)>=100;

--EX7
SELECT a.page_id
FROM pages AS a  
LEFT JOIN page_likes as b 
ON a.page_id=b.page_id
WHERE b.page_id is null
ORDER BY a.page_id ASC;
