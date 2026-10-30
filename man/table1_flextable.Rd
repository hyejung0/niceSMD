\name{table1_flextable}
\alias{table1_flextable}
\title{Format an Editable Table 1}
\usage{
table1_flextable(x, font_size = 10, font_family = "Arial", include_notes = TRUE)
}
\arguments{
  \item{x}{A \code{nice_table1} object.}
  \item{font_size}{Positive font size in points.}
  \item{font_family}{Font family.}
  \item{include_notes}{Include denominator and SMD notes in the table footer.}
}
\description{Creates a \pkg{flextable} with bold variable headings,
indented detail rows, repeating column headers, and an optional explanatory
footer. Keeps variable headings with their first detail row in Word.}
\value{A \code{flextable} object, suitable for customization or inclusion
in Word and Quarto/R Markdown documents.}
\examples{
d <- example_table1_data()
tab <- nice_SMD_table1(d, "group", "age",
  group_for_SMD = c("Control", "Treatment"))
ft <- table1_flextable(tab, font_size = 9)
}
