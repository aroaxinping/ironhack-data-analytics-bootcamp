# Day 3 — Probability & Hypothesis Testing

- Intro to Probability (+ lab)
- Hypothesis Testing (+ lab)

---

## Picking a distribution

The recurring skill this day is matching a word problem to the right
distribution family before touching any code:

- **Binomial** — fixed number of independent trials, each with the same
  success probability, counting how many succeed. `binom.cdf(k, n, p)` =
  P(X ≤ k). Used for the overbooking problem: X = passengers who show up
  out of 460 sold tickets, each with a 97% chance of showing.
- **Geometric** — number of trials *until* the first success.
  `geom.sf(k, p)` = P(X > k) — the survival function is the natural fit
  for "at least N attempts" questions, since P(X ≥ N) = P(X > N-1).
- **Poisson** — count of independent events in a fixed interval, given
  only the average rate. `poisson.sf(k, mu)` = P(X > k). Used for website
  traffic (500 visits/hour on average, is 550 too many?).
- **Exponential** — the *waiting time* between Poisson events. `expon.cdf`
  / `.sf` with `scale=mean`, not `scale=1/mean` — `scipy.stats.expon`
  parameterizes by the mean directly, not the rate λ. Used for helpdesk
  arrival gaps and component lifetime.
- **Normal** — continuous, symmetric, defined by mean and std. Used for
  bird weights.

## Two tricks worth remembering

**Compounding independent hourly probabilities into a daily one:** if
P(overwhelmed in one hour) = p, then P(*never* overwhelmed in 24 hours) =
(1-p)²⁴, so P(overwhelmed at some point) = 1 - (1-p)²⁴. A small per-hour
risk (1.3%) compounds to a much larger daily one (26.8%) — this is the
same shape as the "at least one" logic used all over probability, not
specific to Poisson.

**The exponential distribution is memoryless:** P(T > 15) doesn't care
how long it's already been since the last arrival — there's no "it's been
a while, a customer must be due soon" effect. That's what makes
`expon.sf(15, scale=10)` valid for "will there be a 15-minute gap"
without needing to track elapsed time.

## Hypothesis testing: picking the test

**One question, two groups → two-sample t-test.** For "is Dragon HP
higher than Grass HP," `scipy.stats.ttest_ind(..., equal_var=False)`
(Welch's t-test — don't assume equal variances by default) gives a
two-tailed p-value; since the question is directional ("*more* than," not
"different from"), halve it for a one-tailed p-value — but only when the
sample's `t_stat` already points the right way, otherwise the one-tailed
answer is `1 - p/2`, not `p/2`.

**Several outcome variables, still only two groups → several t-tests, not
ANOVA.** "Legendary vs. Non-Legendary across HP/Attack/Defense/Sp.
Atk/Sp. Def/Speed" is 2 groups × 6 stats — ANOVA is for comparing means
across 3+ groups on *one* outcome, not for multiple outcomes on 2 groups.
The right move is a loop: one two-sided Welch's t-test per stat.

**Constructing a "closeness" feature before testing.** For the housing
lab, "close to a school or hospital" isn't a column in the data — it has
to be engineered: euclidean distance from each house's `(longitude,
latitude)` to two fixed reference points, thresholded at 0.50, then
combined with `|` (close to *either* one counts). Only after that
engineering step does it become a clean two-group t-test problem again.

## Lab results

**[`lab-intro-probability.ipynb`](lab-intro-probability.ipynb)**

| # | Scenario | Distribution | Answer |
| - | -------- | ------------ | -----: |
| 1 | Overbooking: 460 tickets, 450 seats, 3% no-show | Binomial | 88.4% enough seats |
| 2 | Call center: ≥3 attempts to resolve, p=0.3 | Geometric | 49.0% |
| 3 | Website overwhelmed (>550 visits, mean 500) | Poisson | 1.3% per hour, 26.8% per day |
| 4 | Helpdesk: next arrival within 5 min (mean 10 min) | Exponential | 39.3%; 22.3% chance of a break (gap >15 min) |
| 5 | Bird weight between 140–160g (mean 150, sd 10) | Normal | 68.3% (the "68" in 68-95-99.7) |
| 6 | Component fails within 30h (mean lifetime 50h) | Exponential | 45.1% |

**[`lab-hypothesis-testing.ipynb`](lab-hypothesis-testing.ipynb)**

- Dragon-type Pokémon average significantly more HP than Grass-type
  (83.3 vs. 67.3, one-tailed Welch's t-test, p ≈ 0.0008).
- Legendary Pokémon score significantly higher on *all six* base stats
  vs. Non-Legendary (six separate Welch's t-tests, all p < 1e-10).
- California houses within 0.50 (euclidean, lon/lat) of a school or
  hospital are significantly more expensive: $246,952 vs. $180,678 mean
  value (one-tailed Welch's t-test, p ≈ 1.5e-301) — a strong association,
  though not proof the proximity itself is what drives the price.
