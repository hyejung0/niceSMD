# Tables by trial and treatment arm

``` r

library(niceSMD)
```

When you pool individual participant data from several trials (for
example in a trial-level surrogate endpoint analysis),
[`nice_trial_table1()`](https://hyejung0.github.io/niceSMD/reference/nice_trial_table1.md)
summarizes **each trial separately, by treatment arm**. Under the hood
each trial is run through
[`nice_SMD_table1()`](https://hyejung0.github.io/niceSMD/reference/nice_SMD_table1.md),
so every convention (denominators, missing values, weights, SMDs) is
identical; the function arranges the pieces into one table.

## Example data

[`example_trial_data()`](https://hyejung0.github.io/niceSMD/reference/example_trial_data.md)
has three trials. Trials A and B compare Placebo with Active; Trial C
adds a High dose arm.

``` r

d <- example_trial_data()
table(d$trial, d$arm)
#>          
#>           Placebo Active High dose
#>   Trial A      30     30         0
#>   Trial B      24     24         0
#>   Trial C      24     24        24
```

## Trials side by side

``` r

vars <- c("age", "egfr", "sex", "diabetes", "ckd_stage")
labels <- c("Age (years)", "eGFR (mL/min/1.73 m2)", "Sex", "Diabetes", "CKD stage")

wide <- nice_trial_table1(
  d, trial = "trial", treatment = "arm", covar_names = vars,
  print_covariate_names = labels,
  treatment_for_SMD = c("Placebo", "Active"),   # required: Trial C has 3 arms
  notes = "short"
)
wide
```

[TABLE]

Things to notice:

- A header spans each trial; arms sit underneath with their sample
  sizes.
- The SMD in each trial compares only the two arms named in
  `treatment_for_SMD`. Trial C’s High dose arm is shown but not
  compared.
- `ckd_stage` G5 does not occur in Trial A, so it displays as a zero
  count.
- A Missing row appears only for `age` and `eGFR`, the only variables
  with missing values (`show_missing = "if_any"` is the default here).

This layout works for a few trials. With many trials it becomes too
wide.

## One row per trial and arm

``` r

long <- nice_trial_table1(
  d, "trial", "arm", vars, print_covariate_names = labels,
  treatment_for_SMD = c("Placebo", "Active"),
  layout = "long", continuous_stats = "mean_sd", notes = "short"
)
long
```

| Trial | Treatment | N | Age (years) |  | eGFR (mL/min/1.73 m2) |  | Sex |  | Diabetes |  | CKD stage |  |  |
|----|----|----|----|----|----|----|----|----|----|----|----|----|----|
|  |  |  | Mean (SD) | Missing | Mean (SD) | Missing | Female | Male | No | Yes | G3 | G4 | G5 |
| Trial A | Placebo | 30 | 62.70 (9.09) | 0 (0.0%) | 39.67 (5.86) | 0 (0.0%) | 12 (40.0%) | 18 (60.0%) | 18 (60.0%) | 12 (40.0%) | 20 (66.7%) | 10 (33.3%) | 0 (0.0%) |
|  | Active | 30 | 64.07 (8.63) | 1 (3.3%) | 39.66 (5.75) | 1 (3.3%) | 12 (40.0%) | 18 (60.0%) | 16 (53.3%) | 14 (46.7%) | 20 (66.7%) | 10 (33.3%) | 0 (0.0%) |
| Trial B | Placebo | 24 | 65.29 (8.89) | 0 (0.0%) | 43.67 (5.80) | 1 (4.2%) | 10 (41.7%) | 14 (58.3%) | 15 (62.5%) | 9 (37.5%) | 10 (41.7%) | 10 (41.7%) | 4 (16.7%) |
|  | Active | 24 | 68.48 (9.05) | 1 (4.2%) | 42.17 (5.76) | 0 (0.0%) | 10 (41.7%) | 14 (58.3%) | 13 (54.2%) | 11 (45.8%) | 10 (41.7%) | 9 (37.5%) | 5 (20.8%) |
| Trial C | Placebo | 24 | 60.04 (9.00) | 1 (4.2%) | 37.42 (5.83) | 0 (0.0%) | 9 (37.5%) | 15 (62.5%) | 13 (54.2%) | 11 (45.8%) | 9 (37.5%) | 10 (41.7%) | 5 (20.8%) |
|  | Active | 24 | 62.25 (9.23) | 0 (0.0%) | 37.92 (5.75) | 0 (0.0%) | 10 (41.7%) | 14 (58.3%) | 14 (58.3%) | 10 (41.7%) | 10 (41.7%) | 10 (41.7%) | 4 (16.7%) |
|  | High dose | 24 | 60.50 (8.66) | 0 (0.0%) | 38.42 (5.90) | 0 (0.0%) | 10 (41.7%) | 14 (58.3%) | 14 (58.3%) | 10 (41.7%) | 10 (41.7%) | 9 (37.5%) | 5 (20.8%) |
| Summaries are computed within each trial and treatment arm. Categorical: n (%) among nonmissing values. Continuous: mean (SD) and median (Q1, Q3). Missing: n (% of arm). |  |  |  |  |  |  |  |  |  |  |  |  |  |
| A Missing row is shown only for variables with at least one missing value in some trial. |  |  |  |  |  |  |  |  |  |  |  |  |  |

Variables run across the columns, categorical variables get one column
per level, and each trial’s rows are grouped.
`continuous_stats = "mean_sd"` keeps only mean (SD), which roughly
halves the width. SMDs are not shown in this layout, but they are always
available:

``` r

head(long$smd[, c("trial", "label", "smd", "status")], 6)
#>     trial                 label         smd status
#> 1 Trial A           Age (years) 0.154448370     ok
#> 2 Trial A eGFR (mL/min/1.73 m2) 0.001980403     ok
#> 3 Trial A                   Sex 0.000000000     ok
#> 4 Trial A              Diabetes 0.134839972     ok
#> 5 Trial A             CKD stage 0.000000000     ok
#> 6 Trial B           Age (years) 0.355183343     ok
```

## Should the table include SMDs at all?

Within a randomized trial, baseline differences between arms are chance
imbalances, and reporting guidance discourages baseline significance
tests. Many authors therefore omit within-trial SMDs. To drop the SMD
columns from the wide table:

``` r

nice_trial_table1(d, "trial", "arm", vars, treatment_for_SMD = c("Placebo", "Active"),
                  show_smd = FALSE)
```

## Weights, order, and export

``` r

# Weighted summaries within each trial and arm
nice_trial_table1(d, "trial", "arm", vars, weights = "weight",
                  treatment_for_SMD = c("Placebo", "Active"))

# Put trials and arms in a chosen order
nice_trial_table1(d, "trial", "arm", vars,
                  treatment_for_SMD = c("Placebo", "Active"),
                  trial_order = c("Trial C", "Trial A", "Trial B"),
                  treatment_order = c("Active", "Placebo", "High dose"))

# Word (landscape is recommended for trial tables)
save_table1_docx(wide, "Table1_by_trial.docx", landscape = TRUE, font_size = 9)
```

Each trial’s own table is kept in `wide$trials`, for example
`wide$trials[["Trial A"]]`.
