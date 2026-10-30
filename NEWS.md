# niceSMD (development)

* New `nice_trial_table1()`: descriptive summaries by trial and treatment arm
  for pooled individual participant data, with "wide" (trials side by side) and
  "long" (one row per trial and arm) layouts, optional within-trial SMDs, and
  the same `show_missing`, `notes`, weighting, Quarto, and Word support.
* New `example_trial_data()`; `table1_flextable()` and `save_table1_docx()`
  accept trial tables.

* `show_missing` now also accepts `"always"`, `"never"`, and `"if_any"` (Missing
  row only for variables with missing values); `TRUE`/`FALSE` still work.
* New `notes` argument: `"full"` (default), `"short"`, or `"none"` footnotes.
* Tables render as formatted tables in Quarto/R Markdown via a `knit_print`
  method; new `table1_kable()` helper; console print indents category levels.
* Help pages rewritten with detailed argument descriptions and examples.

# niceSMD 0.1.0

* Initial GitHub source package based on the original nice_SMD_table1 function.
* Weighted and unweighted summaries with an explicit selected SMD comparison.
* Support for survey and replicate-weight design objects.
* Factors, characters, logical variables, and explicit numeric category overrides.
* Numeric SMD extraction, stable internal identifiers, and diagnostic status.
* Documented missing-value and percentage denominator conventions.
* Editable Word export with repeating headings and optional landscape pages.
* Synthetic examples, R help, tests, and multi-platform GitHub package checks.
