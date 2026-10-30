# niceSMD

Create Table 1 with one absolute standardized mean difference (SMD) per
variable and export it as an editable Word table.

The package supports unweighted data, nonnegative analysis weights, and
`survey` design objects. Factors, character columns, and logical columns are
categorical automatically. An explicit argument handles numeric category codes.

## Install from GitHub

After uploading this folder's contents to your repository:

```r
install.packages("remotes")  # once
remotes::install_github("hyejung0/niceSMD")
library(niceSMD)
```

The GitHub repository name can differ from the package name; change the
`owner/repository` string accordingly. For a private repository, authenticate
with a GitHub token kept in an environment variable, never in your code.
See [GITHUB_SETUP.md](GITHUB_SETUP.md).

## Unweighted example

```r
library(niceSMD)
d <- example_table1_data()

tab <- nice_SMD_table1(
  dat = d,
  group = "group",                         # d$group also works
  covar_names = c("age", "bmi", "sex", "smoking", "stage_code"),
  print_covariate_names = c("Age", "BMI", "Sex", "Smoking", "Stage"),
  categorical_vars = "stage_code",         # numeric codes -> categories
  group_for_SMD = c("Control", "Treatment"),
  contDigits = 2,
  catDigits = 1,
  smdDigits = 3,
  title = "Table 1 Participant characteristics"
)

tab                     # console table and explanatory notes
tab$flextable            # styled table in RStudio or a document
tab$smd                  # numeric SMDs and calculation status
as.data.frame(tab)       # formatted display data

save_table1_docx(tab, "Table1_unweighted.docx")
```

All three example groups appear in the table. The SMD column compares only
Control and Treatment. With exactly two included groups, `group_for_SMD`
can be omitted.

## Weighted example

```r
weighted <- nice_SMD_table1(
  dat = d,
  group = "group",
  covar_names = c("age", "bmi", "sex", "smoking", "stage_code"),
  categorical_vars = "stage_code",
  weights = "analysis_weight",             # a numeric vector also works
  group_for_SMD = c("Control", "Treatment"),
  weightDigits = 1,
  title = "Table 1 Weighted participant characteristics"
)

weighted$groups         # raw n, sum of weights, Kish effective n
weighted$smd
save_table1_docx(weighted, "Table1_weighted.docx", landscape = TRUE)
```

The package uses the weights you supply. It does not estimate propensity
scores, choose an estimand, stabilize weights, normalize them, or trim them.
For complex survey data, supply a design object; see the user guide.

## Missing values and denominators

| Quantity | Unweighted table | Weighted table |
|---|---|---|
| Group header | Number of included people | Included people and sum of weights |
| Category count | People in the category | Sum of category weights |
| Category percentage denominator | Nonmissing people for that variable and group | Nonmissing weight total for that variable and group |
| Missing count | People missing the variable | Sum of weights for missing observations |
| Missing percentage denominator | All included people in the group | Full included group weight total |
| Continuous summary and SMD | Excludes missing values separately for each variable | Excludes missing values separately for each variable |

Rows with a missing group or a zero weight are excluded with a warning. Negative, missing, or infinite weights are rejected. These conventions are included as Word table footnotes (`notes = "full"`, the default).

### Controlling Missing rows and footnotes

```r
# Show a Missing row only for variables that actually have missing values
tab <- nice_SMD_table1(d, "group", c("age", "stratum", "sex"),
                       group_for_SMD = c("Control", "Treatment"),
                       show_missing = "if_any",   # TRUE/"always", FALSE/"never", "if_any"
                       notes = "short")           # "full", "short", "none"
```

| `show_missing` | Behavior |
|---|---|
| `TRUE` or `"always"` (default) | Missing row for every variable, even when all counts are zero |
| `FALSE` or `"never"` | No Missing rows |
| `"if_any"` | Missing row only for variables with at least one missing value in a displayed group |

| `notes` | Footnote |
|---|---|
| `"full"` (default) | Every denominator, missing-value, SMD, and quartile convention |
| `"short"` | Two or three lines: cell layout, SMD definition, `NE`; plus excluded rows or hidden Missing rows when applicable |
| `"none"` | No footnotes |

Neither option changes any calculation; both only change what is displayed.

## Quarto and R Markdown

A chunk that ends with `tab` renders the formatted table (bold variable names, indented levels, footnotes) in HTML, Word, and PDF output. Use `table1_flextable(tab, font_size = 9)` to control size and fonts, or `table1_kable(tab)` as a lightweight fallback for PDF.

## Several trials: summaries by trial and treatment

For pooled individual participant data from multiple trials, `nice_trial_table1()` summarizes every trial separately by treatment arm, with the same conventions as `nice_SMD_table1()`:

```r
d <- example_trial_data()

# Trials side by side (a few trials), SMD within each trial
nice_trial_table1(d, "trial", "arm", c("age", "egfr", "sex", "ckd_stage"),
                  treatment_for_SMD = c("Placebo", "Active"))

# One row per trial and arm (many trials)
nice_trial_table1(d, "trial", "arm", c("age", "egfr", "sex", "ckd_stage"),
                  treatment_for_SMD = c("Placebo", "Active"),
                  layout = "long", continuous_stats = "mean_sd", notes = "short")
```

Use `layout = "long"` when there are more than about three trials. SMDs for each trial and variable are always in `$smd`; `show_smd = FALSE` omits them from the wide display (baseline differences within a randomized trial are chance imbalances). See `?nice_trial_table1`.

## What the SMD means

* Continuous variables use the absolute mean difference divided by the square
  root of the average of the two group variances.
* Binary variables compare category proportions.
* Multilevel categorical variables use one joint standardized distance across
  the categories. Ordered factors are also treated as categorical, without
  assigning numeric scores.
* `NE` indicates an unavailable SMD. `tab$smd$reason` explains why.
* Identical constant variables have SMD zero. Different constants with zero
  standardizing variance have SMD `Inf`. A singular multilevel categorical
  covariance is reported as `NE`.

The SMD is a descriptive balance measure. The table does not establish causal
identification, test equivalence, or calculate effect-estimate uncertainty.
See the user guide for the exact formulas and weighted SD/quantile conventions.

## Word and document use

```r
# Save while constructing a table, using default portrait settings:
tab <- nice_SMD_table1(
  d, "group", c("age", "sex"),
  group_for_SMD = c("Control", "Treatment"),
  docx_path = "Table1.docx"
)

# More export controls:
save_table1_docx(
  tab, "Table1.docx", overwrite = TRUE,
  landscape = TRUE, font_size = 9, font_family = "Arial"
)

# Customize with flextable before inserting into an existing document:
ft <- table1_flextable(tab, font_size = 9)
ft <- flextable::color(ft, part = "header", color = "#243746")
doc <- officer::read_docx()
doc <- flextable::body_add_flextable(doc, value = ft)
print(doc, target = "Custom_document.docx")
```

In a Quarto document with `format: docx`, place `tab$flextable` as the final
expression of a code chunk. This embeds editable table cells, rather than a
screen image. The exporter protects existing files unless `overwrite = TRUE`.
Very wide tables may need landscape orientation and a smaller font.

## More help

```r
?nice_SMD_table1
?save_table1_docx
?table1_flextable
system.file("doc", "user-guide.md", package = "niceSMD")
```

* [Complete user guide](inst/doc/user-guide.md)
* [Runnable examples](inst/examples/quickstart.R)
* [GitHub setup](GITHUB_SETUP.md)
* [Development and testing](DEVELOPMENT.md)
* [Validation status](VALIDATION.md)

## Changes from the original function

The public function name and original leading arguments are retained.
The return value is now a `nice_table1` object, not a data.table. Use
`as.data.frame(tab)` or `tab$table` when you need the old style of display
data. Use `tab$smd` for analysis because its SMD column is numeric and unrounded.

The old `table1` display engine has been replaced by an explicit row builder.
SMDs still use `tableone`, but are extracted numerically rather than parsed
from printed output. This makes weighting and denominator definitions explicit
and avoids matching on labels. `stddiff`, `cobalt`, `table1`, `Hmisc`,
`data.table`, and `stringr` are not needed by this package.

The MIT license permits reuse and modification. Copyright remains with Hyejung Lee.
