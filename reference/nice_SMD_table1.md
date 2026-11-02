# Descriptive Tables with One Absolute SMD per Variable

Creates continuous and categorical descriptive summaries for two or more
groups, with a single absolute standardized mean difference (SMD) for
each variable. Uses tableone for SMDs and survey for weighted continuous
summaries. All groups are displayed; SMDs compare only the selected pair
of groups. The result prints as a formatted table in the console,
renders as a formatted table in Quarto and R Markdown documents, and
exports to editable Word tables.

## Usage

``` r
nice_SMD_table1(
  dat = NULL, group, covar_names = NULL, print_covariate_names = NULL,
  group_for_SMD = NULL, catDigits = 1, contDigits = 2, smdDigits = 3,
  categorical_vars = NULL, weights = NULL, design = NULL,
  weightDigits = 1, show_missing = TRUE, group_order = NULL,
  title = "Table 1", docx_path = NULL, notes = "full"
)
```

## Arguments

- dat:

  A data.frame, tibble, or data.table holding the grouping variable, the
  covariates, and (optionally) a weight column. Column names must be
  unique and nonempty. May be omitted when `design` is supplied, in
  which case `design$variables` is used. If both are supplied, `dat` and
  `design` must contain the same rows in exactly the same order.

- group:

  The grouping (column) variable, given either as a single column name
  in `dat` (for example `"group"`) or as a vector of length `nrow(dat)`
  (for example `d$group`). Factors keep their level order for the
  display columns; other types use order of first appearance (override
  with `group_order`). Rows with a missing group value are excluded with
  a warning. Empty strings are not allowed as group values.

- covar_names:

  Character vector of column names to summarize, in the order they
  should appear. Defaults to every column of `dat` other than the
  grouping and weight columns named by string. When `group` or `weights`
  are supplied as external vectors, select the covariates explicitly so
  that nothing unintended is summarized. Names must be unique and must
  exist in `dat`. Matrix and list columns are not supported; Date and
  POSIXt columns must be converted to numeric or factor first.

- print_covariate_names:

  Display labels for the covariates, shown in the first column of the
  table. Either an unnamed character vector with one nonempty label per
  entry of `covar_names` (same order), or a named character vector whose
  names are exactly the entries of `covar_names` (order does not
  matter). Defaults to the column names. Labels may repeat or contain
  punctuation such as `=` or parentheses; calculations never use labels
  as identifiers.

- group_for_SMD:

  Character vector of length two naming the two included groups that the
  SMD compares, for example `c("Control", "Treatment")`. The SMD is
  reported as an absolute value, so the order only affects the column
  header and the notes. Defaults to the two displayed groups when
  exactly two groups are present; required when more than two groups are
  displayed. All displayed groups still receive summaries.

- catDigits:

  Integer from 0 to 10. Decimal places for category and missing
  percentages. Default 1, giving values such as `30 (33.3%)`.

- contDigits:

  Integer from 0 to 10. Decimal places for means, SDs, medians, and
  quartiles of continuous variables. Default 2.

- smdDigits:

  Integer from 0 to 10. Decimal places for the displayed SMD column.
  Default 3. The numeric SMDs in `tab$smd` are never rounded.

- categorical_vars:

  Optional character vector, drawn from `covar_names`, naming numeric
  (or other) columns that should be treated as categorical, such as
  numeric category codes like stage 1/2/3. Factors, character columns,
  and logical columns are always categorical automatically; ordered
  factors are treated as unordered categories with no numeric scores.

- weights:

  Optional analysis weights, given either as the name of a numeric
  column in `dat` or as a numeric vector of length `nrow(dat)`. Weights
  must be finite, nonnegative, and nonmissing; rows with weight zero are
  excluded with a warning. Weights are used exactly as supplied (no
  normalization, stabilization, or trimming). Supplying weights switches
  the table to weighted counts, sums of weights, weighted means and SDs,
  and weighted quartiles. Cannot be combined with `design`.

- design:

  Optional survey design object (`survey.design` or `svyrep.design`).
  Use this for clustered, stratified, calibrated, or replicate-weight
  analyses; the design's sampling weights are used for counts and the
  design is used for weighted SDs and quartiles. Cannot be combined with
  `weights`.

- weightDigits:

  Integer from 0 to 10. Decimal places for weighted counts and for sums
  of weights in the group headers. Ignored for unweighted tables.
  Default 1.

- show_missing:

  Controls the “Missing” row under each variable. One of:

  - `TRUE` or `"always"` (default): show a Missing row for every
    variable, including rows where every count is zero.

  - `FALSE` or `"never"`: hide all Missing rows.

  - `"if_any"`: show a Missing row only for variables that have at least
    one missing value in at least one displayed group. A footnote
    records that variables without a Missing row have no missing values.

  This option only affects display. Denominators, summaries, and SMDs
  are identical for all settings, and missingness is never imputed.

- group_order:

  Character vector listing every included group exactly once, giving the
  left-to-right order of the group columns. Defaults to the factor level
  order (for factors) or order of first appearance (otherwise). Groups
  that have no rows after exclusions must not be listed.

- title:

  A single character string used as the heading when printing and in the
  optional Word document. Default `"Table 1"`. Use `""` to omit the
  heading from a Word document.

- docx_path:

  Optional new `.docx` filename. When supplied, the table is also
  written to Word using default portrait settings; an existing file is
  never overwritten. For landscape orientation, fonts, or overwriting
  use
  [`save_table1_docx`](https://hyejung0.github.io/niceSMD/reference/save_table1_docx.md).

- notes:

  Footnote style: `"full"` (default), `"short"`, or `"none"`.

  - `"full"`: a complete description of denominators, missing-value
    handling, SMD definitions, quartile conventions, and the meaning of
    `NE` and `Inf`. Suited to supplements and analysis reports.

  - `"short"`: a compact legend of two or three lines (the layout of the
    cells, “SMD = absolute standardized mean difference”, and “NE = not
    estimable”), plus a line for excluded rows or hidden Missing rows
    when applicable. Suited to manuscript tables.

  - `"none"`: no footnotes.

  The text is stored in `tab$notes` and is used by
  [`print()`](https://rdrr.io/r/base/print.html),
  [`table1_flextable`](https://hyejung0.github.io/niceSMD/reference/table1_flextable.md),
  and
  [`save_table1_docx`](https://hyejung0.github.io/niceSMD/reference/save_table1_docx.md).

## Details

Continuous rows report mean (SD) and median (Q1, Q3). Categorical
variables show the variable name followed by one indented row per level
with count (percent). Category percentages use the nonmissing count, or
nonmissing sum of weights, for the variable and group. Missing
percentages use the entire included group count or sum of weights.
Missing values are excluded separately for each variable's summaries and
SMD; missingness is not added as a categorical level. Unused factor
levels are dropped.

Unweighted quartiles use `stats::quantile(type = 7)`. Weighted quartiles
use `survey::svyquantile(qrule = "math", ci = FALSE)`. Equal weights
need not give identical weighted and unweighted quartiles because the
quantile definitions differ. Weighted SDs use
[`survey::svyvar`](https://rdrr.io/pkg/survey/man/surveysummary.html),
consistent with the weighted SMD engine. Supplied weights are not
normalized or trimmed. Weight-only inputs create a design with
`ids = ~1`; they do not infer clustering, stratification, or corrections
for estimated propensity weights. No standard errors, tests, or
causal-effect estimates are produced.

For a continuous variable the absolute SMD is \$\$\|\bar{x}\_a -
\bar{x}\_b\| / \sqrt{(s_a^2 + s_b^2)/2}.\$\$ The denominator is the
square root of the average of the group variances, not the
sample-size-weighted pooled variance. A multilevel categorical SMD uses
a joint standardized distance between its category proportions.

SMDs require at least two nonmissing positive-weight observations per
group for continuous variables, or one per group for categorical
variables. Identical constants are assigned zero. Different constants
with zero standardizing variance are assigned infinity. Singular
multilevel categorical covariance matrices are reported as not estimable
rather than using a generalized-inverse distance. Other calculation
failures are retained in `smd$reason`.

Survey variance errors during descriptive summaries are propagated; the
function does not change global survey options. Sampling weights, not
replicate weight sums, are used for weighted counts and effective sample
sizes.

**Using the result in Quarto or R Markdown.** Place the object as the
last expression of a chunk (`tab`) to render the formatted table in
HTML, Word, or PDF output. See
[`nice_table1-methods`](https://hyejung0.github.io/niceSMD/reference/nice_table1-methods.md).

## Value

A `nice_table1` list with `table` (formatted data.frame), `smd`
(original variable name, label, numeric SMD, status, and reason),
`groups` (included raw counts, weight sums, and Kish effective sizes),
`row_info` (original variable names and row types: `"variable"`,
`"category"`, `"summary"`, or `"missing"`), `notes` (the footnote text
selected by `notes`), `settings`, `call`, and `flextable` (editable
formatted table). Kish effective size is \\(\sum_i w_i)^2 / \sum_i
w_i^2\\ and does not incorporate clustering or stratification. The
formatted SMD cells use `NE` for not estimable and `Inf` for an infinite
SMD.

## See also

[`save_table1_docx`](https://hyejung0.github.io/niceSMD/reference/save_table1_docx.md),
[`table1_flextable`](https://hyejung0.github.io/niceSMD/reference/table1_flextable.md),
[`table1_kable`](https://hyejung0.github.io/niceSMD/reference/table1_kable.md),
[`nice_table1-methods`](https://hyejung0.github.io/niceSMD/reference/nice_table1-methods.md),
[`tableone::ExtractSmd`](https://rdrr.io/pkg/tableone/man/ExtractSmd.html),
[`survey::svydesign`](https://rdrr.io/pkg/survey/man/svydesign.html)

## Examples

``` r
d <- example_table1_data()
str(d)
#> 'data.frame':    90 obs. of  9 variables:
#>  $ group          : Factor w/ 3 levels "Control","Treatment",..: 1 1 1 1 1 1 1 1 1 1 ...
#>  $ age            : num  43 50 57 NA 71 78 85 92 99 106 ...
#>  $ bmi            : num  20.3 21.6 22.9 24.2 25.5 26.8 NA 29.4 30.7 32 ...
#>  $ sex            : Factor w/ 2 levels "Female","Male": 1 2 NA 2 1 1 2 1 2 1 ...
#>  $ smoking        : chr  "Never" NA "Current" "Never" ...
#>  $ stage_code     : int  1 1 2 3 NA 3 1 1 1 2 ...
#>  $ analysis_weight: num  1.6 2.7 3.8 4.9 6 7.1 8.2 9.3 10.4 11.5 ...
#>  $ stratum        : chr  "North" "South" "North" "South" ...
#>  $ cluster        : int  1 2 3 4 5 6 7 8 9 10 ...

## ---- 1. Minimal two-group table --------------------------------------
## Drop the third group so that group_for_SMD can be omitted.
d2 <- d[d$group != "Registry", ]
tab <- nice_SMD_table1(d2, group = "group", covar_names = c("age", "sex"))
tab                        # formatted console table plus notes
#> Table 1
#> 
#>  Variable            Control\nN = 30        Treatment\nN = 30      
#>  age                                                               
#>      Mean (SD)       147.28 (60.78)         358.55 (61.66)         
#>      Median (Q1, Q3) 148.00 (99.00, 197.00) 360.00 (311.00, 409.00)
#>      Missing         1 (3.3%)               1 (3.3%)               
#>  sex                                                               
#>      Female          17 (58.6%)             17 (58.6%)             
#>      Male            12 (41.4%)             12 (41.4%)             
#>      Missing         1 (3.3%)               1 (3.3%)               
#>  SMD (Control vs. Treatment)
#>  3.451                      
#>                             
#>                             
#>                             
#>  0.000                      
#>                             
#>                             
#>                             
#> 
#> N and category/missing counts are numbers of people.
#> Category percentages use the nonmissing number of people for that variable and group. Missing percentages use the full group number of people.
#> Continuous summaries and SMDs exclude missing values separately for each variable. Missingness is not included as a category in SMDs.
#> Absolute SMDs compare Control and Treatment. A multilevel categorical SMD compares its category proportions jointly.
#> Unweighted quartiles use stats::quantile with type = 7.
#> NE = not estimable; Inf = a nonzero difference with zero standardizing variance; NA = an unavailable descriptive summary. Details are in the returned smd component.
as.data.frame(tab)         # display data.frame
#>          Variable        Control\nN = 30       Treatment\nN = 30
#> 1             age                                               
#> 2       Mean (SD)         147.28 (60.78)          358.55 (61.66)
#> 3 Median (Q1, Q3) 148.00 (99.00, 197.00) 360.00 (311.00, 409.00)
#> 4         Missing               1 (3.3%)                1 (3.3%)
#> 5             sex                                               
#> 6          Female             17 (58.6%)              17 (58.6%)
#> 7            Male             12 (41.4%)              12 (41.4%)
#> 8         Missing               1 (3.3%)                1 (3.3%)
#>   SMD (Control vs. Treatment)
#> 1                       3.451
#> 2                            
#> 3                            
#> 4                            
#> 5                       0.000
#> 6                            
#> 7                            
#> 8                            
tab$smd                    # numeric, unrounded SMDs with status and reason
#>   variable label      smd status reason
#> 1      age   age 3.451033     ok       
#> 2      sex   sex 0.000000     ok       

## ---- 2. Three groups: choose the SMD pair ----------------------------
## All three groups are displayed; the SMD compares Control and Treatment.
tab3 <- nice_SMD_table1(
  d, group = "group",
  covar_names = c("age", "bmi", "sex", "smoking"),
  group_for_SMD = c("Control", "Treatment")
)
tab3
#> Table 1
#> 
#>  Variable            Control\nN = 30        Treatment\nN = 30      
#>  age                                                               
#>      Mean (SD)       147.28 (60.78)         358.55 (61.66)         
#>      Median (Q1, Q3) 148.00 (99.00, 197.00) 360.00 (311.00, 409.00)
#>      Missing         1 (3.3%)               1 (3.3%)               
#>  bmi                                                               
#>      Mean (SD)       39.53 (11.45)          79.49 (11.50)          
#>      Median (Q1, Q3) 39.80 (30.70, 48.90)   79.80 (70.70, 88.90)   
#>      Missing         1 (3.3%)               1 (3.3%)               
#>  sex                                                               
#>      Female          17 (58.6%)             17 (58.6%)             
#>      Male            12 (41.4%)             12 (41.4%)             
#>      Missing         1 (3.3%)               1 (3.3%)               
#>  smoking                                                           
#>      Current         8 (27.6%)              9 (31.0%)              
#>      Former          8 (27.6%)              7 (24.1%)              
#>      Never           13 (44.8%)             13 (44.8%)             
#>      Missing         1 (3.3%)               1 (3.3%)               
#>  Registry\nN = 30        SMD (Control vs. Treatment)
#>                          3.451                      
#>  570.07 (62.10)                                     
#>  572.00 (516.00, 621.00)                            
#>  1 (3.3%)                                           
#>                          3.482                      
#>  117.84 (11.83)                                     
#>  118.95 (107.58, 127.73)                            
#>  2 (6.7%)                                           
#>                          0.000                      
#>  17 (58.6%)                                         
#>  12 (41.4%)                                         
#>  1 (3.3%)                                           
#>                          0.093                      
#>  8 (27.6%)                                          
#>  8 (27.6%)                                          
#>  13 (44.8%)                                         
#>  1 (3.3%)                                           
#> 
#> N and category/missing counts are numbers of people.
#> Category percentages use the nonmissing number of people for that variable and group. Missing percentages use the full group number of people.
#> Continuous summaries and SMDs exclude missing values separately for each variable. Missingness is not included as a category in SMDs.
#> Absolute SMDs compare Control and Treatment. A multilevel categorical SMD compares its category proportions jointly.
#> Unweighted quartiles use stats::quantile with type = 7.
#> NE = not estimable; Inf = a nonzero difference with zero standardizing variance; NA = an unavailable descriptive summary. Details are in the returned smd component.

## ---- 3. Display labels -----------------------------------------------
## Unnamed labels follow the order of covar_names.
nice_SMD_table1(
  d, "group", c("age", "bmi", "sex"),
  print_covariate_names = c("Age (years)", "Body mass index", "Sex"),
  group_for_SMD = c("Control", "Treatment")
)$table
#>           Variable        Control\nN = 30       Treatment\nN = 30
#> 1      Age (years)                                               
#> 2        Mean (SD)         147.28 (60.78)          358.55 (61.66)
#> 3  Median (Q1, Q3) 148.00 (99.00, 197.00) 360.00 (311.00, 409.00)
#> 4          Missing               1 (3.3%)                1 (3.3%)
#> 5  Body mass index                                               
#> 6        Mean (SD)          39.53 (11.45)           79.49 (11.50)
#> 7  Median (Q1, Q3)   39.80 (30.70, 48.90)    79.80 (70.70, 88.90)
#> 8          Missing               1 (3.3%)                1 (3.3%)
#> 9              Sex                                               
#> 10          Female             17 (58.6%)              17 (58.6%)
#> 11            Male             12 (41.4%)              12 (41.4%)
#> 12         Missing               1 (3.3%)                1 (3.3%)
#>           Registry\nN = 30 SMD (Control vs. Treatment)
#> 1                                                3.451
#> 2           570.07 (62.10)                            
#> 3  572.00 (516.00, 621.00)                            
#> 4                 1 (3.3%)                            
#> 5                                                3.482
#> 6           117.84 (11.83)                            
#> 7  118.95 (107.58, 127.73)                            
#> 8                 2 (6.7%)                            
#> 9                                                0.000
#> 10              17 (58.6%)                            
#> 11              12 (41.4%)                            
#> 12                1 (3.3%)                            

## Named labels may be given in any order.
labels <- c(sex = "Sex", age = "Age at enrollment", bmi = "BMI (kg/m2)")
nice_SMD_table1(
  d, "group", c("age", "bmi", "sex"),
  print_covariate_names = labels,
  group_for_SMD = c("Control", "Treatment")
)$table
#>             Variable        Control\nN = 30       Treatment\nN = 30
#> 1  Age at enrollment                                               
#> 2          Mean (SD)         147.28 (60.78)          358.55 (61.66)
#> 3    Median (Q1, Q3) 148.00 (99.00, 197.00) 360.00 (311.00, 409.00)
#> 4            Missing               1 (3.3%)                1 (3.3%)
#> 5        BMI (kg/m2)                                               
#> 6          Mean (SD)          39.53 (11.45)           79.49 (11.50)
#> 7    Median (Q1, Q3)   39.80 (30.70, 48.90)    79.80 (70.70, 88.90)
#> 8            Missing               1 (3.3%)                1 (3.3%)
#> 9                Sex                                               
#> 10            Female             17 (58.6%)              17 (58.6%)
#> 11              Male             12 (41.4%)              12 (41.4%)
#> 12           Missing               1 (3.3%)                1 (3.3%)
#>           Registry\nN = 30 SMD (Control vs. Treatment)
#> 1                                                3.451
#> 2           570.07 (62.10)                            
#> 3  572.00 (516.00, 621.00)                            
#> 4                 1 (3.3%)                            
#> 5                                                3.482
#> 6           117.84 (11.83)                            
#> 7  118.95 (107.58, 127.73)                            
#> 8                 2 (6.7%)                            
#> 9                                                0.000
#> 10              17 (58.6%)                            
#> 11              12 (41.4%)                            
#> 12                1 (3.3%)                            

## ---- 4. Numeric category codes ---------------------------------------
## stage_code is numeric (1/2/3); force it to be categorical.
nice_SMD_table1(
  d, "group", c("age", "stage_code"),
  print_covariate_names = c("Age", "Stage"),
  categorical_vars = "stage_code",
  group_for_SMD = c("Control", "Treatment")
)
#> Table 1
#> 
#>  Variable            Control\nN = 30        Treatment\nN = 30      
#>  Age                                                               
#>      Mean (SD)       147.28 (60.78)         358.55 (61.66)         
#>      Median (Q1, Q3) 148.00 (99.00, 197.00) 360.00 (311.00, 409.00)
#>      Missing         1 (3.3%)               1 (3.3%)               
#>  Stage                                                             
#>      1               14 (48.3%)             11 (37.9%)             
#>      2               7 (24.1%)              9 (31.0%)              
#>      3               8 (27.6%)              9 (31.0%)              
#>      Missing         1 (3.3%)               1 (3.3%)               
#>  Registry\nN = 30        SMD (Control vs. Treatment)
#>                          3.451                      
#>  570.07 (62.10)                                     
#>  572.00 (516.00, 621.00)                            
#>  1 (3.3%)                                           
#>                          0.216                      
#>  11 (37.9%)                                         
#>  9 (31.0%)                                          
#>  9 (31.0%)                                          
#>  1 (3.3%)                                           
#> 
#> N and category/missing counts are numbers of people.
#> Category percentages use the nonmissing number of people for that variable and group. Missing percentages use the full group number of people.
#> Continuous summaries and SMDs exclude missing values separately for each variable. Missingness is not included as a category in SMDs.
#> Absolute SMDs compare Control and Treatment. A multilevel categorical SMD compares its category proportions jointly.
#> Unweighted quartiles use stats::quantile with type = 7.
#> NE = not estimable; Inf = a nonzero difference with zero standardizing variance; NA = an unavailable descriptive summary. Details are in the returned smd component.

## ---- 5. Group order and external vectors -----------------------------
nice_SMD_table1(
  d, "group", c("age", "sex"),
  group_order = c("Registry", "Control", "Treatment"),
  group_for_SMD = c("Control", "Treatment")
)$groups
#>       group  n sum_weights effective_n
#> 1  Registry 30          30          30
#> 2   Control 30          30          30
#> 3 Treatment 30          30          30

## A grouping vector may be used instead of a column name; then list the
## covariates explicitly.
nice_SMD_table1(
  d, group = d$group, covar_names = c("age", "sex"),
  group_for_SMD = c("Control", "Treatment")
)$smd
#>   variable label      smd status reason
#> 1      age   age 3.451033     ok       
#> 2      sex   sex 0.000000     ok       

## ---- 6. Rounding -----------------------------------------------------
nice_SMD_table1(
  d, "group", c("age", "smoking"),
  contDigits = 1, catDigits = 0, smdDigits = 2,
  group_for_SMD = c("Control", "Treatment")
)
#> Table 1
#> 
#>  Variable            Control\nN = 30     Treatment\nN = 30   
#>  age                                                         
#>      Mean (SD)       147.3 (60.8)        358.6 (61.7)        
#>      Median (Q1, Q3) 148.0 (99.0, 197.0) 360.0 (311.0, 409.0)
#>      Missing         1 (3%)              1 (3%)              
#>  smoking                                                     
#>      Current         8 (28%)             9 (31%)             
#>      Former          8 (28%)             7 (24%)             
#>      Never           13 (45%)            13 (45%)            
#>      Missing         1 (3%)              1 (3%)              
#>  Registry\nN = 30     SMD (Control vs. Treatment)
#>                       3.45                       
#>  570.1 (62.1)                                    
#>  572.0 (516.0, 621.0)                            
#>  1 (3%)                                          
#>                       0.09                       
#>  8 (28%)                                         
#>  8 (28%)                                         
#>  13 (45%)                                        
#>  1 (3%)                                          
#> 
#> N and category/missing counts are numbers of people.
#> Category percentages use the nonmissing number of people for that variable and group. Missing percentages use the full group number of people.
#> Continuous summaries and SMDs exclude missing values separately for each variable. Missingness is not included as a category in SMDs.
#> Absolute SMDs compare Control and Treatment. A multilevel categorical SMD compares its category proportions jointly.
#> Unweighted quartiles use stats::quantile with type = 7.
#> NE = not estimable; Inf = a nonzero difference with zero standardizing variance; NA = an unavailable descriptive summary. Details are in the returned smd component.

## ---- 7. Missing-value rows: show_missing -----------------------------
## stratum has no missing values; age does. Compare the three settings.
vars <- c("age", "stratum")
by_mode <- function(mode) {
  nice_SMD_table1(d, "group", vars, group_for_SMD = c("Control", "Treatment"),
                  show_missing = mode)
}
always <- by_mode("always")
if_any <- by_mode("if_any")
never  <- by_mode("never")
c(always = sum(always$row_info$type == "missing"),
  if_any = sum(if_any$row_info$type == "missing"),
  never  = sum(never$row_info$type == "missing"))
#> always if_any  never 
#>      2      1      0 
if_any                     # Missing row only under Age
#> Table 1
#> 
#>  Variable            Control\nN = 30        Treatment\nN = 30      
#>  age                                                               
#>      Mean (SD)       147.28 (60.78)         358.55 (61.66)         
#>      Median (Q1, Q3) 148.00 (99.00, 197.00) 360.00 (311.00, 409.00)
#>      Missing         1 (3.3%)               1 (3.3%)               
#>  stratum                                                           
#>      North           15 (50.0%)             15 (50.0%)             
#>      South           15 (50.0%)             15 (50.0%)             
#>  Registry\nN = 30        SMD (Control vs. Treatment)
#>                          3.451                      
#>  570.07 (62.10)                                     
#>  572.00 (516.00, 621.00)                            
#>  1 (3.3%)                                           
#>                          0.000                      
#>  15 (50.0%)                                         
#>  15 (50.0%)                                         
#> 
#> N and category/missing counts are numbers of people.
#> Category percentages use the nonmissing number of people for that variable and group. Missing percentages use the full group number of people.
#> Continuous summaries and SMDs exclude missing values separately for each variable. Missingness is not included as a category in SMDs.
#> Absolute SMDs compare Control and Treatment. A multilevel categorical SMD compares its category proportions jointly.
#> Unweighted quartiles use stats::quantile with type = 7.
#> NE = not estimable; Inf = a nonzero difference with zero standardizing variance; NA = an unavailable descriptive summary. Details are in the returned smd component.
#> A Missing row is shown only for variables with at least one missing value; variables without one have no missing values in the included rows.
## TRUE and FALSE remain valid: TRUE is "always", FALSE is "never".
nice_SMD_table1(d, "group", "age", show_missing = FALSE,
                group_for_SMD = c("Control", "Treatment"))$table
#>          Variable        Control\nN = 30       Treatment\nN = 30
#> 1             age                                               
#> 2       Mean (SD)         147.28 (60.78)          358.55 (61.66)
#> 3 Median (Q1, Q3) 148.00 (99.00, 197.00) 360.00 (311.00, 409.00)
#>          Registry\nN = 30 SMD (Control vs. Treatment)
#> 1                                               3.451
#> 2          570.07 (62.10)                            
#> 3 572.00 (516.00, 621.00)                            

## ---- 8. Footnotes: notes ---------------------------------------------
full  <- nice_SMD_table1(d, "group", c("age", "sex"),
                         group_for_SMD = c("Control", "Treatment"))
short <- nice_SMD_table1(d, "group", c("age", "sex"),
                         group_for_SMD = c("Control", "Treatment"),
                         notes = "short")
none  <- nice_SMD_table1(d, "group", c("age", "sex"),
                         group_for_SMD = c("Control", "Treatment"),
                         notes = "none")
length(full$notes); length(short$notes); length(none$notes)
#> [1] 6
#> [1] 2
#> [1] 0
short                      # compact legend, suited to a manuscript
#> Table 1
#> 
#>  Variable            Control\nN = 30        Treatment\nN = 30      
#>  age                                                               
#>      Mean (SD)       147.28 (60.78)         358.55 (61.66)         
#>      Median (Q1, Q3) 148.00 (99.00, 197.00) 360.00 (311.00, 409.00)
#>      Missing         1 (3.3%)               1 (3.3%)               
#>  sex                                                               
#>      Female          17 (58.6%)             17 (58.6%)             
#>      Male            12 (41.4%)             12 (41.4%)             
#>      Missing         1 (3.3%)               1 (3.3%)               
#>  Registry\nN = 30        SMD (Control vs. Treatment)
#>                          3.451                      
#>  570.07 (62.10)                                     
#>  572.00 (516.00, 621.00)                            
#>  1 (3.3%)                                           
#>                          0.000                      
#>  17 (58.6%)                                         
#>  12 (41.4%)                                         
#>  1 (3.3%)                                           
#> 
#> Categorical variables: n (%) among nonmissing values. Continuous variables: mean (SD) and median (Q1, Q3). Missing: n (% of group).
#> SMD = absolute standardized mean difference (Control vs. Treatment); NE = not estimable.
## Typical manuscript setting: hide empty Missing rows and keep a short legend.
nice_SMD_table1(
  d, "group", c("age", "stratum", "sex"),
  group_for_SMD = c("Control", "Treatment"),
  show_missing = "if_any", notes = "short"
)
#> Table 1
#> 
#>  Variable            Control\nN = 30        Treatment\nN = 30      
#>  age                                                               
#>      Mean (SD)       147.28 (60.78)         358.55 (61.66)         
#>      Median (Q1, Q3) 148.00 (99.00, 197.00) 360.00 (311.00, 409.00)
#>      Missing         1 (3.3%)               1 (3.3%)               
#>  stratum                                                           
#>      North           15 (50.0%)             15 (50.0%)             
#>      South           15 (50.0%)             15 (50.0%)             
#>  sex                                                               
#>      Female          17 (58.6%)             17 (58.6%)             
#>      Male            12 (41.4%)             12 (41.4%)             
#>      Missing         1 (3.3%)               1 (3.3%)               
#>  Registry\nN = 30        SMD (Control vs. Treatment)
#>                          3.451                      
#>  570.07 (62.10)                                     
#>  572.00 (516.00, 621.00)                            
#>  1 (3.3%)                                           
#>                          0.000                      
#>  15 (50.0%)                                         
#>  15 (50.0%)                                         
#>                          0.000                      
#>  17 (58.6%)                                         
#>  12 (41.4%)                                         
#>  1 (3.3%)                                           
#> 
#> Categorical variables: n (%) among nonmissing values. Continuous variables: mean (SD) and median (Q1, Q3). Missing: n (% of group).
#> SMD = absolute standardized mean difference (Control vs. Treatment); NE = not estimable.
#> Variables without a Missing row have no missing values.

## ---- 9. Weights ------------------------------------------------------
## A weight column name ...
weighted <- nice_SMD_table1(
  d, "group", c("age", "sex", "smoking"),
  weights = "analysis_weight", weightDigits = 1,
  group_for_SMD = c("Control", "Treatment"),
  title = "Table 1 Weighted participant characteristics"
)
weighted$groups            # raw n, sum of weights, Kish effective n
#>       group  n sum_weights effective_n
#> 1   Control 30       526.5    23.17832
#> 2 Treatment 30      1516.5    28.97221
#> 3  Registry 30      2506.5    29.61542
weighted$smd
#>   variable   label        smd status reason
#> 1      age     age 3.43810603     ok       
#> 2      sex     sex 0.01557462     ok       
#> 3  smoking smoking 0.13456603     ok       
## ... or a numeric vector.
nice_SMD_table1(
  d, "group", c("age", "sex"), weights = d$analysis_weight,
  group_for_SMD = c("Control", "Treatment")
)$smd
#>   variable label        smd status reason
#> 1      age   age 3.43810603     ok       
#> 2      sex   sex 0.01557462     ok       

## ---- 10. Survey design (clustered / stratified) ----------------------
design <- survey::svydesign(ids = ~cluster, strata = ~stratum,
                            weights = ~analysis_weight, data = d)
nice_SMD_table1(
  group = "group", covar_names = c("age", "sex"),
  design = design, group_for_SMD = c("Control", "Treatment")
)$smd
#>   variable label        smd status reason
#> 1      age   age 3.43810603     ok       
#> 2      sex   sex 0.01557462     ok       

## ---- 11. Title and Word output ---------------------------------------
path <- tempfile(fileext = ".docx")
nice_SMD_table1(
  d, "group", c("age", "sex"),
  group_for_SMD = c("Control", "Treatment"),
  title = "Table 1 Participant characteristics",
  notes = "short", docx_path = path
)
#> Table 1 Participant characteristics
#> 
#>  Variable            Control\nN = 30        Treatment\nN = 30      
#>  age                                                               
#>      Mean (SD)       147.28 (60.78)         358.55 (61.66)         
#>      Median (Q1, Q3) 148.00 (99.00, 197.00) 360.00 (311.00, 409.00)
#>      Missing         1 (3.3%)               1 (3.3%)               
#>  sex                                                               
#>      Female          17 (58.6%)             17 (58.6%)             
#>      Male            12 (41.4%)             12 (41.4%)             
#>      Missing         1 (3.3%)               1 (3.3%)               
#>  Registry\nN = 30        SMD (Control vs. Treatment)
#>                          3.451                      
#>  570.07 (62.10)                                     
#>  572.00 (516.00, 621.00)                            
#>  1 (3.3%)                                           
#>                          0.000                      
#>  17 (58.6%)                                         
#>  12 (41.4%)                                         
#>  1 (3.3%)                                           
#> 
#> Categorical variables: n (%) among nonmissing values. Continuous variables: mean (SD) and median (Q1, Q3). Missing: n (% of group).
#> SMD = absolute standardized mean difference (Control vs. Treatment); NE = not estimable.
file.exists(path)
#> [1] TRUE
unlink(path)

## ---- 12. Working with the result -------------------------------------
class(tab$flextable)       # an editable flextable object
#> [1] "flextable"
tab$groups                 # group sizes
#>       group  n sum_weights effective_n
#> 1   Control 30          30          30
#> 2 Treatment 30          30          30
tab$settings$show_missing  # normalized show_missing setting
#> [1] "always"
tab$row_info               # row types, useful for custom formatting
#>   variable     type
#> 1      age variable
#> 2      age  summary
#> 3      age  summary
#> 4      age  missing
#> 5      sex variable
#> 6      sex category
#> 7      sex category
#> 8      sex  missing
```
