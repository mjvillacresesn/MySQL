use sakila;

select * from actor;

-- 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name
select concat(first_name, ' ' , last_name) as Actor_name from actor;

-- 2a. find ID, firstname, lastname using only firsname "joe" in one quesry
SELECT * from actor WHERE first_name = "JOE";

-- 2b. Find all actors whose last name contain the letters GEN:
-- wilcard == LKE % 
SELECT * from actor WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. 
-- Order lastname, firstname
SELECT * from actor WHERE last_name LIKE '%LI%' order by last_name, first_name asc;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
-- UNCLEAR ABOUT ABOVE
select country_id, country from country where country IN ("Afghanistan", "Bangladesh", "China"); 

-- 3a. create a column in the table actor named description and use the data type BLOB
alter table actor add description blob;

select * from actor;

-- 3b. Delete column "description"
alter table actor drop column description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
 select count(last_name) from actor;
 
-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
Select a.last_name, count(distinct a.first_name) from actor as a
group by a.last_name
having count(distinct a.first_name) > 1;
 
 -- 4c. Update row record, actor_id = 172
 select * from actor where first_name = "GROUCHO" AND last_name = "WILLIAMS";
 
 update actor set first_name = "HARPO" where actor_id = 172;
 
 -- 4d. update again to "Groucho"
 update actor set first_name = "GROUCHO" where actor_id = 172;
 
-- 5a. Locate the schema of the address table. 
Show create table address;
-- Also, i found table schema by hoovering over "sakila", clicking on "i" info icon,
-- then, selecting the "tables" tab, then right clicking on "address" table
-- hoovering over to "DDL" Data Data Definition Language.
CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address
-- select * from address where address_id IN (3, 4);
-- select * from staff;
-- address_id
select s.first_name, s.last_name, a.address from staff s
left join address a on s.address_id = a.address_id;

-- 6b. Total Amount rung by each staff member in August 2005
-- join staff s on p.staff_id = s.staff_id
select s.first_name, s.last_name, sum(p.amount) as "Total Amount - August 2005" from payment p
left join staff s on s.staff_id = p.staff_id
where payment_date like '2005-05%'
group by p.staff_id;

-- 6c. List e/a film and number of actors per film
select fa.film_id, f.title as "Film Name", count(fa.actor_id) as "No. of Actors / Film" from film_actor fa
inner join film f on f.film_id = fa.film_id
group by film_id ;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
-- used above query to get the film_id ==439 Hunchback Impossible. 
select i.film_id, f.title, count(i.store_id) as "Number of Copies" from inventory i
inner join film f on f.film_id = i.film_id
where i.film_id = 439;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer.
-- List the customers alphabetically by last name
select c.first_name, c.last_name, sum(p.amount) as "Total Amount Paid" from payment p
inner join customer c on c.customer_id = p.customer_id
group by last_name asc;

-- 7a. Movies starting with letters "K" and "Q"
-- 1 == english
-- select l.language_id, l.name from language l;
select f.title as "Film Name", l.name as "Language" from film f
left join language l on f.language_id = l.language_id
where f.title like 'K%' AND f.language_id = 1 OR f.title like 'Q%' AND f.language_id = 1;

-- 7b. Actors who appear in the film below
-- select f.film_id, f.title from film f where title = "Alone Trip";
-- film id == 17
-- select a.actor_id, a.first_name, a.last_name from actor a;
select fa.actor_id, a.first_name, a.last_name, f.title as "Film Title" from film_actor fa
left join actor a on fa.actor_id = a.actor_id
inner join film f on f.film_id = fa.film_id
where fa.film_id = 17;

-- 7c. All names and emails for Canadian cust.
-- select c.country_id, c.country from country c where c.country = "Canada";
-- c.country_id = 20
-- select c.first_name, c.last_name, c.email, a.address_id, a.city_id from address a
-- select c.first_name, c.last_name, c.email, c.address_id from customer c;
select c.first_name, c.last_name, c.email, a.address_id, a.city_id, ci.country_id, cou.country
from city ci 
join country cou on cou.country_id = ci.country_id
join address a on ci.city_id = a.city_id 
join customer c on a.address_id = c.address_id
where cou.country_id = 20;

-- 7d. Family films
-- Family == 8
select  fc.film_id as "Film ID", f.title as "Film Title", cat.category_id as "Category ID", cat.name as "Category Name"
from category cat
join film_category fc on fc.category_id = cat.category_id 
left join film f on f.film_id = fc.film_id
where cat.category_id = 8;

-- 7e.Display the most frequent rented movies in desc order
select f.title as "Film Title", count(re.rental_id) as "No. of times Rented"  from rental re
left join inventory inv on inv.inventory_id = re.inventory_id
left join film f on f.film_id = inv.film_id
group by f.title
order by count(re.rental_id) desc;

-- 7f. How much business in $ per each store
select st.store_id as "Store ID", sum(pa.amount) as "Total Amount $ per Store" from staff st
right join payment pa on st.staff_id = pa.staff_id 
group by store_id;

-- 7g.Write a query to display for each store its store ID, city, and country.
-- select ad.address_id, ad.city_id from address ad;
-- select ci.city_id, ci.city, ci.country_id from city ci;
-- select cou.country_id, cou.country from country cou;
select st.store_id as "Store ID", ci.city, cou.country
from store st
left join address ad on ad.address_id = st.address_id
left join city ci on  ci.city_id = ad.city_id
left join country cou on cou.country_id = ci.country_id ; 

-- 7h. Top 5 genres in gross rev. in dcs order
select cat.name as "Genres", sum(p.amount) as "Gross Revenue"
from payment p
left join rental re on re.rental_id =  p.rental_id
left join inventory inv on inv.inventory_id = re.inventory_id
left join film_category fc on fc.film_id = inv.film_id
left join category cat on cat.category_id = fc.category_id
group by name
order by sum(p.amount) desc limit 5;
-- q. how can i add indexes or ranking to the table? // what i tried didnt work

-- 8a.Create a view for Gross Revenue for Top 5 Genres
create view GrossRev_View as
(select cat.name as "Genres", sum(p.amount) as "Gross Revenue"
from payment p
left join rental re on re.rental_id =  p.rental_id
left join inventory inv on inv.inventory_id = re.inventory_id
left join film_category fc on fc.film_id = inv.film_id
left join category cat on cat.category_id = fc.category_id
group by name
order by sum(p.amount) desc limit 5);

-- 8b. Display View Table
select * from GrossRev_View;

-- 8c. Drop the View Table
drop view GrossRev_View;
