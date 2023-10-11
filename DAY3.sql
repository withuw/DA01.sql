---EX1
SELECT NAME FROM CITY
WHERE COUNTRYCODE='USA'
AND POPULATION>120000;
---EX2
SELECT * FROM CITY
WHERE COUNTRYCODE = 'JPN';
---EX3
SELECT CITY, STATE FROM STATION;
---EX4
select CITY from STATION
where CITY LIKE IN ('a%','e%','i%','o%','u%');
---EX5
select CITY from STATION
where CITY LIKE IN ('%a','%e','%i','%o','%u');
---EX6
select CITY from STATION
where CITY LIKE IN ('a%','e%','i%','o%','u%');
---EX7
SELECT name from Employee
ORDER BY name asc;
---EX8
select name from Employee
where salary>2000
and months<10
order by employee_id asc;
---EX9
select product_id from Products
where low_fats='Y'
and recyclable='Y';
---EX10
SELECT name from Customer
where referee_id!=2 or referee_id is null;
---EX11
Select name, population, area from World
where area>=3000000 or population>=25000000;
---EX12
select distinct author_id as id from Views
where author_id=viewer_id
order by author_id asc;
---EX13
SELECT part FROM parts_assembly
where finish_date is null;
---EX 14
select * from lyft_drivers
where yearly_salary<=30000 or yearly_salary>=70000;
---EX 15
select advertising_channel from uber_advertising
where money_spent>100000 and year=2019;
