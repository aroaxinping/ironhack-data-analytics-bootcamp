# Lab | Advanced Tableau Visualization

**Objective:** extend the day 4 workbook with a choropleth map, a
regression plot and a boxplot, then wrap the findings in a Tableau
**story**.

**Dataset:** the same
[`we_fn_use_c_marketing_customer_value_analysis.csv`](https://raw.githubusercontent.com/data-bootcamp-v4/data/main/we_fn_use_c_marketing_customer_value_analysis.csv)
(9,134 rows), continuing from `tableau-lab.twbx`.

**Deliverable:** the extended Tableau workbook + story. Not committed
here — link below once published.

📊 **Tableau Public:** _(pending)_

---

## Steps

- [ ] **1. Choropleth map** — customers by `State`, colour density =
      number of customers. `State` has to be assigned the **geographic
      role** (State/Province) or Tableau won't map it.
- [ ] **2. Regression plot** — `Customer Lifetime Value` vs. `Income`,
      with a trend line. Scatter needs both fields **disaggregated**
      (Analysis → uncheck Aggregate Measures), otherwise it collapses to
      a single point.
- [ ] **3. Boxplot** — `Total Claim Amount` by `Vehicle Size`.
- [ ] **4. Dashboard** — the three new sheets combined and interactive.
- [ ] **5. Story** — a narrative walking a reader through the findings.

## Reference figures

**Choropleth** — California 3,150, Oregon 2,601, Arizona 1,703, Nevada
882, Washington 798. Only five states have data, so most of the US map
is blank. That's not a bug, but it *is* a design problem: a full-country
map with 45 empty states wastes space and implies missing data. Zooming
to the region, or keeping the day 4 treemap for the comparison and using
the map only for the geographic point, is the honest call.

**CLV vs. Income** — Pearson r ≈ **0.024**, p ≈ 0.02. This is the
interesting one, and it's the day 4 lesson in reverse: the p-value is
"significant" at α = 0.05, and the relationship is **effectively
nonexistent** — r = 0.024 means income explains about 0.06% of the
variance in lifetime value. With n = 9,134, significance is nearly free.
The trend line Tableau draws will look flat because it *is* flat, and
the right conclusion is "no usable relationship", not "a slight positive
relationship".

Worth checking in the scatter: `Income` has a large block of zeros
(unemployed customers), which shows up as a vertical stripe at x = 0 and
drags the fit around.

**Total Claim Amount by Vehicle Size**

| Vehicle Size | n | Mean | Median | Max |
| ------------ | --: | --: | --: | --: |
| Small | 1,764 | 489.43 | 451.20 | 2,327.17 |
| Large | 946 | 426.06 | 378.26 | 2,452.89 |
| Medsize | 6,424 | 420.08 | 362.90 | 2,893.24 |

Two things the boxplot should show: **Small** vehicles have the highest
claims (counter-intuitive, and the most reportable finding here), and
**every** category has mean > median plus a long upper whisker — claim
amounts are right-skewed, exactly the shape day 4's normality work was
about. Medsize is 70% of the data, so its box dominates the eye even
though it's the *lowest* of the three on both mean and median.

## Story notes

The storytelling class lands the same day as this lab, so the story is
the point, not an afterthought. What that means concretely here:

- **Lead with the finding, not the tour.** The claims-by-vehicle-size
  result is the one a business reader can act on. The map is context.
- **Title each story point with its message** — "Small vehicles carry
  the highest average claims", not "Total Claim Amount by Vehicle Size".
- **Say the CLV/Income result out loud as a negative finding.** "Income
  doesn't predict lifetime value here" is a legitimate, useful slide.
  Dressing r = 0.02 up as a positive relationship because the p-value
  cleared 0.05 would be the exact mistake day 4 warned about.
- **Keep colour consistent** across the map, dashboard and story so the
  same state or category reads the same everywhere.
