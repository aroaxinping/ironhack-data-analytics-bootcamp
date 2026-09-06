# Day 4 — Hyperparameter Tuning

- Hyperparameter Tuning (+ hands on)
- Lab | Hyperparameter Tuning

---

## Three search strategies, same idea

All three try combinations of hyperparameters and cross-validate each one
— they differ only in *how* they pick which combinations to try.

- **Grid Search** (`GridSearchCV`) — tries every combination in an
  explicit grid. Exhaustive, but combinations grow multiplicatively (2×2×2×2
  = 16 here) — expensive to widen.
- **Random Search** (`RandomizedSearchCV`) — samples `n_iter` random
  combinations from given ranges instead of trying all of them. Cheaper,
  but no guarantee of finding the best combination — on the California
  housing data it actually did *worse* than Grid Search here (test R² 0.59
  vs. 0.66), a reminder that "random" isn't "smarter."
- **Bayesian Search** (Optuna, not available in scikit-learn) — the
  interesting one: it builds a probability model of `P(score |
  hyperparameters)` from trials already run, and uses that model to pick
  the *next* combination to try, instead of ignoring past results like
  Grid/Random do. Cheaper to evaluate than the real objective function
  once the model is warmed up. Beat both Grid and Random Search here (test
  R² 0.68).

## Optuna mechanics

- `optuna.create_study(direction="maximize"/"minimize")` — direction
  depends on the metric: R² → maximize, RMSE → minimize.
- The `objective(trial)` function is where hyperparameters get sampled:
  `trial.suggest_int(name, low, high)`, `trial.suggest_categorical(name,
  [...])`. Optuna decides what to try next based on everything returned
  by previous calls to this function.
- `trial.set_user_attr(key, value)` — a way to stash extra info per trial
  (here, a confidence interval) that isn't the actual thing being
  optimized, so it can be inspected later via `study.trials`.
- `study.optimize(lambda trial: objective(trial, ...), n_trials=45)` —
  the extra args (`confidence_level`, `folds`) get closed over via the
  lambda, since `objective` needs more than just `trial`.

## `make_scorer` sign-flip gotcha

`make_scorer(root_mean_squared_error, greater_is_better=False)` doesn't
just wrap the metric — it makes `cross_val_score` **negate** the result,
because scikit-learn's internal convention is always "higher score =
better," and RMSE is a loss (lower = better). So `cross_val_score(...,
scoring=scorer)` returns *negative* RMSE values. Forgetting this and
treating them as real RMSE directly silently breaks anything downstream
that assumes a positive error metric — confidence intervals, "which is
the best trial" comparisons, all of it. Fix: flip the sign back
(`-cross_val_score(...)`) before doing anything else with the numbers.

## Check for understanding — KNN Bayesian tuning

Optimized `KNeighborsRegressor` with Optuna (45 trials, minimizing RMSE
via `make_scorer` + the sign-flip above) over:
- `n_neighbors` [2–25]
- `weights` ['uniform', 'distance']
- `p` [1–3] (Minkowski power: 1 = Manhattan, 2 = Euclidean)

**Best combination**: `n_neighbors=10, weights='distance', p=1` — CV RMSE
0.594. On the held-out test set: **RMSE 0.592, R² 0.731** — clearly
better than the Bayesian-tuned Decision Tree from the same notebook (test
RMSE 0.647, R² 0.679). `p=1` (Manhattan distance) winning over the default
Euclidean is a bit non-obvious — worth remembering `p` is tunable at all,
not just `n_neighbors`.

**Class notebook**: [`7.4_hyperparameter_tuning_optuna.ipynb`](7.4_hyperparameter_tuning_optuna.ipynb)
(California housing dataset via `sklearn.datasets.fetch_california_housing`).

## Lab: tuning didn't beat the default, and that's a real result

**[`lab-hyperparameter-tuning.ipynb`](lab-hyperparameter-tuning.ipynb)** —
took Random Forest (the best model from day 3's Ensemble lab, 79.3% test
accuracy on Spaceship Titanic) and ran `GridSearchCV` over `n_estimators`,
`max_depth`, `min_samples_split`, `max_features` (54 combinations, 5-fold
CV).

- Best combination: `max_depth=10, max_features='sqrt',
  min_samples_split=5, n_estimators=300` — CV accuracy **80.7%**.
- Test accuracy with those hyperparameters: **78.8%** — slightly *below*
  the untouched default Random Forest's **79.3%**.

Worth sitting with rather than dismissing: the CV score averages 5 folds
of *training* data, the test score is one measurement on one fixed 20%
split — a gap this small is normal single-split noise, not proof tuning
failed. Grid Search optimizes cross-validated performance, which is a
more reliable signal than any single test split; a small dip on this
particular test set doesn't mean the defaults were secretly better in
general, and constraining `max_depth`/`min_samples_split` away from
scikit-learn's unrestricted defaults is a legitimate anti-overfitting
move even when it doesn't show up as a win on one held-out slice.
