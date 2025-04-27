USE SAKILA;

-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.

SELECT COUNT(*)
FROM SAKILA.INVENTORY
WHERE FILM_ID = (SELECT FILM_ID FROM SAKILA.FILM 
WHERE TITLE='Hunchback Impossible');

-- 2. List all films whose length is longer than the average length of all the films in the Sakila database.

SELECT FILM_ID,TITLE,LENGTH
FROM SAKILA.FILM
WHERE LENGTH>(SELECT AVG(LENGTH) FROM SAKILA.FILM ) 
ORDER BY LENGTH ASC;

-- 3. Use a subquery to display all actors who appear in the film "Alone Trip".

SELECT a.actor_id, a.first_name, a.last_name, f.title
FROM sakila.actor AS a
JOIN sakila.film_actor AS fa 
ON a.actor_id = fa.actor_id
JOIN sakila.film AS f 
ON fa.film_id = f.film_id
WHERE f.film_id IN 
(SELECT f2.film_id
FROM sakila.film AS f2
WHERE f2.title = 'Alone Trip');

-- 4. Sales have been lagging among young families, and you want to target family movies for a promotion. 
--    Identify all movies categorized as family films.

SELECT ca.Name,f.Title
FROM CATEGORY as ca
JOIN film_category as fil
ON ca.category_id=fil.category_id
JOIN film as f
ON fil.film_id=f.film_id
WHERE ca.name=(SELECT cat.NAME FROM CATEGORY AS CAT WHERE CAT.NAME='FAMILY');

-- 5. Retrieve the name and email of customers from Canada using both subqueries and joins. 
--    To use joins, you will need to identify the relevant tables and their primary and foreign keys.
-- USING SUBQUERRIES

SELECT C.CUSTOMER_ID,C.FIRST_NAME,C.LAST_NAME,C.EMAIL,CO.COUNTRY
FROM SAKILA.CUSTOMER AS C
JOIN SAKILA.ADDRESS AS A
ON C.ADDRESS_ID=A.ADDRESS_ID
JOIN SAKILA.CITY AS CT
ON A.CITY_ID=CT.CITY_ID
JOIN SAKILA.COUNTRY AS CO
ON CT.COUNTRY_ID=CO.COUNTRY_ID
WHERE COUNTRY IN (SELECT COU.COUNTRY FROM SAKILA.COUNTRY AS COU WHERE COU.COUNTRY='CANADA');

-- USING JOINS

SELECT C.CUSTOMER_ID,C.FIRST_NAME,C.LAST_NAME,C.EMAIL,CO.COUNTRY
FROM SAKILA.CUSTOMER AS C
JOIN SAKILA.ADDRESS AS A
ON C.ADDRESS_ID=A.ADDRESS_ID
JOIN SAKILA.CITY AS CT
ON A.CITY_ID=CT.CITY_ID
JOIN SAKILA.COUNTRY AS CO
ON CT.COUNTRY_ID=CO.COUNTRY_ID
WHERE CO.COUNTRY ='CANADA';

-- 6. Determine which films were starred by the most prolific actor in the Sakila database. 
--    A prolific actor is defined as the actor who has acted in the most number of films. First, you will need to find the most prolific actor 
--    and then use that actor_id to find the different films that he or she starred in.

SELECT a.first_name, a.last_name, f.title
FROM sakila.film AS f
JOIN sakila.film_actor AS fa 
ON f.film_id = fa.film_id
JOIN sakila.actor AS a 
ON fa.actor_id = a.actor_id
WHERE a.actor_id = (SELECT fa.actor_id
FROM sakila.film_actor AS fa
GROUP BY fa.actor_id
ORDER BY COUNT(fa.film_id) DESC
LIMIT 1)
ORDER BY f.title;

-- 7. Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the 
--    most profitable customer, i.e., the customer who has made the largest sum of payments.

SELECT C.CUSTOMER_ID,C.FIRST_NAME,C.LAST_NAME,F.FILM_ID,F.TITLE
FROM
(SELECT CUSTOMER_ID,SUM(P.AMOUNT) AS TOTAL_PAID
FROM PAYMENT AS P
GROUP BY CUSTOMER_ID
ORDER BY TOTAL_PAID DESC
LIMIT 1) AS PROFITABLE_CUSTOMER
JOIN SAKILA.CUSTOMER AS C
ON C.CUSTOMER_ID=PROFITABLE_CUSTOMER.CUSTOMER_ID
JOIN RENTAL AS R
ON R.CUSTOMER_ID=C.CUSTOMER_ID
JOIN SAKILA.INVENTORY AS I
ON I.INVENTORY_ID=R.INVENTORY_ID
JOIN sakila.film AS f ON f.film_id = i.film_id
ORDER BY f.title;


-- 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. 
--    You can use subqueries to accomplish this.


SELECT P.CUSTOMER_ID, SUM(P.AMOUNT) AS TOTAL_SPENT
FROM PAYMENT AS P
GROUP BY P.CUSTOMER_ID
HAVING SUM(AMOUNT) >(SELECT AVG(TOTAL_SPENT) AS AVERAGE
FROM (SELECT SUM(AMOUNT) AS TOTAL_SPENT 
FROM PAYMENT 
GROUP BY CUSTOMER_ID) AS SUB_TOTALS
ORDER BY TOTAL_SPENT DESC);
