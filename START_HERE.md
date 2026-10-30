# Start here

This folder is a complete R package named **niceSMD**. It creates Table 1 for
unweighted or weighted data and saves an editable Word table. It also contains
help pages, examples, tests, and automated GitHub checks.

The ZIP contains package source. Extract it first; it is not a precompiled
Windows package for direct installation with `install.packages(zip_file)`.

1. Extract the ZIP and open `niceSMD.Rproj` in RStudio.
2. Run `source("tools/configure_package.R")` in the R console. Enter your email
   and GitHub username when prompted. Your name defaults to Hyejung Lee.
   This updates package metadata; it does not upload or publish anything.
3. Run `source("tools/install_local.R")`. This installs dependencies, builds,
   and installs the package from this folder.
4. Run `source("inst/examples/quickstart.R")`. This creates unweighted and
   weighted Word examples in `output/`, and a CSV of numeric SMDs.
5. Follow [GITHUB_SETUP.md](GITHUB_SETUP.md) to upload the folder contents to
   your GitHub repository. The package files must be at the repository root.

After publishing, install on another computer with:

```r
install.packages("remotes")
remotes::install_github("hyejung0/niceSMD")
```

Read [README.md](README.md) for routine use and
[inst/doc/user-guide.md](inst/doc/user-guide.md) for statistical conventions,
survey designs, customization, and migration from the original function.

**Validation status:** this package was assembled and statically inspected in
an environment without R. R tests, `R CMD check`, and Word rendering have not
been run here. [VALIDATION.md](VALIDATION.md) describes what was checked and
how to run the remaining checks locally or on GitHub. Do not interpret the
included workflow as evidence that those checks have already passed.
