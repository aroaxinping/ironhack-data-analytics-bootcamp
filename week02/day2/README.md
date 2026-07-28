# Day 2 — Data Cleaning & Manipulation

My notes on handling nulls, duplicates, formatting, and transforming data
with `apply()`/`map()`/`applymap()`.

---

## Null values

`None` is Python's generic "no value." `NaN` ("Not a Number") is pandas'
specific stand-in for a missing *numeric* value — that's why a column with
even one `NaN` often gets upcast to `float64`, even if every other value
looks like an integer.

```python
df.isna()              # DataFrame of True/False, cell by cell
df.isna().any()         # per column: does it have any nulls at all?
df.isna().sum()         # per column: how many nulls?
df.isna().sum(axis=1)   # per row instead — how many nulls does each row have?
```

### Dropping vs filling

```python
df.dropna()                        # drop any row with at least one null
df.dropna(axis=1)                  # drop columns instead
df.dropna(subset=["Cabin"])        # only care about nulls in this column
df.fillna(-1)                      # replace every null with a fixed value
df.fillna(df.Age.mean())           # ...or a computed one, per column
df["Age"].ffill()                  # forward-fill: copy the previous valid value down
df["Age"].bfill()                  # backward-fill: copy the next valid value up
```

- **Neither `dropna()` nor `fillna()` change the DataFrame** unless you pass
  `inplace=True` or reassign the result back to a variable — same rule as
  `sort_values()`/`sort_index()` from Day 1.
- **Watch the dtype**: `df.fillna("na")` on a numeric column casts the whole
  column to `object` (text) — every value, not just the ones that were
  filled. If you only want to touch one column, target it directly
  (`df["Age"] = df["Age"].fillna(...)`) instead of calling `fillna()` on the
  whole DataFrame.
- There's no universal "right" strategy — mean/median/mode/ffill/bfill/drop
  each introduce a different kind of bias, and which one is defensible
  depends on the actual business question, not a rule of thumb.

---

## Duplicates

```python
df.duplicated()              # boolean Series: is this row a repeat of an earlier one?
df.duplicated().sum()        # how many duplicate rows

df.drop_duplicates()                    # keep the first occurrence of each, drop the rest
df.drop_duplicates(subset=["Sex", "Age"])  # "duplicate" defined by only these columns
df.drop_duplicates(keep="last")         # keep the last occurrence instead of the first

df.reset_index(drop=True, inplace=True)  # close the index gaps left behind after dropping rows
```

`drop=True` on `reset_index()` matters — without it, the old index gets kept
around as a new `"index"` column instead of being thrown away.

---

## Formatting

### Column names

```python
df.columns = ["passenger_id", "Survived", ...]              # replace the whole list
df.rename(columns={"passenger_id": "PassengerId"})           # or just rename a few
df.rename(columns={col: col.replace(" ", "_").lower() for col in df.columns})  # rename all, programmatically
```

### `apply()`, `map()`, and `applymap()`/`map()` on a DataFrame

| Method | Works on | Does |
|---|---|---|
| `Series.apply(func)` | one column | runs `func` on every value |
| `Series.map(dict_or_func)` | one column | swaps values via a dict, **or** runs a function — same idea as `apply` for the function case |
| `DataFrame.apply(func, axis=1)` | whole row at a time | `func` receives the row itself (e.g. to combine two columns) |
| `DataFrame.map(func)` (was `applymap()`) | every cell | runs `func` on each individual value, whole DataFrame |

```python
df['yob'] = df['Age'].apply(lambda age: 1912 - age)     # one column, function

gender_mapping = {'male': 0, 'female': 1}
df['Gender_mapped'] = df['Sex'].map(gender_mapping)       # one column, dict lookup

df = df.map(lambda x: x.upper() if isinstance(x, str) else x)   # every cell in the DataFrame
```

**`map()` vs `apply()` for value substitution:** with 2-3 fixed
categories, a dict via `map()` reads cleaner than an `if/elif/else` lambda
in `apply()` — same result, less nested logic.

**Watch the dtype again:** mapping a column that has `NaN` (like
`Embarked`) upcasts the result to `float64`, even though the mapped values
are meant to be whole numbers (`0`, `1`, `2`) — pandas can't have `NaN`
inside an `int` column, only a `float` one. Fix: fill the nulls first
(with the **mode**, since it's categorical — mean/median don't make sense
for a category), *then* `.astype(int)`.

```python
df['Embarked_nr'] = df['Embarked_nr'].fillna(df['Embarked_nr'].mode()[0])
df['Embarked_nr'] = df['Embarked_nr'].astype(int)
```

---

## Filtering

```python
condition = df.Fare > df.Fare.mean()
df[condition]                          # or just df[df.Fare > df.Fare.mean()]

# combine conditions: & for and, | for or, ~ for not -- each side needs its own parentheses
df[(df.Fare > df.Fare.mean()) & (df.Fare <= 50)]

df[df['Pclass'].isin([2, 3])]          # shorthand for chained == / or
df[df['Fare'].between(90, 100)]        # shorthand for >= and <= together
```

---

## More manipulation

```python
df.set_index('PassengerId', inplace=True)   # use a column as the row index instead of 0,1,2,...
df.drop(1)                                   # drop the row with index label 1
df.drop('Name', axis=1, inplace=True)        # drop a column
df["Survived_bool"] = df['Survived'].map({0: False, 1: True})  # add a column
```

---

## Check for understanding — solved in [2.2_cleaning_and_data_manipulation.ipynb](2.2_cleaning_and_data_manipulation.ipynb)

- Clean a small students DataFrame: check nulls, fill `Age` with the mean,
  fill `Gender` with a default, drop rows missing `Name`, forward-fill
  `Score`.
- Cast `Embarked_nr` to `int` — the "fill nulls with the mode first" fix
  above, applied.
- `student_performance.csv`: total score, per-subject letter grades, an
  uppercase `gender` column, and a pass/fail flag from the row's mean score.
- `supermarket_sales.csv`: null check, round floats, clean column names,
  `total_cost` via `apply()`, filter above-average rows, set the index.

---

## Lab | Data Cleaning and Formatting

Same messy insurance dataset from the Day 1 pandas lab — this time actually
cleaning it instead of just diagnosing it:

- **Column names** → lowercase, underscores, `st` → `state`.
- **Invalid values** → `gender` down to first-letter-uppercase (`F`/`M`);
  state abbreviations to full names; `Bachelors` → `Bachelor`; `%` stripped
  from Customer Lifetime Value; the three luxury vehicle classes collapsed
  into one `"Luxury"`.
- **Data types** → CLV to numeric; `Number of Open Complaints` parsed out
  of its `"1/0/00"` format down to the actual number in the middle.
- **Nulls** → dropped the ~2937 fully-empty padding rows (no customer ID at
  all — not real data), then filled the genuine gaps left in real customer
  rows: `gender` (117) with the mode, `customer_lifetime_value` (3) with
  the median. Zero nulls left. Every numeric column cast to `int` as the
  final step.
- **Duplicates** → zero, once the padding rows were gone.
- **Bonus — functions**: the whole pipeline moved into
  [cleaning_functions.py](cleaning_functions.py), one function per cleaning
  step plus a `clean_data()` that chains them — each function takes a
  DataFrame and returns a new one, nothing mutated in place.
- **Bonus — analysis**: with CLV finally numeric, could compare it against
  claim amount for the first time. **40 customers** are in both the top 25%
  of claim amount *and* the bottom 25% of lifetime value — the segment
  actively costing more than they're projected to bring in.

Solved here: [lab-dw-data-cleaning-and-formatting.ipynb](lab-dw-data-cleaning-and-formatting.ipynb)
(submitted via PR from [lab-dw-data-cleaning-and-formatting](https://github.com/aroaxinping/lab-dw-data-cleaning-and-formatting), required for the Student Portal to mark it as done)
