# Day 1 — Data Wrangling, GDPR & Intro to Pandas

My notes on what data wrangling actually means, the basics of data privacy
under GDPR, and the start of pandas: Series, DataFrames, and exploring data.

---

## Intro to Data Wrangling

Data wrangling = cleaning, transforming, and preparing raw data so it's
actually usable for analysis. It's the unglamorous step between "we have
data" and "we can trust conclusions drawn from this data" — most real
datasets aren't analysis-ready out of the box (missing values, duplicates,
inconsistent formatting, wrong data types — see the pandas lab below for a
live example of exactly this).

Roughly, the process covers:

1. **Cleaning** — handling missing values, duplicates, outliers, formatting.
2. **Combining** — merging/joining data from multiple sources into one place.
3. **Structuring** — reshaping data (pivoting, aggregating) into the shape a
   given analysis actually needs.

This week is organized around exactly that pipeline: today is pandas
basics, Day 2 is cleaning, Day 3 is combining + aggregating, Day 4 is
scraping data from the web to begin with.

---

## GDPR — Data Privacy Basics

GDPR (General Data Protection Regulation) is the EU's data protection law —
relevant here because as a data analyst, the data going through pandas is
often *personal* data, and there are legal rules about handling it, not
just technical ones.

Core ideas worth remembering:

- **Personal data** — anything that can identify a person, directly (name,
  email) or indirectly (an ID that maps back to someone, combined with
  other data).
- **Lawful basis** — you need an actual legal reason to process someone's
  data (consent, contract, legal obligation, etc.) — "we had the data" is
  not on its own a justification.
- **Data minimization** — collect/keep only what's actually needed for the
  stated purpose, not everything that's technically available.
- **Right to erasure** ("right to be forgotten") — people can request their
  data be deleted.
- **Anonymization vs pseudonymization** — anonymized data (no way back to
  the individual) falls outside GDPR's scope; pseudonymized data (e.g. an
  ID instead of a name, but re-identifiable with a separate key) is still
  personal data under GDPR.

Practical takeaway for an analyst: before wrangling a real dataset with
personal fields (names, emails, IDs), check whether it should be
anonymized/pseudonymized first, and don't hoard columns "just in case" —
minimization is a legal requirement, not just tidiness.

---

## Short intro to NumPy

Pandas is built on top of NumPy, so a quick look at it first.

```python
import numpy as np

arr = np.array([1, 2, 3, 4, 5])
arr * 2   # [2, 4, 6, 8, 10] — element-wise, unlike a Python list

[1, 2, 3, 4, 5] * 2   # a plain list just repeats itself: [1,2,3,4,5,1,2,3,4,5]
```

- All elements in a NumPy array must share the **same data type** — mix
  types (`["Hello", 1, False]`) and NumPy casts everything to a common one
  (here, all become strings). Python lists don't have this restriction.
- 2D arrays work like a table with no column/row names — slicing uses
  `array[row_start:row_end, col_start:col_end]`:

  ```python
  a = np.array([[1,2,3,4],[5,6,7,8],[9,10,11,12],[-2,-5,-6,3]])
  a[1:3, 1:3]   # rows 1-2, columns 1-2
  a[a > 5]      # filter: only the elements greater than 5, flattened
  ```

### `.shape`, `.ndim`, `.size`

```python
a = np.array([[1,2,3,4],[5,6,7,8],[9,10,11,12],[-2,-5,-6,3]])

a.shape   # (4, 4)  — (rows, columns)
a.ndim    # 2       — number of dimensions
a.size    # 16      — total element count
```

`.shape` isn't an independent value someone set — NumPy computes it
automatically by inspecting the real structure of the array the moment it's
created, and keeps it in sync if the array changes (e.g. after `.reshape()`).
So `a.shape[0]` (rows) and `a.shape[1]` (columns) are just reading positions
out of that live tuple, which is itself always an accurate description of
`a`'s real shape — there's no scenario where they drift out of sync.

`.shape` generalizes beyond 2D too — it always returns one number per
dimension, "rows and columns" is just what those two numbers mean
specifically in the 2D case:

```python
np.array([1, 2, 3, 4]).shape                 # (4,)      — 1D, just a count
np.array([[1,2,3],[4,5,6]]).shape             # (2, 3)    — 2D, rows/columns
np.array([[[1,2],[3,4]],[[5,6],[7,8]]]).shape # (2, 2, 2) — 3D, no simple row/col label anymore
```

**Arrays don't exist without NumPy.** Python's only built-in general
container is the `list` — there's a rarely-used built-in `array` module,
but it has no math operations and no multi-dimensional support, so nobody
means that when they say "array." Every actual array (fast element-wise
math, `.shape`, multi-dimensional data) requires `import numpy` first;
without it, a `list` is the only option.

### Why pandas exists: NumPy's two limitations for real (mixed) data

Same data — a tiny "people" table — built as a NumPy array vs. a pandas
DataFrame, side by side:

```python
import numpy as np

table = np.array([[1, "Ana", 25.5], [2, "Marc", 30.0]])
print(table)
print(table.dtype)
```
```
[['1' 'Ana' '25.5']
 ['2' 'Marc' '30.0']]
<U32
```
👆 **Everything got forced into one type** — even `1` and `25.5` became the
*strings* `'1'` and `'25.5'`, because a NumPy array must be a single dtype,
period. And there's **no column names** — just position `[0]`, `[1]`, `[2]`.

```python
import pandas as pd

df = pd.DataFrame({"id": [1, 2], "name": ["Ana", "Marc"], "score": [25.5, 30.0]})
print(df)
print(df.dtypes)
```
```
   id  name  score
0   1   Ana   25.5
1   2  Marc   30.0

id         int64
name      object
score    float64
```
👆 Same numbers, same strings — but now `id` stayed a real integer, `score`
stayed a real float, and every column has an actual **name** instead of a
bare position. `0`/`1` on the left is a named row index too, not just "row
zero, row one" implicitly.

| | NumPy array | Pandas DataFrame |
|---|---|---|
| Data type | **one dtype for the whole array** | **each column keeps its own dtype** |
| Row/column identity | position only (`arr[0]`, `arr[1,2]`) | **named** columns + a **named** row index |
| Why | built purely for fast math on uniform numbers | built for real, messy, mixed-type tables |

**The relationship in one sentence:** a DataFrame isn't one NumPy array
pretending to have labels — it's closer to **a separate NumPy array per
column**, glued together side by side with names attached. Each column is
still internally one uniform dtype (NumPy's rule still applies *within* a
column), but different columns are free to differ from each other — which
is exactly what a real dataset (ages as ints, names as strings, prices as
floats, all in one table) actually needs.

---

## Series vs DataFrame

Pandas builds on top of NumPy arrays and adds labels: a **Series** is a
1D labeled array (think: one column), a **DataFrame** is a 2D labeled table
(think: the whole spreadsheet — a collection of Series sharing an index).

### A row is also a Series, not just a column

"Series" just means **a single 1D list of values with labels attached** —
nothing more specific than that. A DataFrame is 2D; slice a 1D piece out of
it in *either* direction and pandas hands you a Series:

```python
df = pd.DataFrame({"id": [1, 2], "name": ["Ana", "Marc"], "score": [25.5, 30.0]})

df["name"]    # slice DOWN a column  → Series
df.loc[0]     # slice SIDEWAYS a row → also a Series
```

- `df["name"]` → index = the row labels (`0, 1`)
- `df.loc[0]` → index = the column names (`id, name, score`)

**Why this doesn't contradict "a DataFrame is a collection of Series"**
(the usual diagram/definition): that statement is about how a DataFrame is
*built* — structurally, each **column** already **is** a Series, and the
DataFrame is those column-Series glued side by side sharing one index.
A **row**-Series isn't a pre-existing building block sitting inside the
DataFrame the same way — pandas *constructs* it fresh, on the spot, by
grabbing one value from each column, whenever you ask for a row (`.loc[]`).

So: columns are Series **by construction** (that's what the DataFrame is
made of); rows become Series **by conversion**, the moment you slice one
out. Both end up being the exact same *type* of object, just arrived at
differently.

```python
import pandas as pd

# from a list — gets a default numeric index
s = pd.Series([1, 2, 3])

# from a list with a custom index
s = pd.Series([1, 2, 3], index=["a", "b", "c"])

# from a dict — keys become the index automatically
s = pd.Series({"a": 1, "b": 2, "c": 3})

# from a file — read_csv + usecols + squeeze("columns") turns a single column into a Series
titanic_series = pd.read_csv(url, usecols=["Name"]).squeeze("columns")
```

### Accessing values in a Series

```python
s[1]        # by pandas' internal numeric position
s["d"]      # by the index label
s[1:]       # slicing works like a list
s[::-1]     # reversed
```

A Series works a lot like a Python dict — `.index` gives the keys,
`.values` gives the raw data as a NumPy array, and it's iterable the same
way:

```python
for key in s.keys():
    print(key)

for key, value in s.items():   # (index, value) pairs, same idea as dict.items()
    print(key, value)
```

### Useful Series methods

- **`concat([s1, s2])`** — stack two Series together. Keeps the original
  indexes by default (duplicates included) unless you pass
  `ignore_index=True`.
- **`sort_values()`** / **`sort_index()`** — sort by value or by index.
  Neither changes the Series in place unless you pass `inplace=True` (or
  reassign the result back to the variable).
- **`value_counts()`** — count of each unique value, sorted descending by
  default. One of the most-used methods in the whole library — this is how
  you answer "how many of each category do I have."

---

## DataFrames

Created from a dict of lists (see the notebook's Extra section), or more
commonly, `read_csv()`:

```python
titanic_df = pd.read_csv(url)
```

### Exploring a DataFrame

| Method / attribute | What it gives you |
|---|---|
| `.head()` / `.tail()` | first / last rows |
| `.shape` | (rows, columns) |
| `.columns` | column names |
| `.index` | the row index |
| `.values` | the underlying data as a NumPy array |
| `.dtypes` | data type of each column |
| `.info()` | dtypes + non-null counts in one summary |
| `.describe()` | mean/std/min/quartiles/max — **numeric columns only** by default; pass `include="all"` or `include="object"` to also cover categorical ones |
| `.nunique()` | number of unique values per column |
| `df["col"].unique()` | the actual unique values of one column |
| `.select_dtypes(include=...)` | filter columns by data type |

**Watch out:** `.describe()` doesn't include the **mode** — if you need it,
`df.mode()` returns it separately (as its own row per column).

### Accessing data

```python
titanic_df["Age"]              # a column, as a Series (dict-style)
titanic_df.Age                 # same thing, attribute-style — only works if the name has no spaces
titanic_df[["Age", "Sex"]]     # multiple columns -> a DataFrame

titanic_df.loc[0]              # a row, by label
titanic_df.iloc[0]             # a row, by position
titanic_df.loc[df["Age"] > 30] # rows matching a condition — boolean filtering
```

### Aggregation

Methods like `.max()`, `.min()`, `.mean()`, `.sum()` work column-wise
across the whole DataFrame, or on a single column/Series the same way.

### Sorting a DataFrame

```python
titanic_df.sort_values(by=["Pclass", "Age"], ascending=[False, True])
```

Multiple columns at once: sorts by the first, and only uses the second to
break ties within equal values of the first. Each column gets its own
ascending/descending flag, matched up by position.

---

## Check for understanding — solved in [2.1_pandas.ipynb](2.1_pandas.ipynb)

Using `titanic_df`: select `Sex` and `Fare`, count how many distinct `Sex`
values there are and how many of each, then a full statistical summary with
`describe(include="all")` — the `include="all"` matters, plain `describe()`
only covers numeric columns and would silently skip `Sex` itself.

---

## Lab | Pandas

Explored a genuinely messy insurance customer dataset — the kind of data
wrangling is *for*:

- **~73% of the rows were entirely empty** (2937 of 4008) — padding, not
  real customers.
- **`Customer Lifetime Value`** and **`Number of Open Complaints`** were
  read in as text (`object`), not numbers — CLV has a trailing `%`,
  Complaints is formatted like `"1/0/00"`. Both need cleaning before any
  math can be done on them (that's literally tomorrow's lab).
- **`ST`** and **`GENDER`** each had multiple spellings for the same real
  value (`"AZ"` vs `"Arizona"`, `"F"`/`"Femal"`/`"female"`) — this actually
  shows up *in the results*: the "5 least common locations" answer includes
  both `"AZ"` and `"Washington"` separately, when they're really the same
  place split by inconsistent text.
- Personal Auto customers average **lower income** (~38.2k) than Corporate
  Auto customers (~41.4k).
- The top-25%-by-claim-amount segment (264 customers) has a **lower**
  average income than the full dataset, despite higher claims — a real
  candidate insight for a retention/risk conversation.

Solved here: [lab-dw-pandas.ipynb](lab-dw-pandas.ipynb)
(submitted via PR from [lab-dw-pandas](https://github.com/aroaxinping/lab-dw-pandas), required for the Student Portal to mark it as done)
