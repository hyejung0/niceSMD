\name{nice_SMD_table1}
\alias{nice_SMD_table1}
\title{Descriptive Tables with One Absolute SMD per Variable}
\usage{
nice_SMD_table1(
  dat = NULL, group, covar_names = NULL, print_covariate_names = NULL,
  group_for_SMD = NULL, catDigits = 1, contDigits = 2, smdDigits = 3,
  categorical_vars = NULL, weights = NULL, design = NULL,
  weightDigits = 1, show_missing = TRUE, group_order = NULL,
  title = "Table 1", docx_path = NULL
)
}
\arguments{
  \item{dat}{A data.frame, tibble, or data.table. If omitted with a survey design,
  uses \code{design$variables}. If supplied with a design, rows must be in exactly
  the same order as the design.}
  \item{group}{A grouping column name or a vector of length \code{nrow(dat)}.
  Rows with missing group values are excluded with a warning.}
  \item{covar_names}{Character vector of columns to summarize. Defaults to all
  columns except grouping and weight columns specified by name. Explicitly
  select covariates when supplying group or weights as external vectors.}
  \item{print_covariate_names}{Display labels in covariate order, or a named
  character vector with one entry for each covariate. Labels may repeat or
  contain punctuation; calculations use internal identifiers.}
  \item{group_for_SMD}{Two distinct included group values. Defaults to the
  displayed groups when there are exactly two. Required with more groups.}
  \item{catDigits}{Decimal places for category and missing percentages.}
  \item{contDigits}{Decimal places for means, SDs, medians and quartiles.}
  \item{smdDigits}{Decimal places for displayed SMDs. Numeric SMDs retain precision.}
  \item{categorical_vars}{Optional character vector of covariate names to force
  to categorical, including numeric category codes. Factors, characters, and
  logical variables are automatically categorical.}
  \item{weights}{A numeric analysis-weight vector or a weight column name.
  Weights must be finite, nonnegative, and nonmissing. Zero-weight rows are
  excluded with a warning. Cannot be combined with \code{design}.}
  \item{design}{An optional \pkg{survey} survey.design or svyrep.design object.
  Use this for clustered, stratified, calibrated, or replicate-weight analyses.
  Its sampling weights must be finite, nonnegative, and nonmissing.}
  \item{weightDigits}{Decimal places for weighted counts and sums of weights.}
  \item{show_missing}{Show a missing-value row for every variable, including zero counts.}
  \item{group_order}{Character vector listing every included group exactly once.
  Defaults to observed factor-level order or first appearance for other types.}
  \item{title}{Title used for printing and the optional Word document.}
  \item{docx_path}{Optional new .docx filename. Existing files are protected.
  For landscape or other export options use \code{save_table1_docx()}.}
}
\description{
Creates continuous and categorical descriptive summaries with a single
absolute standardized mean difference (SMD) for each variable. Uses
\pkg{tableone} for SMDs and \pkg{survey} for weighted continuous summaries.
All groups are displayed; SMDs compare only the selected pair.
}
\details{
Continuous rows report mean (SD) and median (Q1, Q3). Category percentages use
the nonmissing count, or nonmissing sum of weights, for the variable and group.
Missing percentages use the entire included group count or sum of weights.
Missing values are excluded separately for each variable's summaries and SMD;
missingness is not added as a categorical level. Unused factor levels are dropped.

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
}
\value{
A \code{nice_table1} list with \code{table} (formatted data.frame),
\code{smd} (original variable name, label, numeric SMD, status, and reason),
\code{groups} (included raw counts, weight sums, and Kish effective sizes),
\code{row_info} (original variable names and row types), \code{notes},
\code{settings}, \code{call}, and \code{flextable} (editable formatted table).
Kish effective size is \eqn{(\sum_i w_i)^2 / \sum_i w_i^2} and does not
incorporate clustering or stratification. The formatted SMD cells use
\code{NE} for not estimable and \code{Inf} for an infinite SMD.
}
\seealso{\code{\link{save_table1_docx}}, \code{\link{table1_flextable}},
\code{tableone::ExtractSmd}, \code{survey::svydesign}}
\examples{
d <- example_table1_data()
tab <- nice_SMD_table1(
  d, "group", c("age", "sex", "smoking", "stage_code"),
  categorical_vars = "stage_code",
  group_for_SMD = c("Control", "Treatment")
)
tab$smd
head(as.data.frame(tab))
weighted <- nice_SMD_table1(
  d, "group", c("age", "sex"), weights = "analysis_weight",
  group_for_SMD = c("Control", "Treatment")
)
weighted$groups
}
