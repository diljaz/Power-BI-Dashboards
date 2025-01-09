with sales as
(
select t1.orderNumber,t1.customerNumber,productCode, quantityOrdered, priceeach*quantityOrdered as sales_value, creditlimit 
from orders t1 
inner join orderdetails t2
on t1.orderNumber = t2.orderNumber
inner join customers t3
on t1.customerNumber = t3.customerNumber
)

select ordernumber, customernumber,
case when creditlimit < 75000 then "a: less than $75k"
when creditlimit between 75000 and 100000 then "b: $75k - $150k"
when creditlimit between 100000 and 150000 then "c: $100k - $150k"
when creditlimit > 150000 then "d: over $150k"
else "Other"
end as creditlimit_group,
sum(sales_value) as sales_value
from sales
group by ordernumber,customernumber, creditlimit_group;