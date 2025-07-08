# SQL-Project_Awesome_chocolate
This project involves a comprehensive analysis of Awesome Chocolate data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objective
1. Analyaze the distribution of the Sales in each region.
2. Retriving top Products & country(geo) based on total sales.
3. Salesperson from each region with Total sale and number of boxes sold the most.
4. Monthly sales and Total Boxes sold in months.

## Dataset
This <a href="https://github.com/Yashchavan9709/SQL-Project_Awesome_chocolate/blob/main/awesome-chocolates-data.sql">Dataset</a> is used for the project. 

## Business Problems & Solutions
1.Show the total amount of sales for each region.
<pre>
Select g.Region, sum(s.Amount) Total_sales
from geo g
join sales s
 	on g.GeoID = s.GeoID
group by g.Region;
</pre>

Q2.List the salespeople who have made more than 5 sales.
<pre>
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
</pre>

Q3.Find the top 3 products with the highest total amount of sales. 
<pre>
select pd.Product, sum(s.Amount) as total
from products pd
join sales s
	on(pd.PID = s.PID)
group by pd.Product
order by total desc
limit 3;
</pre>

Q4.For each category, calculate the average cost_per_box.
<pre>
select pd.Category, count(s.Customers) as AB
from products pd
join sales s
	on(pd.PID = s.PID)
group by Category; 
</pre>

Q5.Retrieve the total amount of sales for each product by joining sales and products.
<pre>
select p.Product, sum(s.Amount) Total_Sales
from products p
join sales s
	on p.PID = s.PID
group by p.Product
order by Total_Sales desc;
</pre>

Q6. How many shipments (sales) each of the sales persons had in the month of January 2022?
<pre>
select s.SPID, SaleDate, count(s.Boxes), sum(amount)
from sales s
join people p
	on s.SPID = p.SPID
where year(s.SaleDate) = 2022 and month(s.saledate) = 1
group by 1,2;
</pre>

Q7. List the top 3 country with the highest number of customers.
<pre>
select g.Geo, sum(s.Customers) as total_customers
from geo g
join sales s
	on g.GeoID = s.GeoID
group by g.geo
order by total_customers desc
limit 3;
</pre>

Q8. For each product category, find the salesperson who sold the highest number of boxes.
<pre>
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
</pre>

Q9. Using a window function, calculate the running total/cummulative sum of amount for each salesperson ordered by Salesdate.
<pre>
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
</pre>

Q10. How many times we shipped more than 1,000 boxes in each month?
<pre>
select month(SaleDate) sd, count(SumOfBoxes) as TotalBoxes
from (
	select SaleDate, sum(Boxes) as SumOfBoxes
    from sales
    group by SaleDate
) as sale
where year(SaleDate) = 2021 and SumOfBoxes > 10000
group by sd;
</pre>

Q11. Create a CTE to calculate total boxes sold for each product, then find the top product by boxes sold.
<pre>
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
</pre>

Q12. Did we ship at least one box of ‘After Nines’ to ‘New Zealand’ on all the months?
<pre>
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
</pre>

Q13. India or Australia? Who buys more chocolate boxes on a monthly basis?
<pre>
select date_format(s.saledate, '%Y - %m') as mnt,
sum(CASE WHEN g.geo='India' THEN boxes ELSE 0 END) 'India Boxes',
sum(CASE WHEN g.geo='Australia' THEN boxes ELSE 0 END) 'Australia Boxes'
from geo g
join sales s
	on g.GeoID = s.GeoID
where g.geo in('India', 'Australia')
group by mnt
order by mnt asc;
</pre>

Q14. Using a CTE, calculate the percentage of total amount contributed by each region.
<pre>
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
</pre>

15. Monthly sales and Sold boxes
<pre>
select date_format(saledate, '%Y-%m') as month, sum(Amount) as Sales, sum(Boxes) Total_Boxes
from sales 
group by 1;
</pre>
