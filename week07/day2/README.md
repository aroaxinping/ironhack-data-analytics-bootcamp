# Day 2 — Feature Engineering

- Feature Engineering (+ hands on)
- Lab | Feature Engineering

---

## Reducing granularity: keep the signal, drop the noise

`Cabin` looks like `B/0/P` (deck/number/side) — using it raw would mean
one dummy column per unique cabin, mostly seen once each: pure
overfitting fuel, zero generalization. Splitting off just the deck
letter (`spaceship["Cabin"].str[0]`) keeps the part of the value that's
actually shared across many passengers and plausibly predictive (deck
location on the ship), and throws away the part that's closer to a
unique id.

General pattern, not just this dataset: **before dummy-encoding a
high-cardinality column, ask whether a coarser derived version keeps
the useful signal.** Full cabin number: overfits. Deck letter: a real
categorical feature. Same instinct as PassengerId — a plain id column is
never predictive on its own, only drop it, don't encode it.

## Dummies: what `get_dummies` actually does

`pd.get_dummies(df, columns=[...], drop_first=True)` turns each category
into its own 0/1 column. `drop_first=True` drops one category per column
to avoid the dummy variable trap (perfect multicollinearity — if you
know every other dummy is 0, the dropped category is implied, so it
carries no extra information and only adds redundant columns).

## Small feature-engineering win, but not the real fix

Test accuracy: **76.6%** (intro-to-ML lab, numeric columns only) →
**76.9%** (this lab, + `HomePlanet`/`CryoSleep`/`Cabin` deck/`Destination`/`VIP`
as dummies). Real, but small. The bigger issue is still open: KNN is
distance-based and none of these features are scaled — `RoomService` /
`FoodCourt` / `Spa` / `VRDeck` (raw currency, up to thousands) still
dominate the Euclidean distance over `Age` or the 0/1 dummy columns,
regardless of how predictive those are. More features didn't fix that;
scaling is day 3's job (Ensemble lab reuses this exact feature set with
`StandardScaler` added).

## Lab results

**[`lab-feature-engineering.ipynb`](lab-feature-engineering.ipynb)** —
Spaceship Titanic, same base pipeline as day 1's lab plus:
- `Cabin` reduced to deck letter (`{A, B, C, D, E, F, G, T}`)
- `PassengerId` and `Name` dropped (ids, not features)
- Remaining categoricals dummy-encoded (`drop_first=True`)
- `KNeighborsClassifier` (default hyperparameters): **83.4% train, 76.9%
  test accuracy** — the train/test gap (KNN memorizing local neighborhoods
  in training data that don't generalize as cleanly) is the same
  overfitting shape seen in day 1, just slightly worse in absolute terms
  since the wider feature space gives KNN even more ways to fit noise.
