# Lab | Tableau

**Objective:** load a dataset into Tableau, get the measures/dimensions
split right, and build barplots, a treemap and a cross table into a
single dashboard.

**Dataset:**
[`we_fn_use_c_marketing_customer_value_analysis.csv`](https://raw.githubusercontent.com/data-bootcamp-v4/data/main/we_fn_use_c_marketing_customer_value_analysis.csv)
— 9,134 rows × 24 columns of auto-insurance customers (state, gender,
employment status, marital status, income, Customer Lifetime Value,
Total Claim Amount, vehicle class/size, policy and sales-channel info).

**Deliverable:** a Tableau workbook saved as `tableau-lab.twbx`. Tableau
workbooks aren't committed here — the link goes below once it's
published.

📊 **Tableau Public:** _(pending)_

---

## Steps

- [ ] **1. Data import** — connect Tableau to the CSV above.
- [ ] **2. Gender barplot** — customer count by `Gender`.
- [ ] **3. Employment × Gender barplot** — customer count by
      `EmploymentStatus`, segmented by `Gender`.
- [ ] **4. Measures vs. dimensions** — review what Tableau auto-assigned
      and fix it. The trap in this dataset is that several ID-ish or
      code-ish numeric columns get read as measures: `Number of
      Policies`, `Number of Open Complaints`, `Months Since Last Claim`
      and `Months Since Policy Inception` are counts/labels more often
      than things you want summed. `Customer` is an ID, not data.
- [ ] **5. Gender barplot sheet** — its own sheet.
- [ ] **6. Employment × Gender barplot sheet** — its own sheet.
- [ ] **7. State treemap sheet** — customers per `State`, sized by count.
- [ ] **8. Marital Status × Gender cross table.**
- [ ] **9. Dashboard** — all sheets combined, interactive.
- [ ] **10. Save** as `tableau-lab.twbx`.

## Reference figures

Computed in pandas from the same CSV, to sanity-check that each Tableau
view is showing what it should. If a sheet disagrees with these, the
usual culprit is the aggregation (Tableau defaults to `SUM`, and these
are all **counts of rows**, i.e. `CNT`).

**Gender** — F 4,658 / M 4,476. Close to a 51/49 split, so the bar chart
should look almost even; a dramatic difference means something is being
summed instead of counted.

**EmploymentStatus × Gender**

| EmploymentStatus | F | M |
| ---------------- | --: | --: |
| Employed | 2,937 | 2,761 |
| Unemployed | 1,135 | 1,182 |
| Medical Leave | 214 | 218 |
| Retired | 128 | 154 |
| Disabled | 244 | 161 |

Employed + Unemployed is ~88% of the base; the other three categories
are small enough that a stacked bar hides them — worth sorting
descending so they don't vanish.

**Customers per State** (the treemap) — California 3,150, Oregon 2,601,
Arizona 1,703, Nevada 882, Washington 798. Only five states, all West
Coast / Southwest, so the treemap is really a five-tile view: California
and Oregon together are ~63% of customers.

**Marital Status × Gender** (the cross table)

| Marital Status | F | M |
| -------------- | --: | --: |
| Married | 2,779 | 2,519 |
| Single | 1,170 | 1,297 |
| Divorced | 709 | 660 |

Married is the majority for both genders; the one asymmetry worth
noticing is Single, where men outnumber women (1,297 vs. 1,170) —
the reverse of every other row.

## Notes

The recurring lesson from this lab is the one from the Tableau I class:
**check the aggregation before reading anything into a view.** Every
chart here is a row count, but Tableau's instinct on any numeric field
is `SUM`, so a "customers by state" bar built by dragging the wrong pill
silently becomes "total income by state" and still looks plausible.
