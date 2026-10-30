# Run with source("tools/configure_package.R") from the package root.
# This edits local package metadata only; it never connects to GitHub.
local({
  if (!interactive()) stop("Run this configuration script in an interactive R console.")
  if (!file.exists("DESCRIPTION") || !dir.exists("R")) {
    stop("Set the working directory to the package root first.")
  }
  ask <- function(prompt, default = "") {
    response <- trimws(readline(paste0(prompt, if (nzchar(default)) paste0(" [", default, "]") else "", ": ")))
    if (nzchar(response)) response else default
  }
  first <- ask("Author given name", "Hyejung")
  last <- ask("Author family name", "Lee")
  email <- ask("Author contact email (or your GitHub noreply email)")
  username <- ask("GitHub username")
  repository <- ask("GitHub repository name", "niceSMD")
  if (!grepl("^[^[:space:]@]+@[^[:space:]@]+\\.[^[:space:]@]+$", email)) {
    stop("Enter a valid contact email; no files were changed.")
  }
  if (!grepl("^[A-Za-z0-9][A-Za-z0-9-]*$", username) ||
      !grepl("^[A-Za-z0-9_.-]+$", repository) || !nzchar(first) || !nzchar(last)) {
    stop("Check the author name, GitHub username, and repository name; no files were changed.")
  }
  quote_r <- function(x) paste(deparse(x), collapse = "")
  description <- read.dcf("DESCRIPTION")
  description[1L, "Authors@R"] <- paste0("person(", quote_r(first), ", ", quote_r(last),
    ", role = c(\"aut\", \"cre\"), email = ", quote_r(email), ")")
  url <- paste0("https://github.com/", username, "/", repository)
  for (field in c("URL", "BugReports")) {
    if (!field %in% colnames(description)) {
      extra <- matrix("", nrow = 1L, ncol = 1L, dimnames = list(NULL, field))
      description <- cbind(description, extra)
    }
  }
  description[1L, "URL"] <- url
  description[1L, "BugReports"] <- paste0(url, "/issues")
  write.dcf(description, file = "DESCRIPTION", width = 80)
  markdown <- list.files(".", pattern = "\\.md$", recursive = TRUE, full.names = TRUE)
  for (file in markdown) {
    lines <- readLines(file, warn = FALSE)
    lines <- gsub("YOUR_GITHUB_USERNAME/niceSMD", paste0(username, "/", repository),
                  lines, fixed = TRUE)
    lines <- gsub("Hyejung Lee", paste(first, last), lines, fixed = TRUE)
    writeLines(lines, file, useBytes = TRUE)
  }
  license <- readLines("LICENSE", warn = FALSE)
  license <- sub("^COPYRIGHT HOLDER:.*$", paste0("COPYRIGHT HOLDER: ", first, " ", last), license)
  writeLines(license, "LICENSE", useBytes = TRUE)
  message("Configured local metadata for ", username, "/", repository, ". Nothing was published.")
})
