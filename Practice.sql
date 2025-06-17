select * from dbo.Customer
select * from dbo.prod_cat_info
select * from dbo.Transactions


-- DATA PREPARATION AND UNDERSTANDING

--Q.1 WHAT IS THE TOTAL NUMBER OF ROWS IN EACH OF THE 3 TABLES IN THE DATABASE?
select 'customer' As Tables, count(*) As Total_No_of_Raws from dbo.Customer union all
select 'prod_cat_info' As Tables, count(*) As Total_No_of_Raws from dbo.prod_cat_info union all
select 'Transactions' As Tables, count(*) As Total_No_of_Raws from dbo.Transactions;

--Q.2 WHAT IS THE TOTAL NUMBER OF TRANSACTIONS THAT HAVE A RETURN?
select count(total_amt) As Total_No_of_ReturnTrans
from dbo.Transactions
where total_amt < 0;

/*Q.3 AS YOU WOULD HAVE NOTICED, THE DATES PROVIDED ACROSS THE DATASETS ARE NOT IN A CORRECT FORMAT.
FIRST STEP, PLS CONVERT THE DATE VARIABLES INTO VALID DATE FORMATS BEFORE PROCEEDING AHEAD.*/
select CONVERT(Date,DOB, 105) As DOB from dbo.Customer
select CONVERT(DATE,Tran_date, 105) AS Tran_date from dbo.Transactions

--Q.4 WHAT IS THE TIME RANGE OF THE TRANSACTION DATA AVAILABLE FOR ANALYSIS? SHOW THE OUTPUT IN NUMBER OF DAYS, MONTHS AND YEAR  SIMULTANEOUSLY IN DIFFERENT COLUMNS.
select DATEDIFF(day, min(convert(date,tran_date,105)), max(convert(date,tran_date,105))) As [NO_Of_Days],
DATEDIFF(month, min(convert(date, tran_date, 105)), max(convert(date, tran_date, 105))) As [NO_Of_Months],
DATEDIFF(year, min(convert(date, tran_date, 105)), max(convert(date,tran_date, 105))) As [NO_Of_Years]
from dbo.Transactions

--Q.5 WHICH PRODUCT CATEGORY DOES THE SUB-CATEGORY "DIY" BELONGS TO?
select prod_cat, prod_subcat from dbo.prod_cat_info
where prod_subcat = 'DIY';

-------------- DATA ANALYSIS-------------------------------

--Q.1 WHICH CHANNEL IS MOST FREQUENTLY USED FOR TRANSACTIONS?
select * from dbo.Transactions

select top 1 store_type, count(transaction_id) from dbo.Transactions
group by Store_type
order by count(transaction_id) desc;

--Q.2 WHAT IS THE COUNT OF MALE AND FEMALE CUSTOMER IN THE DATABASE?
select * from dbo.Customer

select Gender ,count(customer_Id) As No_of_Genders from dbo.Customer
where not gender = 'null'
group by gender
order by count(customer_Id) desc;

--Q.3 FROM WHICH CITY DO WE HAVE THE MAXIMUM NUMBER OF CUSTOMER AND HOW MANY?
select * from dbo.Customer

select top 1 city_code , count(customer_id) As Max_No_Of_Cust from dbo.Customer
group by city_code
order by count(customer_id) desc;

--Q.4 HOW MANY SUB-CATEGORY ARE THERE UNDER THE BOOKS CATEGORY?
select * from dbo.prod_cat_info

select prod_cat, count(prod_subcat) As No_of_subcat from dbo.prod_cat_info
where prod_cat LIKE 'BOOKS'
group by prod_cat
order by No_of_subcat desc;

--Q.5 WHAT IS THE MAXIMUM QUALITY OF PRODUCTS EVER ORDER?
select top 1 prod_cat, sum(Qty) As Max_prod_order
from dbo.Transactions As T
Inner join dbo.prod_cat_info As P
ON T.prod_cat_code = P.prod_cat_code And T.prod_subcat_code = P.prod_sub_cat_code
where Qty > 0
group by prod_cat
order by Max_prod_order desc;

--Q.6 WHAT IS THE NET TOTAL REVENUE GENERATED IN CATEGORY 'ELECTRONICS' & 'BOOKS'?

select prod_cat ,sum(total_amt) AS Total_Revenue
from dbo.prod_cat_info AS P
Inner join dbo.Transactions As T
ON P.prod_cat_code = T.prod_cat_code And P.prod_sub_cat_code = T.prod_subcat_code
where p.prod_cat IN ('Electronics' , 'Books')
group by prod_cat
order by Total_Revenue desc;

--Q.7 HOW MANY CUSTOMER HAVE >10 TRANSACTIONS WITH US, EXCLUDING RETURN?

select cust_id, count(cust_id) As Total_No_Of_Cust
from dbo.Transactions As T
where Qty > 0 
group by cust_id
having count(cust_id) > 10
order by count(cust_id) desc;

--Q.8 WHAT IS THE COMBINE REVENUE EARNED FROM THE "ELECTRONICS" & "CLOTHING" CATEGORIES FROM "FLAGSHIP STORE"?

select prod_cat, sum(total_amt) As Combine_Revenue
from dbo.prod_cat_info As P
Inner join dbo.Transactions As T
ON p.prod_cat_code = T.prod_cat_code And P.prod_sub_cat_code = T.prod_subcat_code
where p.prod_cat IN ('Electronics' , 'Clothing') And Store_type = 'Flagship store'
group by prod_cat
order by sum(total_amt) desc;

--Q.9 WHAT IS THE TOTAL REVENUE GENERATED FROM 'MALE' CUSTOMERS IN 'ELECTRONICS' CATEGORY? OUTPUT SHOULD BE DISPLAY TOTAL REVENUE BY PROD SUB_CAT.

select Gender, prod_cat, sum(total_amt) As Total_Revenue
from dbo.Customer As C
inner join dbo.Transactions As T
ON C.customer_Id = T.cust_id 
Left Join dbo.prod_cat_info AS P
ON P.prod_cat_code = T.prod_cat_code And P.prod_sub_cat_code = T.prod_subcat_code
Where C.Gender = 'M' And P.prod_cat = 'Electronics'
group by gender , prod_cat
order by sum(total_amt) desc;

--Q.10 WHAT IS PERCENTAGE OF SALES AND RETURNS BY PRODUCT SUB CATEGORY; DISPLAY ONLY TOP 5 SUB CATEGORIES IN TERMS OF SALES?

select  top 5 prod_subcat, sum(case when total_amt >0 then total_amt else 0 end) as sales_by_subcat,
sum(case when total_amt < 0 then total_amt else 0 end) as return_by_subcat
sum(case when total_amt > 0 then total_amt else 0 end)*100/(select sum(case when total_amt >0 then total_amt else 0 end) 
from dbo.Transactions) as sales_percentage,
sum(case when total_amt < 0 then total_amt else 0 end)*100/(select sum(case when total_amt <0 then total_amt else 0 end) 
from dbo.Transactions) as return_percentage
from dbo.Transactions AS T 
Inner join dbo.prod_cat_info As P 
ON T.prod_cat_code = p.prod_cat_code And T.prod_sub_cat_code = P.prod_subcat_code
group by prod_subcat
order by sales_by subcat desc;

/*.11 FOR ALL CUSTOMER AGED BETWEEN 25 TO 35 YEARS FIND WHAT IS THE NET TOTAL REVENUE GENERATED BY THESE CONSUMERS IN LAST 30 DAYS OF TRANSACTIONS FROM MAX 
TRANSACTIONS DATE AVAILABLE IN THE DATABASE?*/

select sum(total_amt) As Total_Revenue from dbo.Transactions AS T
Inner join dbo.Customer As C On T. 
















