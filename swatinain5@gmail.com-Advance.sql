--SQL Advance Case Study
select  * from DIM_CUSTOMER
select top 1 * from DIM_DATE
select  * from DIM_LOCATION
select  * from DIM_MANUFACTURER
select  * from DIM_MODEL
select  * from FACT_TRANSACTIONS
  

--Q1--BEGIN 
	
select distinct a.State from DIM_LOCATION as a    --do i have to use subquery here to get distinct states otherwise its giving wrong
inner join FACT_TRANSACTIONS as b
on a.IDLocation=b.IDLocation
where year(b.Date) >='2005'

--Q1--END

--Q2--BEGIN
select top 1 b.State,sum(a.Quantity) as QTY_sold from FACT_TRANSACTIONS as a
inner join DIM_LOCATION as b
on a.IDLocation=b.IDLocation
inner join DIM_MODEL as c
on a.IDModel=c.IDModel
inner join DIM_MANUFACTURER as d
on c.IDManufacturer= d.IDManufacturer
where b.Country='US' and d.Manufacturer_Name ='Samsung'  --18,10
group by b.State
order by QTY_sold desc

--Q2--END

--Q3--BEGIN    --?  
select b.Model_Name,count(a.IDModel) as no_of_tran,c.ZipCode,c.State from FACT_TRANSACTIONS as a
inner join DIM_MODEL as b
on a.IDModel=b.IDModel
inner join DIM_LOCATION as c
on a.IDLocation=c.IDLocation
group by b.Model_Name,c.ZipCode,c.State

--Q3--END

--Q4--BEGIN
select top 1 a.Model_Name,a.Unit_price 
from DIM_MODEL as a                               -- cheapest cellphone by manufacturer name or model name
order by a.Unit_price 

--Q4--END

--Q5--BEGIN  -- in terms of sales or quantity?
 select a.Model_Name,avg(a.Unit_price) as avg_price from DIM_MODEL as a
 inner join DIM_MANUFACTURER as b
 on a.IDManufacturer=b.IDManufacturer
 where b.Manufacturer_Name in 
                              ( select top 5 a.Manufacturer_Name
                                from DIM_MANUFACTURER as a
                                inner join DIM_MODEL as b
                                on a.IDManufacturer=b.IDManufacturer
                                inner join FACT_TRANSACTIONS as c
                                on b.IDModel=c.IDModel
                                group by a.Manufacturer_Name
                                order by sum(c.Quantity) desc )
group by a.Model_Name
order by avg_price

--Q5--END

--Q6--BEGIN
 select a.Customer_Name,avg(b.TotalPrice) as ttl_amt from DIM_CUSTOMER as a
 inner join FACT_TRANSACTIONS as b
on a.IDCustomer=b.IDCustomer
where year(b.Date)='2009'
group by a.Customer_Name
having avg(b.TotalPrice)>500				

--Q6--END
	
--Q7--BEGIN  --doubt in question
select t.Model_Name from 
             (
               select  top 5 a.Model_Name,sum(b.Quantity) as Qty_ from DIM_MODEL as a
               inner join FACT_TRANSACTIONS as b
               on a.IDModel=b.IDModel 
               where year(b.Date)='2008'
               group by a.Model_Name
               order by Qty_ desc) as t
intersect 
select m.Model_Name from 
             (
               select  top 5 a.Model_Name,sum(b.Quantity) as Qty_ from DIM_MODEL as a
               inner join FACT_TRANSACTIONS as b
               on a.IDModel=b.IDModel 
               where year(b.Date)='2009'
               group by a.Model_Name
               order by Qty_ desc ) as m
intersect
select n.Model_Name from 
             (	
                select  top 5 a.Model_Name,sum(b.Quantity) as Qty_ from DIM_MODEL as a
                inner join FACT_TRANSACTIONS as b
                on a.IDModel=b.IDModel 
                where year(b.Date)='2010'
                group by a.Model_Name
                order by Qty_ desc ) as n
--Q7--END	

--Q8--BEGIN  --showing error
select * from 
                (select top 1 * from (
                                      select top 2 a.Manufacturer_Name,sum(c.TotalPrice) as sales_ from DIM_MANUFACTURER as a
                                      inner join DIM_MODEL as b
                                      on a.IDManufacturer=b.IDManufacturer
                                      inner join FACT_TRANSACTIONS as c
                                      on b.IDModel=c.IDModel
                                      where year(c.Date)='2009'
                                      group by a.Manufacturer_Name
                                      order by sales_ desc ) as t
                 order by t.sales_) as m
union all
select * from
                (select top 1 * from (
                                      select top 2 a.Manufacturer_Name,sum(c.TotalPrice) as sales_ from DIM_MANUFACTURER as a
                                      inner join DIM_MODEL as b
                                      on a.IDManufacturer=b.IDManufacturer
                                       inner join FACT_TRANSACTIONS as c
                                      on b.IDModel=c.IDModel
                                      where year(c.Date)='2010'
                                      group by a.Manufacturer_Name
                                      order by sales_ desc ) as t
                  order by t.sales_) as n


--Q8--END

--Q9--BEGIN
select distinct a.Manufacturer_Name from DIM_MANUFACTURER as a  
                inner join DIM_MODEL as b
                on a.IDManufacturer=b.IDManufacturer
                inner join FACT_TRANSACTIONS as c
                on b.IDModel=c.IDModel
                where year(c.Date)='2010'
except                	
select distinct a.Manufacturer_Name from DIM_MANUFACTURER as a  
                inner join DIM_MODEL as b
                on a.IDManufacturer=b.IDManufacturer
                inner join FACT_TRANSACTIONS as c
                on b.IDModel=c.IDModel
                where year(c.Date)='2009'

--Q9--END

--Q10--BEGIN
select *,((n.total_spend-n.lag_spend)/n.lag_spend)*100 as per_chng_spend from
              (
              select *,lag(m.total_spend,1) over(partition by m.IDCustomer order by m.year_) 
			  as lag_spend from 
                               (select t.IDCustomer,avg(a.TotalPrice) as avg_spend,avg(a.Quantity) as avg_qty,
                                  year(a.Date) as year_,sum(a.TotalPrice) as total_spend
								  from FACT_TRANSACTIONS as a
                                  inner join 
                                           (select top 10 a.IDCustomer from DIM_CUSTOMER as a
                                             inner join FACT_TRANSACTIONS as b
                                             on a.IDCustomer=b.IDCustomer
                                             group by a.IDCustomer
                                             order by sum(b.TotalPrice) desc) as t
                                  on a.IDCustomer=t.IDCustomer
                                  group by year(a.Date),t.IDCustomer) as m)as n















--Q10--END
	