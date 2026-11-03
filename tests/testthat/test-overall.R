pair <- c("Control", "Treatment")
tpair <- c("Placebo", "Active")

test_that("group = NULL gives one Overall column and no SMD", {
  d <- example_table1_data()
  ans <- nice_SMD_table1(d, group = NULL, covar_names = c("age", "sex"))
  expect_equal(ncol(ans$table), 2L)
  expect_match(names(ans$table)[2], "^Overall\nN = 90$")
  expect_false(any(grepl("SMD", names(ans$table))))
  expect_true(all(ans$smd$status == "not_applicable"))
  expect_true(all(is.na(ans$smd$smd)))
  expect_equal(ans$groups$n, 90L)
  expect_null(ans$settings$comparison)
  expect_s3_class(ans$flextable, "flextable")
  expect_false(any(grepl("SMD", ans$notes)))
})

test_that("overall-only summaries equal pooled summaries from a grouped table", {
  d <- example_table1_data()
  ov <- nice_SMD_table1(d, NULL, c("age", "sex", "smoking"))
  grp <- nice_SMD_table1(d, "group", c("age", "sex", "smoking"),
                         group_for_SMD = pair, overall = TRUE)
  expect_equal(ov$table[[2]], grp$table[[2]])
  expect_equal(ov$table[[1]], grp$table[[1]])
})

test_that("overall = TRUE adds a first column and leaves the SMD unchanged", {
  d <- example_table1_data()
  base <- nice_SMD_table1(d, "group", c("age", "sex"), group_for_SMD = pair)
  ov <- nice_SMD_table1(d, "group", c("age", "sex"), group_for_SMD = pair,
                        overall = TRUE)
  expect_equal(ncol(ov$table), ncol(base$table) + 1L)
  expect_equal(ov$groups$group[1], "Overall")
  expect_equal(ov$groups$n[1], sum(base$groups$n))
  expect_equal(ov$smd$smd, base$smd$smd)
  expect_equal(ov$table[, -2], base$table, ignore_attr = TRUE)
  expect_true(any(grepl("Overall = all included", ov$notes)))
  custom <- nice_SMD_table1(d, "group", "age", group_for_SMD = pair,
                            overall = TRUE, overall_label = "All participants")
  expect_match(names(custom$table)[2], "^All participants")
})

test_that("weighted overall column uses the weights", {
  d <- example_table1_data()
  ans <- nice_SMD_table1(d, NULL, c("age", "sex"), weights = "analysis_weight")
  expect_true(ans$settings$weighted)
  expect_equal(ans$groups$sum_weights, sum(d$analysis_weight))
  expect_match(names(ans$table)[2], "sum\\(w\\)")
})

test_that("overall argument validation", {
  d <- example_table1_data()
  expect_error(nice_SMD_table1(d, "group", "age", overall = NA), "overall")
  expect_error(nice_SMD_table1(d, "group", "age", overall_label = ""), "overall_label")
  expect_error(nice_SMD_table1(d, "group", "age", group_for_SMD = pair,
                               overall = TRUE, overall_label = "Control"),
               "overall_label")
  # two or more groups are still required when a group is supplied
  d$one <- "A"
  expect_error(nice_SMD_table1(d, "one", "age"), "two")
})

test_that("nice_trial_table1 without treatment gives one column per trial", {
  d <- example_trial_data()
  ans <- nice_trial_table1(d, "trial", NULL, c("age", "sex", "ckd_stage"))
  expect_equal(ncol(ans$table), 1L + 3L)
  expect_equal(nrow(ans$smd), 0L)
  expect_equal(names(ans$smd), c("trial", "variable", "label", "smd", "status", "reason"))
  expect_equal(sum(ans$col_info$type == "smd"), 0L)
  expect_match(names(ans$table)[2], "^Trial A: N = 60$")
  expect_equal(ans$settings$title, "Table 1 by trial")
  expect_false("treatment" %in% names(ans$groups))
  expect_false(any(grepl("SMD", ans$notes)))
  expect_error(nice_trial_table1(d, "trial", NULL, "age", treatment_for_SMD = tpair),
               "require treatment")
  # a trial's column equals the same trial summarized on its own
  one <- nice_SMD_table1(d[d$trial == "Trial B", ], NULL, c("age", "sex", "ckd_stage"))
  col <- ans$table[[3]]
  expect_equal(col[ans$table$Variable %in% c("Mean (SD)", "Median (Q1, Q3)", "Female", "Male")],
               one$table[[2]][one$table$Variable %in% c("Mean (SD)", "Median (Q1, Q3)",
                                                         "Female", "Male")])
})

test_that("nice_trial_table1 long layout without treatment omits the Treatment column", {
  d <- example_trial_data()
  ans <- nice_trial_table1(d, "trial", NULL, c("age", "sex"), layout = "long")
  expect_equal(names(ans$table)[1:2], c("Trial", "N"))
  expect_equal(ans$table$Trial, c("Trial A", "Trial B", "Trial C"))
  expect_s3_class(ans$flextable, "flextable")
})

test_that("overall = TRUE pools every included participant across trials", {
  d <- example_trial_data()
  vars <- c("age", "sex")
  wide <- nice_trial_table1(d, "trial", "arm", vars, treatment_for_SMD = tpair,
                            overall = TRUE)
  last <- ncol(wide$table)
  expect_match(names(wide$table)[last], "^Overall: N = 180$")
  expect_equal(tail(wide$col_info$type, 1), "arm")
  expect_equal(nrow(wide$smd), 3L * length(vars))   # no SMD rows for Overall
  pooled <- nice_SMD_table1(d, NULL, vars, show_missing = "if_any")
  expect_equal(wide$table[[last]], pooled$table[[2]])
  long <- nice_trial_table1(d, "trial", "arm", vars, treatment_for_SMD = tpair,
                            overall = TRUE, layout = "long")
  expect_equal(nrow(long$table), 8L)
  expect_equal(unlist(long$table[8, 1:3], use.names = FALSE), c("Overall", "All arms", "180"))
  expect_true(any(grepl("pooled across trials and treatment arms", long$notes)))
  expect_error(nice_trial_table1(d, "trial", "arm", vars, treatment_for_SMD = tpair,
                                 overall = TRUE, overall_label = "Trial A"),
               "overall_label")
  expect_error(nice_trial_table1(d, "trial", "arm", vars, treatment_for_SMD = tpair,
                                 overall = "yes"), "overall")
})

test_that("overall pooled column respects weights and exclusions", {
  d <- example_trial_data()
  d$weight[1:2] <- 0
  expect_warning(
    ans <- nice_trial_table1(d, "trial", NULL, "age", weights = "weight",
                             layout = "long", overall = TRUE),
    "excluded")
  expect_equal(ans$table$N[4], "178")
  expect_true("Sum of weights" %in% names(ans$table))
})

test_that("Word export works for overall-only and overall tables", {
  d <- example_table1_data()
  path <- tempfile(fileext = ".docx")
  on.exit(unlink(path), add = TRUE)
  save_table1_docx(nice_SMD_table1(d, NULL, "age"), path)
  expect_true(file.exists(path))
  path2 <- tempfile(fileext = ".docx")
  on.exit(unlink(path2), add = TRUE)
  save_table1_docx(nice_trial_table1(example_trial_data(), "trial", NULL, "age",
                                     overall = TRUE), path2, landscape = TRUE)
  expect_true(file.exists(path2))
})
