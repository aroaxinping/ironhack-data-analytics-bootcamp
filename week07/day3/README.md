# Day 3 — Supervised Learning & Ensemble Methods

- Machine Learning Supervised (+ hands on)
- Ensemble Methods (+ hands on)
- Lab | ML Ensemble

---

## Two ensemble families, two different fixes

**Bagging / Random Forest — reduce variance by averaging independent
models.** Train many high-variance models (deep decision trees) on
bootstrap-resampled subsets of the training data, then vote/average their
predictions. Any single tree overfits its own resample; averaging many
independent overfits cancels most of the noise out. Random Forest adds
one more decorrelation trick on top of plain Bagging: each split only
considers a random subset of features, so trees can't all just latch onto
the single strongest feature every time — that's why Random Forest (79.3%
test accuracy) edged out plain Bagging (78.9%) here.

**Gradient Boosting / AdaBoost — reduce bias by chaining weak learners.**
Instead of training independently, each new (usually shallow) tree is
trained to correct the *previous* ensemble's mistakes:
- **Gradient Boosting** fits each new tree to the gradient of the loss
  function — essentially, the residual errors the ensemble is still
  making.
- **AdaBoost** instead reweights the *training samples* after each round
  — misclassified points get more weight, so the next weak learner is
  forced to focus harder on exactly what's still being gotten wrong.

Different mechanism, same idea: sequential correction instead of
independent averaging.

## `Bagging` vs. `Pasting` — one parameter, not two classes

`BaggingClassifier(bootstrap=True)` (the default) is Bagging — sampling
*with* replacement, so the same row can appear multiple times in one
tree's training subset. `bootstrap=False` is Pasting — sampling *without*
replacement. Same scikit-learn class either way; it's one flag, not a
separate algorithm to import.

## Scaling — the fix day 2 was missing

The one change that carries over from feature engineering: `StandardScaler`
fit on `X_train` only (never on test — fitting the scaler on test data
leaks its distribution into training) then applied to both. All four
ensemble methods here run on the same scaled, dummy-encoded feature set
built in day 2's lab, so results are comparable across all three labs.

## Lab results

**[`lab-ensemble.ipynb`](lab-ensemble.ipynb)** — same Spaceship Titanic
feature engineering as day 2, plus `StandardScaler`:

| Model | Train acc. | Test acc. |
| --- | ---: | ---: |
| Random Forest | 94.0% | **79.3%** |
| Bagging | 94.0% | 78.9% |
| Gradient Boosting | 82.4% | 78.7% |
| AdaBoost | 78.9% | 77.8% |

**Random Forest wins**, narrowly ahead of plain Bagging — consistent with
the extra feature-subsampling decorrelation described above. All four
beat the single-model KNN baselines from days 1–2 (76.6% / 76.9% test
accuracy) — the expected ensemble result: combining many weak or
high-variance learners beats any one of them built the same way.
Bagging and Random Forest's identical, much higher train accuracy (94.0%
vs. Gradient Boosting's 82.4%, AdaBoost's 78.9%) is a visible overfitting
gap of its own — deep unpruned trees fit their bootstrap samples very
closely, it's the averaging across many of them that keeps test
performance reasonable despite that.
