\name{example_table1_data}
\alias{example_table1_data}
\title{Synthetic Data for Table 1 Examples}
\usage{example_table1_data()}
\description{Returns fixed synthetic observations with continuous, factor,
character, and numeric-coded categorical covariates, missing values, three
groups, nonconstant analysis weights, and survey-design identifiers.
Does not alter the random-number generator state.}
\value{A data.frame with 90 rows and the columns \code{group}, \code{age},
\code{bmi}, \code{sex}, \code{smoking}, \code{stage_code},
\code{analysis_weight}, \code{stratum}, and \code{cluster}.}
\examples{head(example_table1_data())}
