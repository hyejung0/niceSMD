test_that("continuous and binary SMDs match explicit formulas", {
  d <- data.frame(g = rep(c("A", "B"), each = 6),
                  x = c(1, 2, 3, 4, 5, NA, 2, 4, 5, 7, 8, 9),
                  b = factor(c(0, 0, 0, 1, 1, NA, 0, 0, 1, 1, 1, 1)))
  ans <- nice_SMD_table1(d, "g", c("x", "b"))
  a <- d$x[d$g == "A"]
  b <- d$x[d$g == "B"]
  expected <- abs(mean(a, na.rm = TRUE) - mean(b)) /
    sqrt((var(a, na.rm = TRUE) + var(b)) / 2)
  expect_equal(ans$smd$smd[1], expected)
  pa <- 2 / 5
  pb <- 4 / 6
  expect_equal(ans$smd$smd[2], abs(pa - pb) /
                 sqrt((pa * (1 - pa) + pb * (1 - pb)) / 2))
})

test_that("multilevel SMD matches a joint categorical distance", {
  d <- data.frame(g = rep(c("A", "B"), each = 10),
                  cat = factor(c(rep(c("a", "b", "c"), c(5, 3, 2)),
                                 rep(c("a", "b", "c"), c(2, 4, 4)))))
  ans <- nice_SMD_table1(d, "g", "cat")
  pa <- c(.3, .2)
  pb <- c(.4, .4)
  covariance <- ((diag(pa) - tcrossprod(pa)) + (diag(pb) - tcrossprod(pb))) / 2
  expected <- sqrt(drop(t(pa - pb) %*% solve(covariance, pa - pb)))
  expect_equal(ans$smd$smd, expected)
  expect_equal(sum(nzchar(ans$table[[ncol(ans$table)]])), 1L)
})

test_that("weighted summaries and SMDs use the same survey convention", {
  d <- data.frame(g = rep(c("A", "B"), each = 5),
                  x = c(1, 2, 3, 6, NA, 2, 4, 5, 7, 10),
                  w = c(.5, 1, 2, 3, 1.5, 1, 1.5, 2, .5, 3))
  des <- survey::svydesign(ids = ~1, weights = ~w, data = d)
  ans <- nice_SMD_table1(d, "g", "x", weights = "w")
  av <- survey::svyvar(~x, des[des$variables$g == "A", ], na.rm = TRUE)
  bv <- survey::svyvar(~x, des[des$variables$g == "B", ], na.rm = TRUE)
  am <- weighted.mean(d$x[d$g == "A"], d$w[d$g == "A"], na.rm = TRUE)
  bm <- weighted.mean(d$x[d$g == "B"], d$w[d$g == "B"], na.rm = TRUE)
  expected <- abs(am - bm) / sqrt((as.numeric(coef(av)) + as.numeric(coef(bv))) / 2)
  expect_equal(ans$smd$smd, expected)
  expect_equal(ans$groups$sum_weights, c(8, 8))
  expect_equal(ans$groups$effective_n[1], 8^2 / sum(d$w[1:5]^2))
  missing_row <- which(ans$row_info$type == "missing")
  expect_equal(ans$table[missing_row, 2], "1.5 (18.8%)")
  from_design <- nice_SMD_table1(group = "g", covar_names = "x", design = des)
  expect_equal(from_design$smd$smd, ans$smd$smd)
})

test_that("weighted categorical denominators are nonmissing weight totals", {
  d <- data.frame(g = rep(c("A", "B"), each = 4),
                  z = c("Yes", "No", NA, "Yes", "No", "Yes", "No", NA),
                  w = c(1, 2, 3, 4, 1, 2, 3, 4))
  ans <- nice_SMD_table1(d, "g", "z", weights = "w", catDigits = 2)
  yes <- which(ans$table$Variable == "Yes")
  missing <- which(ans$row_info$type == "missing")
  expect_equal(ans$table[yes, 2], "5.0 (71.43%)")
  expect_equal(ans$table[missing, 2], "3.0 (30.00%)")
  pa <- 5 / 7
  pb <- 2 / 6
  expect_equal(ans$smd$smd, abs(pa - pb) /
                 sqrt((pa * (1 - pa) + pb * (1 - pb)) / 2))
})

test_that("multiplying all weights changes counts but not SMDs", {
  d <- example_table1_data()
  a <- nice_SMD_table1(d, "group", c("age", "smoking"),
                      weights = d$analysis_weight,
                      group_for_SMD = c("Control", "Treatment"))
  b <- nice_SMD_table1(d, "group", c("age", "smoking"),
                      weights = 10 * d$analysis_weight,
                      group_for_SMD = c("Control", "Treatment"))
  expect_equal(a$smd$smd, b$smd$smd)
  expect_equal(b$groups$sum_weights, 10 * a$groups$sum_weights)
})

test_that("complex survey and replicate-weight designs are accepted", {
  d <- example_table1_data()
  des <- survey::svydesign(ids = ~cluster, strata = ~stratum,
                           weights = ~analysis_weight, data = d)
  ans <- nice_SMD_table1(group = "group", covar_names = c("age", "smoking"),
                          group_for_SMD = c("Control", "Treatment"), design = des)
  expect_true(all(ans$smd$status == "ok"))
  repdes <- survey::as.svrepdesign(des, type = "JKn")
  repans <- nice_SMD_table1(group = "group", covar_names = "age",
                            group_for_SMD = c("Control", "Treatment"), design = repdes)
  expect_equal(repans$smd$smd, ans$smd$smd[1], tolerance = 1e-7)
  expect_equal(names(des$variables), names(d))
})
