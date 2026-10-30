\name{nice_table1-methods}
\alias{print.nice_table1}
\alias{as.data.frame.nice_table1}
\alias{knit_print.nice_table1}
\alias{nice_table1-methods}
\alias{print.nice_trial_table1}
\alias{as.data.frame.nice_trial_table1}
\alias{knit_print.nice_trial_table1}
\title{Print, Render, and Extract Table 1 Data}
\usage{
\method{print}{nice_table1}(x, ...)
\method{as.data.frame}{nice_table1}(x, row.names = NULL, optional = FALSE, ...)
\method{print}{nice_trial_table1}(x, ...)
\method{as.data.frame}{nice_trial_table1}(x, row.names = NULL, optional = FALSE, ...)
knit_print.nice_table1(x, ..., options = NULL)
knit_print.nice_trial_table1(x, ..., options = NULL)
}
\arguments{
  \item{x}{A \code{nice_table1} object returned by \code{\link{nice_SMD_table1}}, or a
  \code{nice_trial_table1} object returned by \code{\link{nice_trial_table1}}.}
  \item{...}{For \code{print}, additional arguments passed to data.frame
  printing. For \code{knit_print}, passed to the underlying renderer. Unused by
  \code{as.data.frame}.}
  \item{row.names}{Optional replacement row names for the extracted data.frame.
  \code{NULL} (default) uses sequential row names.}
  \item{optional}{Accepted for compatibility with the generic; unused.}
  \item{options}{Chunk options supplied automatically by \pkg{knitr}; not
  intended to be set by hand.}
}
\description{\code{print} shows the title, the formatted table (variable names
flush left, category levels indented), and the notes in the console.
\code{as.data.frame} extracts the display data.frame. \code{knit_print} is used
automatically by \pkg{knitr}, so that placing \code{tab} as the last expression
of a Quarto or R Markdown chunk renders the formatted table (bold variable
names, indented levels, footnotes) in HTML, Word, and PDF output. The
\code{knit_print} method is registered when \pkg{knitr} is installed.}
\value{\code{print} returns \code{x} invisibly. \code{as.data.frame} returns
\code{x$table}. \code{knit_print} returns knitr-ready output.}
\examples{
d <- example_table1_data()
tab <- nice_SMD_table1(d, "group", c("age", "sex"),
  group_for_SMD = c("Control", "Treatment"), notes = "short")

print(tab)                       # console view
df <- as.data.frame(tab)         # plain data.frame
head(df, 3)
as.data.frame(tab, row.names = seq_len(nrow(tab$table)))[1:2, 1:2]

## In a .qmd or .Rmd file, a chunk that ends with `tab` renders the
## formatted table automatically:
##   ```{r}
##   tab
##   ```
## To control size or fonts, end the chunk with:
##   table1_flextable(tab, font_size = 9)
}
