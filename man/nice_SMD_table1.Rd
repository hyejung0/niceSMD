\name{nice_SMD_table1}
\alias{nice_SMD_table1}
\title{Descriptive Tables with One Absolute SMD per Variable}
\usage{
nice_SMD_table1(
  dat = NULL, group, covar_names = NULL, print_covariate_names = NULL,
  group_for_SMD = NULL, catDigits = 1, contDigits = 2, smdDigits = 3,
  categorical_vars = NULL, weights = NULL, design = NULL,
  weightDigits = 1, show_missing = TRUE, group_order = NULL,
  title = "Table 1", docx_path = NULL, notes = "full"
)
}
\arguments{
  \item{dat}{A data.frame, tibble, or data.table holding the grouping variable,
  the covariates, and (optionally) a weight column. Column names must be unique
  and nonempty. May be omitted when \code{design} is supplied, in which case
  \code{design$variables} is used. If both are supplied, \code{dat} and
  \code{design} must contain the same rows in exactly the same order.}

  \item{group}{The grouping (column) variable, given either as a single column
  name in \code{dat} (for example \code{"group"}) or as a vector of length
  \code{nrow(dat)} (for example \code{d$group}). Factors keep their level order
  for the display columns; other types use order of first appearance (override
  with \code{group_order}). Rows with a missing group value are excluded with a
  warning. Empty strings are not allowed as group values.}

  \item{covar_names}{Character vector of column names to summarize, in the order
  they should appear. Defaults to every column of \code{dat} other than the
  grouping and weight columns named by string. When \code{group} or
  \code{weights} are supplied as external vectors, select the covariates
  explicitly so that nothing unintended is summarized. Names must be unique and
  must exist in \code{dat}. Matrix and list columns are not supported; Date and
  POSIXt columns must be converted to numeric or factor first.}

  \item{print_covariate_names}{Display labels for the covariates, shown in the
  first column of the table. Either an unnamed character vector with one
  nonempty label per entry of \code{covar_names} (same order), or a named
  character vector whose names are exactly the entries of \code{covar_names}
  (order does not matter). Defaults to the column names. Labels may repeat or
  contain punctuation such as \code{=} or parentheses; calculations never use
  labels as identifiers.}

  \item{group_for_SMD}{Character vector of length two naming the two included
  groups that the SMD compares, for example
  \code{c("Control", "Treatment")}. The SMD is reported as an absolute value, so
  the order only affects the column header and the notes. Defaults to the two
  displayed groups when exactly two groups are present; required when more than
  two groups are displayed. All displayed groups still receive summaries.}

  \item{catDigits}{Integer from 0 to 10. Decimal places for category and
  missing percentages. Default 1, giving values such as \code{30 (33.3\%)}.}

  \item{contDigits}{Integer from 0 to 10. Decimal places for means, SDs,
  medians, and quartiles of continuous variables. Default 2.}

  \item{smdDigits}{Integer from 0 to 10. Decimal places for the displayed SMD
  column. Default 3. The numeric SMDs in \code{tab$smd} are never rounded.}

  \item{categorical_vars}{Optional character vector, drawn from
  \code{covar_names}, naming numeric (or other) columns that should be treated
  as categorical, such as numeric category codes like stage 1/2/3. Factors,
  character columns, and logical columns are always categorical automatically;
  ordered factors are treated as unordered categories with no numeric scores.}

  \item{weights}{Optional analysis weights, given either as the name of a
  numeric column in \code{dat} or as a numeric vector of length
  \code{nrow(dat)}. Weights must be finite, nonnegative, and nonmissing; rows
  with weight zero are excluded with a warning. Weights are used exactly as
  supplied (no normalization, stabilization, or trimming). Supplying weights
  switches the table to weighted counts, sums of weights, weighted means and
  SDs, and weighted quartiles. Cannot be combined with \code{design}.}

  \item{design}{Optional \pkg{survey} design object (\code{survey.design} or
  \code{svyrep.design}). Use this for clustered, stratified, calibrated, or
  replicate-weight analyses; the design's sampling weights are used for counts
  and the design is used for weighted SDs and quartiles. Cannot be combined
  with \code{weights}.}

  \item{weightDigits}{Integer from 0 to 10. Decimal places for weighted counts
  and for sums of weights in the group headers. Ignored for unweighted tables.
  Default 1.}

  \item{show_missing}{Controls the \dQuote{Missing} row under each variable.
  One of:
  \itemize{
    \item \code{TRUE} or \code{"always"} (default): show a Missing row for every
      variable, including rows where every count is zero.
    \item \code{FALSE} or \code{"never"}: hide all Missing rows.
    \item \code{"if_any"}: show a Missing row only for variables that have at
      least one missing value in at least one displayed group. A footnote
      records that variables without a Missing row have no missing values.
  }
  This option only affects display. Denominators, summaries, and SMDs are
  identical for all settings, and missingness is never imputed.}

  \item{group_order}{Character vector listing every included group exactly once,
  giving the left-to-right order of the group columns. Defaults to the factor
  level order (for factors) or order of first appearance (otherwise). Groups
  that have no rows after exclusions must not be listed.}

  \item{title}{A single character string used as the heading when printing and
  in the optional Word document. Default \code{"Table 1"}. Use \code{""} to
  omit the heading from a Word document.}

  \item{docx_path}{Optional new \code{.docx} filename. When supplied, the table
  is also written to Word using default portrait settings; an existing file is
  never overwritten. For landscape orientation, fonts, or overwriting use
  \code{\link{save_table1_docx}}.}

  \item{notes}{Footnote style: \code{"full"} (default), \code{"short"}, or
  \code{"none"}.
  \itemize{
    \item \code{"full"}: a complete description of denominators, missing-value
      handling, SMD definitions, quartile conventions, and the meaning of
      \code{NE} and \code{Inf}. Suited to supplements and analysis reports.
    \item \code{"short"}: a compact legend of two or three lines (the layout of
      the cells, \dQuote{SMD = absolute standardized mean difference}, and
      \dQuote{NE = not estimable}), plus a line for excluded rows or hidden
      Missing rows when applicable. Suited to manuscript tables.
    \item \code{"none"}: no footnotes.
  }
  The text is stored in \code{tab$notes} and is used by \code{print()},
  \code{\link{table1_flextable}}, and \code{\link{save_table1_docx}}.}
}
\description{
Creates continuous and categorical descriptive summaries for two or more groups,
with a single absolute standardized mean difference (SMD) for each variable.
Uses \pkg{tableone} for SMDs and \pkg{survey} for weighted continuous
summaries. All groups are displayed; SMDs compare only the selected pair of
groups. The result prints as a formatted table in the console, renders as a
formatted table in Quarto and R Markdown documents, and exports to editable
Word tables.
}
\details{
Continuous rows report mean (SD) and median (Q1, Q3). Categorical variables
show the variable name followed by one indented row per level with count
(percent). Category percentages use the nonmissing count, or nonmissing sum of
weights, for the variable and group. Missing percentages use the entire
included group count or sum of weights. Missing values are excluded separately
for each variable's summaries and SMD; missingness is not added as a
categorical level. Unused factor levels are dropped.

Unweighted quartiles use \code{stats::quantile(type = 7)}. Weighted quartiles
use \code{survey::svyquantile(qrule = "math", ci = FALSE)}. Equal weights need
not give identical weighted and unweighted quartiles because the quantile
definitions differ. Weighted SDs use \code{survey::svyvar}, consistent with
the weighted SMD engine. Supplied weights are not normalized or trimmed.
Weight-only inputs create a design with \code{ids = ~1}; they do not infer
clustering, stratification, or corrections for estimated propensity weights.
No standard errors, tests, or causal-effect estimates are produced.

For a continuous variable the absolute SMD is
\deqn{|\bar{x}_a - \bar{x}_b| / \sqrt{(s_a^2 + s_b^2)/2}.}
The denominator is the square root of the average of the group variances,
not the sample-size-weighted pooled variance. A multilevel categorical SMD
uses a joint standardized distance between its category proportions.

SMDs require at least two nonmissing positive-weight observations per group for
continuous variables, or one per group for categorical variables. Identical
constants are assigned zero. Different constants with zero standardizing
variance are assigned infinity. Singular multilevel categorical covariance
matrices are reported as not estimable rather than using a generalized-inverse
distance. Other calculation failures are retained in \code{smd$reason}.

Survey variance errors during descriptive summaries are propagated; the function
does not change global survey options. Sampling weights, not replicate weight
sums, are used for weighted counts and effective sample sizes.

\strong{Using the result in Quarto or R Markdown.} Place the object as the last
expression of a chunk (\code{tab}) to render the formatted table in HTML, Word,
or PDF output. See \code{\link{nice_table1-methods}}.
}
\value{
A \code{nice_table1} list with \code{table} (formatted data.frame),
\code{smd} (original variable name, label, numeric SMD, status, and reason),
\code{groups} (included raw counts, weight sums, and Kish effective sizes),
\code{row_info} (original variable names and row types: \code{"variable"},
\code{"category"}, \code{"summary"}, or \code{"missing"}), \code{notes} (the
footnote text selected by \code{notes}), \code{settings}, \code{call}, and
\code{flextable} (editable formatted table).
Kish effective size is \eqn{(\sum_i w_i)^2 / \sum_i w_i^2} and does not
incorporate clustering or stratification. The formatted SMD cells use
\code{NE} for not estimable and \code{Inf} for an infinite SMD.
}
\seealso{\code{\link{save_table1_docx}}, \code{\link{table1_flextable}},
\code{\link{table1_kable}}, \code{\link{nice_table1-methods}},
\code{tableone::ExtractSmd}, \code{survey::svydesign}}
\examples{
d <- example_table1_data()
str(d)

## ---- 1. Minimal two-group table --------------------------------------
## Drop the third group so that group_for_SMD can be omitted.
d2 <- d[d$group != "Registry", ]
tab <- nice_SMD_table1(d2, group = "group", covar_names = c("age", "sex"))
tab                        # formatted console table plus notes
as.data.frame(tab)         # display data.frame
tab$smd                    # numeric, unrounded SMDs with status and reason

## ---- 2. Three groups: choose the SMD pair ----------------------------
## All three groups are displayed; the SMD compares Control and Treatment.
tab3 <- nice_SMD_table1(
  d, group = "group",
  covar_names = c("age", "bmi", "sex", "smoking"),
  group_for_SMD = c("Control", "Treatment")
)
tab3

## ---- 3. Display labels -----------------------------------------------
## Unnamed labels follow the order of covar_names.
nice_SMD_table1(
  d, "group", c("age", "bmi", "sex"),
  print_covariate_names = c("Age (years)", "Body mass index", "Sex"),
  group_for_SMD = c("Control", "Treatment")
)$table

## Named labels may be given in any order.
labels <- c(sex = "Sex", age = "Age at enrollment", bmi = "BMI (kg/m2)")
nice_SMD_table1(
  d, "group", c("age", "bmi", "sex"),
  print_covariate_names = labels,
  group_for_SMD = c("Control", "Treatment")
)$table

## ---- 4. Numeric category codes ---------------------------------------
## stage_code is numeric (1/2/3); force it to be categorical.
nice_SMD_table1(
  d, "group", c("age", "stage_code"),
  print_covariate_names = c("Age", "Stage"),
  categorical_vars = "stage_code",
  group_for_SMD = c("Control", "Treatment")
)

## ---- 5. Group order and external vectors -----------------------------
nice_SMD_table1(
  d, "group", c("age", "sex"),
  group_order = c("Registry", "Control", "Treatment"),
  group_for_SMD = c("Control", "Treatment")
)$groups

## A grouping vector may be used instead of a column name; then list the
## covariates explicitly.
nice_SMD_table1(
  d, group = d$group, covar_names = c("age", "sex"),
  group_for_SMD = c("Control", "Treatment")
)$smd

## ---- 6. Rounding -----------------------------------------------------
nice_SMD_table1(
  d, "group", c("age", "smoking"),
  contDigits = 1, catDigits = 0, smdDigits = 2,
  group_for_SMD = c("Control", "Treatment")
)

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
if_any                     # Missing row only under Age
## TRUE and FALSE remain valid: TRUE is "always", FALSE is "never".
nice_SMD_table1(d, "group", "age", show_missing = FALSE,
                group_for_SMD = c("Control", "Treatment"))$table

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
short                      # compact legend, suited to a manuscript
## Typical manuscript setting: hide empty Missing rows and keep a short legend.
nice_SMD_table1(
  d, "group", c("age", "stratum", "sex"),
  group_for_SMD = c("Control", "Treatment"),
  show_missing = "if_any", notes = "short"
)

## ---- 9. Weights ------------------------------------------------------
## A weight column name ...
weighted <- nice_SMD_table1(
  d, "group", c("age", "sex", "smoking"),
  weights = "analysis_weight", weightDigits = 1,
  group_for_SMD = c("Control", "Treatment"),
  title = "Table 1 Weighted participant characteristics"
)
weighted$groups            # raw n, sum of weights, Kish effective n
weighted$smd
## ... or a numeric vector.
nice_SMD_table1(
  d, "group", c("age", "sex"), weights = d$analysis_weight,
  group_for_SMD = c("Control", "Treatment")
)$smd

## ---- 10. Survey design (clustered / stratified) ----------------------
design <- survey::svydesign(ids = ~cluster, strata = ~stratum,
                            weights = ~analysis_weight, data = d)
nice_SMD_table1(
  group = "group", covar_names = c("age", "sex"),
  design = design, group_for_SMD = c("Control", "Treatment")
)$smd

## ---- 11. Title and Word output ---------------------------------------
path <- tempfile(fileext = ".docx")
nice_SMD_table1(
  d, "group", c("age", "sex"),
  group_for_SMD = c("Control", "Treatment"),
  title = "Table 1 Participant characteristics",
  notes = "short", docx_path = path
)
file.exists(path)
unlink(path)

## ---- 12. Working with the result -------------------------------------
class(tab$flextable)       # an editable flextable object
tab$groups                 # group sizes
tab$settings$show_missing  # normalized show_missing setting
tab$row_info               # row types, useful for custom formatting
}
