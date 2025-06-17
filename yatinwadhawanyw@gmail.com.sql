--SQL Advance Case Study
SELECT * FROM dbo.DIM_CUSTOMER
SELECT * FROM dbo.DIM_DATE
SELECT * FROM dbo.DIM_LOCATION
SELECT * FROM dbo.DIM_MANUFACTURER
SELECT * FROM dbo.DIM_MODEL
SELECT * FROM dbo.FACT_TRANSACTIONS

--Q1--BEGIN	
SELECT STATE , YEAR(Date) AS Year
FROM dbo.DIM_LOCATION AS A
INNER JOIN dbo.FACT_TRANSACTIONS AS B ON A.IDLOCATION = B.IDLOCATION
WHERE YEAR(Date) BETWEEN ('2005') AND GETDATE()
GROUP BY STATE, YEAR(Date)

--Q1--END--

--Q2--BEGIN
SELECT TOP 1 State
FROM dbo.DIM_LOCATION AS A
INNER JOIN dbo.FACT_TRANSACTIONS AS B ON A.IDLocation = B.IDLocation
INNER JOIN dbo.DIM_MODEL AS C ON B.IDModel = C.IDModel
INNER JOIN dbo.DIM_MANUFACTURER AS D ON c.IDManufacturer = d.IDManufacturer
WHERE Manufacturer_Name = 'Samsung'
GROUP BY State
ORDER BY SUM(Quantity) DESC;

--Q2--END

--Q3--BEGIN      
SELECT Model_Name, ZipCode, State, COUNT(IDCustomer) AS NO_OF_TANS 
FROM dbo.DIM_LOCATION AS A
INNER JOIN dbo.FACT_TRANSACTIONS AS B ON A.IDLocation = B.IDLocation
INNER JOIN dbo.DIM_MODEL AS C ON B.IDModel = C.IDModel
GROUP BY  Model_Name, ZipCode, State;

--Q3--END

--Q4--BEGIN
SELECT TOP 1 IDModel,Model_Name
FROM dbo.DIM_MODEL
ORDER BY Unit_price;

--Q4--END

--Q5--BEGIN
SELECT Model_Name, AVG(Unit_price) AS AVG_OF_PRICE
FROM dbo.DIM_MODEL AS A
INNER JOIN dbo.DIM_MANUFACTURER AS B ON A.IDManufacturer = B.IDManufacturer
WHERE Manufacturer_Name IN
(
SELECT TOP 5 Manufacturer_Name FROM dbo.FACT_TRANSACTIONS AS C
INNER JOIN dbo.DIM_MODEL AS D ON C.IDModel = D.IDModel
INNER JOIN dbo.DIM_MANUFACTURER AS E ON D.IDManufacturer = E.IDManufacturer
GROUP BY Manufacturer_Name
ORDER BY SUM(Quantity)
)
GROUP BY Model_Name
ORDER BY AVG(Unit_price) DESC;

--Q5--END

--Q6--BEGIN
SELECT Customer_Name, AVG(TotalPrice) AS AVG_PRICE
FROM dbo.DIM_CUSTOMER AS A 
INNER JOIN DBO.FACT_TRANSACTIONS AS B ON A.IDCustomer = B.IDCustomer
WHERE YEAR(Date) = '2009'
GROUP BY Customer_Name
HAVING  AVG(TotalPrice)>500;

--Q6--END

--Q7--BEGIN  
select IDModel from 
(select idmodel,ROW_NUMBER() over(partition by year([date])
order by quantity desc) m
from
FACT_TRANSACTIONS
where year([date]) in (2008,2009,2010))l
where m<=5
group by IDModel
having count(*)=3

--Q7--END	

--Q8--BEGIN
select top 1 * from (select top 2  Manufacturer_Name ,sum(totalprice) [Sales in Year 2009] from FACT_TRANSACTIONS ft
left join DIM_MODEL dm on ft.IDModel =dm.IDModel
left join DIM_MANUFACTURER dma on dm.IDManufacturer = dma.IDManufacturer
where DATEPART(year,date)='2009'
group by Manufacturer_Name, Quantity
order by sum(TotalPrice)desc) as A,
(select top 2  Manufacturer_Name ,sum(totalprice) [Sales in Year 2010]from FACT_TRANSACTIONS ft
left join DIM_MODEL dm on ft.IDModel =dm.IDModel
left join DIM_MANUFACTURER dma on dm.IDManufacturer = dma.IDManufacturer
where DATEPART(year,date)='2010'
group by Manufacturer_Name, Quantity
order by sum(TotalPrice)desc) as B

--Q8--END

--Q9--BEGIN
SELECT Manufacturer_Name
FROM dbo.DIM_MANUFACTURER AS A
INNER JOIN dbo.DIM_MODEL AS B ON A.IDManufacturer = B.IDManufacturer
INNER JOIN dbo.FACT_TRANSACTIONS AS C ON B.IDModel = C.IDModel
WHERE YEAR(Date) = 2010
EXCEPT 
SELECT Manufacturer_Name
FROM dbo.DIM_MANUFACTURER AS D 
INNER JOIN dbo.DIM_MODEL AS E ON D.IDManufacturer = E.IDManufacturer
INNER JOIN dbo.FACT_TRANSACTIONS AS F ON E.IDModel = F.IDModel
WHERE YEAR(Date) = 2009;

--Q9--END

--Q10--BEGIN
select top 100 t1.customer_name,T1.Year,t1.Average_Price,t1.Average_Quantity,
case when t2.year is not null
then  format(convert (decimal(8,2), (t1.Average_Price-t2.Average_Price)) / convert(decimal (8,2), t2.Average_Price),'p') else null
end as 'Yearly % Change' from

(select t2.customer_name, year (t1.date) as Year , avg(t1.totalprice) as Average_Price ,avg(t1.quantity) as Average_Quantity from FACT_TRANSACTIONS as t1
left join  DIM_CUSTOMER as t2  on  t1.IDCustomer = t2.IDCustomer
where  t1.IDCustomer in (select top 10 idcustomer from FACT_TRANSACTIONS group by IDCustomer order by sum (totalprice) desc)
group by t2.Customer_Name , year(t1.date)
)
t1 left join
(select t2.customer_name , year(t1.date) as Year , avg(t1.totalprice)  as Average_Price ,avg(t1.quantity) as Average_Quantity from FACT_TRANSACTIONS as t1
left join  DIM_CUSTOMER as t2 on t1.IDCustomer = t2.IDCustomer
where t1.IDCustomer in(select top 10  idcustomer from  FACT_TRANSACTIONS group by IDCustomer order by sum(totalprice) desc)
group by  t2.Customer_Name, year(t1.date))

t2 on t1.Customer_Name = t2.Customer_Name and t2.year = t1.year-1

--Q10--END
