\name{nice_table1-methods}
\alias{print.nice_table1}
\alias{as.data.frame.nice_table1}
\title{Print and Extract Table 1 Data}
\usage{
\method{print}{nice_table1}(x, ...)
\method{as.data.frame}{nice_table1}(x, row.names = NULL, optional = FALSE, ...)
}
\arguments{
  \item{x}{A \code{nice_table1} object.}
  \item{...}{Additional arguments passed to data.frame printing; unused by extraction.}
  \item{row.names}{Optional replacement row names.}
  \item{optional}{Accepted for compatibility with the generic; unused.}
}
\description{Prints the formatted table and notes, or extracts its display
data.frame. Printing is intended for console inspection. Use
\code{x$flextable} to display the styled table in a document.}
\value{Printing returns \code{x} invisibly. Extraction returns \code{x$table}.}
