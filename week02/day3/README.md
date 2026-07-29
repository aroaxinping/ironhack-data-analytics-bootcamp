# Day 3 — Structuring, Combining & Aggregating Data

- Data Structuring and Combining
- Aggregating Data
- Lab | Data Structuring and Combining
- Lab | Data Aggregation and Filtering

---

## `concat` — stack DataFrames together

Combines two or more DataFrames by literally stacking them — no key
column needed, no relationship between rows required.

```python
pd.concat([df_sales, df_sales_2], axis=0)   # more rows (axis=0 is the default)
pd.concat([df_sales, df_revenue, df_costs], axis=1)   # more columns
```

- `axis=0` (rows) is for the classic case: the same columns, split across
  multiple files/sources (e.g. monthly sales exports) that need to become
  one longer table.
- `axis=1` (columns) lines DataFrames up **side by side by index position**
  — it doesn't check that the rows actually correspond to the same thing,
  so this only makes sense when the DataFrames already share a meaningful
  index.
- `join="inner"` restricts the result to columns (for `axis=0`) or rows
  (for `axis=1`) common to all the DataFrames, instead of the default
  `join="outer"` which keeps everything and fills gaps with `NaN`.
- Concatenating rows almost always wants `.reset_index(drop=True)`
  afterwards — otherwise the index numbers just repeat (0,1,2... 0,1,2...)
  instead of continuing.

---

## `merge` — combine on a shared column

```python
pd.merge(df_sales, df_revenue, on="Date")                       # inner join by default
pd.merge(df_sales, df_revenue, on="Date", how="outer")
pd.merge(df1, df2, left_on="col_in_df1", right_on="col_in_df2")  # different column names
```

`merge` looks for matching **values** in a specified column (or columes) —
not row position, not the index. If the key column has a different name in
each DataFrame, `left_on`/`right_on` replace `on`.

## Join types (the `how=` parameter)

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

### `join()` — merge by index instead of by column

```python
df_sales.set_index("Date", inplace=True)
df_revenue.set_index("Date", inplace=True)

df_sales.join([df_revenue, df_costs])              # left join by default
df_sales.join([df_revenue, df_costs], how="inner")
```

Functionally similar to `merge`, but two differences matter:

| | `merge()` | `join()` |
|---|---|---|
| Matches on | values in a chosen column | the **index** |
| Default `how` | `inner` | `left` |

`join()` can also take a **list** of DataFrames at once (`df.join([a, b])`)
— but because it matches on the index, joining 3+ that way only keeps rows
whose index exists in *every* table for `how="inner"`, which is stricter
than chaining pairwise `merge()` calls one at a time.

---

## Quick guidelines (from class)

The decision tree the lesson gave for combining DataFrames — what to reach
for depends on what you're actually trying to do:

```
What do you want to add?
│
├── More ROWS (same columns, another batch of the same data)
│   └── pd.concat([df1, df2, ...], axis=0)
│
└── More COLUMNS (different info about the same rows)
    │
    └── How should the rows be matched up?
        │
        ├── Don't care — just line them up by position
        │   └── pd.concat([df1, df2, ...], axis=1)
        │
        └── Match rows using a column's values
            │
            ├── pd.merge(df1, df2, on="common_column", how="inner"/"left"/"right"/"outer")
            │   └── different column names on each side?
            │       use left_on="..." + right_on="..." instead of on="..."
            │
            └── df1.join(df2, how="inner"/"left"/"right"/"outer")
                └── matches on the INDEX, not a column by default —
                    set_index() on the shared key first (or pass
                    on="column_in_df1" to match df1's column against df2's index)
```

The one thing worth adding to the original slide: `join()`'s default
matching key is the **index**, not a column — that's the actual difference
from `merge()`, not just "same thing, different name." The `on=` parameter
on `join()` exists but works differently than `merge()`'s: it lets the
*calling* DataFrame's column match the *other* DataFrame's index, it
doesn't match column-to-column like `merge(on=...)` does.

---

## Quick reference: `concat` vs `merge` vs `join`

| Join type | Keeps | pandas `how=` |
|---|---|---|
| Inner | only rows matching on both sides | `"inner"` (default for `merge`) |
| Left | every row from the left table, matched or not | `"left"` (default for `join`) |
| Right | every row from the right table, matched or not | `"right"` |
| Full / outer | every row from both tables, matched or not | `"outer"` |

| Function | Matches on | Use when |
|---|---|---|
| `concat` | position / index, no key | stacking same-shape data from multiple sources |
| `merge` | values in a column | combining on a shared key, most common case |
| `join` | the index | already indexed by the key, or combining 3+ at once |

**How to actually decide, in order:**

1. **Are the tables just pieces of the same data, no key needed?** (this
   month's export + last month's export, same columns) → `concat`. If it's
   the question "do these rows belong to the same real thing," `concat`
   isn't it — it doesn't check, it just stacks.
2. **Otherwise, is there a shared key living in the columns** (e.g. both
   tables have a `client_id` column)? → `merge`. This is the default case
   for combining two genuinely different tables — customers + orders,
   students + grades.
3. **Is the key already the index** on both sides, or are there 3+ tables
   to combine against the same key? → `join`. It reads cleaner than
   chaining several `merge()` calls, but remember its default is `left`
   (not `inner` like `merge`), and `how="inner"` across 3+ tables at once
   is stricter than pairwise merging (see the lab notes above).

If unsure and the tables aren't already indexed by the key: reach for
`merge` first — it's the most explicit about what it's matching on.

---

## Structuring: pivot, stack/unstack, melt

### Pivot — long to wide

```python
df.pivot(index="country", columns="year", values="Population")
```

Turns unique values from one column (`year`) into **new columns**, filling
each cell with the matching `values`. Requires exactly one value per
`(index, column)` combination — if there's more than one (duplicates),
`pivot()` raises an error.

```python
df.pivot_table(index="country", columns="year", values=["GDP"], aggfunc="sum")
```

`pivot_table` is the version that handles duplicates — `aggfunc` says how
to combine them (`sum`, `mean`, `count`...). In practice, `pivot_table` is
the safer default; reach for plain `pivot` only when you already know
there's exactly one value per cell.

### Stack / Unstack — move between index levels and columns

```python
df_multiindex = df.set_index(["country", "year"])   # a multi-level index
stacked = df_multiindex.stack()          # columns -> another index level (very long/narrow)
unstacked = stacked.unstack("year")      # one of those index levels -> columns again (wider)
```

- `stack()`: columns become part of the row index — the DataFrame gets
  narrower and taller.
- `unstack()`: the opposite — an index level becomes columns, the
  DataFrame gets shorter and wider.
- They're inverses of each other, and specifically for multi-level
  (hierarchical) indexes — `pivot`/`melt` are the more common tools for
  single-level reshaping.

### Melt — wide to long

```python
pd.melt(df, id_vars=["country", "year"], value_vars=["Population", "GDP"],
        var_name="Indicator", value_name="Value")
```

The reverse of `pivot`: several value columns (`Population`, `GDP`)
collapse down into two columns — one naming *which* variable
(`Indicator`), one holding its value (`Value`). `id_vars` are the columns
that stay as-is and repeat for each melted row.

**Long vs wide, when to use which:** wide format (one column per category)
is easier to *read* as a summary table; long format (one row per
observation) is what most plotting/grouping tools actually expect as
input. `melt`/`stack` go wide→long, `pivot`/`unstack` go long→wide.

### Which one, in order

| Tool | Direction | Use when |
|---|---|---|
| `pivot` | long → wide | one value per index/column combo, guaranteed no duplicates |
| `pivot_table` | long → wide | same, but need to aggregate (sum/mean/count) because duplicates exist |
| `stack` | wide → long(er) | need to fold columns into an *index level*, not a plain column — usually prepping for `unstack` later |
| `unstack` | long → wide | undo a `stack`, or promote one level of a multi-index back into columns |
| `melt` | wide → long | need a genuinely long table (one row per observation) for grouping/plotting, `id_vars` stay as-is |

1. **Need a summary table a human will read** (categories across the top,
   one number per cell)? → `pivot_table` almost always — it's the safer
   default over `pivot` since real data usually has duplicate
   index/column combinations somewhere.
2. **Need long format for `groupby`, `seaborn`, or similar tools that
   expect one row per observation?** → `melt`.
3. **Already working with a multi-level index** (from `set_index` on 2+
   columns) and need to move a level between the index and the columns?
   → `stack`/`unstack` — this is specifically their job, `pivot`/`melt`
   don't touch index levels the same way.

---

## Check for understanding — solved in [2.3_combining_structuring_data.ipynb](2.3_combining_structuring_data.ipynb)

- Combine two student DataFrames with `concat`; merge students with courses
  using all four `how=` types and compare the results; set `StudentID` as
  the index on three DataFrames and `join()` them with `inner`/`outer`.
  Joining 3 tables with `join(..., how="inner")` is stricter than chaining
  pairwise merges — it only keeps rows present in **every** table at once.
- Build a product × region sales summary with `pivot_table(..., aggfunc="sum")`.

---

## Lab | Data Structuring and Combining

Builds on the Day 2 cleaning lab — same `cleaning_functions.py`, extended
to handle 3 different data sources at once:

- **Challenge 1**: `file1.csv`/`file2.csv` use the same messy format as the
  cleaning lab (`ST`, `%`-strings, `"1/0/00"` complaints) — but `file3.csv`
  turned out to already be clean (`State`, plain numbers). Concatenating
  them exposed a real bug: `clean_invalid_values`/`format_data_types`
  assumed every value was a string to `.str.replace()`/`.str.split()`, which
  silently turned file3's already-numeric values into `NaN` instead of
  leaving them alone. Fixed by checking the value first instead of assuming
  its type — same fix pushed back to the [Day 2 cleaning functions](../day2/cleaning_functions.py).
- **Challenge 2**: on `marketing_customer_analysis_clean.csv` (already
  clean) — total claim amount by sales channel (Agent brings in ~1.81M, more
  than double Call Center, and over 2.5x Web), average CLV by gender and
  education (highest for "High School or Below" of any education level, in
  both genders — counterintuitive if you'd expect CLV to track with
  education), and a complaints-by-policy-and-month summary reshaped from
  wide (`pivot_table`) to long (`melt`).

Solved here: [lab-dw-data-structuring-and-combining.ipynb](lab-dw-data-structuring-and-combining.ipynb)
(submitted via PR from [lab-dw-data-structuring-and-combining](https://github.com/aroaxinping/lab-dw-data-structuring-and-combining), required for the Student Portal to mark it as done)

---

## Aggregation & Grouping

**Aggregation** reduces multiple values down to one: `mean()`, `sum()`,
`min()`, `max()`, `count()`, `std()`. On its own, applied to a whole
column:

```python
df['Fare'].mean()
```

**Grouping** is what makes aggregation useful — split the data into
buckets first, *then* aggregate each bucket separately:

```python
grouped = df.groupby('Sex')   # doesn't compute anything yet, just sets up the split
```

`groupby()` on its own returns a `GroupBy` object, not a result — nothing
is calculated until you do something with it:

```python
for name, group in grouped:            # iterate: (group label, that group's DataFrame)
    print(name)

grouped.groups                          # dict: {group label: row labels in that group}
grouped.size()                          # rows per group -- INCLUDES NaN, unlike count()
grouped.get_group('female')             # pull out one group as its own DataFrame
```

### Applying an aggregation

```python
numeric_cols = df.select_dtypes('number').columns
df.groupby('Sex')[numeric_cols].mean()    # mean of every numeric column, per group
df.groupby('Sex')['Age'].mean()           # just one column
```

Mental model: **groups → columns → aggregation function** — pick what to
split by, then what to measure, then how to summarize it.

### Multiple aggregations at once — `agg()`

```python
df.groupby('Sex')['Age'].agg(['count', 'mean', 'std'])

df.groupby('Sex').agg({
    "Age": ['count', 'mean', 'std'],
    "Fare": ['min', 'max'],
})
```

`agg()` with a dict lets different columns get *different* aggregation
functions in one call, instead of applying the same function to everything.

### Grouping by multiple variables

```python
df.groupby(['Sex', 'Survived']).agg({"Age": ['count', 'mean', 'std'], "Fare": ['min', 'max']})
```

Pass a list to `groupby()` to split by more than one variable at once —
useful for analyzing data at a finer level of granularity (not just "by
gender" but "by gender *and* survival status").

**`.mean()` on a 0/1 column is a rate, for free** — the average of a
column of 0s and 1s (like `Survived`) *is* the proportion of 1s. No need
to separately divide count-survived by count-total; `groupby(...)['Survived'].mean()`
already gives the survival rate directly.

---

## Check for understanding — solved in [2.4_aggregating_data.ipynb](2.4_aggregating_data.ipynb)

Titanic dataset — fare by sex, survival by class and by gender,
`get_group('1')` for first class then survival-vs-fare within it, a custom
`AgeGroup` bucketing (`Child`/`Teen`/`Adult`/`Senior`) with survivor counts
per group, and the bonus survival *rate* per age group.

Two results worth remembering:
- Survival tracked strongly with both **class** (372 died vs 119 survived
  in 3rd class, the opposite in 1st) and **gender** (468 men died vs 109
  survived; 233 women survived vs 81 died) — "women and children first"
  shows up directly in the numbers.
- Even *within* 1st class alone, survivors paid a higher average fare
  (~95.6) than non-survivors (~64.7) — price correlated with survival even
  after controlling for class.

---

## Lab | Data Aggregation and Filtering

Builds on the previous two labs, on the raw (not pre-cleaned)
`marketing_customer_analysis.csv` — mostly clean already, but needed
column-name cleanup, an `Unnamed: 0` index column dropped, and `month`
extracted from `effective_to_date`.

- Filtered to low-claim (`< $1000`) customers who responded "Yes".
- Compared premium/CLV/claim-amount by policy type and gender for
  responders — Personal Auto (F) stood out with the highest CLV but only a
  mid-pack claim amount, the profile of a profitable, lower-risk segment.
- CLV by education and gender: the **median** barely moves across any
  group (~5.3k–6.3k everywhere) even though the **max** swings wildly
  (32.7k to 83.3k) — education mostly affects how far the high-end
  outliers reach, not the typical customer.
- Bonus: policies sold by state × month (`pivot_table`), narrowed to the
  top 3 states by volume, and response rate by sales channel — built as a
  wide count table first, then reshaped to long with `melt`. Agent has
  both the most volume *and* the best response rate (19.1%, ~70% higher
  than any other channel).

Solved here: [lab-dw-aggregating.ipynb](lab-dw-aggregating.ipynb)
(submitted via PR from [lab-dw-data-aggregation-and-filtering](https://github.com/aroaxinping/lab-dw-data-aggregation-and-filtering), required for the Student Portal to mark it as done)
