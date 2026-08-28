# Day 3 — SQL Joins & Subqueries

- SQL Joins (+ hands on)
- SQL Subqueries (+ hands on)
- Lab | SQL Joins
- Lab | SQL Subqueries

---

## How to decide which join to use, step by step

A framework from class for approaching *any* join from scratch, before
writing a single line of SQL — worked example using `account`/`loan`:

1. **Which tables contain the information I actually want?** →
   `account`, `loan`.
2. **Do they have a column in common?** → `account_id`, in both.
3. **Which table is "left" and which is "right"?** → arbitrary at this
   point, just pick one to anchor the thinking — say `account` = left,
   `loan` = right.
4. **From which table do I want *all* the records, matched or not?** —
   this is the question that actually picks the join type, not step 3.
   Want everything from the left table → `LEFT JOIN`. From the right →
   `RIGHT JOIN`. From both → outer (`UNION` of the two). Only the rows
   that match on both sides → inner `JOIN`.
   - Example: "I want every loan, whether or not it has full account
     info" → all records from `loan` → `RIGHT JOIN` on `loan` (or
     equivalently, `LEFT JOIN` with `loan` written first).
5. **Gather everything — build the join** (the `FROM`/`JOIN`/`ON` skeleton).
6. **Write the final query** — add the actual `SELECT` columns, `WHERE`,
   `ORDER BY`, etc. on top of the join skeleton from step 5.

The useful reframe here is step 4: "left" vs "right" is just a label you
assign in step 3, arbitrary either way — the actual decision is "which
table's rows do I refuse to lose," and *that* is what determines
`LEFT`/`RIGHT`/`INNER`/outer, not which table happens to be named first
in the query.

### The generic join skeleton (and its pandas `merge()` equivalent)

Every join, once steps 1-5 above are answered, fills in the same template:

```sql
SELECT
    left_table.col1,
    left_table.col2,
    right_table.col1,
    right_table.col2
FROM db.left_table [AS left_table_alias]
type_of_join JOIN db.right_table [AS right_table_alias]
ON db.left_table.common_column = db.right_table.common_column;
```

Filled in for `account`/`loan`:

```sql
SELECT a.account_id, a.district_id, l.loan_id, l.amount
FROM bank.account AS a
LEFT JOIN bank.loan AS l
ON a.account_id = l.account_id;
```

`type_of_join` is one of:

| SQL | Meaning |
|---|---|
| `INNER` (or nothing — inner is the default, the only one that **can** be omitted) | only matching rows |
| `LEFT` | every row from the left table |
| `RIGHT` | every row from the right table |
| *(no single keyword)* | full/outer = `LEFT JOIN ... UNION RIGHT JOIN ...` (already covered above) |

**Same thing, pandas side** (from the Day 3 combining lesson, week 2) —
`ON`/`type_of_join` map directly onto `merge()`'s `on=`/`how=`:

```python
pd.merge(left_table, right_table, on=common_column, how=type_of_join)

# common column has a different name on each side -> left_on/right_on instead of on
pd.merge(left_table, right_table,
         left_on=common_column_left_table,
         right_on=common_column_right_table,
         how=type_of_join)
```

The one asymmetry worth remembering: SQL's inner join is the *implicit*
default (`JOIN` alone means inner) — pandas doesn't default to inner
because a `how=` is unspecified, `merge()` explicitly defaults to
`how="inner"` too, so the two behave the same, just one states it as the
keyword's absence and the other as an actual default parameter value.

---

## Inner join

```sql
SELECT * FROM bank.account AS a
JOIN bank.loan AS l
ON a.account_id = l.account_id;
```

Plain `JOIN` **is** an inner join — only rows with a match on both sides
survive. For an inner join specifically, it doesn't matter which table is
"left" and which is "right": the result (the matching intersection) is the
same either way.

**Does the order inside `ON` matter — `a.account_id = l.account_id` vs
`l.account_id = a.account_id`?** In class this came up as "always write
the left table first, it's faster." Checked it rather than taking it on
faith — `EXPLAIN` on both orderings, on the small `loan` table (682 rows)
*and* on the 868K-row `trans` table, and the execution plan is byte-for-
byte identical either way (same `key`, same `rows`, same `Extra`). MySQL's
optimizer normalizes an equality condition regardless of which side each
column is written on — order inside `ON` doesn't affect performance here.

What's actually true, and probably what that advice was pointing at: it's
a **readability convention**, not a speed one. Writing
`left_table.col = right_table.col` — matching the order the tables
already appear in `FROM ... JOIN ...` — makes a query easier to scan at a
glance, especially once there are several joins stacked. Worth doing for
that reason; not because the database cares.

**On writing `JOIN` vs `INNER JOIN`:** the class examples above keep the
bare `JOIN` on purpose — one of the comments in
[4.3_sql_joins.sql](4.3_sql_joins.sql) is specifically making the point
that plain `JOIN` *is* inner by default, so leaving it bare there is the
lesson, not an omission. In my own solved queries (the two check-for-
understanding sections below, and everywhere else going forward this
week) I write `INNER JOIN` explicitly instead — functionally identical,
but it removes any doubt about which join type was intended, the same
way `LEFT`/`RIGHT` never get left implicit.

## Left join / right join — order suddenly matters

```sql
SELECT a.account_id, l.loan_id FROM bank.account AS a
LEFT JOIN bank.loan AS l ON a.account_id = l.account_id;
-- every row from account (the LEFT table), NULL where there's no matching loan

SELECT a.account_id, l.loan_id FROM bank.account AS a
RIGHT JOIN bank.loan AS l ON a.account_id = l.account_id;
-- every row from loan (the RIGHT table) instead
```

**The key thing to internalize:** unlike inner join, `LEFT`/`RIGHT` are
**not symmetric** — swapping which table is named first changes the
result. The exact same query with the tables swapped:

```sql
SELECT a.account_id, l.loan_id FROM bank.loan AS l
RIGHT JOIN bank.account AS a ON a.account_id = l.account_id;
-- back to "every account", same result as the LEFT JOIN version above
```

A `RIGHT JOIN account` and a `LEFT JOIN account` end up meaning the same
thing once you track which table is actually anchoring the result — the
keyword names the *side*, not a fixed table.

## Outer join = LEFT UNION RIGHT

MySQL has no `FULL OUTER JOIN` keyword — you build it by hand:

```sql
SELECT a.account_id, l.loan_id FROM bank.account AS a
LEFT JOIN bank.loan AS l ON a.account_id = l.account_id
UNION
SELECT a.account_id, l.loan_id FROM bank.account AS a
RIGHT JOIN bank.loan AS l ON a.account_id = l.account_id;
```

`UNION` de-duplicates automatically, so the rows that already appeared in
both the left and right join only show up once in the combined result.
With `account` (4,500 rows) much bigger than `loan` (682 rows) here, the
outer join ends up looking identical to the plain left join — there's
nothing on the right side that isn't already covered by "every account."

## Joining 3+ tables

Same idea, just chained — each `JOIN` needs its own `ON`:

```sql
SELECT * FROM bank.disp AS d
JOIN bank.client AS c ON d.client_id = c.client_id
JOIN bank.card AS ca ON d.disp_id = ca.disp_id
WHERE ca.type = 'gold';
```

Read it top to bottom: `disp` joins to `client` first, and *that combined
result* joins to `card` next — not three independent pairings happening
at once.

## Self joins

Joining a table to itself — useful for comparing rows *within* the same
table.

```sql
-- accounts that share a district with a *different* account
SELECT * FROM bank.account a1
JOIN bank.account a2
ON a1.account_id <> a2.account_id      -- exclude comparing a row to itself
AND a1.district_id = a2.district_id;
```

The `<>` here isn't optional — without it, every row would trivially
"match itself" (same district as itself, obviously), which isn't the
comparison being asked for.

```sql
-- clients who are BOTH an OWNER and a DISPONENT on the same account
SELECT d1.account_id, d1.type AS Type1, d2.type AS Type2
FROM bank.disp d1
JOIN bank.disp d2
ON d1.account_id = d2.account_id AND d1.type <> d2.type;
```

This version returns each matching pair **twice** (OWNER→DISPONENT and
DISPONENT→OWNER, for the same two rows) — adding `WHERE d1.type =
'DISPONENT'` pins down one direction and removes the duplicate.

## Cross join (bonus)

```sql
SELECT * FROM (SELECT DISTINCT type FROM bank.card) sub1
CROSS JOIN (SELECT DISTINCT type FROM bank.disp) sub2;
```

Every row from one side paired with *every* row from the other — the full
Cartesian product, not a match on any condition. Result size is `rows_A ×
rows_B`, which is exactly why it gets expensive fast on real tables (this
is why the example cross-joins two tiny 2-3 row lookup lists, not the
actual `card`/`disp` tables directly).

---

## Check for understanding — solved in [4.3_sql_joins.sql](4.3_sql_joins.sql)

- Districts and regions ranked by number of clients — `Hl.m. Praha`
  (Prague) has by far the most at the district level (663), while at the
  region level `south Moravia` (937) edges out `north Moravia` (920).
- Accounts opened per district per year — a `GROUP BY district, year`,
  ordered by both.
- Extended a given 3-table join (`disp`→`client`→`district`) by adding the
  actual `SELECT` columns, a `WHERE d.type = 'OWNER'` filter, and the
  `ORDER BY` — the starter query in the exercise only had the join
  structure, none of that. 4,500 owner rows — one per account, since
  every account has exactly one owner (some also have a second person as
  `DISPONENT`, which is what the self-join above was demonstrating).

---

## Subqueries

A **subquery** is a `SELECT` nested inside another query — the inner one
runs first, and its result gets used as if it were a value (or a table)
in the outer one. Useful whenever the filter/comparison value isn't known
ahead of time, only derivable from the data itself.

```sql
SELECT ROUND(AVG(amount), 2) AS Average FROM bank.loan;   -- one value, on its own: 151410.18

SELECT * FROM bank.loan
WHERE amount > (SELECT ROUND(AVG(amount)) AS Average FROM bank.loan);
```

The inner query computes the overall average once; the outer query uses
that single number as the threshold — no need to run the first query,
read off the number, and paste it in by hand.

### Subqueries with `GROUP BY`/`HAVING`

```sql
-- which loan statuses have an average amount above the OVERALL average?
SELECT status, ROUND(AVG(amount), 2) AS Average
FROM bank.loan
GROUP BY status
HAVING Average > (SELECT ROUND(AVG(amount)) AS Average1 FROM bank.loan)
ORDER BY Average DESC;
```

Same idea as the `WHERE` case, just filtering *groups* instead of rows —
`HAVING` can reference a subquery exactly like it can reference a literal
number.

### Nested subqueries (subqueries inside subqueries)

They can nest as deep as needed. The way to not get lost: build it up one
piece at a time — write and test each inner layer on its own *first*,
then wrap the next one around it once you trust it works.

```sql
-- Goal: all loans whose status has an above-average amount for that status
-- Step 1: the statuses that qualify, as their own subquery
SELECT status FROM (
    SELECT status, AVG(amount) AS Average FROM bank.loan
    GROUP BY status
    HAVING Average > (SELECT ROUND(AVG(amount), 2) AS Average1 FROM bank.loan)
) AS s;

-- Step 2: wrap it in an outer query that uses those statuses to filter loans
SELECT * FROM bank.loan
WHERE status IN (
    SELECT status FROM (
        SELECT status, AVG(amount) AS Average FROM bank.loan
        GROUP BY status
        HAVING Average > (SELECT ROUND(AVG(amount), 2) AS Average1 FROM bank.loan)
    ) AS s
);
```

A subquery used in `FROM` (like `(...) AS s` above) **must** have an
alias — MySQL won't run it otherwise, since every table reference needs a
name, even a derived/temporary one.

### Subquery vs join — which one?

Checked with `EXPLAIN` rather than assuming: for an *uncorrelated*
subquery (the inner query doesn't reference the outer table — every
example above), MySQL 8's optimizer converts the `IN (...)` subquery into
essentially the same plan as an equivalent join (materializes the
subquery into a temp table, then matches against it). Confirmed on
`account`/`district` filtered to Central Bohemia (574 accounts either
way) — both plans scan the same number of rows.

This doesn't generalize, though: a **correlated** subquery (one that
*does* reference a column from the outer query) has to re-run once per
outer row, and can be much slower than the join equivalent, since it
can't be materialized just once. The join is the safer default reach —
more predictable across databases and query shapes where this specific
optimization isn't guaranteed to trigger.

---

## Check for understanding — solved in [4.4_sql_subqueries.sql](4.4_sql_subqueries.sql)

- Average number of transactions per account (192.89) — a subquery in
  `FROM` first counts transactions grouped by account, then the outer
  query averages *those* counts. Not the same thing as an aggregate
  directly on `trans` — the grouping has to happen first, as its own
  step, before there's anything to average.
- Accounts in Central Bohemia, once via a subquery (`district_id IN
  (SELECT A1 FROM district WHERE A3 = 'central Bohemia')`) and once as
  the equivalent join — same 574 rows either way, and the efficiency
  write-up above is the answer to "which one is faster."

---

## Quick reference

| Join | Keeps |
|---|---|
| `INNER JOIN` (or bare `JOIN` — inner is the default) | only rows matching on both sides |
| `LEFT JOIN` | every row from the first (left) table, matched or not |
| `RIGHT JOIN` | every row from the second (right) table, matched or not |
| `LEFT JOIN ... UNION ... RIGHT JOIN` | full outer join (no dedicated keyword in MySQL) |
| self join (`table a1 JOIN table a2`) | compares rows within the same table — remember `a1.id <> a2.id` |
| `CROSS JOIN` | every row × every row (Cartesian product) — no `ON` condition |
