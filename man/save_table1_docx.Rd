\name{save_table1_docx}
\alias{save_table1_docx}
\title{Save an Editable Word Table}
\usage{
save_table1_docx(x, path, title = x$settings$title,
  landscape = FALSE, font_size = 10, font_family = "Arial",
  include_notes = TRUE, overwrite = FALSE)
}
\arguments{
  \item{x}{A \code{nice_table1} object.}
  \item{path}{A .docx filename in an existing directory.}
  \item{title}{Document heading; an empty string omits it.}
  \item{landscape}{Use landscape page orientation.}
  \item{font_size}{Positive font size in points.}
  \item{font_family}{Font family.}
  \item{include_notes}{Include the explanatory table footer.}
  \item{overwrite}{Allow replacing an existing output file. Defaults to FALSE.}
}
\description{Writes the table as editable Word cells using \pkg{officer}
and \pkg{flextable}. Uses automatic table layout and repeating column headings.
For especially wide tables use landscape orientation or a smaller font.}
\value{The normalized output path, invisibly.}
\examples{
d <- example_table1_data()
tab <- nice_SMD_table1(d, "group", "age",
  group_for_SMD = c("Control", "Treatment"))
path <- tempfile(fileext = ".docx")
save_table1_docx(tab, path)
unlink(path)
}
