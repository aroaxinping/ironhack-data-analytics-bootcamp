# Day 1 — EDA & Univariate Analysis

- Introduction to EDA and Univariate Analysis (+ hands on)
- Lab | EDA Univariate Analysis

---

## What EDA actually is

**Exploratory Data Analysis** is the systematic first look at a dataset —
before modeling, before drawing conclusions — meant to understand
structure, spot patterns, and catch anomalies. It sits between loading
the data and cleaning it, and usually needs a second, deeper pass *after*
cleaning too.

Two ways to slice EDA methods:

- **By technique**: numerical measures (stats, frequency counts) vs.
  visual representations (histograms, bar charts, scatter plots...).
- **By variable count**: **univariate** (one variable at a time — today's
  focus), **bivariate** (two variables, usually one against the target),
  **multivariate** (three or more).

The method always has to match the variable type — that's the thread
running through the whole lesson.

## Numerical vs. categorical isn't just `dtype`

`df.select_dtypes("number")` / `df.select_dtypes("object")` is the naive
split, but it's wrong on its own: a numeric column with very few distinct
values (`df[col].nunique() < 20`, as a rough threshold) usually behaves
like a **categorical variable encoded as numbers** — an example from the
dataset info is things like `OverallQual` (1–10 rating) or `MSSubClass`
(a class code). Domain knowledge decides the real cutoff, not the dtype
alone. That's why the notebook builds a separate `df_categorical` /
`df_numerical` split instead of trusting `select_dtypes` directly.

## Categorical variables

- **Frequency table**: `df[col].value_counts()` (counts) and
  `value_counts(normalize=True)` (proportions) — the fastest way to see
  which categories dominate. `pd.crosstab(index=..., columns="count")`
  gives the same counts in a different shape (useful when you want a
  DataFrame you can reindex/reorder, like forcing a specific `order=[...]`
  in a bar chart).
- **Bar chart** (`sns.barplot`) vs. **countplot** (`sns.countplot`):
  functionally the same result for a single categorical column —
  `countplot` just assumes the y-axis is "count" so you don't need to
  compute `value_counts()` yourself first.
- **Pie chart**: `df[col].value_counts().plot.pie(autopct='%.1f%%')` —
  matplotlib, not seaborn (seaborn has no pie chart function). Gets hard
  to read once one category dominates or there are many small slices —
  bar charts usually communicate the same skew better.
- On `MSZoning`: `RL` (Residential Low Density) is ~79% of listings,
  `RM` a distant second at ~15% — a heavily skewed category, the kind of
  thing that's easy to miss without a frequency table.

## Numerical variables

**Centrality**: `.mean()`, `.median()`, `.mode()[0]` — mode needs `[0]`
because it returns a Series (there can be more than one mode).

**Dispersion**: `.var()`, `.std()`, `.min()`/`.max()` (→ range),
`.quantile(q)` for any percentile, not just quartiles — `.describe()`
gives mean/std/min/max/quartiles in one call but *not* mode or variance,
so those still need computing separately.

**Shape**: `.skew()` and `.kurtosis()`.
- Skewness > 0 → **right-skewed** (long tail toward higher values, mean
  pulled above the median). `SalePrice` skew = 1.88 — strongly
  right-skewed, matches intuition (most houses cluster in a normal price
  band, a handful of expensive outliers stretch the tail).
- Kurtosis > 3 (excess kurtosis > 0) → heavier tails / sharper peak than
  a normal distribution, i.e. more extreme outliers than you'd expect.
  `SalePrice` kurtosis = 6.54, confirming the outlier-heavy tail the
  skewness already hinted at.

**Visualizing the shape**: `sns.histplot(df[col], kde=True, bins=...)`
for the distribution shape (the KDE line makes skew visible at a glance),
`sns.boxplot(x=df[col])` for the IQR + outliers specifically (whiskers at
1.5×IQR, points beyond that flagged as outliers). Both told the same
story for `SalePrice`: bulk of sales between $100K–$250K, a real cluster
of high-end outliers pulling the distribution rightward.
`df_numerical.hist(figsize=..., bins=..., ...)` plots every numeric
column at once, useful as a first-pass scan for "what else might
correlate with the target" before running actual correlations.

## Discretization: turning continuous into categorical

Useful for simplifying analysis into groups, at the cost of losing
precision — two ways to pick the bin edges:

- **Fixed-width (`pd.cut`)**: you choose the edges directly —
  `bins=[0, 100000, 200000, 300000, max]` for `SalePrice` → `Low` /
  `Medium` / `High` / `Very High`. Bin *sizes* are equal, but the
  *number of rows per bin* isn't — depends entirely on the underlying
  distribution.
- **Quantile-based (`pd.qcut`)**: you choose how many groups, and pandas
  finds the edges so each group has (roughly) the same row count —
  `pd.qcut(df['SalePrice'], q=4, labels=['Q1','Q2','Q3','Q4'])`. Opposite
  tradeoff: equal *group sizes*, unequal *bin widths*.

`include_lowest=True` on `cut` matters — without it, a value exactly
equal to the lowest bin edge gets excluded (left-open intervals by
default).

## Check for understanding — my answers

**1. `1stFlrSF` into Small/Medium/Large by percentile (33rd/66th)**

```python
df['1stFlrSF_category'] = pd.qcut(
    df['1stFlrSF'], q=[0, 0.33, 0.66, 1], labels=['Small', 'Medium', 'Large']
)
```

`qcut` with custom quantile edges (not just an integer count) splits at
the 33rd (~946 sqft) and 66th (~1258 sqft) percentiles directly — that's
the point of `qcut` over `cut` here, the question asks for percentile
cutoffs, not fixed square-footage thresholds. Result lands close to even
by construction: Large 495, Medium 483, Small 482 houses.

**2. `TotRmsAbvGrd` — full univariate workup**

- Mean 6.52, median 6.0, mode 6 — mean sitting just above median/mode is
  the first hint of a mild right skew, confirmed by skewness = 0.68
  (positive, moderate — nowhere near `SalePrice`'s 1.88).
- Kurtosis 0.88 (< 3): flatter than normal, no heavy-tail drama.
- Histogram + box plot agree on **6 rooms as the typical size** (402
  houses, the tallest bar and the box's median line), with most houses
  falling in the 5–8 room range.
- Outliers are asymmetric: several houses at the high end (10–14 rooms)
  vs. just one at the low end (2 rooms) — more unusually *large* houses
  than unusually small ones, consistent with the right skew direction.

This is the same shape-reading recipe as `SalePrice` above (mean vs.
median position → skew sign → confirm with skew/kurtosis numbers →
confirm again visually), just with a much milder effect size.

## Lab: Amazon UK Product Insights (univariate)

**[`lab-eda-univariate.ipynb`](lab-eda-univariate.ipynb)** — same
2.44M-row Amazon UK dataset used in the [day 2](../day2) bivariate lab
(not committed here, downloaded from
[Kaggle](https://www.kaggle.com/datasets/asaniczka/uk-optimal-product-price-prediction/)).

**Categories**: `Sports & Outdoors` alone is 34.2% of the *entire*
dataset — bigger than the next ~44 categories its size combined. Any
unweighted per-category comparison needs to keep that in mind.

**Price**: mean (£89.24) sits way above median (£19.09) and mode
(£9.99) — the giveaway for right skew, confirmed by the histogram (had
to zoom to the 99th percentile to be readable at all) and box plot. The
£100,000 "maximum" turned out to be a single junk row (*"HB FBA Test
Treadmill"*), a literal test listing — a reminder to always eyeball an
extreme max/min before trusting it, not just compute it.

**Ratings — the one that actually mattered**: `stars == 0` is **50.2%**
of all listings, almost certainly a "not yet rated" placeholder rather
than a real 0-star average (same pattern flagged in the day 2 lab). Every
stat was computed both raw and rated-only, and they tell opposite
stories:

| | Raw (incl. zero-placeholder) | Rated only |
| --- | ---: | ---: |
| Mean | 2.15 | 4.32 |
| Median / Mode | 0.0 / 0.0 | 4.4 / 4.5 |
| Std | 2.19 | 0.56 |
| Skew | 0.08 (looks symmetric) | -2.38 (strongly left-skewed) |

The raw numbers look almost symmetric purely by coincidence — the zero
spike happens to roughly balance the 4-5 star cluster. That "symmetry" is
an artifact of mixing two different populations (rated vs. not-yet-rated)
into one column, not a real property of how customers rate products.
**Always check what a suspicious mode/median value like 0 actually means
in the data before reporting it as a finding.**
