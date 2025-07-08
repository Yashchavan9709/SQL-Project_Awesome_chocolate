-- ******************** Project question *****************************
-- Q1.Show the total amount of sales for each region. 

Select g.Region, sum(s.Amount) Total_sales
from geo g
join sales s
	on g.GeoID = s.GeoID
group by g.Region;


-- Q2.List the salespeople who have made more than 5 sales.

With cte as(
	select SPID, count(customers) as a
    from sales
    group by SPID
)
select pe.Salesperson, c.a
from people pe
join cte c
	on pe.SPID = c.SPID
where a > (select avg(a) from cte);

-- Q3.Find the top 3 products with the highest total amount of sales. 

select pd.Product, sum(s.Amount) as total
from products pd
join sales s
	on(pd.PID = s.PID)
group by pd.Product
order by total desc
limit 3;

-- Q4.For each category, calculate the average cost_per_box.
select pd.Category, count(s.Customers) as AB
from products pd
join sales s
	on(pd.PID = s.PID)
group by Category; 

-- Q5.Retrieve the total amount of sales for each product by joining sales and products.
select p.Product, sum(s.Amount) Total_Sales
from products p
join sales s
	on p.PID = s.PID
group by p.Product
order by Total_Sales desc;

-- Q6. How many shipments (sales) each of the sales persons had in the month of January 2022?

select s.SPID, SaleDate, count(s.Boxes), sum(amount)
from sales s
join people p
	on s.SPID = p.SPID
where year(s.SaleDate) = 2022 and month(s.saledate) = 1
group by 1,2;

-- Q7. List the top 3 country with the highest number of customers.

select g.Geo, sum(s.Customers) as total_customers
from geo g
join sales s
	on g.GeoID = s.GeoID
group by g.geo
order by total_customers desc
limit 3;

-- Q8. For each product category, find the salesperson who sold the highest number of boxes.

with Cnt_boxes as (
	select p.Category, sp.Salesperson, sum(s.Boxes) as total_boxes
	from products p
	join sales s
		on p.PID = s.PID
	join people sp
		on s.SPID = sp.SPID
	group by p.Category, sp.Salesperson
)
,rnk as(
	select *,
		rank() over(partition by Category order by total_boxes desc) as rank1
	from Cnt_boxes
)
select category, salesperson, total_boxes
from rnk
where rank1 = 1;


-- Q9. Using a window function, calculate the running total/cummulative sum of amount for each salesperson ordered by Salesdate.

select SaleDate, revenue,
		sum(revenue) over(order by SaleDate) as Total
from (
	select /* date_format(s.SaleDate, '%Y - %m') as (use for month) */ SaleDate, sum(s.Amount) as revenue
	from people p
	join sales s
		on p.SPID = s.SPID
	group by s.SaleDate
	order by s.SaleDate
) a
group by SaleDate;

-- Q10. How many times we shipped more than 1,000 boxes in each month?

select month(SaleDate) sd, count(SumOfBoxes) as TotalBoxes
from (
	select SaleDate, sum(Boxes) as SumOfBoxes
    from sales
    group by SaleDate
) as sale
where year(SaleDate) = 2021 and SumOfBoxes > 10000
group by sd;


-- Q11. Create a CTE to calculate total boxes sold for each product, then find the top product by boxes sold.

with top as (
	select p.Product, sum(s.Boxes) as Total_boxes
    from products p
    join sales s
		on p.PID = s.PID
	group by p.Product
    order by Total_boxes desc
)
select Product, Total_boxes
from top
limit 1;

-- Q12. Did we ship at least one box of ‘After Nines’ to ‘New Zealand’ on all the months?

select date_format(s.saledate, '%Y - %m') as mnt, count(s.Boxes), /*if(sum(boxes)>1, 'Yes', 'No') as 'Status',*/
		case
			when sum(boxes)>1 then 'Yes'
			else 'No'
		end as 'Case Status'
from sales s
join products p
	on s.PID = p.PID
join geo g
	on s.GeoID = g.GeoID
where p.Product = 'After Nines' and g.geo = 'New Zealand'
group by mnt;

-- Q13. India or Australia? Who buys more chocolate boxes on a monthly basis?

select date_format(s.saledate, '%Y - %m') as mnt,
sum(CASE WHEN g.geo='India' THEN boxes ELSE 0 END) 'India Boxes',
sum(CASE WHEN g.geo='Australia' THEN boxes ELSE 0 END) 'Australia Boxes'
from geo g
join sales s
	on g.GeoID = s.GeoID
where g.geo in('India', 'Australia')
group by mnt
order by mnt asc;


-- Q14. Using a CTE, calculate the percentage of total amount contributed by each region.

with recursive percentage as (
	select g.Region, sum(s.Amount) as Total_amount
    from geo g
    join sales s
		on g.GeoID = s.GeoID
	group by g.Region
),
Total as(
	select sum(Total_amount) as Grand_Total
    from percentage
)
select Region, Total_amount, (Total_amount/ t.Grand_Total)*100 as Contribute_Percent
from Total t
cross join percentage;



/*PROBLEMS
1.Show the total amount of sales for each region. 
2.List the salespeople who have made more than 5 sales.  
3.Find the top 3 products with the highest total amount of sales.  
4.For each category, calculate the average cost_per_box. 
5.Retrieve the total amount of sales for each product by joining sales and products.
6.How many shipments (sales) each of the sales persons had in the month of January 2022? 
7.List the top 3 country with the highest number of customers.
8.For each product category, find the salesperson who sold the highest number of boxes. 
9.Using a window function, calculate the running total of amount for each salesperson ordered by Salesdate.
10.How many times we shipped more than 1,000 boxes in each month? 
11.Create a CTE to calculate total boxes sold for each product, then find the top product by boxes sold.
12.Did we ship at least one box of ‘After Nines’ to ‘New Zealand’ on all the months?
13.India or Australia? Who buys more chocolate boxes on a monthly basis? 
14.Using a CTE, calculate the percentage of total amount contributed by each region. */

