#' @export
print.nice_table1 <- function(x, ...) {
  cat(x$settings$title, "\n\n", sep = "")
  print(x$table, row.names = FALSE, ...)
  cat("\n", paste(x$notes, collapse = "\n"), "\n", sep = "")
  invisible(x)
}

#' @export
as.data.frame.nice_table1 <- function(x, row.names = NULL, optional = FALSE, ...) {
  out <- x$table
  if (!is.null(row.names)) rownames(out) <- row.names
  out
}
