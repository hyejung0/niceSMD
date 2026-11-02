# Synthetic Data for Table 1 Examples

Returns fixed synthetic observations with continuous, factor, character,
and numeric-coded categorical covariates, missing values, three groups
(Control, Treatment, Registry), nonconstant analysis weights, and
survey-design identifiers. The function takes no arguments and does not
alter the random-number generator state, so results are identical on
every call.

## Usage

``` r
example_table1_data()
```

## Value

A data.frame with 90 rows and the columns `group` (factor), `age`, `bmi`
(continuous, with missing values), `sex` (factor, with missing values),
`smoking` (character, with missing values), `stage_code` (numeric codes
1 to 3, with missing values), `analysis_weight` (positive weights),
`stratum` (North/South, no missing values), and `cluster` (unique
identifier per row).

## Examples

``` r
d <- example_table1_data()
head(d)
#>     group age  bmi    sex smoking stage_code analysis_weight stratum cluster
#> 1 Control  43 20.3 Female   Never          1             1.6   North       1
#> 2 Control  50 21.6   Male    <NA>          1             2.7   South       2
#> 3 Control  57 22.9   <NA> Current          2             3.8   North       3
#> 4 Control  NA 24.2   Male   Never          3             4.9   South       4
#> 5 Control  71 25.5 Female  Former         NA             6.0   North       5
#> 6 Control  78 26.8 Female   Never          3             7.1   South       6
table(d$group)
#> 
#>   Control Treatment  Registry 
#>        30        30        30 
colSums(is.na(d))   # which columns contain missing values
#>           group             age             bmi             sex         smoking 
#>               0               3               4               3               3 
#>      stage_code analysis_weight         stratum         cluster 
#>               3               0               0               0 
```
