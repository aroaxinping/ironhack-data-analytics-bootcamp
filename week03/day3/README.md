# Day 3 — SQL Joins & Subqueries

- SQL Joins (+ hands on)
- SQL Subqueries (+ hands on)
- Lab | SQL Joins
- Lab | SQL Subqueries

> Subqueries not covered yet — that's `4.4_sql_subqueries.sql`, which I
> don't have yet. Everything below is Joins.

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

## Quick reference

| Join | Keeps |
|---|---|
| `JOIN` / `INNER JOIN` | only rows matching on both sides |
| `LEFT JOIN` | every row from the first (left) table, matched or not |
| `RIGHT JOIN` | every row from the second (right) table, matched or not |
| `LEFT JOIN ... UNION ... RIGHT JOIN` | full outer join (no dedicated keyword in MySQL) |
| self join (`table a1 JOIN table a2`) | compares rows within the same table — remember `a1.id <> a2.id` |
| `CROSS JOIN` | every row × every row (Cartesian product) — no `ON` condition |
