-- ==================================================
-- SETTING UP THE DATABASE
-- ==================================================

USE sakila;

-- ==================================================
-- CHALLENGE
-- ==================================================

-- 1. Number of copies of "Hunchback Impossible" that exist in the inventory system.
SELECT COUNT(*) AS copies
FROM inventory i
INNER JOIN film f ON i.film_id = f.film_id
WHERE f.title = 'Hunchback Impossible';
-- 6 copies.

-- 2. Films whose length is longer than the average length of all films.
-- The inner query computes the average once; the outer query reuses that single number as
-- the threshold -- same pattern as the loan-amount subquery from the class script.
SELECT title, length
FROM film
WHERE length > (SELECT AVG(length) FROM film)
ORDER BY length DESC;
-- 489 films qualify (out of 1000 total).

-- 3. Actors who appear in "Alone Trip", using a subquery.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN (
    SELECT fa.actor_id
    FROM film_actor fa
    INNER JOIN film f ON fa.film_id = f.film_id
    WHERE f.title = 'Alone Trip'
)
ORDER BY last_name;

-- ==================================================
-- BONUS
-- ==================================================

-- 4. All films categorized as "Family".
SELECT title
FROM film
WHERE film_id IN (
    SELECT fc.film_id
    FROM film_category fc
    INNER JOIN category c ON fc.category_id = c.category_id
    WHERE c.name = 'Family'
)
ORDER BY title;
-- 69 family films.

-- 5. Name and email of customers from Canada -- once with a subquery, once with joins.
-- Subquery version:
SELECT first_name, last_name, email
FROM customer
WHERE address_id IN (
    SELECT a.address_id
    FROM address a
    INNER JOIN city ci ON a.city_id = ci.city_id
    INNER JOIN country co ON ci.country_id = co.country_id
    WHERE co.country = 'Canada'
);

-- Join version (address -> city -> country is the only path to "country" from a customer,
-- there's no shortcut column on customer/address itself):
SELECT c.first_name, c.last_name, c.email
FROM customer c
INNER JOIN address a ON c.address_id = a.address_id
INNER JOIN city ci ON a.city_id = ci.city_id
INNER JOIN country co ON ci.country_id = co.country_id
WHERE co.country = 'Canada';
-- Both return the same 5 customers.

-- 6. Films starred by the most prolific actor (most films acted in).
-- Step 1 as its own subquery: which actor_id has the highest film count.
SELECT actor_id, COUNT(*) AS film_count
FROM film_actor
GROUP BY actor_id
ORDER BY film_count DESC
LIMIT 1;
-- actor_id 107, 42 films.

-- Step 2: use that actor_id (as a subquery, not hardcoded) to pull their films.
SELECT f.title
FROM film f
INNER JOIN film_actor fa ON f.film_id = fa.film_id
WHERE fa.actor_id = (
    SELECT actor_id
    FROM film_actor
    GROUP BY actor_id
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
ORDER BY f.title;
-- 42 films back, matching the film_count from step 1 -- confirms the subquery picked the
-- same actor consistently.

-- 7. Films rented by the most profitable customer (highest total payments).
SELECT f.title
FROM film f
INNER JOIN inventory i ON f.film_id = i.film_id
INNER JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.customer_id = (
    SELECT customer_id
    FROM payment
    GROUP BY customer_id
    ORDER BY SUM(amount) DESC
    LIMIT 1
)
ORDER BY f.title;
-- customer_id 526 ($221.55 total) -- same customer (Karl Seal) that came out on top in the
-- Temporary Tables/Views/CTEs lab's customer summary report, a useful cross-check that both
-- labs' logic agrees.

-- 8. client_id and total_amount_spent for clients who spent more than the average total
-- spent per client. Built as a CTE, since "total spent per client" is needed twice --
-- once as the actual output, once inside the AVG() that filters it -- same reuse-a-named-
-- result idea as the class CTE examples.
WITH customer_totals AS (
    SELECT customer_id, SUM(amount) AS total_amount_spent
    FROM payment
    GROUP BY customer_id
)
SELECT customer_id, ROUND(total_amount_spent, 2) AS total_amount_spent
FROM customer_totals
WHERE total_amount_spent > (SELECT AVG(total_amount_spent) FROM customer_totals)
ORDER BY total_amount_spent DESC;
-- 285 out of 599 customers spend above the average -- expected with typically right-skewed
-- spending data (a handful of high spenders pull the average above where "most" people sit).
