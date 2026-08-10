-- ==================================================
-- SETTING UP THE DATABASE
-- ==================================================

USE sakila;

-- ==================================================
-- CHALLENGE: Creating a Customer Summary Report
-- ==================================================

-- Step 1: View summarizing rental info per customer -- id, name, email, rental_count.
DROP VIEW IF EXISTS rental_summary;
CREATE VIEW rental_summary AS
SELECT c.customer_id,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       c.email,
       COUNT(r.rental_id) AS rental_count
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, customer_name, c.email;

SELECT * FROM rental_summary LIMIT 10;

-- Step 2: Temporary table -- total amount paid per customer, built on top of the view from Step 1.
CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT rs.customer_id,
       rs.customer_name,
       rs.email,
       rs.rental_count,
       SUM(p.amount) AS total_paid
FROM rental_summary rs
JOIN payment p ON rs.customer_id = p.customer_id
GROUP BY rs.customer_id, rs.customer_name, rs.email, rs.rental_count;

SELECT * FROM customer_payment_summary LIMIT 10;

-- Step 3: CTE joining the view-derived temp table into the final customer summary report.
-- (The temp table already carries everything the view had, so the CTE here is mostly about
-- giving the final SELECT a clean, named source to add the derived column onto -- the same
-- "name a step, then build on it" idea as the CTEs from the class script.)
WITH cte_customer_summary AS (
    SELECT customer_name, email, rental_count, total_paid
    FROM customer_payment_summary
)
SELECT customer_name,
       email,
       rental_count,
       total_paid,
       ROUND(total_paid / rental_count, 2) AS average_payment_per_rental
FROM cte_customer_summary
ORDER BY total_paid DESC;

-- Top spender: Karl Seal, 45 rentals, $221.55 total, ~$4.92 per rental.
