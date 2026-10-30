\name{nice_trial_table1}
\alias{nice_trial_table1}
\title{Descriptive Tables by Trial and Treatment Arm}
\usage{
nice_trial_table1(
  dat, trial, treatment, covar_names = NULL, print_covariate_names = NULL,
  treatment_for_SMD = NULL, treatment_order = NULL, trial_order = NULL,
  layout = "wide", show_smd = TRUE, continuous_stats = "both",
  catDigits = 1, contDigits = 2, smdDigits = 3, categorical_vars = NULL,
  weights = NULL, weightDigits = 1, show_missing = "if_any",
  title = "Table 1 by trial and treatment", docx_path = NULL,
  notes = "full"
)
}
\arguments{
  \item{dat}{A data.frame, tibble, or data.table with one row per participant
  (individual participant data), containing the trial identifier, the treatment
  arm, the covariates, and optionally a weight column. Column names must be
  unique and nonempty.}

  \item{trial}{The trial identifier, given as a single column name in
  \code{dat} (for example \code{"trial"}) or as a vector of length
  \code{nrow(dat)}. Factors keep their level order for the display; other
  types use order of first appearance (override with \code{trial_order}). Rows
  with a missing trial are excluded with a warning.}

  \item{treatment}{The treatment arm, given as a single column name or a vector
  of length \code{nrow(dat)}. Arms may differ between trials (for example a
  third arm in one trial). Rows with a missing treatment are excluded with a
  warning. Trials with fewer than two arms are omitted with a warning.}

  \item{covar_names}{Character vector of columns to summarize, in display order.
  Defaults to all columns other than the trial, treatment, and weight columns
  named by string. Select covariates explicitly when \code{trial},
  \code{treatment}, or \code{weights} are supplied as external vectors.}

  \item{print_covariate_names}{Display labels, either an unnamed character
  vector with one label per entry of \code{covar_names} or a named vector named
  by all covariate names (any order). Defaults to the column names.}

  \item{treatment_for_SMD}{Character vector of length two naming the two arms
  whose SMD is reported within each trial, for example
  \code{c("Placebo", "Active")}. Defaults to the two arms of each trial when
  every trial has exactly two arms; required if any trial has more than two. If
  a trial lacks one of the named arms, its SMD is shown as an em dash and
  recorded as not estimable in \code{smd}.}

  \item{treatment_order}{Character vector listing every included treatment
  exactly once, giving the left-to-right (or top-to-bottom) order of arms
  within each trial. Defaults to factor level order or order of first
  appearance. A trial shows only the arms it contains.}

  \item{trial_order}{Character vector listing every included trial exactly once,
  giving the order of trials. Defaults to factor level order or order of first
  appearance. Use it, for example, to order trials by year or sample size.}

  \item{layout}{\code{"wide"} (default) or \code{"long"}.
  \itemize{
    \item \code{"wide"}: rows are variables (names bold, levels indented) and
      columns are trial blocks, each with one column per arm and optionally an
      SMD column, under a header spanning the trial name. Best for a few trials.
    \item \code{"long"}: rows are trial-by-arm combinations (with the arm size
      N and, for weighted tables, the sum of weights) and columns are
      variables; categorical variables get one column per level. This is the
      usual layout for many trials. SMDs are not shown in this layout; use
      \code{x$smd}.
  }}

  \item{show_smd}{\code{TRUE} (default) or \code{FALSE}. Whether the wide layout
  includes a within-trial SMD column. Within a randomized trial baseline
  differences are chance imbalances, so many authors omit them; SMDs remain
  available in \code{x$smd}. Ignored for \code{layout = "long"}.}

  \item{continuous_stats}{Which continuous summaries to display: \code{"both"}
  (default) for mean (SD) and median (Q1, Q3), \code{"mean_sd"}, or
  \code{"median_iqr"}. Display only; SMDs always use means and SDs. Using one
  statistic roughly halves the number of columns in the long layout.}

  \item{catDigits}{Integer 0 to 10. Decimal places for percentages. Default 1.}

  \item{contDigits}{Integer 0 to 10. Decimal places for means, SDs, medians, and
  quartiles. Default 2.}

  \item{smdDigits}{Integer 0 to 10. Decimal places for displayed SMDs. Default 3.
  Numeric SMDs in \code{x$smd} are not rounded.}

  \item{categorical_vars}{Optional character vector of covariates to treat as
  categorical, for example numeric stage codes. Factors, characters, and
  logicals are categorical automatically.}

  \item{weights}{Optional analysis weights, as a numeric column name or a
  numeric vector of length \code{nrow(dat)}. Must be finite and nonnegative;
  rows with zero weight are excluded with a warning. Weights are applied within
  each trial and arm exactly as supplied. Survey design objects are not
  supported; use \code{\link{nice_SMD_table1}} for each trial in that case.}

  \item{weightDigits}{Integer 0 to 10. Decimal places for weighted counts and
  sums of weights. Default 1.}

  \item{show_missing}{Controls Missing rows: \code{TRUE}/\code{"always"},
  \code{FALSE}/\code{"never"}, or \code{"if_any"} (default here). With
  \code{"if_any"} a variable gets a Missing row if any trial has a missing value
  for it; trials with none show \code{0 (0.0\%)}. See
  \code{\link{nice_SMD_table1}}.}

  \item{title}{Heading used when printing and in the Word document. Default
  \code{"Table 1 by trial and treatment"}. Use \code{""} to omit it.}

  \item{docx_path}{Optional new \code{.docx} filename. The table is written in
  landscape orientation; an existing file is never overwritten. For other
  options use \code{\link{save_table1_docx}}.}

  \item{notes}{Footnote style: \code{"full"} (default), \code{"short"}, or
  \code{"none"}. The short legend gives the cell layout, the SMD definition
  and the compared pair, \code{NE}, and lines for excluded rows, hidden Missing
  rows, omitted trials, or em dashes when applicable.}
}
\description{
Builds descriptive summaries separately for each trial and treatment arm from
pooled individual participant data, as used in multi-trial analyses such as
trial-level surrogate endpoint studies. Each trial is summarized with
\code{\link{nice_SMD_table1}}, so all conventions (denominators, missing values,
weighting, SMDs) are identical; this function arranges the per-trial results
into one table with a common set of rows. The result prints in the console,
renders in Quarto and R Markdown, and exports to Word.
}
\details{
Every statistic is computed within a trial and arm; nothing is pooled across
trials. Rows follow a common structure: for categorical variables the levels
are those observed in any trial, in the order of the data. A level not observed
in a given trial displays as a zero count; an em dash marks a cell that does not
apply (for example, a variable that is entirely missing in a trial, or an SMD
whose arm pair is absent).

With many trials, a wide table is unreadable; use \code{layout = "long"}, or
split trials across several calls. A single trial-by-arm table is common in
supplements of multi-trial individual participant data analyses; main-text
tables often show only trial-level characteristics.

The per-trial \code{nice_table1} objects are in \code{x$trials}, so any single
trial can be printed or exported on its own.
}
\value{
A \code{nice_trial_table1} list with \code{table} (formatted data.frame),
\code{col_info} (column keys, header labels, trial, arm, and type),
\code{row_info} (row types for \code{"wide"}; trial and treatment for
\code{"long"}), \code{smd} (long data.frame with one row per trial and
variable: numeric SMD, status, reason), \code{groups} (per trial and arm raw
counts, sums of weights, Kish effective sizes), \code{trials} (named list of
\code{nice_table1} objects), \code{notes}, \code{settings}, \code{call}, and
\code{flextable}.
}
\seealso{\code{\link{nice_SMD_table1}}, \code{\link{table1_flextable}},
\code{\link{save_table1_docx}}, \code{\link{example_trial_data}}}
\examples{
d <- example_trial_data()
head(d)
table(d$trial, d$arm)
vars <- c("age", "egfr", "sex", "diabetes", "ckd_stage")
labels <- c("Age (years)", "eGFR (mL/min/1.73 m2)", "Sex", "Diabetes", "CKD stage")

## ---- 1. Trials side by side (few trials) -----------------------------
## Trial C has three arms, so name the pair the SMD compares.
wide <- nice_trial_table1(
  d, trial = "trial", treatment = "arm", covar_names = vars,
  print_covariate_names = labels,
  treatment_for_SMD = c("Placebo", "Active")
)
wide
wide$smd                     # numeric SMDs, one row per trial and variable
wide$groups                  # arm sizes
wide$trials[["Trial A"]]     # the underlying single-trial table

## ---- 2. One row per trial and arm (many trials) ----------------------
long <- nice_trial_table1(
  d, "trial", "arm", vars, print_covariate_names = labels,
  treatment_for_SMD = c("Placebo", "Active"),
  layout = "long", continuous_stats = "mean_sd", notes = "short"
)
long

## ---- 3. Manuscript style: no SMD column, short legend ----------------
nice_trial_table1(
  d, "trial", "arm", vars, print_covariate_names = labels,
  treatment_for_SMD = c("Placebo", "Active"),
  show_smd = FALSE, notes = "short"
)

## ---- 4. Missing rows ---------------------------------------------------
## Only age and eGFR have missing values: "if_any" (default) shows Missing
## rows for them; "never" hides all; "always" shows one for every variable.
for (mode in c("if_any", "never", "always")) {
  x <- nice_trial_table1(d, "trial", "arm", vars,
                         treatment_for_SMD = c("Placebo", "Active"),
                         show_missing = mode)
  cat(mode, ":", sum(x$row_info$type == "missing"), "Missing rows\n")
}

## ---- 5. Orders and labels ---------------------------------------------
nice_trial_table1(
  d, "trial", "arm", c("age", "sex"),
  print_covariate_names = c(sex = "Sex", age = "Age (years)"),
  treatment_for_SMD = c("Placebo", "Active"),
  trial_order = c("Trial C", "Trial A", "Trial B"),
  treatment_order = c("Active", "Placebo", "High dose")
)$groups

## ---- 6. Rounding, categorical codes, grouping vectors ----------------
nice_trial_table1(
  d, d$trial, d$arm, c("age", "ckd_stage"),
  treatment_for_SMD = c("Placebo", "Active"),
  contDigits = 1, catDigits = 0, smdDigits = 2
)

## ---- 7. Weights ---------------------------------------------------------
nice_trial_table1(
  d, "trial", "arm", c("age", "sex"), weights = "weight",
  treatment_for_SMD = c("Placebo", "Active"), weightDigits = 1,
  layout = "long"
)

## ---- 8. Word output ------------------------------------------------------
path <- tempfile(fileext = ".docx")
save_table1_docx(wide, path, landscape = TRUE, font_size = 9)
unlink(path)
nice_trial_table1(d, "trial", "arm", "age",
                  treatment_for_SMD = c("Placebo", "Active"),
                  docx_path = path)
unlink(path)

## In Quarto, a chunk ending with `wide` renders the formatted table.
}
