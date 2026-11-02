# Get started with niceSMD

niceSMD builds a “Table 1” of descriptive statistics for two or more
groups, with **one absolute standardized mean difference (SMD) per
variable**, and shows it as a formatted table in the console, in Quarto
and R Markdown documents, and in editable Word files.

``` r

library(niceSMD)
d <- example_table1_data()
head(d, 3)
#>     group age  bmi    sex smoking stage_code analysis_weight stratum cluster
#> 1 Control  43 20.3 Female   Never          1             1.6   North       1
#> 2 Control  50 21.6   Male    <NA>          1             2.7   South       2
#> 3 Control  57 22.9   <NA> Current          2             3.8   North       3
```

## A first table

Name the grouping column and the covariates to summarize. When more than
two groups are present, `group_for_SMD` names the pair the SMD compares;
all groups are still displayed.

``` r

tab <- nice_SMD_table1(
  d, group = "group",
  covar_names = c("age", "bmi", "sex", "smoking", "stage_code"),
  print_covariate_names = c("Age (years)", "BMI", "Sex", "Smoking", "Stage"),
  categorical_vars = "stage_code",           # numeric codes -> categories
  group_for_SMD = c("Control", "Treatment"),
  show_missing = "if_any",                   # Missing rows only where needed
  notes = "short"                            # compact footnote
)
tab
```

[TABLE]

Ending a chunk with the object (as above) prints the formatted table in
HTML, Word, and PDF output. Variable names are bold, categories are
indented, and the footnotes appear below the table.

## What you get back

`tab` is a list. The pieces you will use most:

``` r

tab$smd[, c("label", "smd", "status")]   # numeric, unrounded SMDs
#>         label        smd status
#> 1 Age (years) 3.45103284     ok
#> 2         BMI 3.48239000     ok
#> 3         Sex 0.00000000     ok
#> 4     Smoking 0.09313035     ok
#> 5       Stage 0.21601820     ok
tab$groups                               # group sizes
#>       group  n sum_weights effective_n
#> 1   Control 30          30          30
#> 2 Treatment 30          30          30
#> 3  Registry 30          30          30
```

## The options you will use most

| Goal | Argument |
|----|----|
| Show a Missing row only for variables that have missing values | `show_missing = "if_any"` |
| Hide or always show all Missing rows | `show_missing = FALSE` / `TRUE` |
| Short, manuscript-style footnote | `notes = "short"` (or `"none"`) |
| Analysis weights | `weights = "analysis_weight"` |
| Complex survey design | `design = survey::svydesign(...)` |
| Fewer or more decimals | `contDigits`, `catDigits`, `smdDigits` |
| Order of group columns | `group_order = c(...)` |

See
[`?nice_SMD_table1`](https://hyejung0.github.io/niceSMD/reference/nice_SMD_table1.md)
for every argument with examples.

## Export to Word

``` r

save_table1_docx(tab, "Table1.docx", landscape = FALSE, font_size = 10)
```

Or pass `docx_path = "Table1.docx"` to
[`nice_SMD_table1()`](https://hyejung0.github.io/niceSMD/reference/nice_SMD_table1.md).
Use
[`table1_flextable()`](https://hyejung0.github.io/niceSMD/reference/table1_flextable.md)
to get an editable `flextable` for further styling.

## Several trials?

For pooled individual participant data from multiple trials, see
[`nice_trial_table1()`](https://hyejung0.github.io/niceSMD/reference/nice_trial_table1.md)
and the article *Tables by trial and treatment arm*.
