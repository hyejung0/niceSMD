# Validation status

## Checks completed when this bundle was prepared

* Reviewed the supplied original R function and replaced joins based on printed
  labels with internal variable identifiers.
* Inspected the new R source, declared dependencies, exports, help pages,
  example code, tests, and GitHub workflow.
* Ran static checks for balanced R delimiters/strings, help-page brace balance,
  documented exports, expected package files, and archive integrity.
* Independently checked representative SMD formulas and weight/percentage
  examples using Python calculations. These arithmetic checks validate the
  examples and mathematical expectations, not execution of the R implementation.

## Checks not completed in this environment

R was not installed. Attempts to obtain R and access current upstream
documentation were blocked by network restrictions. Accordingly, none of
the following has been executed here:

* R parsing, package build, installation, or `R CMD check`.
* The included testthat suite or R examples.
* Verification against installed versions of `tableone`, `survey`, `flextable`,
  or `officer`.
* Generating and visually rendering the example Word documents.

This is a complete source starter prepared for validation, not a claim of
passing runtime checks. A static delimiter check is not an R parser. The
included GitHub Actions workflow will perform the R checks after upload.

## Complete validation on your computer

```r
source("tools/configure_package.R")
source("tools/install_local.R")
source("tools/check_package.R")
source("inst/examples/quickstart.R")
```

Open both `.docx` files in `output/` and inspect all pages for legible
headings, repeated headers, correct page breaks, and complete footnotes.
Check the numeric SMD output, especially any `not_estimable` or `infinite`
status, before using the function with study data.

If a dependency API or version causes a failure, the error message and
`sessionInfo()` provide the information needed to address it. Keep this
status file until checks have been run; then record the date and R/dependency
versions used for successful validation.
