--EX1
SELECT 
 COUNT(CASE WHEN
   device_type = 'laptop' THEN 1 ELSE 0
 END) AS laptop_views,
 
 COUNT(CASE WHEN
  device_type IN ('tablet','phone') THEN 1 ELSE 0 
 END) AS mobile_views
 
 from viewership;

--EX2
select *,
case when x+y>z and x+z>y and y+z>x then 'Yes' else 'No'
end as triangle
from Triangle

--EX3
SELECT
  ROUND(100.0 * COUNT (case_id) FILTER (
    WHERE call_category IS NULL OR call_category = 'n/a')
  / COUNT (case_id), 1) AS uncategorised_call_pct
FROM callers;

--EX4
SELECT name from Customer
where referee_id!=2 or referee_id is null;

--EX5
select survived,
SUM (CASE WHEN pclass=1 then 1 else 0
END) as first_class,

SUM (CASE WHEN pclass=2 then 1 else 0
END) as second_class,

SUM (CASE WHEN pclass=3 then 1 else 0
END) as third_class

from titanic
group by survived
