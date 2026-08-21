# Day 5 — Advanced Tableau, Storytelling & the Vanguard Project

- Tableau II
- Storytelling
- Lab | Tableau Advanced
- Introduction to the Vanguard Project

---

## Tableau II — beyond dragging fields

Day 4 covered building a worksheet; today is about the pieces that make a
dashboard actually usable by someone who isn't the analyst.

- **Calculated fields** — new fields derived from existing ones, written
  in Tableau's own expression language. The equivalent of a pandas
  assignment, except it lives in the workbook and recomputes with the
  view.
- **Level of detail and aggregation** — the recurring gotcha from day 4.
  Every view has a *grain* (the dimensions on the shelves), and every
  measure is aggregated to that grain. A number that looks wrong is
  usually a grain problem, not a data problem.
- **Parameters vs. filters** — a filter removes rows from the view; a
  parameter is a user-controlled input value the view reacts to. Use a
  filter to narrow, a parameter to let the reader switch what they're
  looking at.
- **Dashboard actions** — filter, highlight and go-to-URL actions turn a
  set of static worksheets into something you click through. Selecting a
  bar in one chart driving the others is what makes a dashboard feel like
  a tool rather than a poster.
- **Dashboard layout** — containers, sizing (fixed vs. automatic), and
  putting the headline number where the eye lands first.

## Storytelling — the part that isn't the chart

The core idea: an analysis isn't finished when the finding exists, it's
finished when someone else acts on it. That's a communication problem,
not a statistics one.

**Start from the audience and the decision.** What does this person need
to decide, and what do they already know? A technical audience wants the
method and the caveats; a business audience wants the recommendation
first and the method available if they ask. Same analysis, different
order.

**Structure: one narrative, not a tour of every chart made.** A workable
shape is context → conflict/finding → resolution/recommendation. Most of
the EDA never makes it into the story; the dead ends and the fifteen
histograms were how the finding was reached, not the finding.

**One message per slide or view**, and put it in the title. A chart
titled "Sales by region" makes the reader do the work; "Northern region
drives 60% of growth" hands them the point and uses the chart as
evidence.

**Design in service of the message** — colour used to highlight the one
thing that matters (and consistently, so the same category is the same
colour everywhere), chart type matched to the comparison being made,
clutter removed, axes honest. Truncated y-axes and 3D pie charts are the
classic ways to mislead without technically lying.

**Be honest about uncertainty.** Correlation isn't causation, a
significant p-value on a big sample can still be a tiny effect (exactly
the `LotArea` r = 0.26 case from day 4), and saying so builds more trust
than a confident overclaim that falls apart in the Q&A.

## Lab | Tableau Advanced

Continues the day 4 workbook: a choropleth map, a regression plot
(`Customer Lifetime Value` vs. `Income`) and a boxplot (`Total Claim
Amount` by `Vehicle Size`), combined into a dashboard and then into a
Tableau **story**.

As with day 4, the workbook lives in Tableau Public, so what's committed
here is the brief plus the reference figures each view should reproduce.
The headline results: small vehicles carry the *highest* average claims,
and CLV vs. Income comes out at r ≈ 0.024 with p ≈ 0.02 — significant and
meaningless at the same time, which is the day 4 lesson showing up again
with the sign flipped.

See [`lab-tableau-advanced.md`](lab-tableau-advanced.md).

## Introduction to the Vanguard Project

The second project of the bootcamp, and the first one that is an **A/B
test** end to end rather than open-ended EDA.

**The scenario:** Vanguard redesigned its online process — a modernised
interface with contextual prompts through the flow — and ran a controlled
experiment to find out whether the new design gets more clients through
to completion than the old one.

**The data**, three pieces that have to be joined on `client_id`:

- **client profiles** — demographics and relationship data (age, tenure,
  number of accounts, balance, recent activity).
- **digital footprints** — the event log, delivered in two parts that get
  concatenated. Each row is a client at a `process_step` in the funnel
  (start → step 1 → step 2 → step 3 → confirm) with a timestamp.
- **experiment roster** — which clients were in **Test** (new UI) and
  which in **Control** (old UI). Not every client in the profile data is
  in the experiment, so this join decides the analysable population.

**The work, in the order it has to happen:**

1. **EDA and cleaning** — who are these clients, what does the missing
   data look like, are Test and Control actually comparable on
   demographics (if they aren't, the experiment is confounded before any
   test is run).
2. **Define the KPIs.** The funnel event log doesn't hand these over;
   they have to be constructed from timestamps and step sequences —
   **completion rate** (reached `confirm`), **time spent per step**, and
   an **error rate** in the sense of clients moving *backwards* to an
   earlier step, which is the signal that a step confused them.
3. **Hypothesis testing** — this is where week 5's day 3 and day 4
   material gets used for real. Is the difference in completion rate
   between Test and Control significant? Not just "is it different" but
   "is it different by enough to be worth the cost of the redesign" — the
   brief sets a minimum increase the new design has to beat, which turns
   the question into a test against a threshold rather than against zero.
   Plus the comparability checks from step 1 as their own tests.
4. **Experiment evaluation** — was the design of the experiment itself
   sound? Randomisation, duration, sample size, and what would be needed
   to trust the conclusion.
5. **Tableau dashboard + presentation** — which is why storytelling lands
   on the same day as the project intro. The deliverable isn't the
   notebook, it's a recommendation someone can act on.

**The thing to keep in mind from day one:** the answer to "did the new
design work?" is a business recommendation with a confidence level
attached, not a p-value. The statistics are the evidence, and the funnel
KPIs are the argument.

Project work itself starts in week 6 — see that week's folder for the
implementation.

## Files

- [`lab-tableau-advanced.md`](lab-tableau-advanced.md) — lab brief, step
  checklist and reference figures.
