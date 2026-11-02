# Format an Editable Table 1

Creates a flextable with bold variable headings, indented detail rows
(category levels, summary statistics, and missing rows), centered group
columns, repeating column headers, and an optional explanatory footer.
Keeps variable headings with their first detail row in Word. The
returned object can be customized further with any flextable function
before being placed in a document.

## Usage

``` r
table1_flextable(x, font_size = 10, font_family = "Arial", include_notes = TRUE)
```

## Arguments

- x:

  A `nice_table1` object returned by
  [`nice_SMD_table1`](https://hyejung0.github.io/niceSMD/reference/nice_SMD_table1.md),
  or a `nice_trial_table1` object returned by
  [`nice_trial_table1`](https://hyejung0.github.io/niceSMD/reference/nice_trial_table1.md).

- font_size:

  A single positive number: the font size in points for the header and
  body. Footnotes use `max(8, font_size - 1)`. Default 10. Reduce it
  (for example 8 or 9) for wide tables with many groups.

- font_family:

  A single character string naming the font, for example `"Arial"` or
  `"Times New Roman"`. The font must be available on the machine that
  opens the document. Default `"Arial"`.

- include_notes:

  `TRUE` (default) or `FALSE`. Whether to add the footnotes stored in
  `x$notes` as a table footer. The footnote content itself is chosen
  with the `notes` argument of
  [`nice_SMD_table1`](https://hyejung0.github.io/niceSMD/reference/nice_SMD_table1.md)
  (`"full"`, `"short"`, `"none"`); if `x$notes` is empty no footer is
  added regardless of this argument.

## Value

A `flextable` object, suitable for customization or inclusion in Word,
HTML, and Quarto/R Markdown documents.

## See also

[`save_table1_docx`](https://hyejung0.github.io/niceSMD/reference/save_table1_docx.md),
[`nice_SMD_table1`](https://hyejung0.github.io/niceSMD/reference/nice_SMD_table1.md),
[`table1_kable`](https://hyejung0.github.io/niceSMD/reference/table1_kable.md)

## Examples

``` r
d <- example_table1_data()
tab <- nice_SMD_table1(d, "group", c("age", "sex", "smoking"),
  group_for_SMD = c("Control", "Treatment"))

## Default table
ft <- table1_flextable(tab)
class(ft)
#> [1] "flextable"

## Smaller font and a different typeface for a wide table
ft_small <- table1_flextable(tab, font_size = 8, font_family = "Times New Roman")

## No footer, for example when notes are written in the manuscript text
ft_plain <- table1_flextable(tab, include_notes = FALSE)

## Compact legend: choose it when the table is built
tab_short <- nice_SMD_table1(d, "group", c("age", "sex", "smoking"),
  group_for_SMD = c("Control", "Treatment"),
  show_missing = "if_any", notes = "short")
ft_short <- table1_flextable(tab_short)

## Further customization with flextable before inserting into a document
ft_custom <- table1_flextable(tab_short, font_size = 9)
ft_custom <- flextable::color(ft_custom, part = "header", color = "#243746")
ft_custom <- flextable::bg(ft_custom, part = "header", bg = "#E8EEF3")

## Insert into an existing Word document
path <- tempfile(fileext = ".docx")
doc <- officer::read_docx()
doc <- flextable::body_add_flextable(doc, value = ft_custom)
print(doc, target = path)
unlink(path)

## In a Quarto chunk, put the flextable last to render it:
##   table1_flextable(tab, font_size = 9)
```
