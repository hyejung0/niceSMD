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

## Without treatment arms, or with a pooled column

Sometimes you want summaries by trial only, or by trial and arm plus a
total. With `treatment = NULL` each trial is one column (or row) and no
SMD is computed:

``` r

nice_trial_table1(d, "trial", treatment = NULL, covar_names = vars,
                  print_covariate_names = labels, notes = "short")
```

| Variable | Trial A | Trial B | Trial C |
|----|----|----|----|
|  | N = 60 | N = 48 | N = 72 |
| Age (years) |  |  |  |
| Mean (SD) | 63.37 (8.82) | 66.85 (9.02) | 60.94 (8.89) |
| Median (Q1, Q3) | 63.00 (56.00, 70.50) | 67.00 (59.00, 74.00) | 61.00 (53.50, 68.00) |
| Missing | 1 (1.7%) | 1 (2.1%) | 1 (1.4%) |
| eGFR (mL/min/1.73 m2) |  |  |  |
| Mean (SD) | 39.66 (5.75) | 42.90 (5.77) | 37.92 (5.76) |
| Median (Q1, Q3) | 39.50 (34.75, 44.25) | 43.00 (38.25, 47.75) | 38.00 (33.00, 43.00) |
| Missing | 1 (1.7%) | 1 (2.1%) | 0 (0.0%) |
| Sex |  |  |  |
| Female | 24 (40.0%) | 20 (41.7%) | 29 (40.3%) |
| Male | 36 (60.0%) | 28 (58.3%) | 43 (59.7%) |
| Diabetes |  |  |  |
| No | 34 (56.7%) | 28 (58.3%) | 41 (56.9%) |
| Yes | 26 (43.3%) | 20 (41.7%) | 31 (43.1%) |
| CKD stage |  |  |  |
| G3 | 40 (66.7%) | 20 (41.7%) | 29 (40.3%) |
| G4 | 20 (33.3%) | 19 (39.6%) | 29 (40.3%) |
| G5 | 0 (0.0%) | 9 (18.8%) | 14 (19.4%) |
| Summaries are computed within each trial. Categorical: n (%) among nonmissing values. Continuous: mean (SD) and median (Q1, Q3). Missing: n (% of trial). |  |  |  |
| A Missing row is shown only for variables with at least one missing value in some trial. |  |  |  |

`overall = TRUE` adds a pooled summary of every participant in the
displayed trials, ignoring trial and arm. The footnote says so, since
pooling across trials ignores the trial structure.

``` r

nice_trial_table1(d, "trial", "arm", vars, print_covariate_names = labels,
                  treatment_for_SMD = c("Placebo", "Active"),
                  layout = "long", continuous_stats = "mean_sd",
                  overall = TRUE, notes = "short")
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
| Overall | All arms | 180 | 63.32 (9.16) | 3 (1.7%) | 39.81 (6.07) | 2 (1.1%) | 73 (40.6%) | 107 (59.4%) | 103 (57.2%) | 77 (42.8%) | 89 (49.4%) | 68 (37.8%) | 23 (12.8%) |
| Summaries are computed within each trial and treatment arm. Categorical: n (%) among nonmissing values. Continuous: mean (SD) and median (Q1, Q3). Missing: n (% of arm). |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Overall = all participants pooled across trials and treatment arms, ignoring the trial structure. |  |  |  |  |  |  |  |  |  |  |  |  |  |
| A Missing row is shown only for variables with at least one missing value in some trial. |  |  |  |  |  |  |  |  |  |  |  |  |  |

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
