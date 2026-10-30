#' Descriptive tables with one absolute SMD per variable
#'
#' See help("nice_SMD_table1") for the complete interface and conventions.
#' Display labels never serve as variable identifiers.
#' @export
nice_SMD_table1 <- function(
    dat = NULL, group, covar_names = NULL, print_covariate_names = NULL,
    group_for_SMD = NULL, catDigits = 1, contDigits = 2, smdDigits = 3,
    categorical_vars = NULL, weights = NULL, design = NULL,
    weightDigits = 1, show_missing = TRUE, group_order = NULL,
    title = "Table 1", docx_path = NULL, notes = "full") {

  weighted <- !is.null(weights) || !is.null(design)
  if (!is.null(weights) && !is.null(design)) {
    stop("Supply weights OR design, not both.", call. = FALSE)
  }
  if (!is.null(design)) {
    if (!inherits(design, "survey.design") &&
        !inherits(design, "svyrep.design")) {
      stop("design must be a survey.design or svyrep.design object.",
           call. = FALSE)
    }
    if (is.null(dat)) dat <- design$variables
  }
  if (!is.data.frame(dat)) {
    stop("dat must be a data.frame or an object inheriting from it.",
         call. = FALSE)
  }
  dat <- as.data.frame(dat)
  if (!nrow(dat) || !ncol(dat) || anyDuplicated(names(dat)) ||
      anyNA(names(dat)) || any(!nzchar(names(dat)))) {
    stop("dat must be nonempty and have unique, nonempty column names.",
         call. = FALSE)
  }
  if (!is.null(design) && nrow(design$variables) != nrow(dat)) {
    stop("dat and design must contain the same rows in the same order.",
         call. = FALSE)
  }
  digits <- list(catDigits = catDigits, contDigits = contDigits,
                 smdDigits = smdDigits, weightDigits = weightDigits)
  for (nm in names(digits)) {
    value <- digits[[nm]]
    if (!is.numeric(value) || length(value) != 1L || is.na(value) ||
        !is.finite(value) || value < 0 || value > 10 || value != floor(value)) {
      stop(nm, " must be an integer from 0 to 10.", call. = FALSE)
    }
  }
  missing_mode <- .nice_missing_mode(show_missing)
  if (!is.character(notes) || length(notes) != 1L || is.na(notes) ||
      !notes %in% c("full", "short", "none")) {
    stop("notes must be one of \"full\", \"short\", or \"none\".", call. = FALSE)
  }
  if (!is.character(title) || length(title) != 1L || is.na(title)) {
    stop("title must be one character string.", call. = FALSE)
  }

  group_column <- if (is.character(group) && length(group) == 1L &&
                       !is.na(group) && group %in% names(dat)) group else NULL
  g <- if (!is.null(group_column)) dat[[group_column]] else group
  if (!is.atomic(g) || !is.null(dim(g)) || length(g) != nrow(dat)) {
    stop("group must be a column name or a vector of length nrow(dat).",
         call. = FALSE)
  }
  original_group_levels <- if (is.factor(g)) levels(g) else unique(as.character(g))
  g <- as.character(g)
  if (any(!is.na(g) & !nzchar(g))) {
    stop("Group values must not be empty strings.", call. = FALSE)
  }

  weight_column <- if (is.character(weights) && length(weights) == 1L &&
                        !is.na(weights) && weights %in% names(dat)) weights else NULL
  w <- if (!is.null(design)) {
    as.numeric(stats::weights(design, type = "sampling"))
  } else if (!is.null(weight_column)) {
    dat[[weight_column]]
  } else if (!is.null(weights)) {
    weights
  } else rep(1, nrow(dat))
  if (!is.numeric(w) || !is.null(dim(w)) || length(w) != nrow(dat) ||
      anyNA(w) || any(!is.finite(w)) || any(w < 0)) {
    stop("Weights must be a finite, nonnegative numeric vector without missing values.",
         call. = FALSE)
  }
  if (!any(w > 0)) stop("At least one weight must be positive.", call. = FALSE)

  if (is.null(covar_names)) {
    covar_names <- setdiff(names(dat), c(group_column, weight_column))
  }
  if (!is.character(covar_names) || !length(covar_names) ||
      anyNA(covar_names) || anyDuplicated(covar_names) ||
      any(!covar_names %in% names(dat))) {
    stop("covar_names must contain unique existing column names.", call. = FALSE)
  }
  if (!is.null(categorical_vars) &&
      (!is.character(categorical_vars) || anyNA(categorical_vars) ||
       any(!categorical_vars %in% covar_names))) {
    stop("categorical_vars must be a character vector drawn from covar_names.",
         call. = FALSE)
  }
  labels <- print_covariate_names
  if (is.null(labels)) labels <- covar_names
  if (!is.character(labels) || length(labels) != length(covar_names) ||
      anyNA(labels) || any(!nzchar(labels))) {
    stop("print_covariate_names must supply one nonempty label per variable.",
         call. = FALSE)
  }
  if (!is.null(names(labels))) {
    if (anyDuplicated(names(labels)) || !setequal(names(labels), covar_names)) {
      stop("Named labels must be named by the complete set of covar_names.",
           call. = FALSE)
    }
    labels <- labels[covar_names]
  }
  labels <- unname(labels)

  keep <- !is.na(g) & w > 0
  exclusions <- c(missing_group = sum(is.na(g)),
                  zero_weight = sum(w == 0), included = sum(keep))
  if (!any(keep)) stop("No rows remain after excluding missing groups and zero weights.",
                       call. = FALSE)
  if (any(!keep)) {
    warning(sum(!keep), " rows excluded because their group is missing or their weight is zero.",
            call. = FALSE)
  }
  present <- unique(g[keep])
  if (is.null(group_order)) {
    group_order <- original_group_levels[!is.na(original_group_levels) &
                                           original_group_levels %in% present]
  }
  if (!is.character(group_order) || anyNA(group_order) ||
      anyDuplicated(group_order) || !setequal(group_order, present)) {
    stop("group_order must list every included group exactly once.", call. = FALSE)
  }
  if (length(group_order) < 2L) stop("At least two included groups are required.",
                                   call. = FALSE)
  if (is.null(group_for_SMD)) {
    if (length(group_order) != 2L) {
      stop("Specify group_for_SMD when more than two groups are displayed.",
           call. = FALSE)
    }
    group_for_SMD <- group_order
  }
  group_for_SMD <- as.character(group_for_SMD)
  if (length(group_for_SMD) != 2L || anyNA(group_for_SMD) ||
      anyDuplicated(group_for_SMD) || any(!group_for_SMD %in% group_order)) {
    stop("group_for_SMD must identify two distinct included groups.", call. = FALSE)
  }

  # Fresh syntactic keys avoid formulas built from user column names or labels.
  prefix <- ".niceSMD_"
  if (!is.null(design)) {
    while (any(startsWith(names(design$variables), prefix))) prefix <- paste0(prefix, "x")
  }
  keys <- paste0(prefix, "v", seq_along(covar_names))
  group_key <- paste0(prefix, "group")
  work <- data.frame(row.names = seq_len(nrow(dat)))
  categorical <- logical(length(covar_names))
  for (j in seq_along(covar_names)) {
    v <- dat[[covar_names[j]]]
    categorical[j] <- is.factor(v) || is.character(v) || is.logical(v) ||
      covar_names[j] %in% categorical_vars
    if (!is.null(dim(v)) || is.list(v)) {
      stop("Unsupported matrix/list column: ", covar_names[j], call. = FALSE)
    }
    if (categorical[j]) {
      if (!is.factor(v)) v <- factor(v)
    } else if (!is.numeric(v) || inherits(v, c("Date", "POSIXt", "difftime", "integer64"))) {
      stop("Unsupported continuous column: ", covar_names[j],
           ". Convert it to numeric or factor explicitly.", call. = FALSE)
    } else if (any(!is.finite(v[!is.na(v)]))) {
      stop("Infinite values in continuous column: ", covar_names[j], call. = FALSE)
    }
    work[[keys[j]]] <- v
  }
  work[[group_key]] <- factor(g, levels = group_order)
  if (weighted) {
    if (is.null(design)) {
      work[[paste0(prefix, "weight")]] <- w
      design <- survey::svydesign(
        ids = ~1, weights = stats::reformulate(paste0(prefix, "weight")), data = work)
    } else {
      for (nm in names(work)) design$variables[[nm]] <- work[[nm]]
    }
    design <- design[keep, ]
  }
  work <- work[keep, , drop = FALSE]
  w <- w[keep]
  for (j in which(categorical)) {
    work[[keys[j]]] <- droplevels(work[[keys[j]]])
    if (weighted) design$variables[[keys[j]]] <- work[[keys[j]]]
  }
  g <- as.character(work[[group_key]])
  groups <- data.frame(group = group_order, n = integer(length(group_order)),
                       sum_weights = numeric(length(group_order)),
                       effective_n = numeric(length(group_order)),
                       stringsAsFactors = FALSE)
  for (k in seq_along(group_order)) {
    wk <- w[g == group_order[k]]
    groups$n[k] <- length(wk)
    groups$sum_weights[k] <- sum(wk)
    groups$effective_n[k] <- sum(wk)^2 / sum(wk^2)
  }

  summary_list <- lapply(seq_along(keys), function(j) {
    lapply(group_order, function(level) {
      idx <- which(g == level)
      v <- work[[keys[j]]][idx]
      observed <- !is.na(v)
      wi <- w[idx]
      missing_count <- sum(wi[!observed])
      observed_weight <- sum(wi[observed])
      ans <- list(n_observed = sum(observed), observed_weight = observed_weight,
                  missing_count = missing_count,
                  missing_pct = 100 * missing_count / sum(wi))
      if (categorical[j]) {
        levs <- levels(work[[keys[j]]])
        ans$counts <- vapply(levs, function(lev) sum(wi[!is.na(v) & v == lev]), numeric(1))
        ans$pct <- if (observed_weight > 0) 100 * ans$counts / observed_weight else
          rep(NA_real_, length(levs))
      } else {
        des <- if (weighted && any(observed)) design[idx[observed], ] else NULL
        ans$continuous <- .nice_continuous(v[observed], des, keys[j])
      }
      ans
    })
  })

  smd <- data.frame(variable = covar_names, label = labels,
                    smd = rep(NA_real_, length(keys)),
                    status = rep("not_estimable", length(keys)),
                    reason = rep("", length(keys)), stringsAsFactors = FALSE)
  pair_idx <- which(g %in% group_for_SMD)
  pair_work <- droplevels(work[pair_idx, , drop = FALSE])
  pair_design <- if (weighted) design[pair_idx, ] else NULL
  if (weighted) {
    for (nm in c(keys, group_key)) pair_design$variables[[nm]] <- pair_work[[nm]]
  }
  for (j in seq_along(keys)) {
    pair_summaries <- summary_list[[j]][match(group_for_SMD, group_order)]
    n_observed <- vapply(pair_summaries, function(z) z$n_observed, numeric(1))
    minimum <- if (categorical[j]) 1 else 2
    if (any(n_observed < minimum)) {
      smd$reason[j] <- paste0("Fewer than ", minimum,
                               " nonmissing positive-weight observations in a comparison group.")
      next
    }
    special <- .nice_smd_special(pair_work[[keys[j]]],
                                 as.character(pair_work[[group_key]]),
                                 w[pair_idx], group_for_SMD, categorical[j],
                                 pair_summaries)
    if (!is.null(special)) {
      smd$smd[j] <- special$value
      smd$reason[j] <- special$reason
    } else {
      extracted <- tryCatch({
        object <- if (weighted) {
          tableone::svyCreateTableOne(vars = keys[j], strata = group_key,
                                     data = pair_design, test = FALSE,
                                     includeNA = FALSE, smd = TRUE)
        } else {
          tableone::CreateTableOne(vars = keys[j], strata = group_key,
                                  data = pair_work, test = FALSE,
                                  includeNA = FALSE, smd = TRUE)
        }
        value <- tableone::ExtractSmd(object, varLabels = FALSE)
        if (is.null(dim(value)) || !keys[j] %in% rownames(value)) {
          stop("No numeric SMD returned for this variable.")
        }
        as.numeric(value[keys[j], 1L])
      }, error = function(e) e)
      if (inherits(extracted, "error")) {
        smd$reason[j] <- conditionMessage(extracted)
      } else {
        smd$smd[j] <- abs(extracted)
        if (is.na(extracted)) smd$reason[j] <- "The SMD calculation returned an undefined value."
      }
    }
    smd$status[j] <- if (is.na(smd$smd[j])) "not_estimable" else if
      (is.infinite(smd$smd[j])) "infinite" else "ok"
  }

  group_headers <- if (weighted) {
    paste0(groups$group, "\nn = ", groups$n, "; sum(w) = ",
           .nice_fmt(groups$sum_weights, weightDigits))
  } else paste0(groups$group, "\nN = ", groups$n)
  smd_header <- paste0("SMD (", group_for_SMD[1L], " vs. ", group_for_SMD[2L], ")")
  headers <- make.unique(c("Variable", group_headers, smd_header))
  rows <- list()
  info <- list()
  add_row <- function(label, values, smd_value, variable, type) {
    rows[[length(rows) + 1L]] <<- c(label, values, smd_value)
    info[[length(info) + 1L]] <<- data.frame(variable = variable, type = type,
                                            stringsAsFactors = FALSE)
  }
  count_digits <- if (weighted) weightDigits else 0
  n_hidden_missing <- 0L
  for (j in seq_along(keys)) {
    z <- summary_list[[j]]
    smd_text <- if (is.na(smd$smd[j])) "NE" else if (is.infinite(smd$smd[j])) "Inf" else
      .nice_fmt(smd$smd[j], smdDigits)
    add_row(labels[j], rep("", length(group_order)), smd_text, covar_names[j], "variable")
    if (categorical[j]) {
      levs <- levels(work[[keys[j]]])
      for (level_index in seq_along(levs)) {
        lev <- levs[level_index]
        values <- vapply(z, function(a) {
          .nice_count_pct(a$counts[level_index], a$pct[level_index],
                          count_digits, catDigits)
        }, character(1))
        add_row(lev, values, "", covar_names[j], "category")
      }
    } else {
      means <- vapply(z, function(a) paste0(.nice_fmt(a$continuous["mean"], contDigits),
                    " (", .nice_fmt(a$continuous["sd"], contDigits), ")"), character(1))
      medians <- vapply(z, function(a) paste0(.nice_fmt(a$continuous["median"], contDigits),
                    " (", .nice_fmt(a$continuous["q1"], contDigits), ", ",
                    .nice_fmt(a$continuous["q3"], contDigits), ")"), character(1))
      add_row("Mean (SD)", means, "", covar_names[j], "summary")
      add_row("Median (Q1, Q3)", medians, "", covar_names[j], "summary")
    }
    has_missing <- any(vapply(z, function(a) a$missing_count > 0, logical(1)))
    if (missing_mode == "always" || (missing_mode == "if_any" && has_missing)) {
      missing_values <- vapply(z, function(a) {
        .nice_count_pct(a$missing_count, a$missing_pct, count_digits, catDigits)
      }, character(1))
      add_row("Missing", missing_values, "", covar_names[j], "missing")
    } else if (missing_mode == "if_any") {
      n_hidden_missing <- n_hidden_missing + 1L
    }
  }
  table <- as.data.frame(do.call(rbind, rows), stringsAsFactors = FALSE)
  names(table) <- headers
  rownames(table) <- NULL
  row_info <- do.call(rbind, info)
  rownames(row_info) <- NULL
  notes_style <- notes
  notes <- .nice_notes(style = notes_style, weighted = weighted,
                       comparison = group_for_SMD,
                       n_excluded = sum(!keep),
                       missing_mode = missing_mode,
                       n_hidden_missing = n_hidden_missing)
  result <- structure(list(table = table, smd = smd, groups = groups,
                            row_info = row_info, notes = notes,
                            settings = list(weighted = weighted,
                              comparison = group_for_SMD, title = title,
                              exclusions = exclusions,
                              show_missing = missing_mode,
                              notes_style = notes_style,
                              categorical_vars = covar_names[categorical],
                              category_denominator = "nonmissing",
                              missing_denominator = "all_included",
                              digits = digits),
                            call = match.call()), class = "nice_table1")
  result$flextable <- table1_flextable(result)
  if (!is.null(docx_path)) save_table1_docx(result, docx_path)
  result
}

.nice_fmt <- function(x, digits) {
  result <- formatC(x, format = "f", digits = digits)
  result[is.na(x)] <- "NA"
  result
}

.nice_count_pct <- function(count, pct, count_digits, pct_digits) {
  paste0(.nice_fmt(count, count_digits), " (", .nice_fmt(pct, pct_digits), "%)")
}

.nice_continuous <- function(x, design, key) {
  ans <- c(mean = NA_real_, sd = NA_real_, median = NA_real_, q1 = NA_real_, q3 = NA_real_)
  if (!length(x)) return(ans)
  if (length(unique(x)) == 1L) {
    ans[] <- x[1L]
    ans["sd"] <- if (length(x) >= 2L) 0 else NA_real_
    return(ans)
  }
  if (is.null(design)) {
    ans["mean"] <- mean(x)
    if (length(x) >= 2L) ans["sd"] <- stats::sd(x)
    ans[c("q1", "median", "q3")] <- stats::quantile(x, c(.25, .5, .75), names = FALSE, type = 7)
  } else {
    formula <- stats::reformulate(key)
    ans["mean"] <- as.numeric(stats::coef(survey::svymean(formula, design, na.rm = TRUE)))[1L]
    if (length(x) >= 2L) {
      variance <- as.numeric(stats::coef(survey::svyvar(formula, design, na.rm = TRUE)))[1L]
      ans["sd"] <- if (is.na(variance)) NA_real_ else sqrt(max(0, variance))
    }
    quantiles <- survey::svyquantile(formula, design, quantiles = c(.25, .5, .75),
                                    ci = FALSE, na.rm = TRUE, qrule = "math")
    ans[c("q1", "median", "q3")] <- as.numeric(stats::coef(quantiles))
  }
  ans
}

.nice_smd_special <- function(x, group, weights, pair, categorical, summaries) {
  if (!categorical) {
    variance <- vapply(summaries, function(a) a$continuous["sd"]^2, numeric(1))
    means <- vapply(summaries, function(a) a$continuous["mean"], numeric(1))
    if (anyNA(variance)) return(list(value = NA_real_, reason = "An SD is unavailable."))
    if (all(variance == 0)) {
      return(list(value = if (means[1L] == means[2L]) 0 else Inf,
                  reason = if (means[1L] == means[2L]) "Identical constant values." else
                    "Different constants and zero standardizing variance."))
    }
    return(NULL)
  }
  levs <- levels(droplevels(x[!is.na(x)]))
  if (length(levs) == 1L) return(list(value = 0, reason = "Identical single observed category."))
  proportions <- lapply(pair, function(g) {
    use <- !is.na(x) & group == g
    vapply(levs, function(lev) sum(weights[use & !is.na(x) & x == lev]), numeric(1)) /
      sum(weights[use])
  })
  if (length(levs) == 2L) {
    p <- vapply(proportions, function(a) a[1L], numeric(1))
    if (all(p * (1 - p) == 0)) {
      return(list(value = if (p[1L] == p[2L]) 0 else Inf,
                  reason = if (p[1L] == p[2L]) "Identical category proportions." else
                    "Different constants and zero standardizing variance."))
    }
    return(NULL)
  }
  reduced <- lapply(proportions, function(p) p[-1L])
  covariance <- lapply(reduced, function(p) diag(p, nrow = length(p)) - tcrossprod(p))
  average <- (covariance[[1L]] + covariance[[2L]]) / 2
  if (qr(average, tol = 1e-10)$rank < nrow(average)) {
    return(list(value = NA_real_, reason = "Singular or numerically singular covariance for multilevel category proportions."))
  }
  NULL
}

# Normalizes show_missing to one of "always", "never", "if_any".
# TRUE/FALSE are accepted for backward compatibility.
.nice_missing_mode <- function(x) {
  bad <- function() stop("show_missing must be TRUE, FALSE, \"always\", \"never\", or \"if_any\".",
                         call. = FALSE)
  if (length(x) != 1L || is.na(x)) bad()
  if (is.logical(x)) return(if (x) "always" else "never")
  if (is.character(x) && x %in% c("always", "never", "if_any")) return(x)
  bad()
}

# Builds the footnote text. "full" documents every convention; "short" gives a
# compact publication-style legend; "none" returns no notes.
.nice_notes <- function(style, weighted, comparison, n_excluded,
                        missing_mode, n_hidden_missing) {
  if (style == "none") return(character(0))
  pair <- paste0(comparison[1L], " and ", comparison[2L])
  pair_vs <- paste0(comparison[1L], " vs. ", comparison[2L])
  if (style == "short") {
    out <- c(
      if (weighted) {
        paste0("Categorical variables: weighted n (%) among nonmissing values. ",
               "Continuous variables: weighted mean (SD) and median (Q1, Q3). ",
               "Missing: weighted n (% of group).")
      } else {
        paste0("Categorical variables: n (%) among nonmissing values. ",
               "Continuous variables: mean (SD) and median (Q1, Q3). ",
               "Missing: n (% of group).")
      },
      paste0("SMD = absolute standardized mean difference (", pair_vs,
             "); NE = not estimable.")
    )
    if (missing_mode == "if_any" && n_hidden_missing > 0L) {
      out <- c(out, "Variables without a Missing row have no missing values.")
    }
    if (n_excluded > 0L) {
      out <- c(out, paste0(n_excluded, " rows excluded (missing group or zero weight)."))
    }
    return(out)
  }
  out <- c(
    if (weighted) {
      "n is the number of people with positive weights; sum(w) and category/missing counts are sums of weights. Weights are used as supplied, without normalization or trimming."
    } else "N and category/missing counts are numbers of people.",
    if (weighted) {
      "Category percentages use the nonmissing sum of weights for that variable and group. Missing percentages use the full group sum of weights."
    } else {
      "Category percentages use the nonmissing number of people for that variable and group. Missing percentages use the full group number of people."
    },
    "Continuous summaries and SMDs exclude missing values separately for each variable. Missingness is not included as a category in SMDs.",
    paste0("Absolute SMDs compare ", pair,
           ". A multilevel categorical SMD compares its category proportions jointly."),
    if (weighted) {
      "Weighted SDs and SMDs follow survey/tableone conventions; weighted quartiles use survey::svyquantile with qrule = 'math'."
    } else "Unweighted quartiles use stats::quantile with type = 7.",
    "NE = not estimable; Inf = a nonzero difference with zero standardizing variance; NA = an unavailable descriptive summary. Details are in the returned smd component."
  )
  if (missing_mode == "if_any" && n_hidden_missing > 0L) {
    out <- c(out, "A Missing row is shown only for variables with at least one missing value; variables without one have no missing values in the included rows.")
  }
  if (n_excluded > 0L) {
    out <- c(out, paste0(n_excluded, " rows were excluded for missing group or zero weight."))
  }
  out
}
