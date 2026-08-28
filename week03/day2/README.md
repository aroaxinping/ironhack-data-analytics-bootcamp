# Day 2 — Basic SQL Queries & Aggregation

My notes on the core `SELECT` toolkit: filtering, functions, `NULL`
handling, `CASE`, sorting, pattern matching, and `GROUP BY`/`HAVING`.

Class material used a real case study — the
[PKDD'99 Financial Data Set](http://lisp.vse.cz/pkdd99/Challenge/berka.htm),
anonymized Czech bank data (accounts, clients, loans, cards,
transactions). See [case_study_readme.md](case_study_readme.md) and
[case_study_extended.pdf](case_study_extended.pdf) for the full schema and
field-by-field meaning — worth reading before the queries below make full
sense, since several answers depend on knowing what a status/operation
code actually means (e.g. loan `status = 'B'` = "contract finished, not
paid").

**Setup, to reproduce:** `unzip mysql_dump.zip && mysql -u root <
mysql_dump.sql` — creates and populates the `bank` database. Verified real
row counts after import: `account` 4,500 · `client`/`disp` 5,369 ·
`order` 6,471 · `loan` 682 · `card` 892 · `district` 77 · `trans` 868,019
(the case study's own doc states 1,056,320 for `trans` — this particular
dump has fewer, a commonly-used trimmed teaching subset rather than the
full original PKDD'99 release).

---

## Basic SELECT

```sql
SELECT * FROM bank.trans;                          -- everything
SELECT trans_id, account_id FROM bank.trans;        -- specific columns
SELECT trans_id, account_id FROM bank.trans LIMIT 10;
SELECT COUNT(*) FROM bank.trans;
SELECT DISTINCT status FROM bank.loan;              -- unique values only

SELECT trans_id AS Transaction_ID FROM bank.trans;              -- alias a column
SELECT bt.trans_id FROM bank.trans AS bt;                       -- alias a table too
```

Qualifying with the database name (`bank.trans` instead of just `trans`)
matters once more than one database is in play on the same server —
otherwise it's optional.

## Arithmetic & comparison operators

```sql
SELECT *, amount - payments AS balance FROM bank.loan;   -- computed column
SELECT duration % 2 FROM bank.loan;                        -- modulus

SELECT * FROM bank.loan WHERE status = 'B';
SELECT * FROM bank.loan WHERE status <> 'B';                -- <> and != are the same
SELECT * FROM bank.loan WHERE status IN ('B', 'b');          -- multiple exact matches
SELECT * FROM bank.loan WHERE status IN ('B','b') AND amount > 100000;
```

## Logical operators

```sql
WHERE status = 'B' OR status = 'D'
WHERE (status = 'B' OR status = 'D') AND amount > 200000     -- parentheses group OR before AND
WHERE NOT k_symbol = 'SIPO'                                   -- negation
```

## Numeric functions

```sql
ROUND(amount / 1000, 2)     -- round to N decimals
FLOOR(AVG(amount))          -- round down
CEILING(AVG(amount))        -- round up
MAX(amount) / MIN(amount)
```

## String functions

```sql
LENGTH('himanshu')                    -- string length
CONCAT(order_id, account_id)          -- join strings together
LOWER(A2) / UPPER(A3)                 -- case conversion
LEFT(A2, 5) / RIGHT(A2, 5)            -- first/last N characters
LTRIM(' Hello ') / RTRIM(' Hello ')   -- strip leading/trailing whitespace
```

## Date & time functions

The `account.date` / `loan.date` columns are stored as plain **integers**
in `YYMMDD` form (e.g. `930226`), not a real `DATE` type — a recurring
theme with older/imported datasets. `CONVERT()` reinterprets a value's
type for **display only**, it doesn't change what's stored:

```sql
SELECT CONVERT(date, DATE) FROM bank.loan;                       -- int -> DATE, for display

-- card.issued is text like "930101 00:00:00" -- split off the date part first
SELECT SUBSTRING_INDEX(issued, ' ', 1) FROM bank.card;
SELECT CONVERT(SUBSTRING_INDEX(issued, ' ', 1), DATE) FROM bank.card;

SELECT DATE_FORMAT(CONVERT(date, DATE), '%Y-%M-%D') FROM bank.loan;  -- custom display format
SELECT DATE_FORMAT(CONVERT(date, DATE), '%Y') FROM bank.loan;        -- just the year
```

`%D` is the one worth remembering — it prints the day **with its English
ordinal suffix** (`7th`, `21st`), which is what makes `'November 7th,
1993'`-style formatting a one-liner instead of a manual case statement.

## NULL handling

`NULL` means "no value" — different from `0`, and different from an empty
string `''`. Comparing `= NULL` never works (always unknown, not true);
use `IS NULL` / `IS NOT NULL` instead.

```sql
SELECT ISNULL(card_id) FROM bank.card;              -- 1 = null, 0 = not null, per row
SELECT SUM(ISNULL(card_id)) FROM bank.card;          -- total null count in the column

SELECT * FROM bank.order WHERE k_symbol IS NULL;
SELECT * FROM bank.order WHERE k_symbol IS NOT NULL AND k_symbol NOT IN ('', ' ');
-- real data is often "empty-but-not-technically-NULL" -- check both
```

## CASE statements

```sql
SELECT loan_id,
CASE
    WHEN status = 'A' THEN 'Good - Contract Finished'
    WHEN status = 'B' THEN 'Defaulter - Contract Finished'
    WHEN status = 'C' THEN 'Good - Contract Running'
    ELSE 'In Debt - Contract Running'
END AS Status_Description
FROM bank.loan;
```

Evaluated top to bottom, first matching `WHEN` wins — same logic as
`if/elif/else`.

## Ordering & filtering by range

```sql
ORDER BY amount              -- ascending (default)
ORDER BY amount DESC
ORDER BY date, amount        -- first column breaks ties, second breaks ties within that
ORDER BY date DESC, amount DESC

WHERE date BETWEEN 971231 AND 981231   -- inclusive on both ends
```

## Pattern matching

```sql
WHERE A2 LIKE 'K%'     -- starts with K
WHERE A2 LIKE '%K'     -- ends with K
WHERE A2 LIKE '%K%'    -- contains K anywhere
WHERE A2 LIKE '____'   -- exactly 4 characters (one _ per position)
```

## Aggregations: GROUP BY and HAVING

```sql
SELECT COUNT(amount), SUM(amount), MIN(amount), MAX(amount), AVG(amount)
FROM bank.order;                          -- one row, summarizing the whole table

SELECT bank_to, SUM(amount) FROM bank.order GROUP BY bank_to;   -- one row per group
```

**`WHERE` vs `HAVING`, the rule that actually matters:** `WHERE` filters
rows *before* grouping (can't reference an aggregate function in it —
`SUM(amount)` doesn't exist yet at that stage); `HAVING` filters groups
*after* aggregation, and can reference the aggregate values directly.

```sql
-- pre-filter, then group
SELECT bank_to, k_symbol, SUM(amount) AS Total_amount
FROM bank.order
WHERE k_symbol NOT IN ('', ' ')
GROUP BY bank_to, k_symbol;

-- group, then post-filter
SELECT bank_to, k_symbol, SUM(amount) AS Total_amount
FROM bank.order
GROUP BY bank_to, k_symbol
HAVING k_symbol NOT IN ('', ' ');
```

Grouping by multiple columns (`GROUP BY bank_to, k_symbol`) groups by the
*combination* — swapping the column order changes which one breaks ties
first, not the actual grouping itself.

**`ORDER BY` after `GROUP BY` — not required, but should always be there
anyway.** SQL is not going to error without it. But nothing in the SQL
standard (or in MySQL) guarantees *any* particular order for grouped
results — the engine is free to return groups in whatever order its
execution plan happens to produce (which table/index it scans, whether it
sorts or hashes to build the groups, etc.), and that can change between
runs, MySQL versions, or just because the optimizer picked a different
plan. Proof, not just a claim — this is the *unordered* result of the
`GROUP BY bank_to` query above:

```
bank_to  total
YZ       1636982.8
ST       1690662.7
QR       1728170.3
WX       1730775.7
CD       1498209.4
...
```

Not alphabetical, not sorted by total, not sorted by anything — that's
genuinely just whatever order MySQL's temp table happened to build the
groups in (`EXPLAIN` on that query shows `Using temporary`). If the result
needs to be in a specific order — for a report, for `LIMIT` to cut off
the "top N", for a chart — that's what `ORDER BY` is for, always added
explicitly, never assumed from `GROUP BY` alone.

---

## Check for understanding — solved in [4.2_sql_queries.sql](4.2_sql_queries.sql)

Seven blocks across the script, all run against the real imported `bank`
database. A few worth calling out:

- **Urban population** (`district.A4 * A10 / 100`): straightforward once
  you know `A10` is already a percentage, not a raw count.
- **"Junior cards issued last year"**: the dataset's own most recent date
  is `981229` (Dec 1998) — so "last year" means 1998, which is exactly why
  the hint says to compare against `980000`. 70 cards matched.
- **The `payment`/`customer_id` question near the aggregation section
  doesn't match this dataset at all** — no `payment` table exists, and
  `customer_id` isn't reachable without a `JOIN` (tomorrow's topic). This
  turned out to be leftover wording from the **Sakila** database (the
  classic movie-rental sample DB) — confirmed once I got to today's other
  two labs, which use Sakila directly. Adapted it to the closest
  equivalent actually available today: total revenue from `order`
  (21,228,993.60) and the same broken down by `account_id` instead of a
  customer.

---

## Lab | SQL Basic Queries & Lab | SQL Data Aggregation and Transformation

Both against the **Sakila** sample database (movie rentals) — MySQL's
official sample dataset, downloaded from
[dev.mysql.com/doc/sakila](https://dev.mysql.com/doc/sakila/en/sakila-installation.html)
rather than kept in this repo (schema + data script is ~3.4MB, easy to
re-fetch, not worth committing).

- **Basic Queries**: table listing, column selection with aliases,
  `DISTINCT`, `COUNT`-based insights (2 stores, 2 staff, 958 distinct
  films both in inventory *and* rented at least once — every film in
  stock has been rented), 10 longest films, `LIKE` pattern filtering.
- **Aggregation and Transformation**: `MAX`/`MIN`/`AVG` on film duration
  (average: 1h 55m), `DATEDIFF` for days-in-operation (266 days), adding
  computed `month`/`weekday`/`DAY_TYPE` columns to rental data via
  `CASE`, `IFNULL` for a safe-by-design null substitution, `CONCAT` +
  `LEFT` for an email-campaign column, `GROUP BY`/`HAVING` on film
  ratings (only `PG-13` averages over 2 hours, at 120.44 minutes), and 66
  actor last names that appear exactly once.

Solved here: [4.2_sql_queries.sql](4.2_sql_queries.sql),
[lab-sql-basic-queries.sql](lab-sql-basic-queries.sql),
[lab-sql-aggregation-and-transformation.sql](lab-sql-aggregation-and-transformation.sql)
(submitted via PR from [lab-sql-basic-queries](https://github.com/aroaxinping/lab-sql-basic-queries)
and [lab-sql-aggregation-and-transformation](https://github.com/aroaxinping/lab-sql-aggregation-and-transformation),
required for the Student Portal to mark them as done)
