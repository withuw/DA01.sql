--EX1
SELECT Country.Continent, FLOOR(AVG(City.Population))
FROM Country INNER JOIN City 
WHERE Country.Code = City.CountryCode 
GROUP BY Country.Continent;

--EX2
