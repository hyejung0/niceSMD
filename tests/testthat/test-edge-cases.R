test_that("labels and nonsyntactic names cannot break SMD alignment", {
  d <- data.frame(g = rep(c("A", "B"), each = 6),
                  x = 1:12, y = c(2, 4, 3, 8, 6, 7, 3, 6, 8, 9, 12, 13))
  names(d)[2:3] <- c("blood pressure", "value=score")
  ans <- nice_SMD_table1(d, "g", names(d)[2:3],
                          print_covariate_names = c("Same = label (%)", "Same = label (%)"))
  expect_equal(nrow(ans$table), 8L)
  expect_equal(ans$smd$variable, names(d)[2:3])
  expect_true(all(is.finite(ans$smd$smd)))
  expect_equal(sum(ans$row_info$type == "variable"), 2L)
})

test_that("numeric categorical overrides and character factors agree", {
  d <- data.frame(g = rep(c("A", "B"), each = 6),
                  z = rep(c(1, 1, 2, 2, 3, 3), 2))
  a <- nice_SMD_table1(d, "g", "z", categorical_vars = "z")
  d$z <- as.character(d$z)
  b <- nice_SMD_table1(d, "g", "z")
  expect_equal(a$smd$smd, b$smd$smd)
  expect_equal(sum(a$row_info$type == "category"), 3L)
})

test_that("unweighted category and missing percentages use distinct denominators", {
  d <- data.frame(g = rep(c("A", "B"), each = 4),
                  z = c("Yes", "No", NA, "Yes", "No", "Yes", "No", NA))
  ans <- nice_SMD_table1(d, "g", "z", catDigits = 2)
  yes <- which(ans$table$Variable == "Yes")
  missing <- which(ans$row_info$type == "missing")
  expect_equal(ans$table[yes, 2], "2 (66.67%)")
  expect_equal(ans$table[missing, 2], "1 (25.00%)")
})

test_that("missing summaries and degenerate SMDs are explicit", {
  d <- data.frame(g = rep(c("A", "B"), each = 4),
                  equal = rep(5, 8), different = rep(c(1, 2), each = 4),
                  empty = rep(NA_real_, 8),
                  z = factor(rep("one", 8)),
                  binary = factor(rep(c("a", "b"), each = 4)))
  ans <- nice_SMD_table1(d, "g", names(d)[-1])
  expect_equal(ans$smd$smd[c(1, 2, 4, 5)], c(0, Inf, 0, Inf))
  expect_true(is.na(ans$smd$smd[3]))
  expect_equal(ans$smd$status[3], "not_estimable")
  expect_true("NE" %in% ans$table[[ncol(ans$table)]])
  d$multi <- factor(c("a", "a", "b", "b", "c", "c", "d", "d"))
  singular <- nice_SMD_table1(d, "g", "multi")
  expect_equal(singular$smd$status, "not_estimable")
  expect_match(singular$smd$reason, "Singular")
})

test_that("all groups can be displayed with one selected comparison", {
  d <- example_table1_data()
  ans <- nice_SMD_table1(d, "group", "age",
                          group_for_SMD = c("Control", "Treatment"))
  expect_equal(nrow(ans$groups), 3L)
  expect_equal(ncol(ans$table), 5L)
  expect_error(nice_SMD_table1(d, "group", "age"), "more than two groups")
  expect_error(nice_SMD_table1(d, "group", "age",
                 group_for_SMD = c("Control", "Control")), "distinct")
})

test_that("invalid inputs fail before silently recycling or misclassifying", {
  d <- data.frame(g = rep(c("A", "B"), each = 3), x = 1:6, w = 1)
  expect_error(nice_SMD_table1(d, c("A", "B"), "x"), "length nrow")
  expect_error(nice_SMD_table1(d, "g", "x", weights = c(-1, rep(1, 5))), "nonnegative")
  expect_error(nice_SMD_table1(d, "g", "x", weights = c(NA, rep(1, 5))), "without missing")
  expect_error(nice_SMD_table1(d, "g", "x", weights = rep(0, 6)), "positive")
  expect_error(nice_SMD_table1(d, "g", "absent"), "existing column")
  expect_error(nice_SMD_table1(d, "g", "x", print_covariate_names = c("a", "b")), "one nonempty")
  expect_error(nice_SMD_table1(d, "g", "x", catDigits = 1.5), "integer")
  expect_error(nice_SMD_table1(d, "g", "x", categorical_vars = "absent"), "drawn")
  d$x[1] <- Inf
  expect_error(nice_SMD_table1(d, "g", "x"), "Infinite")
})

test_that("zero weights and missing groups are explicitly excluded", {
  d <- data.frame(g = c("A", "A", "A", "B", "B", "B", NA),
                  x = c(1, 2, 1000, 4, 5, 6, 7), w = c(1, 1, 0, 1, 1, 1, 1))
  expect_warning(ans <- nice_SMD_table1(d, "g", "x", weights = "w"), "2 rows excluded")
  expect_equal(ans$groups$n, c(2L, 3L))
  expect_equal(ans$settings$exclusions[["included"]], 5)
})
