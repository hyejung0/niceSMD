#' @export
print.nice_table1 <- function(x, ...) {
  cat(x$settings$title, "\n\n", sep = "")
  tab <- x$table
  is_var <- x$row_info$type == "variable"
  tab[[1L]] <- ifelse(is_var, tab[[1L]], paste0("    ", tab[[1L]]))
  print(tab, row.names = FALSE, right = FALSE, ...)
  cat("\n", paste(x$notes, collapse = "\n"), "\n", sep = "")
  invisible(x)
}

#' @export
as.data.frame.nice_table1 <- function(x, row.names = NULL, optional = FALSE, ...) {
  out <- x$table
  if (!is.null(row.names)) rownames(out) <- row.names
  out
}

#' @export
print.nice_trial_table1 <- function(x, ...) {
  cat(x$settings$title, "\n\n", sep = "")
  tab <- x$table
  if (x$settings$layout == "wide") {
    is_var <- x$row_info$type == "variable"
    tab[[1L]] <- ifelse(is_var, tab[[1L]], paste0("    ", tab[[1L]]))
  }
  print(tab, row.names = FALSE, right = FALSE, ...)
  if (length(x$notes)) cat("\n", paste(x$notes, collapse = "\n"), "\n", sep = "")
  invisible(x)
}

#' @export
as.data.frame.nice_trial_table1 <- function(x, row.names = NULL, optional = FALSE, ...) {
  out <- x$table
  if (!is.null(row.names)) rownames(out) <- row.names
  out
}
