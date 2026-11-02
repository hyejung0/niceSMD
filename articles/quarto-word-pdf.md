# Quarto, R Markdown, Word and PDF output

``` r

library(niceSMD)
d <- example_table1_data()
tab <- nice_SMD_table1(
  d, "group", c("age", "sex", "smoking"),
  group_for_SMD = c("Control", "Treatment"), notes = "short"
)
```

## In a Quarto or R Markdown document

Put the object as the **last expression** of a chunk:

``` r

# inside a .qmd or .Rmd code chunk
tab
```

niceSMD registers a `knit_print` method, so `tab` is rendered as a
formatted table (bold variable names, indented levels, footnotes) in
HTML, Word, and PDF output. Printing it at the console gives a
plain-text version with the same structure. The table below is rendered
that way:

``` r

tab
```

[TABLE]

If you assign the result (`tab <- nice_SMD_table1(...)`) the chunk
prints nothing; end the chunk with `tab` to display it.
[`nice_trial_table1()`](https://hyejung0.github.io/niceSMD/reference/nice_trial_table1.md)
results render the same way.

## Controlling size and fonts

For a different font or size, end the chunk with the flextable instead:

``` r

table1_flextable(tab, font_size = 9, font_family = "Arial")
```

[TABLE]

Wide tables (many groups, or trial tables) read better in a smaller font
or, in Word, a landscape section.

## Further styling with flextable

[`table1_flextable()`](https://hyejung0.github.io/niceSMD/reference/table1_flextable.md)
returns an ordinary `flextable`, so any flextable function applies:

``` r

ft <- table1_flextable(tab)
ft <- flextable::bg(ft, part = "header", bg = "#EAF0F4")
ft <- flextable::color(ft, part = "header", color = "#243746")
ft
```

[TABLE]

## Word files

``` r

# Standalone Word file
save_table1_docx(tab, "Table1.docx", landscape = TRUE, font_size = 9)

# Or write while building the table
nice_SMD_table1(d, "group", "age", group_for_SMD = c("Control", "Treatment"),
                docx_path = "Table1.docx")

# Export a flextable you modified yourself
flextable::save_as_docx(`Participant characteristics` = ft, path = "Custom.docx")
```

[`save_table1_docx()`](https://hyejung0.github.io/niceSMD/reference/save_table1_docx.md)
never overwrites an existing file unless you set `overwrite = TRUE`.
Headers repeat on each page, and a variable’s name stays with its first
row.

## PDF output

Table rendering to PDF goes through LaTeX. If flextable’s PDF output has
font or package problems on your machine,
[`table1_kable()`](https://hyejung0.github.io/niceSMD/reference/table1_kable.md)
is a lighter alternative that needs only knitr:

``` r

table1_kable(tab)                    # chunk ending: renders in the document format
table1_kable(tab, format = "latex")  # force LaTeX
cat(tab$notes, sep = "\n")           # footnotes are printed separately
```

## Extracting numbers

``` r

as.data.frame(tab)[1:3, ]            # the display table
#>          Variable        Control\nN = 30       Treatment\nN = 30
#> 1             age                                               
#> 2       Mean (SD)         147.28 (60.78)          358.55 (61.66)
#> 3 Median (Q1, Q3) 148.00 (99.00, 197.00) 360.00 (311.00, 409.00)
#>          Registry\nN = 30 SMD (Control vs. Treatment)
#> 1                                               3.451
#> 2          570.07 (62.10)                            
#> 3 572.00 (516.00, 621.00)
tab$smd[, c("label", "smd", "status")]  # unrounded SMDs
#>     label        smd status
#> 1     age 3.45103284     ok
#> 2     sex 0.00000000     ok
#> 3 smoking 0.09313035     ok
```
