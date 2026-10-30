\name{save_table1_docx}
\alias{save_table1_docx}
\title{Save an Editable Word Table}
\usage{
save_table1_docx(x, path, title = x$settings$title,
  landscape = FALSE, font_size = 10, font_family = "Arial",
  include_notes = TRUE, overwrite = FALSE)
}
\arguments{
  \item{x}{A \code{nice_table1} object returned by \code{\link{nice_SMD_table1}}.}
  \item{path}{A single filename ending in \code{.docx}. The directory must
  already exist. An existing file is not replaced unless \code{overwrite = TRUE}.}
  \item{title}{A single character string used as a \dQuote{Heading 1}
  paragraph above the table. Defaults to the title given to
  \code{nice_SMD_table1}. An empty string \code{""} omits the heading.}
  \item{landscape}{\code{TRUE} or \code{FALSE} (default). Use landscape page
  orientation, recommended for tables with many groups or long labels.}
  \item{font_size}{A single positive number: font size in points. Default 10.
  Footnotes use \code{max(8, font_size - 1)}.}
  \item{font_family}{A single character string naming the font. Default
  \code{"Arial"}.}
  \item{include_notes}{\code{TRUE} (default) or \code{FALSE}. Include the
  footnotes stored in \code{x$notes}. Choose their detail level with the
  \code{notes} argument of \code{\link{nice_SMD_table1}}.}
  \item{overwrite}{\code{TRUE} or \code{FALSE} (default). Whether an existing
  file at \code{path} may be replaced.}
}
\description{Writes the table as editable Word cells using \pkg{officer}
and \pkg{flextable}. Uses automatic table layout, 0.7-inch margins, and
repeating column headings. For especially wide tables use landscape
orientation or a smaller font.}
\value{The normalized output path, invisibly.}
\seealso{\code{\link{table1_flextable}}, \code{\link{nice_SMD_table1}}}
\examples{
d <- example_table1_data()
tab <- nice_SMD_table1(d, "group", c("age", "sex"),
  group_for_SMD = c("Control", "Treatment"))
path <- tempfile(fileext = ".docx")

## Default portrait document
save_table1_docx(tab, path)

## Replace an existing file; landscape page, smaller font, different typeface
save_table1_docx(tab, path, overwrite = TRUE, landscape = TRUE,
                 font_size = 9, font_family = "Times New Roman")

## Custom heading, or no heading at all
save_table1_docx(tab, path, overwrite = TRUE,
                 title = "Table 1. Baseline characteristics")
save_table1_docx(tab, path, overwrite = TRUE, title = "")

## Without footnotes ...
save_table1_docx(tab, path, overwrite = TRUE, include_notes = FALSE)

## ... or with a short legend, hiding Missing rows that are always zero
tab_short <- nice_SMD_table1(d, "group", c("age", "stratum"),
  group_for_SMD = c("Control", "Treatment"),
  show_missing = "if_any", notes = "short")
save_table1_docx(tab_short, path, overwrite = TRUE, landscape = TRUE)

## The path is returned invisibly
out <- save_table1_docx(tab, path, overwrite = TRUE)
basename(out) == basename(path)
unlink(path)
}
