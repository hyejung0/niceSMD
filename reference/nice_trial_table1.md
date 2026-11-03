# Descriptive Tables by Trial and Treatment Arm

Builds descriptive summaries separately for each trial and treatment arm
from pooled individual participant data, as used in multi-trial analyses
such as trial-level surrogate endpoint studies. Each trial is summarized
with
[`nice_SMD_table1`](https://hyejung0.github.io/niceSMD/reference/nice_SMD_table1.md),
so all conventions (denominators, missing values, weighting, SMDs) are
identical; this function arranges the per-trial results into one table
with a common set of rows. The result prints in the console, renders in
Quarto and R Markdown, and exports to Word. Summaries can also be
requested by trial only (`treatment = NULL`) and with a pooled overall
column or row (`overall = TRUE`), neither of which involves an SMD.

## Usage

``` r
nice_trial_table1(
  dat, trial, treatment = NULL, covar_names = NULL, print_covariate_names = NULL,
  treatment_for_SMD = NULL, treatment_order = NULL, trial_order = NULL,
  layout = "wide", show_smd = TRUE, continuous_stats = "both",
  catDigits = 1, contDigits = 2, smdDigits = 3, categorical_vars = NULL,
  weights = NULL, weightDigits = 1, show_missing = "if_any",
  title = "Table 1 by trial and treatment", docx_path = NULL,
  notes = "full", overall = FALSE, overall_label = "Overall"
)
```

## Arguments

- dat:

  A data.frame, tibble, or data.table with one row per participant
  (individual participant data), containing the trial identifier, the
  treatment arm, the covariates, and optionally a weight column. Column
  names must be unique and nonempty.

- trial:

  The trial identifier, given as a single column name in `dat` (for
  example `"trial"`) or as a vector of length `nrow(dat)`. Factors keep
  their level order for the display; other types use order of first
  appearance (override with `trial_order`). Rows with a missing trial
  are excluded with a warning.

- treatment:

  The treatment arm, given as a single column name or a vector of length
  `nrow(dat)`. Arms may differ between trials (for example a third arm
  in one trial). Rows with a missing treatment are excluded with a
  warning. Trials with fewer than two arms are omitted with a warning.
  `NULL` (the default) requests **summaries by trial only**: one column
  (wide layout) or one row (long layout) per trial, with no arms and no
  SMD. `treatment_for_SMD` and `treatment_order` then must not be
  supplied.

- covar_names:

  Character vector of columns to summarize, in display order. Defaults
  to all columns other than the trial, treatment, and weight columns
  named by string. Select covariates explicitly when `trial`,
  `treatment`, or `weights` are supplied as external vectors.

- print_covariate_names:

  Display labels, either an unnamed character vector with one label per
  entry of `covar_names` or a named vector named by all covariate names
  (any order). Defaults to the column names.

- treatment_for_SMD:

  Character vector of length two naming the two arms whose SMD is
  reported within each trial, for example `c("Placebo", "Active")`.
  Defaults to the two arms of each trial when every trial has exactly
  two arms; required if any trial has more than two. If a trial lacks
  one of the named arms, its SMD is shown as an em dash and recorded as
  not estimable in `smd`.

- treatment_order:

  Character vector listing every included treatment exactly once, giving
  the left-to-right (or top-to-bottom) order of arms within each trial.
  Defaults to factor level order or order of first appearance. A trial
  shows only the arms it contains.

- trial_order:

  Character vector listing every included trial exactly once, giving the
  order of trials. Defaults to factor level order or order of first
  appearance. Use it, for example, to order trials by year or sample
  size.

- layout:

  `"wide"` (default) or `"long"`.

  - `"wide"`: rows are variables (names bold, levels indented) and
    columns are trial blocks, each with one column per arm and
    optionally an SMD column, under a header spanning the trial name.
    Best for a few trials.

  - `"long"`: rows are trial-by-arm combinations (with the arm size N
    and, for weighted tables, the sum of weights) and columns are
    variables; categorical variables get one column per level. This is
    the usual layout for many trials. SMDs are not shown in this layout;
    use `x$smd`.

- show_smd:

  `TRUE` (default) or `FALSE`. Whether the wide layout includes a
  within-trial SMD column. Within a randomized trial baseline
  differences are chance imbalances, so many authors omit them; SMDs
  remain available in `x$smd`. Ignored for `layout = "long"`.

- continuous_stats:

  Which continuous summaries to display: `"both"` (default) for mean
  (SD) and median (Q1, Q3), `"mean_sd"`, or `"median_iqr"`. Display
  only; SMDs always use means and SDs. Using one statistic roughly
  halves the number of columns in the long layout.

- catDigits:

  Integer 0 to 10. Decimal places for percentages. Default 1.

- contDigits:

  Integer 0 to 10. Decimal places for means, SDs, medians, and
  quartiles. Default 2.

- smdDigits:

  Integer 0 to 10. Decimal places for displayed SMDs. Default 3. Numeric
  SMDs in `x$smd` are not rounded.

- categorical_vars:

  Optional character vector of covariates to treat as categorical, for
  example numeric stage codes. Factors, characters, and logicals are
  categorical automatically.

- weights:

  Optional analysis weights, as a numeric column name or a numeric
  vector of length `nrow(dat)`. Must be finite and nonnegative; rows
  with zero weight are excluded with a warning. Weights are applied
  within each trial and arm exactly as supplied. Survey design objects
  are not supported; use
  [`nice_SMD_table1`](https://hyejung0.github.io/niceSMD/reference/nice_SMD_table1.md)
  for each trial in that case.

- weightDigits:

  Integer 0 to 10. Decimal places for weighted counts and sums of
  weights. Default 1.

- show_missing:

  Controls Missing rows: `TRUE`/`"always"`, `FALSE`/`"never"`, or
  `"if_any"` (default here). With `"if_any"` a variable gets a Missing
  row if any trial has a missing value for it; trials with none show
  `0 (0.0%)`. See
  [`nice_SMD_table1`](https://hyejung0.github.io/niceSMD/reference/nice_SMD_table1.md).

- title:

  Heading used when printing and in the Word document. Default
  `"Table 1 by trial and treatment"`. Use `""` to omit it.

- docx_path:

  Optional new `.docx` filename. The table is written in landscape
  orientation; an existing file is never overwritten. For other options
  use
  [`save_table1_docx`](https://hyejung0.github.io/niceSMD/reference/save_table1_docx.md).

- notes:

  Footnote style: `"full"` (default), `"short"`, or `"none"`. The short
  legend gives the cell layout, the SMD definition and the compared
  pair, `NE`, and lines for excluded rows, hidden Missing rows, omitted
  trials, or em dashes when applicable.

- overall:

  `TRUE` or `FALSE` (default). Adds a pooled summary of every included
  participant from the displayed trials, ignoring trial and arm, as a
  last block (wide layout: a column headed `overall_label`; long layout:
  a final row with Treatment “All arms”). No SMD is computed for it.
  Weights, if supplied, are applied as given. The footnotes state that
  the pooled summary ignores the trial structure.

- overall_label:

  Heading of the pooled summary. Default `"Overall"`. Must be one
  nonempty string that differs from every trial name.

## Details

Every statistic is computed within a trial and arm; nothing is pooled
across trials. Rows follow a common structure: for categorical variables
the levels are those observed in any trial, in the order of the data. A
level not observed in a given trial displays as a zero count; an em dash
marks a cell that does not apply (for example, a variable that is
entirely missing in a trial, or an SMD whose arm pair is absent).

With many trials, a wide table is unreadable; use `layout = "long"`, or
split trials across several calls. A single trial-by-arm table is common
in supplements of multi-trial individual participant data analyses;
main-text tables often show only trial-level characteristics.

The per-trial `nice_table1` objects are in `x$trials`, so any single
trial can be printed or exported on its own.

## Value

A `nice_trial_table1` list with `table` (formatted data.frame),
`col_info` (column keys, header labels, trial, arm, and type),
`row_info` (row types for `"wide"`; trial and treatment for `"long"`),
`smd` (long data.frame with one row per trial and variable: numeric SMD,
status, reason), `groups` (per trial and arm raw counts, sums of
weights, Kish effective sizes), `trials` (named list of `nice_table1`
objects), `notes`, `settings`, `call`, and `flextable`.

## See also

[`nice_SMD_table1`](https://hyejung0.github.io/niceSMD/reference/nice_SMD_table1.md),
[`table1_flextable`](https://hyejung0.github.io/niceSMD/reference/table1_flextable.md),
[`save_table1_docx`](https://hyejung0.github.io/niceSMD/reference/save_table1_docx.md),
[`example_trial_data`](https://hyejung0.github.io/niceSMD/reference/example_trial_data.md)

## Examples

``` r
d <- example_trial_data()
head(d)
#>     trial     arm age egfr    sex diabetes ckd_stage weight
#> 1 Trial A Placebo  55 35.5 Female       No        G3    1.0
#> 2 Trial A  Active  63 41.0   Male      Yes        G4    1.5
#> 3 Trial A Placebo  69 46.5 Female       No        G3    0.7
#> 4 Trial A  Active  NA 32.0   Male      Yes        G3    1.2
#> 5 Trial A Placebo  52 37.5   Male       No        G4    1.7
#> 6 Trial A  Active  60 43.0 Female       No        G3    0.9
table(d$trial, d$arm)
#>          
#>           Placebo Active High dose
#>   Trial A      30     30         0
#>   Trial B      24     24         0
#>   Trial C      24     24        24
vars <- c("age", "egfr", "sex", "diabetes", "ckd_stage")
labels <- c("Age (years)", "eGFR (mL/min/1.73 m2)", "Sex", "Diabetes", "CKD stage")

## ---- 1. Trials side by side (few trials) -----------------------------
## Trial C has three arms, so name the pair the SMD compares.
wide <- nice_trial_table1(
  d, trial = "trial", treatment = "arm", covar_names = vars,
  print_covariate_names = labels,
  treatment_for_SMD = c("Placebo", "Active")
)
wide
#> Table 1 by trial and treatment
#> 
#>  Variable              Trial A: Placebo\nN = 30 Trial A: Active\nN = 30
#>  Age (years)                                                           
#>      Mean (SD)         62.70 (9.09)             64.07 (8.63)           
#>      Median (Q1, Q3)   62.50 (55.25, 69.75)     64.00 (57.00, 71.00)   
#>      Missing           0 (0.0%)                 1 (3.3%)               
#>  eGFR (mL/min/1.73 m2)                                                 
#>      Mean (SD)         39.67 (5.86)             39.66 (5.75)           
#>      Median (Q1, Q3)   39.50 (34.75, 44.25)     40.00 (35.00, 44.00)   
#>      Missing           0 (0.0%)                 1 (3.3%)               
#>  Sex                                                                   
#>      Female            12 (40.0%)               12 (40.0%)             
#>      Male              18 (60.0%)               18 (60.0%)             
#>  Diabetes                                                              
#>      No                18 (60.0%)               16 (53.3%)             
#>      Yes               12 (40.0%)               14 (46.7%)             
#>  CKD stage                                                             
#>      G3                20 (66.7%)               20 (66.7%)             
#>      G4                10 (33.3%)               10 (33.3%)             
#>      G5                0 (0.0%)                 0 (0.0%)               
#>  Trial A: SMD (Placebo vs. Active) Trial B: Placebo\nN = 24
#>  0.154                                                     
#>                                    65.29 (8.89)            
#>                                    65.50 (57.75, 72.25)    
#>                                    0 (0.0%)                
#>  0.002                                                     
#>                                    43.67 (5.80)            
#>                                    43.50 (39.00, 49.00)    
#>                                    1 (4.2%)                
#>  0.000                                                     
#>                                    10 (41.7%)              
#>                                    14 (58.3%)              
#>  0.135                                                     
#>                                    15 (62.5%)              
#>                                    9 (37.5%)               
#>  0.000                                                     
#>                                    10 (41.7%)              
#>                                    10 (41.7%)              
#>                                    4 (16.7%)               
#>  Trial B: Active\nN = 24 Trial B: SMD (Placebo vs. Active)
#>                          0.355                            
#>  68.48 (9.05)                                             
#>  68.00 (62.50, 76.50)                                     
#>  1 (4.2%)                                                 
#>                          0.261                            
#>  42.17 (5.76)                                             
#>  42.50 (37.00, 46.25)                                     
#>  0 (0.0%)                                                 
#>                          0.000                            
#>  10 (41.7%)                                               
#>  14 (58.3%)                                               
#>                          0.170                            
#>  13 (54.2%)                                               
#>  11 (45.8%)                                               
#>                          0.117                            
#>  10 (41.7%)                                               
#>  9 (37.5%)                                                
#>  5 (20.8%)                                                
#>  Trial C: Placebo\nN = 24 Trial C: Active\nN = 24 Trial C: High dose\nN = 24
#>                                                                             
#>  60.04 (9.00)             62.25 (9.23)            60.50 (8.66)              
#>  59.00 (53.50, 67.50)     62.50 (54.75, 69.00)    60.50 (52.75, 68.25)      
#>  1 (4.2%)                 0 (0.0%)                0 (0.0%)                  
#>                                                                             
#>  37.42 (5.83)             37.92 (5.75)            38.42 (5.90)              
#>  37.00 (32.88, 42.25)     38.25 (33.25, 42.25)    38.50 (33.75, 43.62)      
#>  0 (0.0%)                 0 (0.0%)                0 (0.0%)                  
#>                                                                             
#>  9 (37.5%)                10 (41.7%)              10 (41.7%)                
#>  15 (62.5%)               14 (58.3%)              14 (58.3%)                
#>                                                                             
#>  13 (54.2%)               14 (58.3%)              14 (58.3%)                
#>  11 (45.8%)               10 (41.7%)              10 (41.7%)                
#>                                                                             
#>  9 (37.5%)                10 (41.7%)              10 (41.7%)                
#>  10 (41.7%)               10 (41.7%)              9 (37.5%)                 
#>  5 (20.8%)                4 (16.7%)               5 (20.8%)                 
#>  Trial C: SMD (Placebo vs. Active)
#>  0.242                            
#>                                   
#>                                   
#>                                   
#>  0.086                            
#>                                   
#>                                   
#>                                   
#>  0.085                            
#>                                   
#>                                   
#>  0.084                            
#>                                   
#>                                   
#>  0.117                            
#>                                   
#>                                   
#>                                   
#> 
#> All summaries are computed separately within each trial and treatment arm.
#> N and counts are numbers of people. Category percentages use the nonmissing number of people for that variable and arm; missing percentages use the full arm number of people.
#> Continuous summaries and SMDs exclude missing values separately for each variable and trial. Missingness is not included as a category in SMDs.
#> Absolute SMDs compare Placebo vs. Active within each trial. A multilevel categorical SMD compares its category proportions jointly. NE = not estimable; Inf = a nonzero difference with zero standardizing variance. SMDs are descriptive and are not tests.
#> Unweighted quartiles use stats::quantile with type = 7.
#> A Missing row is shown only for variables with at least one missing value in some trial.
wide$smd                     # numeric SMDs, one row per trial and variable
#>      trial  variable                 label         smd status reason
#> 1  Trial A       age           Age (years) 0.154448370     ok       
#> 2  Trial A      egfr eGFR (mL/min/1.73 m2) 0.001980403     ok       
#> 3  Trial A       sex                   Sex 0.000000000     ok       
#> 4  Trial A  diabetes              Diabetes 0.134839972     ok       
#> 5  Trial A ckd_stage             CKD stage 0.000000000     ok       
#> 6  Trial B       age           Age (years) 0.355183343     ok       
#> 7  Trial B      egfr eGFR (mL/min/1.73 m2) 0.260815434     ok       
#> 8  Trial B       sex                   Sex 0.000000000     ok       
#> 9  Trial B  diabetes              Diabetes 0.169637786     ok       
#> 10 Trial B ckd_stage             CKD stage 0.117012527     ok       
#> 11 Trial C       age           Age (years) 0.242054622     ok       
#> 12 Trial C      egfr eGFR (mL/min/1.73 m2) 0.086368162     ok       
#> 13 Trial C       sex                   Sex 0.085280287     ok       
#> 14 Trial C  diabetes              Diabetes 0.084066270     ok       
#> 15 Trial C ckd_stage             CKD stage 0.117012527     ok       
wide$groups                  # arm sizes
#>     trial treatment  n sum_weights effective_n
#> 1 Trial A   Placebo 30          30          30
#> 2 Trial A    Active 30          30          30
#> 3 Trial B   Placebo 24          24          24
#> 4 Trial B    Active 24          24          24
#> 5 Trial C   Placebo 24          24          24
#> 6 Trial C    Active 24          24          24
#> 7 Trial C High dose 24          24          24
wide$trials[["Trial A"]]     # the underlying single-trial table
#> Trial 'Trial A'
#> 
#>  Variable              Placebo\nN = 30      Active\nN = 30      
#>  Age (years)                                                    
#>      Mean (SD)         62.70 (9.09)         64.07 (8.63)        
#>      Median (Q1, Q3)   62.50 (55.25, 69.75) 64.00 (57.00, 71.00)
#>      Missing           0 (0.0%)             1 (3.3%)            
#>  eGFR (mL/min/1.73 m2)                                          
#>      Mean (SD)         39.67 (5.86)         39.66 (5.75)        
#>      Median (Q1, Q3)   39.50 (34.75, 44.25) 40.00 (35.00, 44.00)
#>      Missing           0 (0.0%)             1 (3.3%)            
#>  Sex                                                            
#>      Female            12 (40.0%)           12 (40.0%)          
#>      Male              18 (60.0%)           18 (60.0%)          
#>  Diabetes                                                       
#>      No                18 (60.0%)           16 (53.3%)          
#>      Yes               12 (40.0%)           14 (46.7%)          
#>  CKD stage                                                      
#>      G3                20 (66.7%)           20 (66.7%)          
#>      G4                10 (33.3%)           10 (33.3%)          
#>  SMD (Placebo vs. Active)
#>  0.154                   
#>                          
#>                          
#>                          
#>  0.002                   
#>                          
#>                          
#>                          
#>  0.000                   
#>                          
#>                          
#>  0.135                   
#>                          
#>                          
#>  0.000                   
#>                          
#>                          
#> 
#> 

## ---- 2. One row per trial and arm (many trials) ----------------------
long <- nice_trial_table1(
  d, "trial", "arm", vars, print_covariate_names = labels,
  treatment_for_SMD = c("Placebo", "Active"),
  layout = "long", continuous_stats = "mean_sd", notes = "short"
)
long
#> Table 1 by trial and treatment
#> 
#>  Trial   Treatment N  Age (years): Mean (SD) Age (years): Missing
#>  Trial A Placebo   30 62.70 (9.09)           0 (0.0%)            
#>  Trial A Active    30 64.07 (8.63)           1 (3.3%)            
#>  Trial B Placebo   24 65.29 (8.89)           0 (0.0%)            
#>  Trial B Active    24 68.48 (9.05)           1 (4.2%)            
#>  Trial C Placebo   24 60.04 (9.00)           1 (4.2%)            
#>  Trial C Active    24 62.25 (9.23)           0 (0.0%)            
#>  Trial C High dose 24 60.50 (8.66)           0 (0.0%)            
#>  eGFR (mL/min/1.73 m2): Mean (SD) eGFR (mL/min/1.73 m2): Missing Sex: Female
#>  39.67 (5.86)                     0 (0.0%)                       12 (40.0%) 
#>  39.66 (5.75)                     1 (3.3%)                       12 (40.0%) 
#>  43.67 (5.80)                     1 (4.2%)                       10 (41.7%) 
#>  42.17 (5.76)                     0 (0.0%)                       10 (41.7%) 
#>  37.42 (5.83)                     0 (0.0%)                       9 (37.5%)  
#>  37.92 (5.75)                     0 (0.0%)                       10 (41.7%) 
#>  38.42 (5.90)                     0 (0.0%)                       10 (41.7%) 
#>  Sex: Male  Diabetes: No Diabetes: Yes CKD stage: G3 CKD stage: G4
#>  18 (60.0%) 18 (60.0%)   12 (40.0%)    20 (66.7%)    10 (33.3%)   
#>  18 (60.0%) 16 (53.3%)   14 (46.7%)    20 (66.7%)    10 (33.3%)   
#>  14 (58.3%) 15 (62.5%)   9 (37.5%)     10 (41.7%)    10 (41.7%)   
#>  14 (58.3%) 13 (54.2%)   11 (45.8%)    10 (41.7%)    9 (37.5%)    
#>  15 (62.5%) 13 (54.2%)   11 (45.8%)    9 (37.5%)     10 (41.7%)   
#>  14 (58.3%) 14 (58.3%)   10 (41.7%)    10 (41.7%)    10 (41.7%)   
#>  14 (58.3%) 14 (58.3%)   10 (41.7%)    10 (41.7%)    9 (37.5%)    
#>  CKD stage: G5
#>  0 (0.0%)     
#>  0 (0.0%)     
#>  4 (16.7%)    
#>  5 (20.8%)    
#>  5 (20.8%)    
#>  4 (16.7%)    
#>  5 (20.8%)    
#> 
#> Summaries are computed within each trial and treatment arm. Categorical: n (%) among nonmissing values. Continuous: mean (SD) and median (Q1, Q3). Missing: n (% of arm).
#> A Missing row is shown only for variables with at least one missing value in some trial.

## ---- 3. Manuscript style: no SMD column, short legend ----------------
nice_trial_table1(
  d, "trial", "arm", vars, print_covariate_names = labels,
  treatment_for_SMD = c("Placebo", "Active"),
  show_smd = FALSE, notes = "short"
)
#> Table 1 by trial and treatment
#> 
#>  Variable              Trial A: Placebo\nN = 30 Trial A: Active\nN = 30
#>  Age (years)                                                           
#>      Mean (SD)         62.70 (9.09)             64.07 (8.63)           
#>      Median (Q1, Q3)   62.50 (55.25, 69.75)     64.00 (57.00, 71.00)   
#>      Missing           0 (0.0%)                 1 (3.3%)               
#>  eGFR (mL/min/1.73 m2)                                                 
#>      Mean (SD)         39.67 (5.86)             39.66 (5.75)           
#>      Median (Q1, Q3)   39.50 (34.75, 44.25)     40.00 (35.00, 44.00)   
#>      Missing           0 (0.0%)                 1 (3.3%)               
#>  Sex                                                                   
#>      Female            12 (40.0%)               12 (40.0%)             
#>      Male              18 (60.0%)               18 (60.0%)             
#>  Diabetes                                                              
#>      No                18 (60.0%)               16 (53.3%)             
#>      Yes               12 (40.0%)               14 (46.7%)             
#>  CKD stage                                                             
#>      G3                20 (66.7%)               20 (66.7%)             
#>      G4                10 (33.3%)               10 (33.3%)             
#>      G5                0 (0.0%)                 0 (0.0%)               
#>  Trial B: Placebo\nN = 24 Trial B: Active\nN = 24 Trial C: Placebo\nN = 24
#>                                                                           
#>  65.29 (8.89)             68.48 (9.05)            60.04 (9.00)            
#>  65.50 (57.75, 72.25)     68.00 (62.50, 76.50)    59.00 (53.50, 67.50)    
#>  0 (0.0%)                 1 (4.2%)                1 (4.2%)                
#>                                                                           
#>  43.67 (5.80)             42.17 (5.76)            37.42 (5.83)            
#>  43.50 (39.00, 49.00)     42.50 (37.00, 46.25)    37.00 (32.88, 42.25)    
#>  1 (4.2%)                 0 (0.0%)                0 (0.0%)                
#>                                                                           
#>  10 (41.7%)               10 (41.7%)              9 (37.5%)               
#>  14 (58.3%)               14 (58.3%)              15 (62.5%)              
#>                                                                           
#>  15 (62.5%)               13 (54.2%)              13 (54.2%)              
#>  9 (37.5%)                11 (45.8%)              11 (45.8%)              
#>                                                                           
#>  10 (41.7%)               10 (41.7%)              9 (37.5%)               
#>  10 (41.7%)               9 (37.5%)               10 (41.7%)              
#>  4 (16.7%)                5 (20.8%)               5 (20.8%)               
#>  Trial C: Active\nN = 24 Trial C: High dose\nN = 24
#>                                                    
#>  62.25 (9.23)            60.50 (8.66)              
#>  62.50 (54.75, 69.00)    60.50 (52.75, 68.25)      
#>  0 (0.0%)                0 (0.0%)                  
#>                                                    
#>  37.92 (5.75)            38.42 (5.90)              
#>  38.25 (33.25, 42.25)    38.50 (33.75, 43.62)      
#>  0 (0.0%)                0 (0.0%)                  
#>                                                    
#>  10 (41.7%)              10 (41.7%)                
#>  14 (58.3%)              14 (58.3%)                
#>                                                    
#>  14 (58.3%)              14 (58.3%)                
#>  10 (41.7%)              10 (41.7%)                
#>                                                    
#>  10 (41.7%)              10 (41.7%)                
#>  10 (41.7%)              9 (37.5%)                 
#>  4 (16.7%)               5 (20.8%)                 
#> 
#> Summaries are computed within each trial and treatment arm. Categorical: n (%) among nonmissing values. Continuous: mean (SD) and median (Q1, Q3). Missing: n (% of arm).
#> A Missing row is shown only for variables with at least one missing value in some trial.

## ---- 4. Missing rows ---------------------------------------------------
## Only age and eGFR have missing values: "if_any" (default) shows Missing
## rows for them; "never" hides all; "always" shows one for every variable.
for (mode in c("if_any", "never", "always")) {
  x <- nice_trial_table1(d, "trial", "arm", vars,
                         treatment_for_SMD = c("Placebo", "Active"),
                         show_missing = mode)
  cat(mode, ":", sum(x$row_info$type == "missing"), "Missing rows\n")
}
#> if_any : 2 Missing rows
#> never : 0 Missing rows
#> always : 5 Missing rows

## ---- 5. Orders and labels ---------------------------------------------
nice_trial_table1(
  d, "trial", "arm", c("age", "sex"),
  print_covariate_names = c(sex = "Sex", age = "Age (years)"),
  treatment_for_SMD = c("Placebo", "Active"),
  trial_order = c("Trial C", "Trial A", "Trial B"),
  treatment_order = c("Active", "Placebo", "High dose")
)$groups
#>     trial treatment  n sum_weights effective_n
#> 1 Trial C    Active 24          24          24
#> 2 Trial C   Placebo 24          24          24
#> 3 Trial C High dose 24          24          24
#> 4 Trial A    Active 30          30          30
#> 5 Trial A   Placebo 30          30          30
#> 6 Trial B    Active 24          24          24
#> 7 Trial B   Placebo 24          24          24

## ---- 6. Rounding, categorical codes, grouping vectors ----------------
nice_trial_table1(
  d, d$trial, d$arm, c("age", "ckd_stage"),
  treatment_for_SMD = c("Placebo", "Active"),
  contDigits = 1, catDigits = 0, smdDigits = 2
)
#> Table 1 by trial and treatment
#> 
#>  Variable            Trial A: Placebo\nN = 30 Trial A: Active\nN = 30
#>  age                                                                 
#>      Mean (SD)       62.7 (9.1)               64.1 (8.6)             
#>      Median (Q1, Q3) 62.5 (55.2, 69.8)        64.0 (57.0, 71.0)      
#>      Missing         0 (0%)                   1 (3%)                 
#>  ckd_stage                                                           
#>      G3              20 (67%)                 20 (67%)               
#>      G4              10 (33%)                 10 (33%)               
#>      G5              0 (0%)                   0 (0%)                 
#>  Trial A: SMD (Placebo vs. Active) Trial B: Placebo\nN = 24
#>  0.15                                                      
#>                                    65.3 (8.9)              
#>                                    65.5 (57.8, 72.2)       
#>                                    0 (0%)                  
#>  0.00                                                      
#>                                    10 (42%)                
#>                                    10 (42%)                
#>                                    4 (17%)                 
#>  Trial B: Active\nN = 24 Trial B: SMD (Placebo vs. Active)
#>                          0.36                             
#>  68.5 (9.0)                                               
#>  68.0 (62.5, 76.5)                                        
#>  1 (4%)                                                   
#>                          0.12                             
#>  10 (42%)                                                 
#>  9 (38%)                                                  
#>  5 (21%)                                                  
#>  Trial C: Placebo\nN = 24 Trial C: Active\nN = 24 Trial C: High dose\nN = 24
#>                                                                             
#>  60.0 (9.0)               62.2 (9.2)              60.5 (8.7)                
#>  59.0 (53.5, 67.5)        62.5 (54.8, 69.0)       60.5 (52.8, 68.2)         
#>  1 (4%)                   0 (0%)                  0 (0%)                    
#>                                                                             
#>  9 (38%)                  10 (42%)                10 (42%)                  
#>  10 (42%)                 10 (42%)                9 (38%)                   
#>  5 (21%)                  4 (17%)                 5 (21%)                   
#>  Trial C: SMD (Placebo vs. Active)
#>  0.24                             
#>                                   
#>                                   
#>                                   
#>  0.12                             
#>                                   
#>                                   
#>                                   
#> 
#> All summaries are computed separately within each trial and treatment arm.
#> N and counts are numbers of people. Category percentages use the nonmissing number of people for that variable and arm; missing percentages use the full arm number of people.
#> Continuous summaries and SMDs exclude missing values separately for each variable and trial. Missingness is not included as a category in SMDs.
#> Absolute SMDs compare Placebo vs. Active within each trial. A multilevel categorical SMD compares its category proportions jointly. NE = not estimable; Inf = a nonzero difference with zero standardizing variance. SMDs are descriptive and are not tests.
#> Unweighted quartiles use stats::quantile with type = 7.
#> A Missing row is shown only for variables with at least one missing value in some trial.

## ---- 7. Weights ---------------------------------------------------------
nice_trial_table1(
  d, "trial", "arm", c("age", "sex"), weights = "weight",
  treatment_for_SMD = c("Placebo", "Active"), weightDigits = 1,
  layout = "long"
)
#> Table 1 by trial and treatment
#> 
#>  Trial   Treatment N  Sum of weights age: Mean (SD) age: Median (Q1, Q3)
#>  Trial A Placebo   30 33.4           61.53 (9.20)   60.00 (54.00, 69.00)
#>  Trial A Active    30 32.8           63.29 (8.80)   63.00 (56.00, 71.00)
#>  Trial B Placebo   24 25.7           63.80 (8.78)   63.00 (57.00, 71.00)
#>  Trial B Active    24 27.3           67.87 (9.33)   67.00 (62.00, 76.00)
#>  Trial C Placebo   24 27.2           59.05 (9.02)   58.00 (50.00, 67.00)
#>  Trial C Active    24 26.2           61.35 (9.49)   61.00 (53.00, 68.00)
#>  Trial C High dose 24 26.5           59.82 (8.88)   60.00 (52.00, 68.00)
#>  age: Missing sex: Female  sex: Male   
#>  0.0 (0.0%)   13.3 (39.8%) 20.1 (60.2%)
#>  1.2 (3.7%)   13.4 (40.9%) 19.4 (59.1%)
#>  0.0 (0.0%)   11.0 (42.8%) 14.7 (57.2%)
#>  1.6 (5.9%)   11.3 (41.4%) 16.0 (58.6%)
#>  1.1 (4.0%)   10.0 (36.8%) 17.2 (63.2%)
#>  0.0 (0.0%)   10.1 (38.5%) 16.1 (61.5%)
#>  0.0 (0.0%)   11.1 (41.9%) 15.4 (58.1%)
#> 
#> All summaries are computed separately within each trial and treatment arm.
#> n is the number of people with positive weights; counts are sums of weights, used as supplied without normalization or trimming. Category percentages use the nonmissing sum of weights for that variable and arm; missing percentages use the full arm sum of weights.
#> Continuous summaries exclude missing values separately for each variable and trial.
#> Weighted SDs follow survey conventions; weighted quartiles use survey::svyquantile with qrule = 'math'.
#> A Missing row is shown only for variables with at least one missing value in some trial.

## ---- 8. Word output ------------------------------------------------------
path <- tempfile(fileext = ".docx")
save_table1_docx(wide, path, landscape = TRUE, font_size = 9)
unlink(path)
nice_trial_table1(d, "trial", "arm", "age",
                  treatment_for_SMD = c("Placebo", "Active"),
                  docx_path = path)
#> Table 1 by trial and treatment
#> 
#>  Variable            Trial A: Placebo\nN = 30 Trial A: Active\nN = 30
#>  age                                                                 
#>      Mean (SD)       62.70 (9.09)             64.07 (8.63)           
#>      Median (Q1, Q3) 62.50 (55.25, 69.75)     64.00 (57.00, 71.00)   
#>      Missing         0 (0.0%)                 1 (3.3%)               
#>  Trial A: SMD (Placebo vs. Active) Trial B: Placebo\nN = 24
#>  0.154                                                     
#>                                    65.29 (8.89)            
#>                                    65.50 (57.75, 72.25)    
#>                                    0 (0.0%)                
#>  Trial B: Active\nN = 24 Trial B: SMD (Placebo vs. Active)
#>                          0.355                            
#>  68.48 (9.05)                                             
#>  68.00 (62.50, 76.50)                                     
#>  1 (4.2%)                                                 
#>  Trial C: Placebo\nN = 24 Trial C: Active\nN = 24 Trial C: High dose\nN = 24
#>                                                                             
#>  60.04 (9.00)             62.25 (9.23)            60.50 (8.66)              
#>  59.00 (53.50, 67.50)     62.50 (54.75, 69.00)    60.50 (52.75, 68.25)      
#>  1 (4.2%)                 0 (0.0%)                0 (0.0%)                  
#>  Trial C: SMD (Placebo vs. Active)
#>  0.242                            
#>                                   
#>                                   
#>                                   
#> 
#> All summaries are computed separately within each trial and treatment arm.
#> N and counts are numbers of people. Category percentages use the nonmissing number of people for that variable and arm; missing percentages use the full arm number of people.
#> Continuous summaries and SMDs exclude missing values separately for each variable and trial. Missingness is not included as a category in SMDs.
#> Absolute SMDs compare Placebo vs. Active within each trial. A multilevel categorical SMD compares its category proportions jointly. NE = not estimable; Inf = a nonzero difference with zero standardizing variance. SMDs are descriptive and are not tests.
#> Unweighted quartiles use stats::quantile with type = 7.
unlink(path)

## ---- 9. Overall summaries ---------------------------------------------
## By trial only (no treatment): one column per trial, no SMD.
nice_trial_table1(d, "trial", treatment = NULL, covar_names = vars,
                  print_covariate_names = labels)
#> Table 1 by trial
#> 
#>  Variable              Trial A: N = 60      Trial B: N = 48     
#>  Age (years)                                                    
#>      Mean (SD)         63.37 (8.82)         66.85 (9.02)        
#>      Median (Q1, Q3)   63.00 (56.00, 70.50) 67.00 (59.00, 74.00)
#>      Missing           1 (1.7%)             1 (2.1%)            
#>  eGFR (mL/min/1.73 m2)                                          
#>      Mean (SD)         39.66 (5.75)         42.90 (5.77)        
#>      Median (Q1, Q3)   39.50 (34.75, 44.25) 43.00 (38.25, 47.75)
#>      Missing           1 (1.7%)             1 (2.1%)            
#>  Sex                                                            
#>      Female            24 (40.0%)           20 (41.7%)          
#>      Male              36 (60.0%)           28 (58.3%)          
#>  Diabetes                                                       
#>      No                34 (56.7%)           28 (58.3%)          
#>      Yes               26 (43.3%)           20 (41.7%)          
#>  CKD stage                                                      
#>      G3                40 (66.7%)           20 (41.7%)          
#>      G4                20 (33.3%)           19 (39.6%)          
#>      G5                0 (0.0%)             9 (18.8%)           
#>  Trial C: N = 72     
#>                      
#>  60.94 (8.89)        
#>  61.00 (53.50, 68.00)
#>  1 (1.4%)            
#>                      
#>  37.92 (5.76)        
#>  38.00 (33.00, 43.00)
#>  0 (0.0%)            
#>                      
#>  29 (40.3%)          
#>  43 (59.7%)          
#>                      
#>  41 (56.9%)          
#>  31 (43.1%)          
#>                      
#>  29 (40.3%)          
#>  29 (40.3%)          
#>  14 (19.4%)          
#> 
#> All summaries are computed separately within each trial.
#> N and counts are numbers of people. Category percentages use the nonmissing number of people for that variable and trial; missing percentages use the full trial number of people.
#> Continuous summaries exclude missing values separately for each variable and trial.
#> Unweighted quartiles use stats::quantile with type = 7.
#> A Missing row is shown only for variables with at least one missing value in some trial.
## By trial and arm, plus a pooled column across all trials.
nice_trial_table1(d, "trial", "arm", vars, print_covariate_names = labels,
                  treatment_for_SMD = c("Placebo", "Active"),
                  overall = TRUE, notes = "short")
#> Table 1 by trial and treatment
#> 
#>  Variable              Trial A: Placebo\nN = 30 Trial A: Active\nN = 30
#>  Age (years)                                                           
#>      Mean (SD)         62.70 (9.09)             64.07 (8.63)           
#>      Median (Q1, Q3)   62.50 (55.25, 69.75)     64.00 (57.00, 71.00)   
#>      Missing           0 (0.0%)                 1 (3.3%)               
#>  eGFR (mL/min/1.73 m2)                                                 
#>      Mean (SD)         39.67 (5.86)             39.66 (5.75)           
#>      Median (Q1, Q3)   39.50 (34.75, 44.25)     40.00 (35.00, 44.00)   
#>      Missing           0 (0.0%)                 1 (3.3%)               
#>  Sex                                                                   
#>      Female            12 (40.0%)               12 (40.0%)             
#>      Male              18 (60.0%)               18 (60.0%)             
#>  Diabetes                                                              
#>      No                18 (60.0%)               16 (53.3%)             
#>      Yes               12 (40.0%)               14 (46.7%)             
#>  CKD stage                                                             
#>      G3                20 (66.7%)               20 (66.7%)             
#>      G4                10 (33.3%)               10 (33.3%)             
#>      G5                0 (0.0%)                 0 (0.0%)               
#>  Trial A: SMD (Placebo vs. Active) Trial B: Placebo\nN = 24
#>  0.154                                                     
#>                                    65.29 (8.89)            
#>                                    65.50 (57.75, 72.25)    
#>                                    0 (0.0%)                
#>  0.002                                                     
#>                                    43.67 (5.80)            
#>                                    43.50 (39.00, 49.00)    
#>                                    1 (4.2%)                
#>  0.000                                                     
#>                                    10 (41.7%)              
#>                                    14 (58.3%)              
#>  0.135                                                     
#>                                    15 (62.5%)              
#>                                    9 (37.5%)               
#>  0.000                                                     
#>                                    10 (41.7%)              
#>                                    10 (41.7%)              
#>                                    4 (16.7%)               
#>  Trial B: Active\nN = 24 Trial B: SMD (Placebo vs. Active)
#>                          0.355                            
#>  68.48 (9.05)                                             
#>  68.00 (62.50, 76.50)                                     
#>  1 (4.2%)                                                 
#>                          0.261                            
#>  42.17 (5.76)                                             
#>  42.50 (37.00, 46.25)                                     
#>  0 (0.0%)                                                 
#>                          0.000                            
#>  10 (41.7%)                                               
#>  14 (58.3%)                                               
#>                          0.170                            
#>  13 (54.2%)                                               
#>  11 (45.8%)                                               
#>                          0.117                            
#>  10 (41.7%)                                               
#>  9 (37.5%)                                                
#>  5 (20.8%)                                                
#>  Trial C: Placebo\nN = 24 Trial C: Active\nN = 24 Trial C: High dose\nN = 24
#>                                                                             
#>  60.04 (9.00)             62.25 (9.23)            60.50 (8.66)              
#>  59.00 (53.50, 67.50)     62.50 (54.75, 69.00)    60.50 (52.75, 68.25)      
#>  1 (4.2%)                 0 (0.0%)                0 (0.0%)                  
#>                                                                             
#>  37.42 (5.83)             37.92 (5.75)            38.42 (5.90)              
#>  37.00 (32.88, 42.25)     38.25 (33.25, 42.25)    38.50 (33.75, 43.62)      
#>  0 (0.0%)                 0 (0.0%)                0 (0.0%)                  
#>                                                                             
#>  9 (37.5%)                10 (41.7%)              10 (41.7%)                
#>  15 (62.5%)               14 (58.3%)              14 (58.3%)                
#>                                                                             
#>  13 (54.2%)               14 (58.3%)              14 (58.3%)                
#>  11 (45.8%)               10 (41.7%)              10 (41.7%)                
#>                                                                             
#>  9 (37.5%)                10 (41.7%)              10 (41.7%)                
#>  10 (41.7%)               10 (41.7%)              9 (37.5%)                 
#>  5 (20.8%)                4 (16.7%)               5 (20.8%)                 
#>  Trial C: SMD (Placebo vs. Active) Overall: N = 180    
#>  0.242                                                 
#>                                    63.32 (9.16)        
#>                                    63.00 (56.00, 71.00)
#>                                    3 (1.7%)            
#>  0.086                                                 
#>                                    39.81 (6.07)        
#>                                    39.75 (35.00, 44.50)
#>                                    2 (1.1%)            
#>  0.085                                                 
#>                                    73 (40.6%)          
#>                                    107 (59.4%)         
#>  0.084                                                 
#>                                    103 (57.2%)         
#>                                    77 (42.8%)          
#>  0.117                                                 
#>                                    89 (49.4%)          
#>                                    68 (37.8%)          
#>                                    23 (12.8%)          
#> 
#> Summaries are computed within each trial and treatment arm. Categorical: n (%) among nonmissing values. Continuous: mean (SD) and median (Q1, Q3). Missing: n (% of arm).
#> SMD = absolute standardized mean difference (Placebo vs. Active); NE = not estimable.
#> Overall = all participants pooled across trials and treatment arms, ignoring the trial structure.
#> A Missing row is shown only for variables with at least one missing value in some trial.
## Long layout: a final Overall row.
nice_trial_table1(d, "trial", treatment = NULL, covar_names = vars,
                  layout = "long", overall = TRUE, continuous_stats = "mean_sd")
#> Table 1 by trial
#> 
#>  Trial   N   age: Mean (SD) age: Missing egfr: Mean (SD) egfr: Missing
#>  Trial A 60  63.37 (8.82)   1 (1.7%)     39.66 (5.75)    1 (1.7%)     
#>  Trial B 48  66.85 (9.02)   1 (2.1%)     42.90 (5.77)    1 (2.1%)     
#>  Trial C 72  60.94 (8.89)   1 (1.4%)     37.92 (5.76)    0 (0.0%)     
#>  Overall 180 63.32 (9.16)   3 (1.7%)     39.81 (6.07)    2 (1.1%)     
#>  sex: Female sex: Male   diabetes: No diabetes: Yes ckd_stage: G3 ckd_stage: G4
#>  24 (40.0%)  36 (60.0%)  34 (56.7%)   26 (43.3%)    40 (66.7%)    20 (33.3%)   
#>  20 (41.7%)  28 (58.3%)  28 (58.3%)   20 (41.7%)    20 (41.7%)    19 (39.6%)   
#>  29 (40.3%)  43 (59.7%)  41 (56.9%)   31 (43.1%)    29 (40.3%)    29 (40.3%)   
#>  73 (40.6%)  107 (59.4%) 103 (57.2%)  77 (42.8%)    89 (49.4%)    68 (37.8%)   
#>  ckd_stage: G5
#>  0 (0.0%)     
#>  9 (18.8%)    
#>  14 (19.4%)   
#>  23 (12.8%)   
#> 
#> All summaries are computed separately within each trial.
#> N and counts are numbers of people. Category percentages use the nonmissing number of people for that variable and trial; missing percentages use the full trial number of people.
#> Continuous summaries exclude missing values separately for each variable and trial.
#> Unweighted quartiles use stats::quantile with type = 7.
#> Overall = all participants pooled across trials, ignoring the trial structure.
#> A Missing row is shown only for variables with at least one missing value in some trial.

## In Quarto, a chunk ending with `wide` renders the formatted table.
```
