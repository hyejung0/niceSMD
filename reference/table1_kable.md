# Lightweight Table 1 for Quarto and R Markdown

Returns a [`knitr::kable`](https://rdrr.io/pkg/knitr/man/kable.html)
table with bold variable names and indented category levels, summaries,
and missing rows. It needs only knitr, so it is a robust alternative to
[`table1_flextable`](https://hyejung0.github.io/niceSMD/reference/table1_flextable.md)
when PDF output has font or LaTeX problems. Footnotes are not included;
print them separately with `cat(x$notes, sep = "\n")`.

## Usage

``` r
table1_kable(x, format = NULL)
```

## Arguments

- x:

  A `nice_table1` object returned by
  [`nice_SMD_table1`](https://hyejung0.github.io/niceSMD/reference/nice_SMD_table1.md).

- format:

  Output format passed to
  [`knitr::kable()`](https://rdrr.io/pkg/knitr/man/kable.html): `NULL`
  (default, chosen from the document), `"html"`, `"latex"`,
  `"markdown"`, or `"pipe"`. With `"latex"`, variable names use
  `\textbf{}` and levels are indented with `\hspace{1em}`; other formats
  use Markdown bold and non-breaking spaces.

## Value

A `knitr_kable` object.

## See also

[`table1_flextable`](https://hyejung0.github.io/niceSMD/reference/table1_flextable.md),
[`nice_table1-methods`](https://hyejung0.github.io/niceSMD/reference/nice_table1-methods.md)

## Examples

``` r
if (requireNamespace("knitr", quietly = TRUE)) {
  d <- example_table1_data()
  tab <- nice_SMD_table1(d, "group", c("age", "sex"),
    group_for_SMD = c("Control", "Treatment"), notes = "short")

  ## Markdown (default outside a document)
  table1_kable(tab, format = "markdown")

  ## HTML and LaTeX targets
  table1_kable(tab, format = "html")
  table1_kable(tab, format = "latex")

  ## Print the notes below the table
  cat(tab$notes, sep = "\n")
}
#> Categorical variables: n (%) among nonmissing values. Continuous variables: mean (SD) and median (Q1, Q3). Missing: n (% of group).
#> SMD = absolute standardized mean difference (Control vs. Treatment); NE = not estimable.
```
