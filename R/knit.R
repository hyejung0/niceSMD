# Rendering inside knitr / Quarto -------------------------------------------
# Without a knit_print method, a bare `tab` in a qmd chunk falls back to
# print.nice_table1(), i.e. plain console text. This method makes `tab` render
# as a formatted table in HTML, Word and PDF output.

#' Render a nice_table1 object in knitr / Quarto documents
#'
#' Registered automatically when knitr is available. Placing `tab` as the last
#' expression of a chunk renders the formatted table (bold variable names,
#' indented levels, notes as footnotes).
#' @param x A `nice_table1` object.
#' @param ... Passed to the underlying renderer.
#' @param options Chunk options supplied by knitr.
#' @noRd
knit_print.nice_table1 <- function(x, ..., options = NULL) {
  fmt <- if (requireNamespace("knitr", quietly = TRUE)) {
    knitr::opts_knit$get("rmarkdown.pandoc.to")
  } else NULL
  fmt <- if (is.null(fmt)) "" else fmt

  # flextable handles html and docx natively and pdf through LaTeX.
  ft <- table1_flextable(x, font_size = .nice_default_size(fmt))
  knitr::knit_print(ft, ...)
}

.nice_default_size <- function(fmt) {
  if (grepl("latex|pdf", fmt)) 8 else 10
}

#' Lightweight kable version (no flextable), useful for PDF without fonts
#'
#' Variable names are bold and levels are indented with non-breaking spaces.
#' @param x A `nice_table1` object.
#' @param format Passed to `knitr::kable()`; default picks from the document.
#' @export
table1_kable <- function(x, format = NULL) {
  if (!inherits(x, "nice_table1")) stop("x must be a nice_table1 object.", call. = FALSE)
  if (!is.null(format) && (!is.character(format) || length(format) != 1L || is.na(format))) {
    stop("format must be NULL or one character string.", call. = FALSE)
  }
  tab <- x$table
  is_var <- x$row_info$type == "variable"
  kind <- if (is.null(format)) "markdown" else format
  indent <- if (kind == "latex") "\\hspace{1em}" else "&nbsp;&nbsp;&nbsp;&nbsp;"
  first <- as.character(tab[[1L]])
  first[is_var] <- switch(kind,
    latex = paste0("\\textbf{", first[is_var], "}"),
    html = paste0("<strong>", first[is_var], "</strong>"),
    paste0("**", first[is_var], "**"))
  first[!is_var] <- paste0(indent, first[!is_var])
  tab[[1L]] <- first
  names(tab) <- gsub("\n", " ", names(tab), fixed = TRUE)
  knitr::kable(tab, format = format, escape = FALSE, row.names = FALSE,
               align = c("l", rep("c", ncol(tab) - 1L)))
}

# Same rendering path as nice_table1: table1_flextable() dispatches on class.
knit_print.nice_trial_table1 <- knit_print.nice_table1
