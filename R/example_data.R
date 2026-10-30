#' Reproducible synthetic data for Table 1 examples
#' @export
example_table1_data <- function() {
  # Fixed values make this example reproducible without changing RNG state.
  n <- 90L
  i <- seq_len(n)
  group <- factor(rep(c("Control", "Treatment", "Registry"), each = 30L),
                   levels = c("Control", "Treatment", "Registry"))
  age <- 36 + (i * 7 %% 43) + rep(c(0, 2, 4), each = 30L)
  age[c(4, 37, 69)] <- NA_real_
  bmi <- 19 + (i * 13 %% 151) / 10 + rep(c(0, 1, .5), each = 30L)
  bmi[c(7, 38, 72, 75)] <- NA_real_
  sex <- factor(rep(c("Female", "Male", "Female", "Male", "Female"), length.out = n))
  sex[c(3, 35, 66)] <- NA
  smoking <- rep(c("Never", "Former", "Current", "Never", "Former", "Never", "Current"),
                 length.out = n)
  smoking[c(2, 40, 68)] <- NA_character_
  stage_code <- rep(c(1L, 1L, 2L, 3L, 2L, 3L, 1L), length.out = n)
  stage_code[c(5, 36, 70)] <- NA_integer_
  data.frame(group = group, age = age, bmi = bmi, sex = sex,
              smoking = smoking, stage_code = stage_code,
              analysis_weight = .5 + (i * 11 %% 19) / 10,
              stratum = rep(c("North", "South"), length.out = n),
              cluster = i, stringsAsFactors = FALSE)
}

#' Reproducible synthetic multi-trial data for examples
#' @export
example_trial_data <- function() {
  sizes <- c(`Trial A` = 60L, `Trial B` = 48L, `Trial C` = 72L)
  trial <- rep(names(sizes), sizes)
  i <- sequence(sizes)
  shift <- c(`Trial A` = 0, `Trial B` = 3, `Trial C` = -2)[trial]
  arm <- ifelse(trial == "Trial C",
                c("Placebo", "Active", "High dose")[(i - 1L) %% 3L + 1L],
                c("Placebo", "Active")[(i - 1L) %% 2L + 1L])
  age <- 48 + ((i * 7L) %% 31L) + shift + ifelse(arm == "Active", 1, 0)
  egfr <- 30 + ((i * 11L) %% 40L) / 2 + shift
  sex <- c("Female", "Male", "Female", "Male", "Male")[(i - 1L) %% 5L + 1L]
  diabetes <- c("No", "Yes", "No", "Yes", "No", "No", "Yes")[(i - 1L) %% 7L + 1L]
  ckd_stage <- ifelse(trial == "Trial A",
                      c("G3", "G4", "G3")[(i - 1L) %% 3L + 1L],
                      c("G3", "G4", "G3", "G5", "G4")[(i - 1L) %% 5L + 1L])
  age[c(4, 70, 130)] <- NA_real_
  egfr[c(10, 75)] <- NA_real_
  data.frame(
    trial = factor(trial, levels = names(sizes)),
    arm = factor(arm, levels = c("Placebo", "Active", "High dose")),
    age = age, egfr = egfr, sex = factor(sex), diabetes = diabetes,
    ckd_stage = ckd_stage, weight = .5 + ((i * 5L) %% 13L) / 10,
    stringsAsFactors = FALSE)
}
