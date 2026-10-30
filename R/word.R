#' Format a nice_table1 object as an editable table
#' @export
table1_flextable <- function(x, font_size = 10, font_family = "Arial",
                            include_notes = TRUE) {
  if (!inherits(x, "nice_table1")) stop("x must be a nice_table1 object.", call. = FALSE)
  if (!is.numeric(font_size) || length(font_size) != 1L ||
      !is.finite(font_size) || font_size <= 0) {
    stop("font_size must be one positive number.", call. = FALSE)
  }
  if (!is.character(font_family) || length(font_family) != 1L || is.na(font_family)) {
    stop("font_family must be one character string.", call. = FALSE)
  }
  if (!is.logical(include_notes) || length(include_notes) != 1L || is.na(include_notes)) {
    stop("include_notes must be TRUE or FALSE.", call. = FALSE)
  }
  ft <- flextable::flextable(x$table)
  ft <- flextable::theme_booktabs(ft)
  ft <- flextable::font(ft, fontname = font_family, part = "all")
  ft <- flextable::fontsize(ft, size = font_size, part = "all")
  ft <- flextable::align(ft, j = 1L, align = "left", part = "all")
  ft <- flextable::align(ft, j = seq.int(2L, ncol(x$table)), align = "center", part = "all")
  headings <- which(x$row_info$type == "variable")
  details <- which(x$row_info$type != "variable")
  ft <- flextable::bold(ft, i = headings, j = 1L, bold = TRUE, part = "body")
  ft <- flextable::padding(ft, i = headings, padding.top = 6, part = "body")
  if (length(details)) {
    ft <- flextable::padding(ft, i = details, j = 1L, padding.left = 12, part = "body")
  }
  if (include_notes) {
    ft <- flextable::add_footer_lines(ft, values = x$notes)
    ft <- flextable::fontsize(ft, size = max(8, font_size - 1), part = "footer")
    ft <- flextable::align(ft, align = "left", part = "footer")
  }
  ft <- flextable::autofit(ft)
  ft <- flextable::set_table_properties(ft, layout = "autofit", width = 1,
                 opts_word = list(split = FALSE, repeat_headers = TRUE))
  ft <- flextable::paginate(ft, init = FALSE, hdr_ftr = TRUE)
  # Keep each variable label with its first detail row without forcing an
  # entire large categorical block onto one page.
  keep <- x$row_info$type == "variable"
  ft <- flextable::keep_with_next(ft, i = which(keep), value = TRUE, part = "body")
  ft
}

#' Save a Table 1 object as an editable Word document
#' @export
save_table1_docx <- function(x, path, title = x$settings$title,
                            landscape = FALSE, font_size = 10,
                            font_family = "Arial", include_notes = TRUE,
                            overwrite = FALSE) {
  if (!inherits(x, "nice_table1")) stop("x must be a nice_table1 object.", call. = FALSE)
  if (!is.character(path) || length(path) != 1L || is.na(path) ||
      !grepl("\\.docx$", path, ignore.case = TRUE)) {
    stop("path must be a .docx filename.", call. = FALSE)
  }
  if (!is.logical(overwrite) || length(overwrite) != 1L || is.na(overwrite)) {
    stop("overwrite must be TRUE or FALSE.", call. = FALSE)
  }
  if (file.exists(path) && !overwrite) {
    stop("The file already exists. Use overwrite = TRUE to replace it.", call. = FALSE)
  }
  if (!dir.exists(dirname(path))) stop("The output directory does not exist.", call. = FALSE)
  if (!is.character(title) || length(title) != 1L || is.na(title)) {
    stop("title must be one character string.", call. = FALSE)
  }
  if (!is.logical(landscape) || length(landscape) != 1L || is.na(landscape)) {
    stop("landscape must be TRUE or FALSE.", call. = FALSE)
  }
  ft <- table1_flextable(x, font_size = font_size,
                         font_family = font_family, include_notes = include_notes)
  doc <- officer::read_docx()
  # Set page size explicitly before inserting the table.
  section <- officer::prop_section(
    page_size = officer::page_size(orient = if (landscape) "landscape" else "portrait"),
    page_margins = officer::page_mar(top = .7, bottom = .7, left = .7, right = .7))
  doc <- officer::body_set_default_section(doc, value = section)
  if (nzchar(title)) doc <- officer::body_add_par(doc, value = title, style = "heading 1")
  doc <- flextable::body_add_flextable(doc, value = ft)
  print(doc, target = path)
  invisible(normalizePath(path, mustWork = TRUE))
}
