-- ==================================================
-- SETTING UP THE DATABASE
-- ==================================================

USE sakila;

-- ==================================================
-- CHALLENGE 1
-- ==================================================

-- 1. Rank films by length -- title, length, rank only. Filter out null/zero length.
SELECT title, length, RANK() OVER (ORDER BY length DESC) AS length_rank
FROM film
WHERE length IS NOT NULL AND length <> 0
ORDER BY length_rank;
-- Checked: 0 films have a NULL or 0 length in this dataset, so the WHERE filter here
-- doesn't actually remove any rows -- it's a defensive filter for data that could exist
-- in principle, not one this specific dataset needed. Several films tie for #1 at 185
-- minutes, which is exactly why RANK() (not ROW_NUMBER()) is the right call: ties should
-- share a rank, not get an arbitrary tie-break.

-- 2. Rank films by length WITHIN their rating category -- title, length, rating, rank.
SELECT title, length, rating, RANK() OVER (PARTITION BY rating ORDER BY length DESC) AS length_rank
FROM film
WHERE length IS NOT NULL AND length <> 0
ORDER BY rating, length_rank;
-- Same query as #1, just with PARTITION BY rating added -- the rank now restarts at 1
-- for every rating category instead of running across all films at once.

-- 3. For each film, the actor/actress who has acted in the greatest number of films,
-- and how many films that actor has been in total.
-- Built in two named steps rather than one nested query: first count films per actor,
-- then rank actors WITHIN each film by that count and keep only the top-ranked one(s).
WITH actor_film_counts AS (
    SELECT actor_id, COUNT(*) AS film_count
    FROM film_actor
    GROUP BY actor_id
),
film_actor_ranked AS (
    SELECT fa.film_id, fa.actor_id, afc.film_count,
           RANK() OVER (PARTITION BY fa.film_id ORDER BY afc.film_count DESC) AS rnk
    FROM film_actor fa
    JOIN actor_film_counts afc ON fa.actor_id = afc.actor_id
)
SELECT f.title,
       CONCAT(a.first_name, ' ', a.last_name) AS most_prolific_actor,
       far.film_count AS actor_total_films
FROM film_actor_ranked far
JOIN film f ON far.film_id = f.film_id
JOIN actor a ON far.actor_id = a.actor_id
WHERE far.rnk = 1
ORDER BY f.title;
-- Ties happen here too (e.g. AIRPLANE SIERRA returns both Richard Penn and Michael
-- Bolger, tied at 30 films each) -- RANK() = 1 keeps every tied actor, on purpose,
-- rather than picking one arbitrarily.

-- ==================================================
-- CHALLENGE 2
-- ==================================================

-- Step 1: monthly active customers -- unique customers who rented at least once that month.
SELECT DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
       COUNT(DISTINCT customer_id) AS active_customers
FROM rental
GROUP BY rental_month
ORDER BY rental_month;
-- Worth flagging honestly: the whole `rental` table only covers 5 real calendar months
-- (May-Aug 2005, then a gap, then a small batch in Feb 2006) -- not a full year. This
-- shapes how "previous month" gets interpreted in the next steps: there is no real
-- January 2006 data to compare Feb 2006 against, so "previous month" below means
-- "the previous month that actually appears in the data," not the literal previous
-- calendar month.

-- Step 2 + 3: active users in the previous month, and the % change vs. that.
WITH monthly_active AS (
    SELECT DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
           COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY rental_month
)
SELECT rental_month,
       active_customers,
       LAG(active_customers) OVER (ORDER BY rental_month) AS prev_month_active,
       ROUND(
           (active_customers - LAG(active_customers) OVER (ORDER BY rental_month))
           / LAG(active_customers) OVER (ORDER BY rental_month) * 100
       , 2) AS pct_change
FROM monthly_active
ORDER BY rental_month;
-- 2005-05 -> 06: +13.46%, 06 -> 07: +1.53%, 07 -> 08: +0.00% (599 both months, identical
-- count), then 08(2005) -> 02(2006): -73.62% -- that huge drop is the 6-month gap showing
-- up as a single "month-over-month" comparison, not a real one-month collapse in business.

-- Step 4: retained customers -- active in BOTH the current month and the previous one.
-- Can't do this with a single LAG() on the count, since "retained" needs to check actual
-- customer overlap between two months, not just compare two totals -- built as: get each
-- customer's active months, find each month's chronological predecessor (from the months
-- that actually exist in the data), then inner-join a month's customers against its
-- predecessor's customers.
WITH monthly_customers AS (
    SELECT DISTINCT customer_id, DATE_FORMAT(rental_date, '%Y-%m') AS rental_month
    FROM rental
),
months_with_prev AS (
    SELECT DISTINCT rental_month,
           LAG(rental_month) OVER (ORDER BY rental_month) AS prev_month
    FROM monthly_customers
)
SELECT mwp.rental_month,
       mwp.prev_month,
       COUNT(DISTINCT curr.customer_id) AS retained_customers
FROM months_with_prev mwp
JOIN monthly_customers curr ON curr.rental_month = mwp.rental_month
JOIN monthly_customers prev ON prev.rental_month = mwp.prev_month
                            AND prev.customer_id = curr.customer_id
GROUP BY mwp.rental_month, mwp.prev_month
ORDER BY mwp.rental_month;
-- Genuinely surprising, checked twice before trusting it: ALL 158 customers active in
-- Feb 2006 were ALSO active back in Aug 2005 -- 100% retention across a 6-month gap,
-- which is a much higher rate than any of the real consecutive months (May-Aug, ~87-100%
-- range). Reads less like organic monthly retention and more like the Feb 2006 batch
-- being a small re-used sample of the same customer pool rather than new activity --
-- a dataset quirk worth knowing about before drawing business conclusions from it.
