\name{table1_flextable}
\alias{table1_flextable}
\title{Format an Editable Table 1}
\usage{
table1_flextable(x, font_size = 10, font_family = "Arial", include_notes = TRUE)
}
\arguments{
  \item{x}{A \code{nice_table1} object returned by \code{\link{nice_SMD_table1}}.}
  \item{font_size}{A single positive number: the font size in points for the
  header and body. Footnotes use \code{max(8, font_size - 1)}. Default 10.
  Reduce it (for example 8 or 9) for wide tables with many groups.}
  \item{font_family}{A single character string naming the font, for example
  \code{"Arial"} or \code{"Times New Roman"}. The font must be available on the
  machine that opens the document. Default \code{"Arial"}.}
  \item{include_notes}{\code{TRUE} (default) or \code{FALSE}. Whether to add
  the footnotes stored in \code{x$notes} as a table footer. The footnote
  content itself is chosen with the \code{notes} argument of
  \code{\link{nice_SMD_table1}} (\code{"full"}, \code{"short"}, \code{"none"});
  if \code{x$notes} is empty no footer is added regardless of this argument.}
}
\description{Creates a \pkg{flextable} with bold variable headings,
indented detail rows (category levels, summary statistics, and missing rows),
centered group columns, repeating column headers, and an optional explanatory
footer. Keeps variable headings with their first detail row in Word. The
returned object can be customized further with any \pkg{flextable} function
before being placed in a document.}
\value{A \code{flextable} object, suitable for customization or inclusion
in Word, HTML, and Quarto/R Markdown documents.}
\seealso{\code{\link{save_table1_docx}}, \code{\link{nice_SMD_table1}},
\code{\link{table1_kable}}}
\examples{
d <- example_table1_data()
tab <- nice_SMD_table1(d, "group", c("age", "sex", "smoking"),
  group_for_SMD = c("Control", "Treatment"))

## Default table
ft <- table1_flextable(tab)
class(ft)

## Smaller font and a different typeface for a wide table
ft_small <- table1_flextable(tab, font_size = 8, font_family = "Times New Roman")

## No footer, for example when notes are written in the manuscript text
ft_plain <- table1_flextable(tab, include_notes = FALSE)

## Compact legend: choose it when the table is built
tab_short <- nice_SMD_table1(d, "group", c("age", "sex", "smoking"),
  group_for_SMD = c("Control", "Treatment"),
  show_missing = "if_any", notes = "short")
ft_short <- table1_flextable(tab_short)

## Further customization with flextable before inserting into a document
ft_custom <- table1_flextable(tab_short, font_size = 9)
ft_custom <- flextable::color(ft_custom, part = "header", color = "#243746")
ft_custom <- flextable::bg(ft_custom, part = "header", bg = "#E8EEF3")

## Insert into an existing Word document
path <- tempfile(fileext = ".docx")
doc <- officer::read_docx()
doc <- flextable::body_add_flextable(doc, value = ft_custom)
print(doc, target = path)
unlink(path)

## In a Quarto chunk, put the flextable last to render it:
##   table1_flextable(tab, font_size = 9)
}
