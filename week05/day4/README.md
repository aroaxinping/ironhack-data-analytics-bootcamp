# Day 4 — Correlation, Normality & Tableau

- More on Correlation and Normality
- Tableau I
- Lab | Tableau

---

## Hypothesis testing applied back to EDA

Days 1–2 described relationships and distributions; day 3 introduced
hypothesis testing. Today those two threads meet: instead of eyeballing
a scatter plot or a histogram and calling it, we put a p-value on both
questions — *is this relationship real?* and *is this variable normal?*

The dataset is the same housing price one from earlier labs
(`housing_price_eda.csv`).

## Correlation as a test, not just a number

`scipy.stats.pearsonr(x, y)` returns **two** things, and the second one
matters as much as the first:

- **the coefficient** — strength and direction, from -1 to 1
- **the p-value** — against the null hypothesis *"there is no linear
  relationship between these two variables"*

For `LotArea` vs. `SalePrice`: r ≈ **0.26**, p ≈ **1.1e-24**. Both facts
are true at once and they say different things — the relationship is
**statistically significant** (a p-value that small means it is
essentially not a fluke of this sample) but **practically weak** (r =
0.26 means bigger lots trend more expensive, with a huge amount of
scatter around that trend). Significant ≠ strong. With n = 1460 rows,
even a mild relationship clears the significance bar easily; sample size
inflates significance, not effect size.

Also worth remembering: Pearson tests for a **linear** relationship
only. A low r doesn't rule out a strong curved one.

## Checking normality: three angles, not one

Why bother at all — because t-tests, ANOVA and linear regression all
carry a normality assumption somewhere, so "is this normal?" decides
which tools are legitimate downstream, and whether a transformation is
needed first.

1. **Visual** — histogram (looking for the bell), **Q-Q plot** (quantiles
   of the data against quantiles of a normal; normal data hugs the 45°
   line), box plot symmetry.
2. **Statistical tests** — both have the *same* null hypothesis: "the
   data is normal". So a **low p-value means NOT normal**, which is the
   inverted logic that trips people up.
   - **Shapiro-Wilk** (`stats.shapiro`) — better suited to smaller samples.
   - **Kolmogorov-Smirnov** (`stats.kstest(x, 'norm')`) — compares the
     empirical CDF to a theoretical one. It compares against the
     *standard* normal, so the data **has to be standardized first**
     (subtract the mean, divide by the std) or the test is meaningless.
3. **Descriptive** — skewness (0 for symmetric) and kurtosis (≈3 for
   normal), only ever as a supporting signal.

Result on the housing data: `SalePrice`, `LotArea` and `1stFlrSF` all
come back significantly non-normal — right-skewed, as size-and-price
variables usually are (bounded below at 0, no ceiling, a few very large
houses stretching the tail).

## Transformations: which one for which shape

- **Log** (`np.log1p`) — right-skewed data, exponential-looking growth.
  `log1p` rather than `log` avoids blowing up on zeros.
- **Square root** (`np.sqrt`) — mild to moderate skew; softens extremes
  more gently than a log.
- **Box-Cox** (`scipy.stats.boxcox`) — picks the best power
  transformation automatically, but **requires strictly positive values**.

The important habit is that a transformation is not the end of the step:
you re-plot and re-test afterwards.

## What the after-checks actually showed

| Variable | Transformation | Verdict after |
| -------- | -------------- | ------------- |
| `SalePrice` | log | p ≈ 0.015 — still rejects normality, but far closer than before |
| `LotArea` | Box-Cox | Q-Q line much straighter, p still < 0.05 |
| `1stFlrSF` | square root | p up but still < 0.05 |
| `GrLivArea` | log | p ≈ 0.19 — **no longer rejected**, skew 1.37 → ~0 |

The pattern: transformations move you toward normality, they don't
guarantee arrival. `GrLivArea` was the one that made it all the way,
probably because it started out less extreme. And "close enough to
normal for the method I want to use" is usually the real goal — chasing
a p-value above 0.05 for its own sake isn't.

## Central Limit Theorem — what it does and doesn't excuse

The CLT says the sampling distribution of the **mean** approaches normal
as n grows (rule of thumb n > 30), whatever the population's shape. It
does *not* say individual data points become normal with a big enough
dataset. A million-row skewed column is still skewed. Since most tests
assume the **data points** are normal, a large n is not a free pass out
of the assumption.

## Tableau I

First contact with Tableau: connecting to a data source, the
dimensions/measures split, dragging fields onto rows and columns to build
worksheets, and assembling worksheets into a dashboard.

The mental shift from pandas + matplotlib is that Tableau aggregates by
default — dropping a measure onto a shelf gives you `SUM(...)`, not the
raw rows — so the first thing to check on any new view is *what
aggregation is this actually showing*, and whether the dimension you
dropped in is the grain you meant.

Tableau deliverables live in Tableau Public rather than in this repo, so
there are no files for the lab here — only the notebook above.

## Files

- [`5.6_more_on_normality_correlation.ipynb`](5.6_more_on_normality_correlation.ipynb)
  — class notebook, including the solved "check for understanding"
  section (after-transformation checks for `LotArea` and `1stFlrSF`, plus
  `GrLivArea` chosen and transformed from scratch).
