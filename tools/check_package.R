# Full package checks, including examples and the testthat suite.
local({
  if (!file.exists("DESCRIPTION")) stop("Set the working directory to the package root first.")
  required <- c("remotes", "rcmdcheck", "testthat")
  absent <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
  if (length(absent)) utils::install.packages(absent, repos = "https://cloud.r-project.org")
  remotes::install_deps(dependencies = TRUE, upgrade = "never")
  rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "warning")
})
