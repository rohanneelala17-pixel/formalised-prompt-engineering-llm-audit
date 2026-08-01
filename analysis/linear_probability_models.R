# Linear probability models for the frozen Sami-father experiment.
#
# The treatment coefficient is the formalised-minus-answer-only difference in
# outcome probabilities. HC2 heteroskedasticity-robust standard errors are
# calculated with base R, so this script has no external package dependency.

args <- commandArgs(trailingOnly = TRUE)
dataset_path <- if (length(args) >= 1) {
  args[[1]]
} else {
  "data/responses_with_locked_human_verification_public.csv"
}
output_path <- if (length(args) >= 2) {
  args[[2]]
} else {
  "results/lpm_results.csv"
}

df <- read.csv(dataset_path, stringsAsFactors = FALSE)

needed <- c(
  "response_id",
  "prompt_condition",
  "auditable_correct_answer_human",
  "identifies_nurse_as_samis_father_human",
  "answer_contradictory_human",
  "unresolved_possibility_human",
  "answer_ambiguous_human"
)
missing <- setdiff(needed, names(df))
if (length(missing) > 0) {
  stop("Missing expected columns: ", paste(missing, collapse = ", "))
}

stopifnot(
  nrow(df) == 576,
  length(unique(df$response_id)) == 576,
  sum(df$prompt_condition == "answer_only") == 288,
  sum(df$prompt_condition == "formalised_argumentation") == 288
)

df$formalised <- as.integer(df$prompt_condition == "formalised_argumentation")

fit_lpm <- function(outcome, label, family, desirable_direction) {
  y <- df[[outcome]]
  if (!all(y %in% c(0, 1))) {
    stop("Outcome is not binary: ", outcome)
  }

  fit <- lm(y ~ formalised, data = df)
  design <- model.matrix(fit)
  residual <- residuals(fit)
  leverage <- hatvalues(fit)
  omega <- residual^2 / (1 - leverage)
  bread <- solve(crossprod(design))
  meat <- crossprod(design, design * omega)
  vcov_hc2 <- bread %*% meat %*% bread

  estimate <- unname(coef(fit)["formalised"])
  standard_error <- unname(sqrt(diag(vcov_hc2))["formalised"])
  z_value <- estimate / standard_error
  p_value <- 2 * pnorm(abs(z_value), lower.tail = FALSE)

  data.frame(
    outcome = outcome,
    label = label,
    family = family,
    desirable_direction = desirable_direction,
    answer_only_rate = mean(y[df$formalised == 0]),
    formalised_rate = mean(y[df$formalised == 1]),
    risk_difference = estimate,
    hc2_standard_error = standard_error,
    ci_95_lower = estimate - qnorm(0.975) * standard_error,
    ci_95_upper = estimate + qnorm(0.975) * standard_error,
    p_value = p_value,
    stringsAsFactors = FALSE
  )
}

results <- rbind(
  fit_lpm(
    "auditable_correct_answer_human",
    "Strict committed correctness",
    "confirmatory",
    "positive"
  ),
  fit_lpm(
    "identifies_nurse_as_samis_father_human",
    "Identifies father solution",
    "exploratory",
    "positive"
  ),
  fit_lpm(
    "answer_contradictory_human",
    "Contains contradiction",
    "exploratory",
    "negative"
  ),
  fit_lpm(
    "unresolved_possibility_human",
    "Leaves answer as unresolved possibility",
    "exploratory",
    "context-dependent"
  ),
  fit_lpm(
    "answer_ambiguous_human",
    "Coded ambiguous",
    "exploratory",
    "negative"
  )
)

results$holm_adjusted_p <- NA_real_
exploratory <- results$family == "exploratory"
results$holm_adjusted_p[exploratory] <- p.adjust(
  results$p_value[exploratory],
  method = "holm"
)

dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)
write.csv(results, output_path, row.names = FALSE)

print(results, row.names = FALSE, digits = 4)
cat("\nTreatment coefficient: formalised probability minus answer-only probability.\n")
cat("Standard errors: HC2 heteroskedasticity-robust.\n")
cat("Wrote", output_path, "\n")
