# Day 4 — Temporary Tables, Views, CTEs & Window Functions

- SQL Temporary Tables, Views and CTEs (+ hands on)
- SQL Window Functions (+ hands on)
- Lab | Temporary Tables, Views and CTEs
- Lab | Window Functions

Same case study as the last two days: the
[PKDD'99 Financial Data Set](http://lisp.vse.cz/pkdd99/Challenge/berka.htm)
(`bank` database — see [day 2's README](../day2/README.md) for the full
setup/schema notes). Temp tables/views/CTEs below are solved from the real
class script,
[4.5_sql_temp_tables_views_ctes.sql](4.5_sql_temp_tables_views_ctes.sql).

> **Window functions section is still a draft**, written ahead of class
> from the general lesson material — no real class script for it yet.
> Every example in it is verified against the real `bank` database, not
> just copied from docs, but expect it to get reorganized once the actual
> `4.6_sql_window_functions.sql` shows up.

---

## Temporary tables

Exist only for the current session — created, used, and gone once the
connection closes. Useful for storing an intermediate result you'll query
multiple times *within* that session, without permanently altering the
database. No `AS` needed before the `SELECT` — the columns and rows are
inferred straight from the query:

```sql
CREATE TEMPORARY TABLE bank.loan_and_account
SELECT l.loan_id, l.account_id, a.district_id, l.amount, l.payments, a.frequency
FROM bank.loan l
JOIN bank.account a
ON l.account_id = a.account_id;

SELECT * FROM bank.loan_and_account;   -- query it like any other table, for the rest of the session
```

- **Scope**: only visible to the session/connection that created it — a
  different session (or a different query tab in Workbench, depending on
  connection) won't see it. Open a second connection and try
  `SELECT * FROM bank.loan_and_account` there — it errors, table doesn't
  exist as far as that session is concerned.
- **Why bother, instead of just a subquery?** Once it's created it
  behaves like a real table for the rest of the session — you can join
  it, index it, run several unrelated queries against it — instead of
  re-running the same subquery's logic every time you need it.
- **Naming convention**: no `temp_` prefix required, but it makes it
  obvious at a glance which tables are throwaway (the class script
  doesn't bother, so this is just a personal-notes habit).

## Views

A **virtual** table — stores the *query*, not the data. Every time you
select from a view, it re-runs the underlying query against the current
data. Unlike a temp table, a view can be built directly on top of a CTE:

```sql
CREATE VIEW running_contract_ok_balances AS
WITH cte_running_contract_OK_balances AS (
  SELECT *, amount - payments AS Balance
  FROM bank.loan
  WHERE status = 'C'
  ORDER BY Balance
)
SELECT * FROM cte_running_contract_OK_balances
WHERE Balance > (
  SELECT AVG(Balance) FROM cte_running_contract_OK_balances
)
ORDER BY Balance DESC
LIMIT 20;
```

Reusing the same CTE twice in one query (once to filter rows, once inside
the `AVG` subquery to compute the threshold) is exactly the kind of thing
that gets unreadable fast as a nested subquery — naming it once with
`WITH` and referencing it twice is the whole point. Verified: 20 rows
back, the 20 running/OK-status loans whose balance beats the average
balance of that same group.

- **Unlike a temp table**, a view persists across sessions (it's saved in
  the database schema) and never goes stale — since it holds no data of
  its own, it can't drift out of sync with the source table the way a
  temp table (a one-time snapshot) could.
- Good for: hiding a complex query behind a simple name, or restricting
  which columns/rows a user is allowed to see.
- Most views are read-only in practice — `running_contract_ok_balances`
  has an `ORDER BY` + `LIMIT`, which already rules out updating through
  it in MySQL.

## CTEs (Common Table Expressions)

A **named, temporary result set**, scoped to a single query — written
with `WITH`, right before the query that uses it.

```sql
WITH cte_loan AS (
  SELECT * FROM bank.loan
)
SELECT * FROM cte_loan
WHERE status = 'B';

-- same result without the CTE at all -- for a one-off filter this simple, the CTE is pure overhead
SELECT * FROM bank.loan
WHERE status = 'B';
```

The class script is upfront about this: the trivial example above proves
the *syntax*, not the *value* — a CTE only starts paying off once the
inner query is something you'd otherwise have to repeat or nest. The next
example in the script makes that case for real — aggregate `trans` by
`account_id` first, then join the aggregated result to `account`:

```sql
WITH cte_transactions AS (
  SELECT account_id, ROUND(SUM(amount),2) AS Total_amount, ROUND(SUM(balance),2) AS Total_balance
  FROM bank.trans
  GROUP BY account_id
)
SELECT ct.account_id, ct.Total_amount, ct.Total_balance, a.district_id, a.frequency, a.date
FROM cte_transactions AS ct
JOIN bank.account a
ON ct.account_id = a.account_id;
```

Without the CTE this would mean either repeating the `GROUP BY` subquery
inline in the `FROM` clause (works, just harder to read once it's this
long) or aggregating *after* the join, which is wrong — joining first
would multiply each transaction by however many rows it matches on the
`account` side before summing, inflating the totals.

- Same underlying idea as a subquery in `FROM` (like the `(...) AS s`
  pattern from [yesterday's subqueries notes](../day3/README.md)) — a CTE
  is really just that, with a name and cleaner syntax up front instead of
  buried inline.
- **Only exists for the one query it's attached to** — unlike a temp
  table, it disappears the instant that statement finishes, and unlike a
  view, it's never saved anywhere.
- Multiple CTEs can be chained/referenced from the same `WITH` clause,
  which is what makes a genuinely complex query readable — name each
  logical step, then compose them at the end, instead of one giant nested
  subquery. Used exactly this way in the check-for-understanding below.

### Defining more than one CTE — the comma, and why only the first gets `WITH`

```sql
WITH cte_a AS (
  ...
),
cte_b AS (
  ...
),
cte_c AS (
  ...
)
SELECT ...   -- the actual query, outside/after every CTE definition
```

- **`WITH` is written once**, before the *first* CTE only — it's not a
  per-CTE keyword, it's what says "a block of named result sets is about
  to follow." Everything after it is one continuous list.
- **Each CTE after the first is separated by a comma**, not by repeating
  `WITH` — same punctuation as listing columns in a `SELECT`, just at the
  clause level instead of the column level.
- **They don't have to relate to each other.** `cte_b` is free to ignore
  `cte_a` completely and query a totally unrelated table — the comma just
  means "one more named result set is available in this query," not "this
  one depends on the last one." (`cte_max_trans_per_district` in the
  check-for-understanding below *does* build on `cte_client_trans_count`,
  but that's a choice, not a requirement of the syntax.)
- **Order still matters in one direction, though**: a CTE can only
  reference CTEs defined *before* it in the same `WITH` list, never one
  that comes later. MySQL reads top to bottom and a later name simply
  doesn't exist yet from an earlier CTE's point of view.

**Python analogy, since it maps almost exactly:** a CTE behaves like a
`def` — you have to define it before you can call it, and it only exists
in the scope it was defined in.

```python
def cte_a():
    return ...          # defining it -- like WITH cte_a AS (...)

def cte_b():
    return cte_a() + 1  # can call cte_a() here, it already exists

result = cte_b()         # calling it -- like SELECT ... FROM cte_b
```

Try to call `cte_a()` from inside a function defined *above* it, before
Python has even seen the `def cte_a` line, and it breaks — same reason
`cte_max_trans_per_district` can reference `cte_client_trans_count` but
not the other way around. And the final `SELECT` outside the `WITH`
block is like the line that actually *calls* the function — defining
`cte_a` and `cte_b` alone does nothing on its own, same as a Python file
full of `def`s that never gets a line calling any of them; nothing runs
until something at the bottom says `cte_b()`.

### Temp table vs view vs CTE vs subquery — when to reach for which

| | Lives for | Reusable across queries? | Stores data? |
|---|---|---|---|
| Temp table | the session | yes, within that session | yes (a snapshot) |
| View | permanently (until dropped) | yes, any session | no — re-runs the query each time |
| CTE | one single query | no | no |
| Subquery | one single query | no | no |

Rule of thumb from the lesson: temp tables for a large intermediate
result you'll hit multiple times in one session; views for a "saved"
query other people/sessions will reuse; CTEs for breaking one complex
query into readable named steps; plain subqueries for a one-off
computation you won't reuse at all.

---

## Check for understanding — solved in [4.5_sql_temp_tables_views_ctes.sql](4.5_sql_temp_tables_views_ctes.sql)

**1. Find the most active customer for each district in Central Bohemia,
using at least one CTE.**

"Most active" = highest transaction count. Two chained CTEs: first count
transactions per client (joining `client` → `disp` → `trans`, filtered to
clients whose own district is in the Central Bohemia region), then take
the `MAX(trans_count)` per district and join it back to pick out the
winner(s):

```sql
WITH cte_client_trans_count AS (
  SELECT c.client_id, c.district_id, COUNT(t.trans_id) AS trans_count
  FROM bank.client c
  INNER JOIN bank.disp d ON c.client_id = d.client_id
  INNER JOIN bank.trans t ON d.account_id = t.account_id
  INNER JOIN bank.district da ON c.district_id = da.A1
  WHERE da.A3 = 'central Bohemia'
  GROUP BY c.client_id, c.district_id
),
cte_max_trans_per_district AS (
  SELECT district_id, MAX(trans_count) AS max_trans_count
  FROM cte_client_trans_count
  GROUP BY district_id
)
SELECT da.A2 AS district_name, ct.client_id, ct.trans_count AS most_active_client_trans_count
FROM cte_client_trans_count ct
INNER JOIN cte_max_trans_per_district m
  ON ct.district_id = m.district_id AND ct.trans_count = m.max_trans_count
INNER JOIN bank.district da ON ct.district_id = da.A1
ORDER BY district_name;
```

All three joins here are `INNER JOIN`, written explicitly rather than
left as bare `JOIN` — same convention as [day 3](../day3/README.md#inner-join):
the class script's own lecture examples (the temp tables and CTE
examples above) keep the bare `JOIN` the professor wrote, but in my own
solved queries I spell out `INNER` so the intent reads the same way
`LEFT`/`RIGHT` already have to.

16 rows back for the region's districts — and 4 of them (Kladno, Melnik,
Mlada Boleslav, Rakovnik) return **two** tied "most active" clients
instead of one. Checked why rather than assuming a bug: those pairs are
joint accounts — one client `OWNER`, the other `DISPONENT` on the exact
same account in `disp` — so every transaction on that account counts
identically for both of them. A tie here is the correct answer, not
duplicate data.

**2. Create a view `last_week_withdrawals` — total withdrawals by client,
in the last week.**

```sql
CREATE VIEW last_week_withdrawals AS
SELECT d.client_id, ROUND(SUM(t.amount),2) AS total_withdrawals
FROM bank.trans t
INNER JOIN bank.disp d ON t.account_id = d.account_id
WHERE t.type IN ('VYDAJ','VYBER')
AND CONVERT(t.date, DATE) BETWEEN
    (SELECT DATE_SUB(MAX(CONVERT(date,DATE)), INTERVAL 6 DAY) FROM bank.trans)
    AND (SELECT MAX(CONVERT(date,DATE)) FROM bank.trans)
GROUP BY d.client_id
ORDER BY total_withdrawals DESC;
```

Three things worth spelling out:

- **"Withdrawal" isn't a single value.** `trans.type` has three values —
  `PRIJEM` (credit/deposit) and two withdrawal labels, `VYDAJ` and
  `VYBER`. Filtering only on `VYDAJ` silently drops a chunk of real
  withdrawals; both go in `IN (...)`.
- **"Last week" has no "today"** — this is a frozen historical dataset,
  not a live one, so `CURDATE()`/`NOW()` would be meaningless here.
  Instead, "last week" is defined relative to the data's own most recent
  transaction date (`MAX(date)` = 981231), going back 6 days from there —
  computed with a subquery rather than hardcoded, so the view still makes
  sense if the underlying data ever changes.
- **No join to `bank.client` needed** — same lesson as the CTE query
  above: `disp` already carries `client_id`, so joining `client` just to
  read a column that was already sitting right there in `disp` adds a
  join for nothing. Checked it doesn't change the result: same 1,219
  rows, same top client (`1556`, 65,500) with or without it.

Verified: 1,219 clients show up (out of ~5,369 total), topped by client
`1556` at 65,500. `SELECT * FROM last_week_withdrawals;` any time after
this runs — like any view, it's just re-run live, no stale snapshot to
worry about.

---

## Window functions (draft — no real class script for this half yet)

Aggregate-*like* functions that **don't collapse rows** — each row keeps
its identity, but gets an extra column computed across a "window" of
related rows (defined by `OVER`). This is the key difference from
`GROUP BY`: grouping reduces N rows to fewer rows; a window function keeps
all N rows and just adds information to each one.

```sql
SELECT column1, column2,
       WINDOW_FUNCTION(column3) OVER (
           PARTITION BY column4   -- split into groups, like GROUP BY, but without collapsing rows
           ORDER BY column5       -- order *within* each partition
       ) AS alias_name
FROM tablename;
```

### `ROW_NUMBER()` — a running count per partition

```sql
SELECT district_id, account_id, date,
       ROW_NUMBER() OVER (PARTITION BY district_id ORDER BY date) AS row_num
FROM bank.account;
```

Numbers each account 1, 2, 3... *within its own district*, ordered by
when it was opened — the numbering restarts at 1 for every new
`district_id`.

### `RANK()` vs `DENSE_RANK()` — ties behave differently

```sql
SELECT status, ROUND(AVG(amount), 2) AS avg_amount,
       RANK() OVER (ORDER BY AVG(amount) DESC) AS rnk,
       DENSE_RANK() OVER (ORDER BY AVG(amount) DESC) AS dense_rnk
FROM bank.loan
GROUP BY status;
```

Verified result — loan statuses ranked by average amount:

```
status  avg_amount  rnk  dense_rnk
D       249284.53   1    1
C       171410.35   2    2
B       140720.90   3    3
A       91641.46    4    4
```

No ties here, so `RANK`/`DENSE_RANK` happen to agree — the real
difference only shows up with tied values: `RANK()` **skips** the next
number after a tie (1, 1, 3), `DENSE_RANK()` **doesn't** (1, 1, 2).

### `NTILE(n)` — split into n roughly-equal buckets

```sql
SELECT status, ROUND(AVG(amount), 2) AS avg_amount,
       NTILE(2) OVER (ORDER BY AVG(amount)) AS half
FROM bank.loan
GROUP BY status;
```

Verified: splits the 4 statuses into a lower half (`A`, `B` → bucket 1)
and upper half (`C`, `D` → bucket 2) by average amount — a quick way to
bucket things into quartiles/halves/deciles without manually computing
percentile cutoffs.

### `LAG()` / `LEAD()` — look at a neighboring row

```sql
SELECT A1 AS district_id, A2 AS district_name, A11 AS avg_salary,
       LAG(A11) OVER (ORDER BY A1) AS prev_district_salary
FROM bank.district;
```

`LAG()` pulls in a value from the *previous* row (by the given order);
`LEAD()` does the same for the *next* row. First row's `LAG()` is `NULL`
— there's nothing before it. Classic use case: month-over-month change,
computed as `current_value - LAG(current_value) OVER (...)`.

### Window frame — `ROWS BETWEEN ... PRECEDING AND ... FOLLOWING`

For things like a moving average, the frame narrows *which* rows around
the current one get included:

```sql
SELECT date, amount,
       AVG(amount) OVER (
           ORDER BY date
           ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
       ) AS moving_avg
FROM bank.trans
WHERE account_id = 1787;
```

`1 PRECEDING AND 1 FOLLOWING` = a 3-row window centered on the current
row (itself + one before + one after). `UNBOUNDED PRECEDING` instead
means "everything from the start up to here" — a running total/average.

---

## Quick reference

| Construct | Scope | Use for |
|---|---|---|
| `CREATE TEMPORARY TABLE` | current session | a large intermediate result, reused several times |
| `CREATE VIEW` | permanent | a saved/reusable query, simplification, restricted access |
| `WITH ... AS (...)` (CTE) | one query | breaking a complex query into named, readable steps |
| `ROW_NUMBER()` | window | sequential numbering within a partition |
| `RANK()` / `DENSE_RANK()` | window | ranking, with/without gaps after ties |
| `NTILE(n)` | window | split into n roughly-equal buckets |
| `LAG()` / `LEAD()` | window | compare a row to its neighbor |
| `ROWS BETWEEN ... AND ...` | window frame | moving average / running total |
