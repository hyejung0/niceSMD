# Run from the package root or any writable working directory after installation.
library(niceSMD)
d <- example_table1_data()
dir.create("output", showWarnings = FALSE)

variables <- c("age", "bmi", "sex", "smoking", "stage_code")
labels <- c(age = "Age in years", bmi = "Body mass index", sex = "Sex",
             smoking = "Smoking history", stage_code = "Stage")

unweighted <- nice_SMD_table1(
  dat = d,
  group = "group",
  covar_names = variables,
  print_covariate_names = labels,
  categorical_vars = "stage_code",
  group_for_SMD = c("Control", "Treatment"),
  catDigits = 1, contDigits = 2, smdDigits = 3,
  title = "Table 1 Participant characteristics"
)
print(unweighted)
save_table1_docx(unweighted, "output/Table1_unweighted.docx", overwrite = TRUE)

weighted <- nice_SMD_table1(
  dat = d,
  group = "group",
  covar_names = variables,
  print_covariate_names = labels,
  categorical_vars = "stage_code",
  group_for_SMD = c("Control", "Treatment"),
  weights = "analysis_weight",
  weightDigits = 1,
  title = "Table 1 Weighted participant characteristics"
)
print(weighted$groups)
print(weighted$smd)
save_table1_docx(weighted, "output/Table1_weighted.docx",
                 landscape = TRUE, overwrite = TRUE)

# Keep calculations separate from formatted table cells:
utils::write.csv(weighted$smd, "output/numeric_SMDs.csv", row.names = FALSE)
utils::write.csv(as.data.frame(weighted), "output/Table1_weighted.csv", row.names = FALSE)

# Manuscript-style table: hide empty Missing rows and use a short legend.
compact <- nice_SMD_table1(
  dat = d, group = "group", covar_names = c("age", "stratum", "sex"),
  group_for_SMD = c("Control", "Treatment"),
  show_missing = "if_any", notes = "short"
)
print(compact)
save_table1_docx(compact, "output/Table1_compact.docx", overwrite = TRUE)

# Survey-design route, retaining stratification:
design <- survey::svydesign(ids = ~cluster, strata = ~stratum,
                             weights = ~analysis_weight, data = d)
survey_table <- nice_SMD_table1(
  group = "group", covar_names = variables,
  print_covariate_names = labels, categorical_vars = "stage_code",
  design = design,
  group_for_SMD = c("Control", "Treatment")
)
print(survey_table$smd)

message("Examples written to: ", normalizePath("output"))
