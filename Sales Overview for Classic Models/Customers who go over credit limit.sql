with cte_sales as 
(
select 
orderDate,
t1.customerNumber,
t1.orderNumber,
customerName,
productCode,
creditLimit,
quantityOrdered*priceEach as sales_value 
from orders t1
inner join orderdetails t2
on t1.orderNumber=t2.orderNumber
inner join customers t3
on t1.customerNumber=t3.customerNumber
),

running_total_sales_cte as
(
select *, lead(orderDate) over (partition by customerNumber order by orderDate) as next_order_date
from
	(
	select orderdate,
	orderNumber,
	customerNumber,
	customername,
	creditlimit,
	sum(sales_value) as sales_value
	from cte_sales
	group by
	orderdate,
	orderNumber,
	customerNumber,
	customername,
	creditlimit
	)subquery
),

payment_cte as
(
select *
from payments
),

main_cte as
(
select t1.*,
sum(sales_value) over (partition by t1.customerNumber order by orderDate) as running_total_sales_value,
sum(amount) over (partition by t1.customerNumber order by orderDate) as running_total_payments 
from running_total_sales_cte t1
left join payment_cte t2
on t1.customerNumber = t2.customerNumber and t2.paymentDate between t1.orderDate and case when t1.next_order_date is null then current_date() else next_order_date end 
)

select *, (running_total_sales_value - running_total_payments) as money_owed,
creditlimit - (running_total_sales_value - running_total_payments) as difference
from main_cte