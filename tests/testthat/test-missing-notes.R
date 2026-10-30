two_groups <- function() {
  d <- example_table1_data()
  d[d$group != "Registry", ]
}
pair <- c("Control", "Treatment")

test_that("show_missing accepts logical and string modes", {
  d <- two_groups()
  n_missing <- function(mode) {
    ans <- nice_SMD_table1(d, "group", c("age", "stratum"),
                            group_for_SMD = pair, show_missing = mode)
    sum(ans$row_info$type == "missing")
  }
  expect_equal(n_missing(TRUE), 2L)
  expect_equal(n_missing("always"), 2L)
  expect_equal(n_missing(FALSE), 0L)
  expect_equal(n_missing("never"), 0L)
  expect_equal(n_missing("if_any"), 1L)
})

test_that("if_any keeps Missing rows only where values are missing", {
  d <- two_groups()
  ans <- nice_SMD_table1(d, "group", c("age", "stratum"),
                          group_for_SMD = pair, show_missing = "if_any")
  rows <- ans$row_info[ans$row_info$type == "missing", ]
  expect_equal(rows$variable, "age")
  expect_equal(ans$settings$show_missing, "if_any")
  expect_true(any(grepl("without a Missing row|only for variables", ans$notes)))
})

test_that("if_any shows a row when only one group has missing values", {
  d <- data.frame(g = rep(c("A", "B"), each = 5),
                  x = c(1, 2, 3, 4, 5, 2, 3, NA, 5, 6))
  ans <- nice_SMD_table1(d, "g", "x", show_missing = "if_any")
  expect_equal(sum(ans$row_info$type == "missing"), 1L)
})

test_that("show_missing does not change SMDs or summaries", {
  d <- two_groups()
  a <- nice_SMD_table1(d, "group", c("age", "sex"), group_for_SMD = pair,
                        show_missing = "always")
  b <- nice_SMD_table1(d, "group", c("age", "sex"), group_for_SMD = pair,
                        show_missing = "never")
  expect_equal(a$smd$smd, b$smd$smd)
  keep <- a$row_info$type != "missing"
  expect_equal(a$table[keep, ], b$table, ignore_attr = TRUE)
})

test_that("if_any note is omitted when no row is hidden", {
  d <- two_groups()
  ans <- nice_SMD_table1(d, "group", "age", group_for_SMD = pair,
                          show_missing = "if_any")
  expect_false(any(grepl("only for variables", ans$notes)))
})

test_that("invalid show_missing and notes values are rejected", {
  d <- two_groups()
  expect_error(nice_SMD_table1(d, "group", "age", show_missing = "sometimes"),
               "show_missing")
  expect_error(nice_SMD_table1(d, "group", "age", show_missing = NA),
               "show_missing")
  expect_error(nice_SMD_table1(d, "group", "age", show_missing = c(TRUE, FALSE)),
               "show_missing")
  expect_error(nice_SMD_table1(d, "group", "age", notes = "medium"), "notes")
  expect_error(nice_SMD_table1(d, "group", "age", notes = c("full", "short")),
               "notes")
  expect_error(nice_SMD_table1(d, "group", "age", notes = NA_character_), "notes")
})

test_that("notes styles differ in length and keep the key definitions", {
  d <- two_groups()
  make <- function(style, ...) {
    nice_SMD_table1(d, "group", c("age", "sex"), group_for_SMD = pair,
                    notes = style, ...)
  }
  full <- make("full")
  short <- make("short")
  none <- make("none")
  expect_gt(length(full$notes), length(short$notes))
  expect_gt(sum(nchar(full$notes)), sum(nchar(short$notes)))
  expect_length(none$notes, 0L)
  expect_equal(full$settings$notes_style, "full")
  expect_equal(short$settings$notes_style, "short")
  expect_equal(none$settings$notes_style, "none")
  expect_true(any(grepl("standardized mean difference", short$notes)))
  expect_true(any(grepl("NE = not estimable", short$notes)))
  expect_true(any(grepl("Control vs. Treatment", short$notes)))
  expect_true(any(grepl("nonmissing", full$notes)))
  # Default is the full legend.
  default <- nice_SMD_table1(d, "group", c("age", "sex"), group_for_SMD = pair)
  expect_equal(default$notes, full$notes)
})

test_that("short notes mention weights and exclusions when relevant", {
  d <- example_table1_data()
  d$analysis_weight[1:2] <- 0
  expect_warning(
    ans <- nice_SMD_table1(d, "group", "age", weights = "analysis_weight",
                            group_for_SMD = pair, notes = "short"),
    "excluded")
  expect_true(any(grepl("weighted", ans$notes, ignore.case = TRUE)))
  expect_true(any(grepl("excluded", ans$notes)))
})

test_that("print and flextable handle every notes style", {
  d <- two_groups()
  for (style in c("full", "short", "none")) {
    ans <- nice_SMD_table1(d, "group", c("age", "sex"), group_for_SMD = pair,
                            notes = style, show_missing = "if_any")
    expect_s3_class(ans$flextable, "flextable")
    expect_output(print(ans), "Control")
    expect_s3_class(table1_flextable(ans, include_notes = FALSE), "flextable")
  }
  none <- nice_SMD_table1(d, "group", "age", group_for_SMD = pair, notes = "none")
  expect_equal(flextable::nrow_part(none$flextable, "footer"), 0L)
})

test_that("indented console print and kable helpers work", {
  d <- two_groups()
  ans <- nice_SMD_table1(d, "group", c("age", "sex"), group_for_SMD = pair)
  out <- capture.output(print(ans))
  expect_true(any(grepl("^ *    (Female|Male)", out)))
  skip_if_not_installed("knitr")
  md <- as.character(table1_kable(ans, format = "markdown"))
  expect_true(any(grepl("\\*\\*age\\*\\*", md)))
  html <- as.character(table1_kable(ans, format = "html"))
  expect_true(any(grepl("<strong>age</strong>", html)))
  tex <- as.character(table1_kable(ans, format = "latex"))
  expect_true(any(grepl("textbf", tex)))
  expect_error(table1_kable(1), "nice_table1")
})
