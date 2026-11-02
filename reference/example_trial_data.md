# Synthetic Multi-Trial Data for Examples

Returns fixed synthetic individual participant data from three trials:
Trial A and Trial B have two arms (Placebo, Active) and Trial C has
three (Placebo, Active, High dose). Includes continuous, factor, and
character covariates, missing values, a CKD stage category that is not
observed in Trial A, and positive analysis weights. The function takes
no arguments and does not alter the random-number generator state.

## Usage

``` r
example_trial_data()
```

## Value

A data.frame with 180 rows and the columns `trial` (factor), `arm`
(factor), `age` and `egfr` (continuous, with missing values), `sex`
(factor), `diabetes` and `ckd_stage` (character), and `weight`.

## See also

[`nice_trial_table1`](https://hyejung0.github.io/niceSMD/reference/nice_trial_table1.md)

## Examples

``` r
d <- example_trial_data()
table(d$trial, d$arm)
#>          
#>           Placebo Active High dose
#>   Trial A      30     30         0
#>   Trial B      24     24         0
#>   Trial C      24     24        24
colSums(is.na(d))
#>     trial       arm       age      egfr       sex  diabetes ckd_stage    weight 
#>         0         0         3         2         0         0         0         0 
```
