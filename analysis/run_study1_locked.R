# Run the full Study 1 analysis inside the package library recorded by renv.
#
# Usage from the repository root:
#   Rscript --vanilla analysis/run_study1_locked.R \
#     data/responses_with_locked_human_verification_public.csv

script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(script_arg) != 1L) stop("Unable to determine runner location.")

runner_path <- normalizePath(sub("^--file=", "", script_arg), mustWork = TRUE)
project_root <- normalizePath(file.path(dirname(runner_path), ".."), mustWork = TRUE)
setwd(project_root)

if (!requireNamespace("renv", quietly = TRUE)) {
  stop("Package 'renv' is required. Run install.packages('renv') and renv::restore().")
}

project_library <- renv::paths$library(project = project_root)
if (!dir.exists(project_library)) {
  stop("The locked R library is absent. Run renv::restore() from the repository root.")
}

.libPaths(c(project_library, .libPaths()))
source(file.path(project_root, "analysis", "study1_analysis.R"), chdir = FALSE)
