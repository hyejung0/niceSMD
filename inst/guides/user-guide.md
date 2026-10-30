# User guide

This guide explains the calculations, options, and output of `niceSMD`.
The package makes the selected two-group SMD comparison explicit while
allowing additional descriptive columns for other groups.

Each input row represents one analysis unit, typically one person. The
function does not collapse repeated measurements into a baseline record.

## Choosing variables and labels

```r
d <- niceSMD::example_table1_data()
vars <- c("age", "bmi", "sex", "smoking", "stage_code")
labels <- c(
  age = "Age in years", bmi = "Body mass index", sex = "Sex",
  smoking = "Smoking history", stage_code = "Stage"
)
tab <- niceSMD::nice_SMD_table1(
  d, "group", vars, print_covariate_names = labels,
  categorical_vars = "stage_code",
  group_for_SMD = c("Control", "Treatment")
)
```

Labels can instead be an unnamed vector in covariate order. Repeated labels
and characters such as `=` do not affect calculations. Column names can
contain spaces or punctuation. The original column names remain in
`tab$smd$variable` and `tab$row_info$variable`.

Factors retain the order of their observed levels; unused levels are dropped.
Characters and logical values are converted with `factor()`. To choose a
category order or names, convert the variable before calling the function:

```r
d$stage_code <- factor(d$stage_code, levels = 1:3,
                      labels = c("Stage I", "Stage II", "Stage III"))
```

Numeric columns are continuous unless named in `categorical_vars`.
Matrices, lists, dates, date-times, durations, and integer64 continuous
columns require an explicit conversion before use.

If `covar_names` is omitted, all columns except group and weight columns
identified by name are summarized. Explicit selection is recommended so
identifiers and design variables do not accidentally enter Table 1.

## Group order and comparison

Factor grouping variables use their observed factor-level order. Other
group variables use first appearance. Override it with, for example:

```r
tab <- niceSMD::nice_SMD_table1(
  d, "group", c("age", "sex"),
  group_order = c("Treatment", "Control", "Registry"),
  group_for_SMD = c("Treatment", "Control")
)
```

SMDs are absolute, so reversing the pair does not change their numeric values.
The pair must contain two distinct included groups. Missing group values are
excluded with a warning and are not printed as a separate group.

## Nonnegative analysis weights

```r
weighted <- niceSMD::nice_SMD_table1(
  d, "group", c("age", "sex", "smoking"),
  weights = "analysis_weight",
  group_for_SMD = c("Control", "Treatment")
)
```

The vector form `weights = d$analysis_weight` is equivalent. The function
uses the supplied weights directly. Each must be finite, nonnegative, and
nonmissing. Zero-weight observations are excluded entirely, including from
the displayed raw n. No truncation or normalization is performed.

The weight-only route constructs `survey::svydesign(ids = ~1, weights = ...)`.
This supports weighted descriptive summaries and the weighted `tableone`
SMD convention. It does not infer a survey sampling design and does not
account for estimation of propensity scores. No inferential SEs are reported.

Weighted category and missing counts are sums of weights, so they may be
fractional and need not equal the number of people. Multiplying every weight
by the same positive constant scales these counts but leaves weighted
proportions, means, SMDs, and Kish effective n unchanged.

The `groups` component reports the included number of people, sum of weights,
and the Kish effective sample size:

$$n_{\mathrm{eff}} = \frac{(\sum_i w_i)^2}{\sum_i w_i^2}.$$

This is computed over the full included group, before variable-specific
missingness is excluded. It describes concentration of weights and does not
include effects of clustering or stratification.

## Survey designs and replicate weights

For complex survey data, supply the actual design instead of just a vector:

```r
design <- survey::svydesign(
  ids = ~cluster, strata = ~stratum,
  weights = ~analysis_weight, data = d
)
survey_tab <- niceSMD::nice_SMD_table1(
  group = "group", covar_names = c("age", "sex", "smoking"),
  design = design,
  group_for_SMD = c("Control", "Treatment")
)

rep_design <- survey::as.svrepdesign(design, type = "JKn")
rep_tab <- niceSMD::nice_SMD_table1(
  group = "group", covar_names = c("age", "sex"),
  design = rep_design,
  group_for_SMD = c("Control", "Treatment")
)
```

Omitting `dat` uses `design$variables` and avoids a separate row-alignment
requirement. If both are supplied, they must contain the same observations
in exactly the same order; row count alone cannot establish alignment.
Do not supply `weights` together with `design`.

The function retains the original design variables and adds private working
columns to a local copy. Sampling weights drive counts and percentages.
Replicate weights are used by the survey methods where relevant, not summed
to produce counts. Complex-design SD and SMD conventions come from `survey`
and `tableone`; no design-based confidence intervals are printed.

If a design produces an error such as a stratum with only one sampled PSU,
resolve the sampling-design issue or choose an appropriate survey option
for your analysis. The package does not change global survey options for you.

## Missing values and percentage denominators

The variable's observed data determine its continuous summaries and SMD.
SMDs for different variables can therefore use different subsets of people.
An SMD does not assess differences in missingness itself.

For an unweighted example, suppose a group contains 100 people, 10 have
missing smoking status, and 30 of the other 90 are current smokers. The
table displays current smoking as `30 (33.3%)` and missing as `10 (10.0%)`.
Category percentages sum to 100% among observed values, before rounding;
the missing percentage has a different denominator.

In a weighted table, replace each count in that example by its sum of weights.
Missing percentages use the full group weight total. These definitions are
written in every exported table's notes by default.

`show_missing` controls only the display of the Missing row: `TRUE`/`"always"`
(default) shows one for every variable, `FALSE`/`"never"` hides them all, and
`"if_any"` shows one only for variables with at least one missing value in a
displayed group. No setting imputes observations or changes the denominators.

`notes` controls the footnotes: `"full"` (default) documents every convention,
`"short"` gives a compact legend suited to manuscript tables, and `"none"`
omits footnotes. The text is stored in `tab$notes`.

 All-missing continuous summaries display `NA`;
an SMD with insufficient observed data displays `NE`, with a reason in `smd`.

## Continuous summary definitions

Both mean (SD) and median (Q1, Q3) are always shown. The mean and variance
use nonmissing observations separately in each group. Unweighted SDs use
the usual sample variance; weighted SDs are the square root of
`survey::svyvar` estimates, matching the weighted SMD engine.

Unweighted quartiles use `stats::quantile(type = 7)`. Weighted quartiles use
`survey::svyquantile(qrule = "math", ci = FALSE)`. These are different quantile
conventions, so a vector of equal weights need not give the same quartiles
as the unweighted call. No interpolation across missing values is performed.

`contDigits` controls all continuous summary decimal places. `catDigits`
controls category and missing percentages. `weightDigits` controls weighted
counts and weight totals; unweighted counts remain integers. `smdDigits`
controls only displayed SMDs, not `tab$smd$smd`.

## SMD formulas and exceptional cases

For a continuous variable, let the two observed group means be $m_a,m_b$
and their variances be $s_a^2,s_b^2$. The SMD is

$$\frac{|m_a-m_b|}{\sqrt{(s_a^2+s_b^2)/2}}.$$

The numerator describes the mean difference. Dividing by a measure of
within-group variability expresses the difference in SD units. The two
variances contribute equally; this is not a sample-size-weighted pooled SD.

For a binary variable, replace the means by observed proportions $p_a,p_b$
and the variances by Bernoulli variances:

$$\frac{|p_a-p_b|}{\sqrt{\{p_a(1-p_a)+p_b(1-p_b)\}/2}}.$$

For a categorical variable with $K$ observed levels, retain $K-1$ proportions
to avoid redundancy. Let $p_g$ be this vector in group $g$. Its categorical
covariance is $S_g=\operatorname{diag}(p_g)-p_gp_g^T$. The joint distance is

$$\sqrt{(p_a-p_b)^T\{(S_a+S_b)/2\}^{-1}(p_a-p_b)}.$$

This extends the binary comparison by accounting for dependence among the
category indicators. Changing the omitted category does not change the
distance when the covariance is nonsingular. It is not an average of
separate category SMDs. Weighted categorical proportions use sums of weights.

Ordinary, nonsingular SMDs are extracted numerically with
`tableone::ExtractSmd()` from `CreateTableOne()` or `svyCreateTableOne()`.
The wrapper handles the following cases explicitly:

| Situation | Result |
|---|---|
| Continuous variable has fewer than two observed positive-weight people in either group | `NE` |
| Categorical variable has no observed positive-weight people in either group | `NE` |
| Same constant value or single observed category in both groups | `0` |
| Different constants and zero standardizing variance | `Inf` |
| Singular multilevel category covariance | `NE` |
| SMD engine fails or returns an undefined value | `NE`, with reason retained |

Singular or numerically singular multilevel cases deliberately do not use a generalized inverse;
such a result could obscure differences along directions with zero variance.
No imbalance threshold is automatically applied.

## Output and customization

| Component | Contents |
|---|---|
| `tab$table` | Formatted character data.frame used for display |
| `tab$smd` | Original variable identifiers, labels, numeric SMDs, status, reasons |
| `tab$groups` | Included group sizes, weight totals, Kish effective sizes |
| `tab$row_info` | Original variable and row type for every displayed row |
| `tab$notes` | Denominator, weighting, missingness, and SMD definitions |
| `tab$settings` | Comparison, variable types, exclusions, and decimal settings |
| `tab$flextable` | Editable formatted table ready for document use |

`as.data.frame(tab)` returns `tab$table`. To select SMDs numerically:

```r
tab$smd[!is.na(tab$smd$smd) & tab$smd$smd > 0.1, ]
utils::write.csv(tab$smd, "numeric_SMDs.csv", row.names = FALSE)
```

To customize the editable table:

```r
ft <- niceSMD::table1_flextable(tab, font_size = 9)
ft <- flextable::bg(ft, part = "header", bg = "#EAF0F4")
ft <- flextable::color(ft, part = "header", color = "#243746")
flextable::save_as_docx(`Participant characteristics` = ft,
                      path = "Customized_Table1.docx")
```

`save_table1_docx()` rebuilds the table from the object's data and options.
To export a manually modified `ft`, use `flextable::save_as_docx()` or
`flextable::body_add_flextable()` as above.

The exporter repeats column headers and keeps a variable heading with its
first detail row. It allows long variables to continue on the next page.
For many groups or long labels, use landscape or reduce the font size.

## Migration from the original script

The original argument order is preserved, so the old call pattern continues
to work with the new package. The return value is now a structured object.
Replace direct manipulation of the returned data.table with `tab$table` or
`as.data.frame(tab)`. The first display column is `Variable`.

Do not `source()` the old function into the same R session and expect
`library(niceSMD)` to replace that global function. Restart R or call
`niceSMD::nice_SMD_table1()` explicitly.

The display engine was rebuilt because the old workflow joined tables using
modified printed labels. Internal keys now connect the summary rows to the
original variables. Formatting no longer controls numerical calculations.

## Primary documentation

* [tableone project and function reference](https://kaz-yos.github.io/tableone/)
* [survey package documentation](https://r-survey.r-forge.r-project.org/survey/)
* [flextable documentation](https://davidgohel.github.io/flextable/)
* [officer documentation](https://davidgohel.github.io/officer/)

The dependency versions installed on your computer determine the behavior of
their numerical engines. The package test suite checks the stated formulas,
weighting conventions, and Word structure against those installed versions.
