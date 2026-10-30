\name{example_trial_data}
\alias{example_trial_data}
\title{Synthetic Multi-Trial Data for Examples}
\usage{example_trial_data()}
\description{Returns fixed synthetic individual participant data from three
trials: Trial A and Trial B have two arms (Placebo, Active) and Trial C has
three (Placebo, Active, High dose). Includes continuous, factor, and character
covariates, missing values, a CKD stage category that is not observed in
Trial A, and positive analysis weights. The function takes no arguments and does
not alter the random-number generator state.}
\value{A data.frame with 180 rows and the columns \code{trial} (factor),
\code{arm} (factor), \code{age} and \code{egfr} (continuous, with missing
values), \code{sex} (factor), \code{diabetes} and \code{ckd_stage}
(character), and \code{weight}.}
\seealso{\code{\link{nice_trial_table1}}}
\examples{
d <- example_trial_data()
table(d$trial, d$arm)
colSums(is.na(d))
}
