# Day 2 — EDA Bivariate Analysis

- EDA Bivariate Analysis (+ hands on)
- Lab | EDA Bivariate Analysis

---

## Categorical vs. categorical

**Crosstab** (`pd.crosstab(cat_a, cat_b)`) is the starting point — raw
counts of every combination. To compare *rates* across groups of very
different sizes, divide by the row total (`ct[True] / ct.sum(axis=1)`)
rather than eyeballing counts — a category with 5 best-sellers out of 50
listings and one with 50 best-sellers out of 5,000 look similar in raw
counts but are wildly different in rate (10% vs. 1%).

**Chi-square test of independence** (`chi2_contingency(ct)`) answers "is
there *any* relationship at all" — but with a large enough sample, it
rejects independence for almost any real-world pair of categoricals, even
trivially weak ones. That's what **Cramér's V** is for: it rescales the
chi-square statistic into a 0–1 "how strong is this relationship,
practically" number, independent of sample size. Significance and effect
size are two different questions — a dataset can answer "yes, definitely
related" (p ≈ 0) and "barely" (Cramér's V ≈ 0.12) at the same time, and
both answers matter.

## Numerical vs. categorical

**Violin plot vs. box plot**: a violin plot shows the full shape of the
distribution (via a KDE mirrored on both sides), a box plot compresses it
to five numbers (min/Q1/median/Q3/max) plus outliers. Violin is better
for spotting bimodality or skew shape; box is better for quickly comparing
medians and spread across many categories side by side.

**Filter to the top-N categories by count before plotting** — with
hundreds of categories, most holding a handful of rows, a full plot is
unreadable and the sparse categories don't have enough data for a
meaningful shape anyway. But when a question asks "which category has
the highest median/average X," answer it against **all** categories, not
just the filtered top-N used for the chart — the chart is for
readability, not for finding the true answer.

**Sampling before plotting large data**: with millions of rows, a scatter
plot or violin plot doesn't gain anything past a certain sample size —
the shape has already converged — it just gets slower to render and the
points overplot into a solid blob. Sampling (`df.sample(n=..., 
random_state=...)`) before plotting is a legitimate, standard move, not
a shortcut that changes the answer — the summary statistics (medians,
correlations, chi-square) should still be computed on the full data.

## Numerical vs. numerical

**Correlation coefficient** (`.corr()`, Pearson by default) is a single
number for a linear relationship; always pair it with a **scatter plot**,
because Pearson can miss a strong non-linear relationship entirely (or
call a relationship "weak" when it's actually strong but curved).

**Correlation heatmap** (`sns.heatmap(df[cols].corr(), annot=True)`) is
the fast way to scan every pairwise correlation among several numerical
columns at once, rather than computing and comparing them one at a time.

**QQ plot** (`scipy.stats.probplot(x, dist='norm', plot=ax)`) checks
whether a variable is normally distributed by comparing its quantiles
against a theoretical normal's — points hugging the diagonal reference
line means "looks normal," points curving away (especially at the tails)
means skew or heavy tails. This matters because several statistical
tests (like the standard t-test) assume normality.

## IQR outlier removal, as a preliminary step

`Q1 - 1.5*IQR` to `Q3 + 1.5*IQR` is the same rule used for box-plot
whiskers — anything outside those bounds gets dropped before the rest of
the analysis runs. Worth checking **both** versions of a conclusion
(with and without outliers) rather than assuming outlier removal doesn't
change the story — in this lab it didn't flip any conclusion, but it did
change the strength of one (see the price-rating correlation below).

## Lab: Amazon UK Product Insights

**[`lab-eda-bivariate.ipynb`](lab-eda-bivariate.ipynb)** — full analysis
on the real 2.44M-row Amazon UK dataset (not committed here, ~480MB, over
GitHub's file limit — each teammate downloads it from
[Kaggle](https://www.kaggle.com/datasets/asaniczka/uk-optimal-product-price-prediction/)).
This dataset version has no `brand` column, only `category` — so the
"brands" angle mentioned in the lab title isn't explorable here.

**Part 1 — Best-seller trends by category:**
- Best-seller rate is very unevenly spread across categories: the top
  ones (Grocery, Smart Home Security & Lighting, Health & Personal Care)
  sit around 5.7-5.8%, many categories have exactly 0%.
- Chi-square rejects independence (p ≈ 0), but Cramér's V ≈ 0.12 — a
  real but weak association. Category shifts best-seller odds a little,
  it doesn't drive them.

**Part 2 — Prices and ratings across categories** (IQR outliers removed,
6.8% of rows):
- Highest median price: **Desktop PCs** (£74.00), with Boxing Shoes,
  Tablets, Graphics Cards and Motherboards close behind — a tech-hardware
  cluster, plus one genuine surprise (Boxing Shoes).
- Highest average price: **Motherboards** (£68.77) — same cluster,
  slightly reordered by how mean vs. median react to each category's
  remaining right-tail.
- Highest median rating: **Computer Memory** (4.7). Data quality flag:
  several of the *largest* categories show a median rating of 0.0 —
  almost certainly `stars = 0` used as a "no ratings yet" placeholder,
  not genuine 1-star-below-zero dissatisfaction.

**Part 3 — Price vs. rating:**
- Essentially uncorrelated (Pearson ≈ -0.08, outliers removed) — paying
  more doesn't reliably buy a better rating.
- QQ plot confirms price is still right-skewed even after IQR outlier
  removal — not surprising for something bounded at £0 with no natural
  upper bound.
- **Bonus (with outliers kept):** correlation actually gets *slightly
  more* negative (-0.125 vs. -0.078) — the priciest outlier products skew
  a touch lower-rated, not higher. Removing outliers didn't manufacture
  the "no real relationship" finding; if anything it was understating how
  weak (and slightly negative) the relationship already is.
