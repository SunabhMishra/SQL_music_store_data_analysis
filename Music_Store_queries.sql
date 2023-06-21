/*	Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */
select * from employee order by levels desc limit 1;


/* Q2: Which countries have the most Invoices? */
select billing_country, count(*) as invoice_count from invoice 
group by billing_country 
order by invoice_count desc;


/* Q3: What are top 3 values of total invoice? */
select total from invoice order by total desc limit 3;


/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select billing_city, sum(total) as total_invoice from invoice 
group by billing_city 
order by total_invoice desc limit 1;


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select c.customer_id, c.first_name, c.last_name, sum(i.total) as total_invoice 
from invoice as i join
customer as c on c.customer_id = i.customer_id
group by c.customer_id 
order by total_invoice desc limit 1;


/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select distinct( c.email), c.customer_id, c.first_name, c.last_name 
from customer as c 
join invoice as i on c.customer_id = i.customer_id 
join invoice_line as il on i.invoice_id = il.invoice_id 
where il.track_id in (
select track_id from track as t 
join genre as g on g.genre_id = t.genre_id
where g.name like 'Rock') 
order by c.email;


/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select a.name, count(t.name) as number_of_tracks 
from artist as a 
join album as ab on a.artist_id = ab.artist_id
join track as t on t.album_id = ab.album_id  
where t.track_id in (
select track_id from track as t 
join genre as g on g.genre_id = t.genre_id
where g.name like 'Rock')
group by (a.name)
order by number_of_tracks desc limit 10


/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name, milliseconds 
from track 
where milliseconds >
(select avg(milliseconds) from track)
order by milliseconds desc;


/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */

with best_selling_artist as (
	select a.artist_id as artist_id, a.name as artist_name, sum(il.unit_price*il.quantity) as total_sales
	from invoice_line as il
	join track as t on t.track_id = il.track_id
	join album as al on al.album_id = t.album_id
	join artist as a on a.artist_id = al.artist_id
	group by 1
	order by 3 desc
	limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name, sum(il.unit_price*il.quantity) as amount_spent
from invoice as i
join customer as c on c.customer_id = i.customer_id
join invoice_line as il on il.invoice_id = i.invoice_id
join track as t on t.track_id = il.track_id
join album as alb on alb.album_id = t.album_id
join best_selling_artist as bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;


/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */

with popular_genre as (
	select count(il.quantity) as purchases, c.country, g.name, g.genre_id,
	row_number() over(partition by c.country order by count(il.quantity) desc) as RowNo
	from invoice_line as il
	join invoice as i on i.invoice_id = il.invoice_id
	join customer as c on c.customer_id = i.customer_id 
	join track as t on t.track_id = il.track_id
	join genre as g on g.genre_id = t.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc	
)
select * from popular_genre where RowNo = 1;


/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */

with Customter_with_country as (
		select customer.customer_id,first_name,last_name,billing_country, sum(total) as total_spending,
	    row_number() over(partition by billing_country order by sum(total) desc) as RowNo 
		from invoice
		join customer on customer.customer_id = invoice.customer_id
		group by 1,2,3,4
		order by 4 asc,5 desc)
select * from Customter_with_country where RowNo <= 1


