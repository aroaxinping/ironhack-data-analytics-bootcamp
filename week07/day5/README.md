# Day 5 — Class Imbalance

- Class Imbalance (+ hands on)
- Lab | Imbalanced

---

## Accuracy lies when classes are imbalanced

With a target that's 91.3% one class and 8.7% the other (this lab's fraud
column), a model that predicts "never fraud" scores **91.3% accuracy**
while catching zero fraud. Any dataset with a skewed target needs a
different lens: **precision** (of what you flagged, how much was real)
and **recall** (of what was real, how much you caught), balanced by
**F1**. Which of precision/recall matters more is a business call, not a
math one — for fraud, a missed case (low recall) usually costs more than
a false alarm (low precision), so recall tends to be the priority metric.

## Three ways to rebalance a training set

- **Oversampling** — resample the minority class *with replacement* up
  to the majority class's size. Simple, but literally duplicates existing
  minority rows — the model can end up seeing the same fraud examples
  many times over.
- **Undersampling** — the mirror image: randomly drop majority-class rows
  down to the minority class's size. No duplication, but throws away real
  data — this lab's undersampled set was ~140K rows vs. oversampling's
  ~1.46M, discarding roughly 660K legit-transaction rows in the process.
- **SMOTE** (Synthetic Minority Oversampling Technique) — instead of
  duplicating minority rows, generates new *synthetic* ones by
  interpolating between real minority points and their nearest minority
  neighbors. The more sophisticated option, meant to avoid the
  "memorizing duplicates" failure mode of plain oversampling.

**All three only ever touch the training set.** Rebalancing the test set
would defeat the point — evaluation needs to reflect the real-world class
distribution the model will actually face in production.

## Balancing didn't move F1 — and that's the actual lesson

All three techniques landed in nearly the same place on this dataset:
recall jumped from 60% (imbalanced baseline) to ~95%, while precision
dropped from 90% to ~57% — and **F1 stayed roughly flat** (~0.72 baseline
vs. ~0.71 balanced). Rebalancing didn't make the model "better" by any
single number; it moved *where* the model sits on the precision/recall
tradeoff. Whether that trade is worth it depends entirely on which
mistake is more expensive for the business in question — that's the
actual decision balancing techniques are for, not a guaranteed metric
win.

## Lab results

**[`lab-imbalanced.ipynb`](lab-imbalanced.ipynb)** — 1,000,000 credit
card transactions, 8.7% fraud, Logistic Regression:

| | Precision | Recall | F1 |
| --- | ---: | ---: | ---: |
| Baseline (imbalanced) | 89.5% | 60.2% | 72.0% |
| Oversampled | 57.2% | 95.0% | 71.4% |
| Undersampled | 57.1% | 95.0% | 71.3% |
| SMOTE | 57.4% | 94.8% | 71.5% |

The baseline model is conservative — high precision, but misses 40% of
actual fraud. All three balancing techniques converge to essentially the
same aggressive alternative — catch 95% of fraud, accept far more false
positives. For fraud detection specifically, that trade is usually the
right call: the balanced models are the ones worth deploying here, even
though "F1 went up" isn't the reason why.
