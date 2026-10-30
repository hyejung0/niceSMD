\name{example_table1_data}
\alias{example_table1_data}
\title{Synthetic Data for Table 1 Examples}
\usage{example_table1_data()}
\description{Returns fixed synthetic observations with continuous, factor,
character, and numeric-coded categorical covariates, missing values, three
groups (Control, Treatment, Registry), nonconstant analysis weights, and
survey-design identifiers. The function takes no arguments and does not alter
the random-number generator state, so results are identical on every call.}
\value{A data.frame with 90 rows and the columns \code{group} (factor),
\code{age}, \code{bmi} (continuous, with missing values), \code{sex} (factor,
with missing values), \code{smoking} (character, with missing values),
\code{stage_code} (numeric codes 1 to 3, with missing values),
\code{analysis_weight} (positive weights), \code{stratum} (North/South, no
missing values), and \code{cluster} (unique identifier per row).}
\examples{
d <- example_table1_data()
head(d)
table(d$group)
colSums(is.na(d))   # which columns contain missing values
}
