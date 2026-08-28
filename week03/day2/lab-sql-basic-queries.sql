USE sakila;

-- 1. Display all available tables in the Sakila database.
SHOW TABLES;

-- 2. Retrieve all the data from the tables actor, film and customer.
SELECT * FROM actor;
SELECT * FROM film;
SELECT * FROM customer;

-- 3.1 Titles of all films
SELECT title FROM film;

-- 3.2 List of languages, aliased as `language`
SELECT name AS language FROM language;

-- 3.3 First names of all employees from the staff table
SELECT first_name FROM staff;

-- 4. Retrieve unique release years.
SELECT DISTINCT release_year FROM film;

-- 5.1 Number of stores
SELECT COUNT(*) AS number_of_stores FROM store;

-- 5.2 Number of employees
SELECT COUNT(*) AS number_of_employees FROM staff;

-- 5.3 How many films are available for rent, and how many have been rented
-- "available for rent" = distinct films that exist in inventory (a copy exists to rent)
-- "have been rented" = distinct films that show up in the rental history at least once
SELECT COUNT(DISTINCT film_id) AS films_available_for_rent
FROM inventory;

SELECT COUNT(DISTINCT inventory.film_id) AS films_rented_at_least_once
FROM rental
INNER JOIN inventory ON rental.inventory_id = inventory.inventory_id;
-- both come back as 958 -- every film currently in inventory has been rented at least once

-- 5.4 Number of distinct last names of actors
SELECT COUNT(DISTINCT last_name) AS distinct_actor_last_names FROM actor;

-- 6. Retrieve the 10 longest films.
SELECT title, length
FROM film
ORDER BY length DESC
LIMIT 10;

-- 7.1 All actors with the first name "SCARLETT"
SELECT * FROM actor
WHERE first_name = 'SCARLETT';

-- BONUS 7.2 Movies with ARMAGEDDON in the title, duration > 100 minutes
SELECT title, length
FROM film
WHERE title LIKE '%ARMAGEDDON%' AND length > 100;

-- BONUS 7.3 Number of films that include Behind the Scenes content
SELECT COUNT(*) AS films_with_behind_the_scenes
FROM film
WHERE special_features LIKE '%Behind the Scenes%';
