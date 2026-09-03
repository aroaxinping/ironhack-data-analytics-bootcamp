# Day 1 — Intro to Machine Learning

- Intro to Machine Learning (+ hands on)
- Lab | Intro to Machine Learning
- ML Project kickoff

---

## KNN: no training, just distance at prediction time

K-Nearest Neighbors doesn't build a model in the usual sense — `.fit()`
just stores the training data. All the work happens at `.predict()`
time: find the K closest points (by distance) to the new one, and either
vote (classification) or average (regression) their target values.

Two direct consequences:
- **It's a distance-based algorithm**, so every feature needs to be on a
  comparable scale, and **all input has to be numerical** — no dummies
  yet at this stage, so day 1 works with numeric columns only (categorical
  handling is day 2's job, Feature Engineering).
- **K matters, but scaling matters more.** Comparing K=10 vs. K=5 on the
  California housing regression barely moved the test R² (third decimal),
  while the train R² jumped a lot for K=5 — fewer neighbors means each
  prediction can fit the training data more tightly, which is overfitting,
  not improvement. The real ceiling on this demo wasn't K at all: with
  unscaled features, a distance metric gets dominated by whichever column
  happens to have the largest raw numbers (income in the thousands vs. a
  ratio near 0-1), regardless of which feature is actually more
  predictive.

## Train/test split — why, not just how

`train_test_split(X, y, test_size=0.2)` exists to answer one question:
does the model generalize, or did it just memorize the training rows?
Evaluating on data the model already saw during `.fit()` can't tell the
two apart — a model can look perfect on training data and fall apart on
anything new. The demo's own R² numbers make the point directly: train R²
and test R² diverging is the tell that something (usually overfitting)
is happening.

## Classification vs. regression, same algorithm

`KNeighborsClassifier` (categorical target, majority vote among
neighbors) vs. `KNeighborsRegressor` (continuous target, average of
neighbors) — same neighbor-finding mechanism underneath, different
aggregation at the end. Picking between them is about the target
variable's type, not the features.

## Lab results

**[`lab-intro-to-ml.ipynb`](lab-intro-to-ml.ipynb)** — Spaceship Titanic,
predicting `Transported` with `KNeighborsClassifier` (default
hyperparameters, numeric columns only, dropna for missing values):

- **Missing data compounds column-by-column**: each individual column is
  only ~2% null, but across twelve columns that adds up — dropping any
  row with *any* null removed **2,087 of 8,693 rows (24%)**. A single
  column's null rate understates how much data a blanket `dropna()`
  actually costs once there are several such columns.
- **Accuracy**: 80.8% train, 76.6% test — some overfitting gap, but not
  dramatic.
- Same scaling issue as the class demo: the spending columns (RoomService,
  FoodCourt, Spa, VRDeck — all in raw currency units) dominate the
  distance metric over things like Age, purely because of their scale,
  not because they're more predictive. That's a bigger lever on this
  model's ceiling than which K gets picked — Feature Engineering (day 2)
  and Ensemble methods (day 3) build on exactly this dataset to fix it.

**Class notebook**: [`7.1_intro_to_ml.ipynb`](7.1_intro_to_ml.ipynb) —
Iris classification demo (96.67% accuracy, KNN default) and the
California housing regression walkthrough (R² 0.16 unscaled — a
deliberately bad starting point) with the K=10 vs. K=5 predicted-vs-real
scatter comparison described above.
