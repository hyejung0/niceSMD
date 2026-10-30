# Run from the package root. Internet access is required for missing dependencies.
local({
  if (!file.exists("DESCRIPTION")) stop("Set the working directory to the package root first.")
  if (getRversion() < "4.1.0") stop("R 4.1.0 or later is required.")
  minimum <- c(flextable = "0.9.5", officer = "0.6.0", survey = "4.1", tableone = "0.13.2")
  needed <- names(minimum)[vapply(names(minimum), function(pkg) {
    !requireNamespace(pkg, quietly = TRUE) || utils::packageVersion(pkg) < minimum[[pkg]]
  }, logical(1))]
  if (length(needed)) utils::install.packages(needed, repos = "https://cloud.r-project.org")
  if (!requireNamespace("remotes", quietly = TRUE)) {
    utils::install.packages("remotes", repos = "https://cloud.r-project.org")
  }
  remotes::install_local(".", dependencies = NA, upgrade = "never")
  message("Installed niceSMD. Next: source('inst/examples/quickstart.R')")
})
