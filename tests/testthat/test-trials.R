vars <- c("age", "egfr", "sex", "ckd_stage")
pair <- c("Placebo", "Active")

make <- function(...) {
  nice_trial_table1(example_trial_data(), "trial", "arm", vars,
                    treatment_for_SMD = pair, ...)
}

test_that("per-trial results match nice_SMD_table1 run on each trial", {
  d <- example_trial_data()
  ans <- make()
  expect_s3_class(ans, "nice_trial_table1")
  expect_equal(names(ans$trials), c("Trial A", "Trial B", "Trial C"))
  for (tr in names(ans$trials)) {
    sub <- d[d$trial == tr, ]
    sub <- sub[sub$arm %in% levels(droplevels(sub$arm)), ]
    ref <- nice_SMD_table1(sub, as.character(sub$arm), vars,
                            group_for_SMD = pair, show_missing = "if_any")
    got <- ans$smd[ans$smd$trial == tr, ]
    expect_equal(got$smd, ref$smd$smd)
  }
})

test_that("wide layout has one column block per trial and shared rows", {
  ans <- make()
  info <- ans$col_info
  expect_equal(sum(info$type == "arm"), 2 + 2 + 3)
  expect_equal(sum(info$type == "smd"), 3)
  expect_equal(nrow(ans$table), nrow(ans$row_info))
  expect_equal(ncol(ans$table), nrow(info))
  expect_equal(sum(ans$row_info$type == "variable"), length(vars))
  # categories absent from Trial A are shown as zero, not dropped
  g5 <- which(ans$table$Variable == "G5")
  expect_length(g5, 1L)
  expect_match(ans$table[g5, 2], "^0 \\(0\\.0%\\)$")
})

test_that("show_smd = FALSE drops SMD columns", {
  ans <- make(show_smd = FALSE)
  expect_equal(sum(ans$col_info$type == "smd"), 0L)
  expect_false(any(grepl("SMD", names(ans$table))))
})

test_that("long layout has one row per trial and arm", {
  ans <- make(layout = "long")
  expect_equal(nrow(ans$table), 7L)
  expect_equal(ans$table$Trial, c("Trial A", "Trial A", "Trial B", "Trial B",
                                  "Trial C", "Trial C", "Trial C"))
  expect_equal(ans$table$N, as.character(c(30, 30, 24, 24, 24, 24, 24)))
  expect_s3_class(ans$flextable, "flextable")
})

test_that("continuous_stats filters summary rows", {
  both <- make()
  mean_only <- make(continuous_stats = "mean_sd")
  median_only <- make(continuous_stats = "median_iqr")
  expect_equal(sum(both$row_info$type == "summary"), 4L)
  expect_equal(sum(mean_only$row_info$type == "summary"), 2L)
  expect_true(all(mean_only$table$Variable[mean_only$row_info$type == "summary"] ==
                    "Mean (SD)"))
  expect_true(all(median_only$table$Variable[median_only$row_info$type == "summary"] ==
                    "Median (Q1, Q3)"))
})

test_that("missing rows follow show_missing and absent trials show zero", {
  always <- make(show_missing = "always")
  never <- make(show_missing = FALSE)
  if_any <- make()
  expect_equal(sum(always$row_info$type == "missing"), length(vars))
  expect_equal(sum(never$row_info$type == "missing"), 0L)
  expect_equal(sum(if_any$row_info$type == "missing"), 2L)  # age and egfr only
})

test_that("weights give weighted columns and a weight total in long layout", {
  ans <- make(weights = "weight", layout = "long")
  expect_true("Sum of weights" %in% names(ans$table))
  expect_true(ans$settings$weighted)
})

test_that("notes styles work and flextables build for every combination", {
  for (layout in c("wide", "long")) for (style in c("full", "short", "none")) {
    ans <- make(layout = layout, notes = style)
    expect_s3_class(ans$flextable, "flextable")
    expect_s3_class(table1_flextable(ans, font_size = 8, include_notes = FALSE),
                    "flextable")
    expect_equal(length(ans$notes) == 0L, style == "none")
    expect_output(print(ans), "Trial A")
  }
  expect_gt(length(make(notes = "full")$notes) + 5L, length(make(notes = "short")$notes))
  expect_gt(sum(nchar(make(notes = "full")$notes)), sum(nchar(make(notes = "short")$notes)))
})

test_that("trials without the SMD pair and single-arm trials are handled", {
  d <- example_trial_data()
  d$arm <- as.character(d$arm)
  b <- d$trial == "Trial B"
  d$arm[b] <- ifelse(d$arm[b] == "Active", "Drug X", "Placebo")
  extra <- d[1:5, ]
  extra$trial <- "Trial D"
  extra$arm <- "Placebo"
  d <- rbind(d, extra)
  expect_warning(
    ans <- nice_trial_table1(d, "trial", "arm", c("age", "sex"),
                              treatment_for_SMD = pair),
    "Trial D")
  expect_equal(names(ans$trials), c("Trial A", "Trial B", "Trial C"))
  expect_true(all(is.na(ans$smd$smd[ans$smd$trial == "Trial B"])))
  expect_true(any(grepl("not applicable", ans$notes)))
  expect_true(any(ans$table == "\u2014"))
})

test_that("more than two arms requires treatment_for_SMD", {
  expect_error(nice_trial_table1(example_trial_data(), "trial", "arm", "age"),
               "treatment_for_SMD")
})

test_that("orders, labels, and input validation", {
  d <- example_trial_data()
  ans <- nice_trial_table1(d, "trial", "arm", c("age", "sex"),
                            print_covariate_names = c(sex = "Sex", age = "Age (y)"),
                            treatment_for_SMD = pair,
                            trial_order = c("Trial C", "Trial A", "Trial B"),
                            treatment_order = c("Active", "Placebo", "High dose"))
  expect_equal(names(ans$trials), c("Trial C", "Trial A", "Trial B"))
  expect_equal(ans$table$Variable[ans$row_info$type == "variable"], c("Age (y)", "Sex"))
  expect_equal(ans$groups$treatment[1:3], c("Active", "Placebo", "High dose"))
  bad <- function(...) nice_trial_table1(d, "trial", "arm", "age",
                                         treatment_for_SMD = pair, ...)
  expect_error(bad(layout = "tall"), "layout")
  expect_error(bad(continuous_stats = "sd"), "continuous_stats")
  expect_error(bad(notes = "medium"), "notes")
  expect_error(bad(show_smd = NA), "show_smd")
  expect_error(bad(show_missing = "sometimes"), "show_missing")
  expect_error(bad(trial_order = "Trial A"), "trial_order")
  expect_error(nice_trial_table1(d, "trial", "arm", "age",
                                 treatment_for_SMD = c("Placebo", "Nope")),
               "treatment_for_SMD")
  expect_error(nice_trial_table1(1, "trial", "arm"), "data.frame")
})

test_that("rows with missing trial/treatment are excluded with a warning", {
  d <- example_trial_data()
  d$trial[1] <- NA
  expect_warning(
    ans <- nice_trial_table1(d, "trial", "arm", "age", treatment_for_SMD = pair,
                              notes = "short"), "excluded")
  expect_true(any(grepl("excluded", ans$notes)))
})

test_that("Word export, as.data.frame and kable-free printing work", {
  ans <- make()
  file <- tempfile(fileext = ".docx")
  folder <- tempfile(); dir.create(folder)
  on.exit(unlink(c(file, folder), recursive = TRUE), add = TRUE)
  save_table1_docx(ans, file, landscape = TRUE)
  utils::unzip(file, files = "word/document.xml", exdir = folder)
  xml <- paste(readLines(file.path(folder, "word/document.xml"), warn = FALSE), collapse = "")
  expect_match(xml, "w:gridSpan")
  expect_match(xml, "w:tblHeader")
  expect_match(xml, "Trial B")
  expect_equal(as.data.frame(ans), ans$table)
  path2 <- tempfile(fileext = ".docx")
  on.exit(unlink(path2), add = TRUE)
  nice_trial_table1(example_trial_data(), "trial", "arm", "age",
                    treatment_for_SMD = pair, docx_path = path2)
  expect_true(file.exists(path2))
})
