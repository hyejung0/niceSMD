\name{table1_kable}
\alias{table1_kable}
\title{Lightweight Table 1 for Quarto and R Markdown}
\usage{
table1_kable(x, format = NULL)
}
\arguments{
  \item{x}{A \code{nice_table1} object returned by \code{\link{nice_SMD_table1}}.}
  \item{format}{Output format passed to \code{knitr::kable()}: \code{NULL}
  (default, chosen from the document), \code{"html"}, \code{"latex"},
  \code{"markdown"}, or \code{"pipe"}. With \code{"latex"}, variable names use
  \code{\\textbf{}} and levels are indented with \code{\\hspace{1em}}; other
  formats use Markdown bold and non-breaking spaces.}
}
\description{Returns a \code{knitr::kable} table with bold variable names and
indented category levels, summaries, and missing rows. It needs only
\pkg{knitr}, so it is a robust alternative to \code{\link{table1_flextable}}
when PDF output has font or LaTeX problems. Footnotes are not included; print
them separately with \code{cat(x$notes, sep = "\\n")}.}
\value{A \code{knitr_kable} object.}
\seealso{\code{\link{table1_flextable}}, \code{\link{nice_table1-methods}}}
\examples{
if (requireNamespace("knitr", quietly = TRUE)) {
  d <- example_table1_data()
  tab <- nice_SMD_table1(d, "group", c("age", "sex"),
    group_for_SMD = c("Control", "Treatment"), notes = "short")

  ## Markdown (default outside a document)
  table1_kable(tab, format = "markdown")

  ## HTML and LaTeX targets
  table1_kable(tab, format = "html")
  table1_kable(tab, format = "latex")

  ## Print the notes below the table
  cat(tab$notes, sep = "\\n")
}
}
