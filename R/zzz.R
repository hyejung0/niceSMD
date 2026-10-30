.onLoad <- function(libname, pkgname) {
  # Register the knitr method without making knitr a hard dependency.
  if (requireNamespace("knitr", quietly = TRUE)) {
    registerS3method("knit_print", "nice_table1", knit_print.nice_table1,
                    envir = asNamespace("knitr"))
    registerS3method("knit_print", "nice_trial_table1", knit_print.nice_trial_table1,
                    envir = asNamespace("knitr"))
  }
}
