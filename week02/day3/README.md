# Day 3 — Structuring, Combining & Aggregating Data

- Data Structuring and Combining
- Aggregating Data
- Lab | Data Structuring and Combining
- Lab | Data Aggregation and Filtering

> Not fully covered yet — starting with join types below, since that's the
> piece I had a clear worked example for. The rest (`concat`, pivot,
> stack/unstack, melt, aggregation) will get filled in as we go through the
> actual lesson.

---

## Join types

Two tables:

```
clients                    loans
client_id | name          loan_id | client_id | amount
1         | Ana           101     | 1         | 5000
2         | Marc          102     | 1         | 2000
3         | Laia          103     | 2         | 10000
                           104     | 4         | 3000   ← client_id 4 doesn't exist in clients!
```

Notice: Laia (id 3) has no loans, and loan 104 references `client_id` 4,
which doesn't exist — a data problem, common in real datasets (a typo, a
deleted client, a bad import).

### Inner join — "show me clients who currently have a loan"

```python
pd.merge(clients, loans, on="client_id", how="inner")
```

```
Ana  — loan 101 (5000)
Ana  — loan 102 (2000)
Marc — loan 103 (10000)
```

Laia is dropped (no loan to match), and loan 104 is dropped (no client to
match). Only rows with a partner on **both** sides survive — the
intersection.

### Left join — "show me every client, and their loan info if they have any"

```python
pd.merge(clients, loans, on="client_id", how="left")
```

```
Ana  — loan 101
Ana  — loan 102
Marc — loan 103
Laia — NaN         ← kept, even though she has no loan
```

This is the practical query for "which clients have never taken out a
loan" — a genuinely common business question (e.g. marketing a new loan
product to clients who don't have one yet).

### Right join — "show me every loan, even if the client record is broken"

```python
pd.merge(clients, loans, on="client_id", how="right")
```

```
loan 101 — Ana
loan 102 — Ana
loan 103 — Marc
loan 104 — NaN     ← kept, even though the client doesn't exist
```

This is exactly how you'd catch that data problem — a loan pointing at a
`client_id` that isn't in the `clients` table at all. Very real, very
common in messy production data.

### Full (outer) join — "give me everything, don't lose anything from either side"

```python
pd.merge(clients, loans, on="client_id", how="outer")
```

```
Ana  — 101
Ana  — 102
Marc — 103
Laia — NaN
NaN  — 104
```

Useful for an audit: you want to see both "clients with no loans" and
"loans with no valid client" in one pass, to fully understand data
completeness.

### More than 2 tables

Say there's also a `payments` table:

```
payments
payment_id | loan_id | amount_paid
p1         | 101     | 1000
p2         | 103     | 5000
```

You can't join 3 tables in one step — joins are always pairwise. The trick:
the result of the first join becomes the new "table" for the next join,
chained one after another.

```python
step1 = pd.merge(clients, loans, on="client_id", how="left")     # clients + loans
final = pd.merge(step1, payments, on="loan_id", how="left")      # (clients+loans) + payments
```

Think of it like function composition — `step1` isn't a special
intermediate object, it's just a regular table, same as `clients` or
`loans` were, so it can be joined again exactly the same way. In SQL,
this is just multiple `JOIN` clauses stacked in one query:

```sql
SELECT *
FROM clients
LEFT JOIN loans ON clients.client_id = loans.client_id
LEFT JOIN payments ON loans.loan_id = payments.loan_id
```

**Key mental model for any number of tables:** pick two, join them, treat
the result as a single new table, then join the next one in — repeat until
every table is merged in. You never actually combine 3+ tables "at once,"
it just looks that way because the chaining happens quickly.

---

## Quick reference

| Join type | Keeps | pandas `how=` |
|---|---|---|
| Inner | only rows matching on both sides | `"inner"` (default) |
| Left | every row from the left table, matched or not | `"left"` |
| Right | every row from the right table, matched or not | `"right"` |
| Full / outer | every row from both tables, matched or not | `"outer"` |
