# Print, Render, and Extract Table 1 Data

`print` shows the title, the formatted table (variable names flush left,
category levels indented), and the notes in the console. `as.data.frame`
extracts the display data.frame. `knit_print` is used automatically by
knitr, so that placing `tab` as the last expression of a Quarto or R
Markdown chunk renders the formatted table (bold variable names,
indented levels, footnotes) in HTML, Word, and PDF output. The
`knit_print` method is registered when knitr is installed.

## Usage

``` r
# S3 method for class 'nice_table1'
print(x, ...)
# S3 method for class 'nice_table1'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)
# S3 method for class 'nice_trial_table1'
print(x, ...)
# S3 method for class 'nice_trial_table1'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)
knit_print.nice_table1(x, ..., options = NULL)
knit_print.nice_trial_table1(x, ..., options = NULL)
```

## Arguments

- x:

  A `nice_table1` object returned by
  [`nice_SMD_table1`](https://hyejung0.github.io/niceSMD/reference/nice_SMD_table1.md),
  or a `nice_trial_table1` object returned by
  [`nice_trial_table1`](https://hyejung0.github.io/niceSMD/reference/nice_trial_table1.md).

- ...:

  For `print`, additional arguments passed to data.frame printing. For
  `knit_print`, passed to the underlying renderer. Unused by
  `as.data.frame`.

- row.names:

  Optional replacement row names for the extracted data.frame. `NULL`
  (default) uses sequential row names.

- optional:

  Accepted for compatibility with the generic; unused.

- options:

  Chunk options supplied automatically by knitr; not intended to be set
  by hand.

## Value

`print` returns `x` invisibly. `as.data.frame` returns `x$table`.
`knit_print` returns knitr-ready output.

## Examples

``` r
d <- example_table1_data()
tab <- nice_SMD_table1(d, "group", c("age", "sex"),
  group_for_SMD = c("Control", "Treatment"), notes = "short")

print(tab)                       # console view
#> Table 1
#> 
#>  Variable            Control\nN = 30        Treatment\nN = 30      
#>  age                                                               
#>      Mean (SD)       147.28 (60.78)         358.55 (61.66)         
#>      Median (Q1, Q3) 148.00 (99.00, 197.00) 360.00 (311.00, 409.00)
#>      Missing         1 (3.3%)               1 (3.3%)               
#>  sex                                                               
#>      Female          17 (58.6%)             17 (58.6%)             
#>      Male            12 (41.4%)             12 (41.4%)             
#>      Missing         1 (3.3%)               1 (3.3%)               
#>  Registry\nN = 30        SMD (Control vs. Treatment)
#>                          3.451                      
#>  570.07 (62.10)                                     
#>  572.00 (516.00, 621.00)                            
#>  1 (3.3%)                                           
#>                          0.000                      
#>  17 (58.6%)                                         
#>  12 (41.4%)                                         
#>  1 (3.3%)                                           
#> 
#> Categorical variables: n (%) among nonmissing values. Continuous variables: mean (SD) and median (Q1, Q3). Missing: n (% of group).
#> SMD = absolute standardized mean difference (Control vs. Treatment); NE = not estimable.
df <- as.data.frame(tab)         # plain data.frame
head(df, 3)
#>          Variable        Control\nN = 30       Treatment\nN = 30
#> 1             age                                               
#> 2       Mean (SD)         147.28 (60.78)          358.55 (61.66)
#> 3 Median (Q1, Q3) 148.00 (99.00, 197.00) 360.00 (311.00, 409.00)
#>          Registry\nN = 30 SMD (Control vs. Treatment)
#> 1                                               3.451
#> 2          570.07 (62.10)                            
#> 3 572.00 (516.00, 621.00)                            
as.data.frame(tab, row.names = seq_len(nrow(tab$table)))[1:2, 1:2]
#>    Variable Control\nN = 30
#> 1       age                
#> 2 Mean (SD)  147.28 (60.78)

## In a .qmd or .Rmd file, a chunk that ends with `tab` renders the
## formatted table automatically:
##   ```{r}
##   tab
##   ```
## To control size or fonts, end the chunk with:
##   table1_flextable(tab, font_size = 9)
```
