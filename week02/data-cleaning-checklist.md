# Data Cleaning Checklist

A general-purpose order of operations for cleaning any new dataset, distilled
from the Day 1 (pandas) and Day 2 (cleaning & formatting) labs. The
insurance dataset from those labs is used for the examples, but the steps
apply to any DataFrame.

**The order isn't arbitrary — each step depends on the one before it:**

- Fix column names before anything else, so every later step can reference
  columns without typos or guesswork.
- Fix categories and data types *before* counting nulls — a value like
  `"697953.59%"` looks non-null but is unusable until it's actually numeric.
  Count nulls too early and you undercount the real problem.
- Handle nulls *before* duplicates — filling a missing value can turn two
  near-identical rows into exact duplicates (or the reverse).
- Verify at the very end, not after each step — a check halfway through
  can pass even though an earlier step introduced a problem two steps back.

## At a glance

```
.
├── 1. Explore                     # understand what's there before touching anything
│   ├── shape, head(), tail()
│   ├── info()                     # dtypes + nulls at a glance
│   ├── describe(include="all")
│   └── isna().all(axis=1).sum()   # any fully-empty padding rows?
│
├── 2. Column names                # everything else depends on these being right
│   └── .str.lower().str.replace(" ", "_")
│
├── 3. Broken rows
│   └── dropna(subset=["id"])      # no real identifier -> not data, just junk
│
├── 4. Inconsistent values
│   ├── unique()                   # spot every variant/typo
│   └── replace({...})             # collapse them into one category
│
├── 5. Data types
│   ├── strip symbols ("%", "$")
│   ├── to_numeric(errors="coerce")
│   └── to_datetime(errors="coerce")
│
├── 6. Real nulls                  # only now do the counts mean something
│   ├── isna().sum()
│   └── fillna() / dropna()        # depends on what the column means
│
├── 7. Duplicates
│   ├── duplicated().sum()
│   ├── drop_duplicates()
│   └── reset_index(drop=True)
│
├── 8. Final types
│   └── astype(int)                # only once everything is actually clean
│
└── 9. Verify and save
    ├── isna().sum().sum() == 0
    ├── duplicated().sum() == 0
    └── to_csv()
```

---

## 1. Explore first

Don't touch anything yet — understand what you actually have.

```python
df.shape                      # (rows, columns)
df.head(); df.tail()
df.info()                     # dtypes + non-null counts in one shot
df.describe(include="all")    # numeric AND categorical summary
df.nunique()                  # unique values per column
df[col].unique()              # the actual values, for any column that looks suspicious

# is a chunk of this "data" actually empty padding?
df.isna().all(axis=1).sum()
```

## 2. Fix column names

```python
df.columns = df.columns.str.lower().str.replace(" ", "_")
df.rename(columns={"st": "state"}, inplace=True)   # unclear abbreviations -> descriptive names
```

## 3. Drop structurally broken rows

Rows with no real identifier at all aren't salvageable — they're not
missing data, they're not data.

```python
df = df.dropna(subset=["customer"])   # or whatever the row's actual key is
```

## 4. Standardize inconsistent values

Use `.unique()` from step 1 to find every spelling/typo/abbreviation of the
same real category, then collapse them.

```python
df["gender"] = df["gender"].str[0].str.upper()   # "F"/"Femal"/"female" -> "F"
df["state"] = df["state"].replace({"AZ": "Arizona", "Cali": "California"})

# strip symbols that block numeric conversion
df["customer_lifetime_value"] = df["customer_lifetime_value"].str.replace("%", "", regex=False)
```

## 5. Fix data types

```python
df["customer_lifetime_value"] = pd.to_numeric(df["customer_lifetime_value"], errors="coerce")
df["date_column"] = pd.to_datetime(df["date_column"], errors="coerce")

# pull a number out of a compound string, e.g. "1/0/00" -> 0
df["complaints"] = df["complaints"].str.split("/").str[1]
df["complaints"] = pd.to_numeric(df["complaints"], errors="coerce")
```

## 6. Handle real nulls

Only *now* is `isna().sum()` telling you the truth — everything before this
was either structurally empty (already dropped) or hidden inside a bad
dtype (already fixed).

```python
df.isna().sum()   # what's left is genuine missing data

df["gender"] = df["gender"].fillna(df["gender"].mode()[0])            # categorical -> mode
df["income"] = df["income"].fillna(df["income"].median())             # skewed numeric -> median, not mean
df["date_column"] = df["date_column"].ffill()                          # sequential/time data -> ffill/bfill

df.isna().sum().sum()   # should be 0 before moving on
```

There's no universal rule for *which* fill strategy — it depends on what
the column means and what question the analysis is trying to answer.
Document the choice, don't just apply a default.

## 7. Handle duplicates

```python
df.duplicated().sum()
df = df.drop_duplicates()                     # or subset=[...] for specific columns
df.reset_index(drop=True, inplace=True)       # close index gaps left behind
```

## 8. Final type pass

```python
numeric_cols = df.select_dtypes(include="number").columns
df[numeric_cols] = df[numeric_cols].astype(int)   # only once everything is actually clean
```

## 9. Verify

```python
assert df.isna().sum().sum() == 0
assert df.duplicated().sum() == 0
print(df.dtypes)
print(df.describe())   # do min/max/mean actually make sense?
```

## 10. Save and productionize

```python
df.to_csv("cleaned_data.csv", index=False)
```

For anything beyond a one-off notebook, move each step into its own
function and chain them — see
[`cleaning_functions.py`](day2/cleaning_functions.py) for the pattern:
each function takes a DataFrame and returns a new one (never mutates in
place), and one `clean_data()` calls them all in order.

---

## Quick reference

| Step | Question it answers | Key methods |
|---|---|---|
| Explore | What am I actually working with? | `.shape` `.info()` `.describe()` `.nunique()` |
| Column names | Can I reference every column reliably? | `.columns.str.lower()` `.rename()` |
| Broken rows | Is this row real data at all? | `.dropna(subset=[key])` |
| Inconsistent values | Are these really the same category? | `.unique()` `.replace()` `.str[0].str.upper()` |
| Data types | Is this column actually usable for math? | `pd.to_numeric()` `pd.to_datetime()` `.str.split()` |
| Real nulls | What's genuinely missing, now that types are fixed? | `.isna().sum()` `.fillna()` `.ffill()`/`.bfill()` |
| Duplicates | Is this row counted more than once? | `.duplicated()` `.drop_duplicates()` `.reset_index()` |
| Final types | Are the cleaned columns the right dtype? | `.astype(int)` |
| Verify | Did every step actually work? | `.isna().sum().sum()` `.duplicated().sum()` |
