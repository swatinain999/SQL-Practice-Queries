create database cs_retail

select  * from Customer
select  * from prod_cat_info
select  * from Transactions

--Data Preparation And Understanding

--Q1.
select count(*) as Total_no_of_rows_in_tables  from Customer as a
union all
select count(*) from prod_cat_info as b
union all
select count(*) from Transactions as c

--Q2.
select count(a.transaction_id) as return_tran from Transactions as a
where a.Qty<0

--Q3.
select CONVERT(DATE,a.tran_date,23) as tran_date from Transactions as a 
select CONVERT(DATE,b.DOB,23) as DOB_ from Customer as b


--Q4.
select datediff(day,'2011-01-25','2014-02-28') as timerange_days,datediff(month,'2011-01-25','2014-02-28') as timerange_month,
datediff(year,'2011-01-25','2014-02-28') as timerange_year

--Q5.
select a.prod_cat from prod_cat_info as a
where a.prod_subcat='diy'

--Data Analysis

--Q1
select top 1 a.Store_type,count(a.Store_type) as chnlcount_ from Transactions as a
group by a.Store_type
order by chnlcount_ desc 

--Q2.
select a.gender, count(a.Gender) as count_ from Customer as a
where a.gender is not null
group by a.Gender


--Q3.
select top 1 a.city_code, count(a.customer_Id) as max_no_of_customers from customer as a
group by a.city_code
order by count(a.city_code) desc

--Q4.
select count(distinct a.prod_subcat) as cnt_subcat
from prod_cat_info as a
group by a.prod_cat
having a.prod_cat='books'

--Q5
select max(a.Qty) as max_qty from Transactions as a

--Q6
select a.prod_cat,sum(b.total_amt) as total_revenue from prod_cat_info as a
inner join Transactions as b
on a.prod_cat_code=b.prod_cat_code
and a.prod_sub_cat_code  = b.prod_subcat_code
where a.prod_cat in ('electronics','books') 
group by a.prod_cat


--Q7.
select count(*) as no_of_customers from
                     (
                       select a.cust_id,count(a.transaction_id) as no_of_transaction
                       from Transactions as a
                       where a.Qty >=1
                       group by a.cust_id
                       having count(a.transaction_id)>10
					   ) as t

--Q8.
select sum(b.total_amt) as total_revenue from prod_cat_info as a
inner join Transactions as b
on a.prod_cat_code=b.prod_cat_code
and a.prod_sub_cat_code  = b.prod_subcat_code
where a.prod_cat in ('electronics','clothing')  and b.Store_type='flagship store'

--Q9.
select c.prod_subcat,sum(b.total_amt) as total_revenue
from Customer as a
inner join Transactions as b
on a.customer_Id=b.cust_id
inner join prod_cat_info as c
on b.prod_cat_code=c.prod_cat_code
and b.prod_subcat_code  = c.prod_sub_cat_code
where a.Gender='m' and c.prod_cat='electronics'
group by c.prod_subcat

--Q10.                                       
select *,(cast(abs(t2.ttl_qty) as float)/(select abs(sum(a.Qty)) from Transactions as a where a.Qty<0))*100 as perc_Of_Return
            from
              (select c.prod_subcat,t1.total_sales,t1.percentage_sales_,c.ttl_qty from
                                        (select a.prod_subcat,sum(b.Qty) as ttl_qty from prod_cat_info as a
                                         inner join Transactions as b
                                         on a.prod_cat_code=b.prod_cat_code and a.prod_sub_cat_code=b.prod_subcat_code
                                         where b.Qty<0
                                         group by a.prod_subcat) as c
              right join(
              select *,(t.total_sales/(select sum(a.total_amt) from Transactions as a))*100 as percentage_sales_
                                  from 
                                          (select top 5 a.prod_subcat,sum(b.total_amt) as total_sales from prod_cat_info as a
                                            inner join Transactions as b
                                             on a.prod_cat_code=b.prod_cat_code
                                            and a.prod_sub_cat_code=b.prod_subcat_code
			                                 group by a.prod_subcat
                                             order by total_sales desc) as t) as t1
              on c.prod_subcat=t1.prod_subcat) as t2



--Q11.

select a.customer_Id,sum(b.total_amt) as total_sales
from Customer as a
inner join Transactions as b
on a.customer_Id=b.cust_id
where DATEDIFF(YEAR,a.DOB,GETDATE()) between 25 and 35
group by a.customer_Id,DATEDIFF(YEAR,a.DOB,GETDATE()),b.tran_date
having b.tran_date <= (select max(a.tran_date) from Transactions as a) 
 and b.tran_date>=(select dateadd(day,-30,max(a.tran_date)) from Transactions as a)

--Q12.
select distinct a.prod_cat from prod_cat_info as a
inner join Transactions as b
on a.prod_cat_code=b.prod_cat_code and a.prod_sub_cat_code=b.prod_subcat_code
where b.Qty in 
               (select min(b.Qty) as max_returns from prod_cat_info as a
                inner join Transactions as b
                on a.prod_cat_code=b.prod_cat_code 
                and a.prod_sub_cat_code=b.prod_subcat_code
                where b.Qty<0)
            and b.tran_date>=(select dateadd(month,-3,(select max(b.tran_date) from transactions as b)))
--Q13.
select top 1 a.Store_type,sum(a.Qty) as total_quantity,sum(a.total_amt) as sales_amount from Transactions as a
group by a.Store_type
order by sales_amount desc,total_quantity desc

--Q14.
select t.prod_cat from
              (select a.prod_cat,avg(b.total_amt) as avg_category from prod_cat_info as a
                 inner join Transactions as b
                 on a.prod_cat_code=b.prod_cat_code 
                 and a.prod_sub_cat_code=b.prod_subcat_code
                 group by a.prod_cat) as t
where t.avg_category>(select avg(a.total_amt) from Transactions as a)

--Q15.
select a.prod_subcat,avg(b.total_amt) as average_,sum(b.total_amt) as total_revenue from prod_cat_info as a
inner join Transactions as b
on a.prod_cat_code=b.prod_cat_code and a.prod_sub_cat_code=b.prod_subcat_code
where a.prod_cat in (
                      select top 5 b.prod_cat from Transactions as a
                       inner join prod_cat_info as b
                      on a.prod_cat_code=b.prod_cat_code 
                      and a.prod_subcat_code=b.prod_sub_cat_code
                      group by b.prod_cat
                      order by sum(a.Qty) desc)
group by a.prod_subcat

