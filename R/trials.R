#' Descriptive tables by trial and treatment arm
#'
#' See help("nice_trial_table1") for the complete interface.
#' @export
nice_trial_table1 <- function(
    dat, trial, treatment = NULL, covar_names = NULL, print_covariate_names = NULL,
    treatment_for_SMD = NULL, treatment_order = NULL, trial_order = NULL,
    layout = "wide", show_smd = TRUE, continuous_stats = "both",
    catDigits = 1, contDigits = 2, smdDigits = 3, categorical_vars = NULL,
    weights = NULL, weightDigits = 1, show_missing = "if_any",
    title = "Table 1 by trial and treatment", docx_path = NULL,
    notes = "full", overall = FALSE, overall_label = "Overall") {

  if (!is.data.frame(dat)) {
    stop("dat must be a data.frame or an object inheriting from it.", call. = FALSE)
  }
  dat <- as.data.frame(dat)
  if (!nrow(dat) || !ncol(dat) || anyDuplicated(names(dat)) ||
      anyNA(names(dat)) || any(!nzchar(names(dat)))) {
    stop("dat must be nonempty and have unique, nonempty column names.", call. = FALSE)
  }
  one_of <- function(x, choices, nm) {
    if (!is.character(x) || length(x) != 1L || is.na(x) || !x %in% choices) {
      stop(nm, " must be one of ", paste0("\"", choices, "\"", collapse = ", "),
           ".", call. = FALSE)
    }
  }
  one_of(layout, c("wide", "long"), "layout")
  one_of(continuous_stats, c("both", "mean_sd", "median_iqr"), "continuous_stats")
  one_of(notes, c("full", "short", "none"), "notes")
  if (!is.logical(show_smd) || length(show_smd) != 1L || is.na(show_smd)) {
    stop("show_smd must be TRUE or FALSE.", call. = FALSE)
  }
  if (!is.character(title) || length(title) != 1L || is.na(title)) {
    stop("title must be one character string.", call. = FALSE)
  }
  if (!is.logical(overall) || length(overall) != 1L || is.na(overall)) {
    stop("overall must be TRUE or FALSE.", call. = FALSE)
  }
  if (!is.character(overall_label) || length(overall_label) != 1L ||
      is.na(overall_label) || !nzchar(overall_label)) {
    stop("overall_label must be one nonempty character string.", call. = FALSE)
  }
  has_treatment <- !is.null(treatment)
  if (!has_treatment && identical(title, "Table 1 by trial and treatment")) {
    title <- "Table 1 by trial"
  }
  if (!has_treatment && (!is.null(treatment_for_SMD) || !is.null(treatment_order))) {
    stop("treatment_for_SMD and treatment_order require treatment.", call. = FALSE)
  }
  missing_mode <- .nice_missing_mode(show_missing)
  digits <- list(catDigits = catDigits, contDigits = contDigits,
                 smdDigits = smdDigits, weightDigits = weightDigits)
  for (nm in names(digits)) {
    value <- digits[[nm]]
    if (!is.numeric(value) || length(value) != 1L || is.na(value) ||
        !is.finite(value) || value < 0 || value > 10 || value != floor(value)) {
      stop(nm, " must be an integer from 0 to 10.", call. = FALSE)
    }
  }

  resolve <- function(arg, what) {
    column <- if (is.character(arg) && length(arg) == 1L && !is.na(arg) &&
                  arg %in% names(dat)) arg else NULL
    value <- if (!is.null(column)) dat[[column]] else arg
    if (!is.atomic(value) || !is.null(dim(value)) || length(value) != nrow(dat)) {
      stop(what, " must be a column name or a vector of length nrow(dat).", call. = FALSE)
    }
    list(value = value, column = column)
  }
  trial_info <- resolve(trial, "trial")
  treat_info <- if (has_treatment) resolve(treatment, "treatment") else
    list(value = rep(NA_character_, nrow(dat)), column = NULL)
  trial_raw <- trial_info$value
  treat_raw <- treat_info$value
  trial_chr <- as.character(trial_raw)
  treat_chr <- as.character(treat_raw)
  if (any(!is.na(trial_chr) & !nzchar(trial_chr)) ||
      (has_treatment && any(!is.na(treat_chr) & !nzchar(treat_chr)))) {
    stop("Trial and treatment values must not be empty strings.", call. = FALSE)
  }

  weighted <- !is.null(weights)
  weight_column <- NULL
  w <- rep(1, nrow(dat))
  if (weighted) {
    weight_info <- resolve(weights, "weights")
    w <- weight_info$value
    weight_column <- weight_info$column
    if (!is.numeric(w) || anyNA(w) || any(!is.finite(w)) || any(w < 0)) {
      stop("Weights must be a finite, nonnegative numeric vector without missing values.",
           call. = FALSE)
    }
  }

  if (is.null(covar_names)) {
    covar_names <- setdiff(names(dat), c(trial_info$column, treat_info$column, weight_column))
  }
  if (!is.character(covar_names) || !length(covar_names) ||
      anyNA(covar_names) || anyDuplicated(covar_names) ||
      any(!covar_names %in% names(dat))) {
    stop("covar_names must contain unique existing column names.", call. = FALSE)
  }

  keep <- !is.na(trial_chr) & (!has_treatment | !is.na(treat_chr)) & w > 0
  n_excluded <- sum(!keep)
  if (!any(keep)) stop("No rows remain after exclusions.", call. = FALSE)
  if (n_excluded > 0L) {
    warning(n_excluded, " rows excluded because their trial or treatment is missing ",
            "or their weight is zero.", call. = FALSE)
  }

  level_order <- function(raw, chr, supplied, what) {
    present <- unique(chr[keep])
    if (is.null(supplied)) {
      lv <- if (is.factor(raw)) levels(raw) else unique(as.character(raw))
      return(lv[!is.na(lv) & lv %in% present])
    }
    if (!is.character(supplied) || anyNA(supplied) || anyDuplicated(supplied) ||
        !setequal(supplied, present)) {
      stop(what, " must list every included value exactly once.", call. = FALSE)
    }
    supplied
  }
  trial_levels <- level_order(trial_raw, trial_chr, trial_order, "trial_order")
  arm_levels <- if (has_treatment) {
    level_order(treat_raw, treat_chr, treatment_order, "treatment_order")
  } else character(0)
  if (overall && overall_label %in% trial_levels) {
    stop("overall_label must differ from the trial names.", call. = FALSE)
  }

  if (!is.null(treatment_for_SMD)) {
    treatment_for_SMD <- as.character(treatment_for_SMD)
    if (length(treatment_for_SMD) != 2L || anyNA(treatment_for_SMD) ||
        anyDuplicated(treatment_for_SMD) || any(!treatment_for_SMD %in% arm_levels)) {
      stop("treatment_for_SMD must name two distinct treatments present in the data.",
           call. = FALSE)
    }
  }

  # One nice_SMD_table1 per trial; everything below only arranges the pieces.
  make_entry <- function(res, arms, smd_ok, has_smd, is_overall = FALSE) {
    ri <- res$row_info
    labs <- as.character(res$table[[1L]])
    list(
      res = res, arms = arms, smd_ok = smd_ok, has_smd = has_smd,
      is_overall = is_overall, single = !has_smd,
      keys = paste(ri$variable, ri$type, ifelse(ri$type == "variable", "", labs), sep = "\r"),
      has_cat = vapply(covar_names, function(v) any(ri$variable == v & ri$type == "category"),
                       logical(1)))
  }
  summarize <- function(idx, label, arms = NULL, pair = NULL) {
    tryCatch(
      nice_SMD_table1(
        dat = dat[idx, covar_names, drop = FALSE],
        group = if (is.null(arms)) NULL else treat_chr[idx],
        covar_names = covar_names, print_covariate_names = print_covariate_names,
        group_for_SMD = pair, catDigits = catDigits, contDigits = contDigits,
        smdDigits = smdDigits, categorical_vars = categorical_vars,
        weights = if (weighted) w[idx] else NULL, weightDigits = weightDigits,
        show_missing = missing_mode, group_order = arms, title = label,
        notes = "none", overall_label = overall_label),
      error = function(e) stop(label, ": ", conditionMessage(e), call. = FALSE))
  }
  results <- list()
  skipped <- character(0)
  for (tr in trial_levels) {
    idx <- which(keep & trial_chr == tr)
    if (!has_treatment) {
      results[[tr]] <- make_entry(summarize(idx, paste0("Trial '", tr, "'")),
                                  overall_label, smd_ok = FALSE, has_smd = FALSE)
      next
    }
    arms <- arm_levels[arm_levels %in% unique(treat_chr[idx])]
    if (length(arms) < 2L) {
      skipped <- c(skipped, tr)
      next
    }
    smd_ok <- TRUE
    if (!is.null(treatment_for_SMD)) {
      pair <- if (all(treatment_for_SMD %in% arms)) treatment_for_SMD else {
        smd_ok <- FALSE
        arms[1:2]
      }
    } else if (length(arms) == 2L) {
      pair <- arms
    } else {
      stop("Trial '", tr, "' has more than two treatment arms. ",
           "Specify treatment_for_SMD.", call. = FALSE)
    }
    results[[tr]] <- make_entry(summarize(idx, paste0("Trial '", tr, "'"), arms, pair),
                                arms, smd_ok = smd_ok, has_smd = TRUE)
  }
  if (!length(results)) {
    stop("No trial has at least two treatment arms.", call. = FALSE)
  }
  if (length(skipped)) {
    warning("Trials with fewer than two treatment arms were skipped: ",
            paste(skipped, collapse = ", "), ".", call. = FALSE)
  }
  if (overall) {
    # Everyone from the displayed trials, pooled without regard to trial or arm.
    pooled_idx <- which(keep & trial_chr %in% names(results))
    results[[overall_label]] <- make_entry(
      summarize(pooled_idx, paste0("Overall (", overall_label, ")")),
      overall_label, smd_ok = FALSE, has_smd = FALSE, is_overall = TRUE)
  }
  trial_names <- names(results)

  # Common row structure across trials: variable, then its detail rows.
  var_labels <- results[[1L]]$res$smd$label
  cat_vars <- unique(unlist(lapply(results, function(r) r$res$settings$categorical_vars)))
  master_parts <- lapply(seq_along(covar_names), function(j) {
    v <- covar_names[j]
    rows <- do.call(rbind, lapply(results, function(r) {
      ri <- r$res$row_info
      k <- which(ri$variable == v & ri$type != "variable")
      data.frame(type = ri$type[k], label = as.character(r$res$table[[1L]])[k],
                 stringsAsFactors = FALSE)
    }))
    rows <- unique(rows)
    sub_order <- seq_len(nrow(rows))
    if (v %in% cat_vars) {
      lv <- levels(factor(dat[[v]][keep]))
      sub_order <- match(rows$label, lv)
      sub_order[is.na(sub_order)] <- length(lv) + 1L
      sub_order[rows$type != "category"] <- 0L
    }
    rows <- rows[order(match(rows$type, c("summary", "category", "missing")), sub_order), ,
                 drop = FALSE]
    if (continuous_stats == "mean_sd") {
      rows <- rows[rows$type != "summary" | rows$label == "Mean (SD)", , drop = FALSE]
    } else if (continuous_stats == "median_iqr") {
      rows <- rows[rows$type != "summary" | rows$label == "Median (Q1, Q3)", , drop = FALSE]
    }
    data.frame(variable = v,
               type = c("variable", rows$type),
               label = c(var_labels[j], rows$label),
               stringsAsFactors = FALSE)
  })
  master <- do.call(rbind, master_parts)
  master$key <- paste(master$variable, master$type,
                      ifelse(master$type == "variable", "", master$label), sep = "\r")
  rownames(master) <- NULL

  dash <- "\u2014"
  count_digits <- if (weighted) weightDigits else 0
  zero_cell <- .nice_count_pct(0, 0, count_digits, catDigits)
  cells_for <- function(r, arm) {
    vals <- r$res$table[[1L + match(arm, r$arms)]]
    idx <- match(master$key, r$keys)
    out <- vals[idx]
    for (m in which(is.na(idx))) {
      out[m] <- if (master$type[m] == "missing") zero_cell else
        if (master$type[m] == "category" && r$has_cat[[master$variable[m]]]) zero_cell else dash
    }
    out
  }
  smd_cells_for <- function(r) {
    tab <- r$res$table
    out <- character(nrow(master))
    is_var <- master$type == "variable"
    out[is_var] <- if (r$smd_ok) tab[[ncol(tab)]][match(master$key[is_var], r$keys)] else dash
    out
  }

  if (layout == "wide") {
    values <- list(Variable = master$label)
    info <- data.frame(key = "Variable", top = "Variable", bottom = "Variable",
                       trial = NA_character_, arm = NA_character_, type = "label",
                       stringsAsFactors = FALSE)
    for (i in seq_along(results)) {
      r <- results[[i]]
      tn <- trial_names[i]
      for (k in seq_along(r$arms)) {
        key <- paste0("t", i, "_a", k)
        header <- names(r$res$table)[1L + k]
        if (r$single) header <- sub("^[^\n]*\n", "", header)
        values[[key]] <- cells_for(r, r$arms[k])
        info <- rbind(info, data.frame(key = key, top = tn, bottom = header, trial = tn,
                                       arm = r$arms[k], type = "arm",
                                       stringsAsFactors = FALSE))
      }
      if (show_smd && r$has_smd) {
        key <- paste0("t", i, "_smd")
        values[[key]] <- smd_cells_for(r)
        info <- rbind(info, data.frame(key = key, top = tn,
                                       bottom = names(r$res$table)[ncol(r$res$table)],
                                       trial = tn, arm = NA_character_, type = "smd",
                                       stringsAsFactors = FALSE))
      }
    }
    table <- as.data.frame(values, stringsAsFactors = FALSE, check.names = FALSE)
    names(table) <- ifelse(info$type == "label", "Variable",
                           paste0(info$top, ": ", info$bottom))
    row_info <- master[, c("variable", "type")]
  } else {
    body <- which(master$type != "variable")
    body_info <- data.frame(
      key = paste0("c", seq_along(body)),
      top = var_labels[match(master$variable[body], covar_names)],
      bottom = ifelse(master$type[body] == "missing", "Missing", master$label[body]),
      stringsAsFactors = FALSE)
    left <- data.frame(key = c("trial", if (has_treatment) "treatment", "n",
                               if (weighted) "sumw"),
                       top = c("Trial", if (has_treatment) "Treatment", "N",
                               if (weighted) "Sum of weights"),
                       stringsAsFactors = FALSE)
    left$bottom <- left$top
    info <- rbind(left, body_info)
    info$type <- c(rep("label", nrow(left)), rep("value", nrow(body_info)))
    rows <- list()
    row_trial <- character(0)
    row_arm <- character(0)
    for (i in seq_along(results)) {
      r <- results[[i]]
      for (a in r$arms) {
        g <- r$res$groups[match(a, r$res$groups$group), ]
        arm_label <- if (r$is_overall) "All arms" else a
        rows[[length(rows) + 1L]] <- c(
          trial_names[i], if (has_treatment) arm_label, as.character(g$n),
          if (weighted) .nice_fmt(g$sum_weights, weightDigits),
          cells_for(r, a)[body])
        row_trial <- c(row_trial, trial_names[i])
        row_arm <- c(row_arm, arm_label)
      }
    }
    table <- as.data.frame(do.call(rbind, rows), stringsAsFactors = FALSE)
    names(table) <- ifelse(info$type == "label", info$top, paste0(info$top, ": ", info$bottom))
    names(table) <- make.unique(names(table), sep = " #")
    row_info <- data.frame(trial = row_trial, treatment = row_arm, stringsAsFactors = FALSE)
  }
  rownames(table) <- NULL

  groups <- do.call(rbind, lapply(seq_along(results), function(i) {
    g <- results[[i]]$res$groups
    names(g)[names(g) == "group"] <- "treatment"
    if (!has_treatment) g$treatment <- NULL
    cbind(trial = trial_names[i], g, stringsAsFactors = FALSE)
  }))
  rownames(groups) <- NULL
  smd_parts <- lapply(seq_along(results), function(i) {
    if (!results[[i]]$has_smd) return(NULL)
    s <- results[[i]]$res$smd
    if (!results[[i]]$smd_ok) {
      s$smd <- NA_real_
      s$status <- "not_estimable"
      s$reason <- "The requested treatment pair is not present in this trial."
    }
    cbind(trial = trial_names[i], s, stringsAsFactors = FALSE)
  })
  smd_parts <- smd_parts[!vapply(smd_parts, is.null, logical(1))]
  smd <- if (length(smd_parts)) do.call(rbind, smd_parts) else
    data.frame(trial = character(), variable = character(), label = character(),
               smd = numeric(), status = character(), reason = character(),
               stringsAsFactors = FALSE)
  rownames(smd) <- NULL

  hidden <- sum(vapply(covar_names, function(v) !any(master$variable == v & master$type == "missing"),
                       logical(1)))
  notes_style <- notes
  notes <- .nice_trial_notes(
    style = notes_style, weighted = weighted,
    show_smd = show_smd && layout == "wide" && has_treatment,
    pair = treatment_for_SMD, n_excluded = n_excluded, missing_mode = missing_mode,
    n_hidden_missing = hidden, has_treatment = has_treatment, overall = overall,
    used_dash = any(unlist(lapply(results, function(r) vapply(r$arms, function(a) {
      any(cells_for(r, a) == dash)
    }, logical(1))))) || (show_smd && layout == "wide" &&
      any(vapply(results, function(r) r$has_smd && !r$smd_ok, logical(1)))),
    skipped = skipped)

  result <- structure(list(
    table = table, col_info = info, row_info = row_info, smd = smd, groups = groups,
    trials = lapply(results, function(r) r$res), notes = notes,
    settings = list(weighted = weighted, layout = layout, title = title,
                    show_smd = show_smd, show_missing = missing_mode,
                    notes_style = notes_style, continuous_stats = continuous_stats,
                    comparison = treatment_for_SMD, exclusions = n_excluded,
                    overall = overall, overall_label = overall_label,
                    has_treatment = has_treatment,
                    skipped = skipped, digits = digits),
    call = match.call()), class = "nice_trial_table1")
  result$flextable <- table1_flextable(result)
  if (!is.null(docx_path)) save_table1_docx(result, docx_path, landscape = TRUE)
  result
}

.nice_trial_notes <- function(style, weighted, show_smd, pair, n_excluded,
                              missing_mode, n_hidden_missing, used_dash, skipped,
                              has_treatment = TRUE, overall = FALSE) {
  if (style == "none") return(character(0))
  pair_text <- if (is.null(pair)) "the two treatment arms of each trial" else
    paste0(pair[1L], " vs. ", pair[2L])
  w <- if (weighted) "weighted " else ""
  strata <- if (has_treatment) "trial and treatment arm" else "trial"
  unit <- if (has_treatment) "arm" else "trial"
  extra <- c(
    if (overall)
      paste0("Overall = all participants pooled across trials",
             if (has_treatment) " and treatment arms", ", ignoring the trial structure."),
    if (missing_mode == "if_any" && n_hidden_missing > 0L)
      "A Missing row is shown only for variables with at least one missing value in some trial.",
    if (used_dash)
      "\u2014 = not applicable (category not observed in the trial, or SMD pair not available).",
    if (n_excluded > 0L)
      paste0(n_excluded, " rows were excluded for missing trial",
             if (has_treatment) ", missing treatment,", " or zero weight."),
    if (length(skipped))
      paste0("Trials with fewer than two treatment arms were omitted: ",
             paste(skipped, collapse = ", "), ".")
  )
  if (style == "short") {
    return(c(
      paste0("Summaries are computed within each ", strata, ". Categorical: ",
             w, "n (%) among nonmissing values. Continuous: ", w,
             "mean (SD) and median (Q1, Q3). Missing: ", w, "n (% of ", unit, ")."),
      if (show_smd) paste0("SMD = absolute standardized mean difference (", pair_text,
                           "); NE = not estimable."),
      extra))
  }
  c(
    paste0("All summaries are computed separately within each ", strata, "."),
    if (weighted) {
      paste0("n is the number of people with positive weights; counts are sums of weights, used as supplied without normalization or trimming. Category percentages use the nonmissing sum of weights for that variable and ", unit, "; missing percentages use the full ", unit, " sum of weights.")
    } else {
      paste0("N and counts are numbers of people. Category percentages use the nonmissing number of people for that variable and ", unit, "; missing percentages use the full ", unit, " number of people.")
    },
    if (show_smd) {
      "Continuous summaries and SMDs exclude missing values separately for each variable and trial. Missingness is not included as a category in SMDs."
    } else "Continuous summaries exclude missing values separately for each variable and trial.",
    if (show_smd) paste0("Absolute SMDs compare ", pair_text,
                         " within each trial. A multilevel categorical SMD compares its category proportions jointly. ",
                         "NE = not estimable; Inf = a nonzero difference with zero standardizing variance. ",
                         "SMDs are descriptive and are not tests."),
    if (weighted) {
      if (show_smd) {
        "Weighted SDs and SMDs follow survey/tableone conventions; weighted quartiles use survey::svyquantile with qrule = 'math'."
      } else "Weighted SDs follow survey conventions; weighted quartiles use survey::svyquantile with qrule = 'math'."
    } else "Unweighted quartiles use stats::quantile with type = 7.",
    extra)
}

# Flextable for a nice_trial_table1 object (called by table1_flextable()).
.nice_trial_flextable <- function(x, font_size, font_family, include_notes) {
  info <- x$col_info
  tab <- x$table
  names(tab) <- info$key
  ft <- flextable::flextable(tab)
  header <- data.frame(col_keys = info$key, top = info$top, bottom = info$bottom,
                       stringsAsFactors = FALSE)
  ft <- flextable::set_header_df(ft, mapping = header, key = "col_keys")
  ft <- flextable::merge_h(ft, part = "header")
  ft <- flextable::merge_v(ft, part = "header")
  ft <- flextable::theme_booktabs(ft)
  ft <- flextable::font(ft, fontname = font_family, part = "all")
  ft <- flextable::fontsize(ft, size = font_size, part = "all")
  ft <- flextable::align(ft, align = "center", part = "all")
  n_left <- sum(info$type == "label")
  ft <- flextable::align(ft, j = seq_len(n_left), align = "left", part = "all")
  ft <- flextable::bold(ft, part = "header", bold = TRUE)
  if (x$settings$layout == "wide") {
    types <- x$row_info$type
    headings <- which(types == "variable")
    details <- which(types != "variable")
    ft <- flextable::bold(ft, i = headings, j = 1L, bold = TRUE, part = "body")
    ft <- flextable::padding(ft, i = headings, padding.top = 6, part = "body")
    if (length(details)) {
      ft <- flextable::padding(ft, i = details, j = 1L, padding.left = 12, part = "body")
    }
    ft <- flextable::keep_with_next(ft, i = headings, value = TRUE, part = "body")
  } else {
    ft <- flextable::merge_v(ft, j = 1L, part = "body")
    ft <- flextable::valign(ft, j = 1L, valign = "top", part = "body")
    ft <- flextable::bold(ft, j = 1L, bold = TRUE, part = "body")
    ends <- cumsum(rle(x$row_info$trial)$lengths)
    ends <- ends[-length(ends)]
    if (length(ends)) {
      ft <- flextable::hline(ft, i = ends, border = officer::fp_border(width = 0.75),
                             part = "body")
    }
  }
  if (include_notes && length(x$notes)) {
    ft <- flextable::add_footer_lines(ft, values = x$notes)
    ft <- flextable::fontsize(ft, size = max(8, font_size - 1), part = "footer")
    ft <- flextable::align(ft, align = "left", part = "footer")
  }
  ft <- flextable::autofit(ft)
  ft <- flextable::set_table_properties(ft, layout = "autofit", width = 1,
                 opts_word = list(split = FALSE, repeat_headers = TRUE))
  flextable::paginate(ft, init = FALSE, hdr_ftr = TRUE)
}
