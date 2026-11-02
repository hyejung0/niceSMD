# Save an Editable Word Table

Writes the table as editable Word cells using officer and flextable.
Uses automatic table layout, 0.7-inch margins, and repeating column
headings. For especially wide tables use landscape orientation or a
smaller font.

## Usage

``` r
save_table1_docx(x, path, title = x$settings$title,
  landscape = FALSE, font_size = 10, font_family = "Arial",
  include_notes = TRUE, overwrite = FALSE)
```

## Arguments

- x:

  A `nice_table1` object returned by
  [`nice_SMD_table1`](https://hyejung0.github.io/niceSMD/reference/nice_SMD_table1.md),
  or a `nice_trial_table1` object returned by
  [`nice_trial_table1`](https://hyejung0.github.io/niceSMD/reference/nice_trial_table1.md).

- path:

  A single filename ending in `.docx`. The directory must already exist.
  An existing file is not replaced unless `overwrite = TRUE`.

- title:

  A single character string used as a “Heading 1” paragraph above the
  table. Defaults to the title given to `nice_SMD_table1`. An empty
  string `""` omits the heading.

- landscape:

  `TRUE` or `FALSE` (default). Use landscape page orientation,
  recommended for tables with many groups or long labels.

- font_size:

  A single positive number: font size in points. Default 10. Footnotes
  use `max(8, font_size - 1)`.

- font_family:

  A single character string naming the font. Default `"Arial"`.

- include_notes:

  `TRUE` (default) or `FALSE`. Include the footnotes stored in
  `x$notes`. Choose their detail level with the `notes` argument of
  [`nice_SMD_table1`](https://hyejung0.github.io/niceSMD/reference/nice_SMD_table1.md).

- overwrite:

  `TRUE` or `FALSE` (default). Whether an existing file at `path` may be
  replaced.

## Value

The normalized output path, invisibly.

## See also

[`table1_flextable`](https://hyejung0.github.io/niceSMD/reference/table1_flextable.md),
[`nice_SMD_table1`](https://hyejung0.github.io/niceSMD/reference/nice_SMD_table1.md)

## Examples

``` r
d <- example_table1_data()
tab <- nice_SMD_table1(d, "group", c("age", "sex"),
  group_for_SMD = c("Control", "Treatment"))
path <- tempfile(fileext = ".docx")

## Default portrait document
save_table1_docx(tab, path)

## Replace an existing file; landscape page, smaller font, different typeface
save_table1_docx(tab, path, overwrite = TRUE, landscape = TRUE,
                 font_size = 9, font_family = "Times New Roman")

## Custom heading, or no heading at all
save_table1_docx(tab, path, overwrite = TRUE,
                 title = "Table 1. Baseline characteristics")
save_table1_docx(tab, path, overwrite = TRUE, title = "")

## Without footnotes ...
save_table1_docx(tab, path, overwrite = TRUE, include_notes = FALSE)

## ... or with a short legend, hiding Missing rows that are always zero
tab_short <- nice_SMD_table1(d, "group", c("age", "stratum"),
  group_for_SMD = c("Control", "Treatment"),
  show_missing = "if_any", notes = "short")
save_table1_docx(tab_short, path, overwrite = TRUE, landscape = TRUE)

## The path is returned invisibly
out <- save_table1_docx(tab, path, overwrite = TRUE)
basename(out) == basename(path)
#> [1] TRUE
unlink(path)
```
