# Development and testing

## Package files

| Path | Purpose |
|---|---|
| `DESCRIPTION` | Package metadata and dependency versions |
| `NAMESPACE` | Public functions and S3 method registrations |
| `R/` | Table construction, calculations, Word export, example data |
| `man/` | R help pages included in the package |
| `inst/doc/user-guide.md` | Installed usage and statistical guide |
| `inst/examples/quickstart.R` | Complete runnable examples |
| `tests/testthat/` | Numerical, edge-case, and Word structure tests |
| `.github/workflows/` | Linux, Windows, and macOS package checks |
| `tools/` | Local configuration, installation, and checking helpers |

## Check locally

From the package root:

```r
source("tools/check_package.R")
```

This installs development dependencies if needed and calls
`rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "warning")`.
The check runs examples and the test suite. LaTeX is not required.
No CRAN submission is attempted.

For a faster development cycle, with devtools installed:

```r
devtools::load_all()
devtools::test()
devtools::check(args = "--no-manual")
```

Or, after installing the package, check its examples from any folder:

```r
source(system.file("examples", "quickstart.R", package = "niceSMD"))
```

The Word test inspects the generated Open XML package for editable table
cells and repeating headers. A structural check cannot establish visual
page layout; also open the example documents in Word or LibreOffice.

## Documentation maintenance

Help files in `man/` are maintained directly. The short roxygen-style comments
in `R/` are explanatory; there is no roxygen generation step. Do not run
`devtools::document()` expecting it to preserve these complete help pages.
Update both a function's signature and its `.Rd` usage when changing arguments.

## Numerical tests

The tests compare ordinary continuous and binary SMDs with explicit formulas,
multilevel categorical SMDs with a covariance-matrix calculation, weighted
continuous SMDs with survey variances, and weighted categorical SMDs with
weighted proportions. They also cover weight scaling, missing-value
denominators, character variables, numeric categorical overrides, duplicate
labels, punctuation in names, zero weights, missing groups, constants,
insufficient observations, and complex survey/replicate designs.

SMD calculation failures are recorded in the result rather than silently
losing values. Inspect `tab$smd$status` and `tab$smd$reason` in your analysis.

## Local source install without helper scripts

From a terminal in the package root:

```bash
R CMD build .
R CMD INSTALL niceSMD_0.1.0.tar.gz
R CMD check --no-manual niceSMD_0.1.0.tar.gz
```

Install `Imports` and `Suggests` dependencies first. The helper scripts do
that for you. No user data is included in the package; examples are synthetic.
