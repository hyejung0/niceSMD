# Publish the package on GitHub

You do not need a CRAN submission, a package website, or a compiled binary.
GitHub can host the package source, and `remotes::install_github()` builds
and installs it on your computer.

## Prepare the folder once

1. Extract the ZIP. The folder containing `DESCRIPTION`, `NAMESPACE`, and `R/`
   is the package root.
2. Open `niceSMD.Rproj` in RStudio.
3. Run the following from that folder:

```r
source("tools/configure_package.R")
source("tools/install_local.R")
source("inst/examples/quickstart.R")
source("tools/check_package.R")
```

The configuration script asks for your author name, email, GitHub username,
and desired repository name. It replaces the clearly marked author email
and installation placeholders and adds the repository URLs to `DESCRIPTION`.
It does not connect to GitHub or publish files.

The placeholder email is syntactically valid so the starter has complete
package metadata, but replace it with your chosen contact address before
publishing. Your GitHub-provided noreply email is also an option.

Confirm that the example Word files open correctly and that the checks pass
before relying on the package for an analysis. `VALIDATION.md` explains the
checks that could not be run when this ZIP was prepared.

## Option A Upload through the GitHub website

1. Sign in to [GitHub](https://github.com/).
2. Create a repository named `niceSMD`, or the name chosen during configuration.
3. Choose public or private visibility. Do not initialize it with a README,
   license, or `.gitignore`; these files are already in the package folder.
4. Choose **uploading an existing file** or **Add file > Upload files**.
5. Upload the **contents** of the package folder. `DESCRIPTION` must appear at
   the repository root, not inside an extra `niceSMD/` directory. Uploading
   just the ZIP will not make the repository installable as an R package.
6. Include `.github/workflows/R-CMD-check.yaml` if the browser's upload dialog
   omits hidden folders. You can create it with **Add file > Create new file**,
   type that exact path, and paste in the supplied YAML contents.
7. Commit the files. Check the **Actions** tab for the R package check results.

The `.gitignore`, `.Rbuildignore`, and `.github` entries begin with a dot.
On macOS, Command + Shift + Period shows them in Finder. On Windows, enable
hidden items in File Explorer. The Git method below includes them automatically.

Do not upload the generated `output/` folder or personal datasets.

## Option B Push with Git

Create the empty repository first. Then open a terminal **in the package root**:

```bash
git init
git add .
git commit -m "Add initial niceSMD package"
git branch -M main
git remote add origin https://github.com/hyejung0/niceSMD.git
git push -u origin main
```

Use your actual repository URL if its name differs. Authenticate with GitHub's
normal browser, credential-manager, or SSH flow. Do not put a token in the
remote URL or commit it to any file. If `git commit` requests your identity,
configure your local Git author name and email first.

The supplied workflow has read-only repository permissions. It installs
dependencies and runs `R CMD check`, examples, and tests on current R releases
for Linux, Windows, and macOS. It does not publish a release or modify code.
Workflow files may need enabling in the repository's Actions settings.

## Install from your repository

```r
install.packages("remotes")
remotes::install_github("hyejung0/niceSMD")
library(niceSMD)
```

For a private repository, provide an appropriate GitHub token through your
normal environment or credential manager. `remotes` reads `GITHUB_PAT`:

```r
# Check whether a token is available without printing its contents:
nzchar(Sys.getenv("GITHUB_PAT"))
remotes::install_github("hyejung0/niceSMD")
```

Never place a real token in the repository, README, scripts, or shared output.

## Release versions and later updates

The first version is `0.1.0`. After checks pass, you may create a GitHub release
with tag `v0.1.0`. A tag lets you reinstall the same source version later:

```r
remotes::install_github("hyejung0/niceSMD@v0.1.0")
```

When updating, edit the code and relevant tests/help, increase `Version` in
`DESCRIPTION`, update `NEWS.md`, rerun checks, and commit/push. Install the
updated main branch with `remotes::install_github(..., force = TRUE)`.
Restart R before reinstalling if a loaded package cannot be replaced.

No GitHub account is connected and nothing is published merely by extracting
or running the package examples.
