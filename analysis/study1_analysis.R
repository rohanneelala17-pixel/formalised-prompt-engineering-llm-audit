# =============================================================================
# Study 1: Formalised argumentation prompting vs answer-only prompting
# Causal effect estimation and exploratory decomposition (R)
#
# Usage:
#   Rscript analysis/study1_analysis.R [path/to/responses_with_locked_human_verification.csv]
#
# With no argument, runs on data/synthetic_locked.csv (generated if absent),
# and stamps every output SYNTHETIC VALIDATION RUN. The synthetic file matches
# the frozen marginal counts, so Sections 1-2 reproduce the real results
# exactly; Section 3's joint decomposition is a pipeline check only until the
# real locked CSV is supplied.
#
# Identification note. prompt_condition was randomised by a frozen schedule,
# so between-condition contrasts estimate causal effects of the prompt on
# response behaviour for this item and model configuration. The primary
# analysis (strict correctness) was PRESPECIFIED and is confirmatory. The
# diagnostic contrasts and the recognition/commitment decomposition were
# selected AFTER observing the primary result: they are EXPLORATORY, and the
# decomposition conditions on post-treatment variables, so it is reported as
# descriptive arithmetic, not as identified mediation effects (see the DAG,
# figures/fig4_dag.png).
# =============================================================================

suppressPackageStartupMessages({
  library(ggplot2)
  library(jsonlite)
  library(dplyr)
  library(scales)
})

args <- commandArgs(trailingOnly = TRUE)
frozen <- fromJSON("data/final_analysis_statistics.json")

if (length(args) >= 1) {
  dataset_path <- args[[1]]
  synthetic <- FALSE
} else {
  dataset_path <- "data/synthetic_locked.csv"
  synthetic <- TRUE
  if (!file.exists(dataset_path)) source("analysis/make_synthetic_data.R")
}
run_label <- if (synthetic) "SYNTHETIC VALIDATION RUN" else "LOCKED DATASET"
message("Dataset: ", dataset_path, "  [", run_label, "]")

df <- read.csv(dataset_path, stringsAsFactors = FALSE)

needed <- c("prompt_condition", "pair_id", "response_id",
            "auditable_correct_answer_human",
            "identifies_nurse_as_samis_father_human",
            "answer_contradictory_human",
            "unresolved_possibility_human",
            "answer_ambiguous_human")
missing <- setdiff(needed, names(df))
if (length(missing) > 0) stop("Missing expected columns: ", paste(missing, collapse = ", "))

AO <- "answer_only"; FA <- "formalised_argumentation"
n_arm <- 288L
stopifnot(sum(df$prompt_condition == AO) == n_arm,
          sum(df$prompt_condition == FA) == n_arm)

# --- Statistical machinery (matches the frozen Python analysis) --------------

wilson_ci <- function(k, n, conf = 0.95) {
  z <- qnorm(1 - (1 - conf) / 2)
  p <- k / n
  denom <- 1 + z^2 / n
  centre <- p + z^2 / (2 * n)
  half <- z * sqrt(p * (1 - p) / n + z^2 / (4 * n^2))
  c((centre - half) / denom, (centre + half) / denom)
}

newcombe_rd <- function(k1, n1, k2, n2, conf = 0.95) {
  # risk difference p1 - p2 with Newcombe hybrid-Wilson CI
  w1 <- wilson_ci(k1, n1, conf); w2 <- wilson_ci(k2, n2, conf)
  p1 <- k1 / n1; p2 <- k2 / n2; d <- p1 - p2
  c(rd = d,
    lo = d - sqrt((p1 - w1[1])^2 + (w2[2] - p2)^2),
    hi = d + sqrt((w1[2] - p1)^2 + (p2 - w2[1])^2))
}

contrast_row <- function(name, col, family) {
  kf <- sum(df[[col]][df$prompt_condition == FA])
  ka <- sum(df[[col]][df$prompt_condition == AO])
  nc <- newcombe_rd(kf, n_arm, ka, n_arm)
  ft <- fisher.test(matrix(c(kf, n_arm - kf, ka, n_arm - ka), nrow = 2, byrow = TRUE))
  data.frame(contrast = name, family = family, formalised = kf, answer_only = ka,
             rd = nc["rd"], lo = nc["lo"], hi = nc["hi"],
             odds_ratio = unname(ft$estimate), fisher_p = ft$p.value)
}

# --- Section 0: reconcile against the frozen record --------------------------

frz_diag <- frozen$human_diagnostic_code_counts
frz_get <- function(cond, col) frz_diag[[cond]][[col]][["1"]]
check <- function(label, got, expect) {
  if (!isTRUE(all.equal(got, expect))) stop("FROZEN-COUNT MISMATCH: ", label, " got ", got, " expected ", expect)
  invisible(TRUE)
}
check("AO correct", sum(df$auditable_correct_answer_human[df$prompt_condition == AO]), frozen$human_verified_correct$answer_only)
check("FA correct", sum(df$auditable_correct_answer_human[df$prompt_condition == FA]), frozen$human_verified_correct$formalised_argumentation)
for (col in c("identifies_nurse_as_samis_father_human", "answer_contradictory_human",
              "unresolved_possibility_human", "answer_ambiguous_human")) {
  check(paste("AO", col), sum(df[[col]][df$prompt_condition == AO]), frz_get("answer_only", col))
  check(paste("FA", col), sum(df[[col]][df$prompt_condition == FA]), frz_get("formalised_argumentation", col))
}
message("Section 0: all counts reconcile with the frozen record.")

# --- Section 1: confirmatory primary effect (prespecified) -------------------

primary <- contrast_row("Strict committed correct (PRIMARY)",
                        "auditable_correct_answer_human", "confirmatory")
stopifnot(abs(primary$rd - frozen$formal_minus_answer_only_risk_difference) < 1e-9,
          abs(primary$lo - frozen$newcombe_95_ci[1]) < 1e-9,
          abs(primary$hi - frozen$newcombe_95_ci[2]) < 1e-9)
message(sprintf("Section 1: primary causal effect reproduced: RD %+.2f pp, 95%% CI [%+.2f, %+.2f], Fisher p = %.3f",
                100 * primary$rd, 100 * primary$lo, 100 * primary$hi, primary$fisher_p))

# --- Section 2: exploratory diagnostic contrasts + Holm ----------------------

diag_specs <- list(
  c("Identifies father solution (recognition)", "identifies_nurse_as_samis_father_human"),
  c("Contains contradiction",                   "answer_contradictory_human"),
  c("Presents answer as unresolved (hedging)",  "unresolved_possibility_human"),
  c("Coded ambiguous",                          "answer_ambiguous_human"))
diagnostics <- bind_rows(lapply(diag_specs, function(s) contrast_row(s[1], s[2], "exploratory")))
diagnostics$holm_p <- p.adjust(diagnostics$fisher_p, method = "holm")

# --- Section 3: recognition x commitment decomposition (descriptive) ---------

decomp <- df %>%
  group_by(prompt_condition) %>%
  summarise(
    identified = sum(identifies_nurse_as_samis_father_human),
    identified_and_correct = sum(auditable_correct_answer_human[identifies_nurse_as_samis_father_human == 1]),
    correct_without_identification = sum(auditable_correct_answer_human[identifies_nurse_as_samis_father_human == 0]),
    .groups = "drop") %>%
  mutate(commitment_rate = identified_and_correct / identified)

p_rec  <- setNames(decomp$identified / n_arm, decomp$prompt_condition)
p_com  <- setNames(decomp$commitment_rate,     decomp$prompt_condition)
extra  <- setNames(decomp$correct_without_identification / n_arm, decomp$prompt_condition)
waterfall <- data.frame(
  component = c("Recognition gain", "Commitment loss among recognisers", "Correct without recognition"),
  pp = 100 * c((p_rec[FA] - p_rec[AO]) * p_com[AO],
               p_rec[FA] * (p_com[FA] - p_com[AO]),
               extra[FA] - extra[AO]))
stopifnot(abs(sum(waterfall$pp) - 100 * primary$rd) < 1e-9)  # arithmetic identity

# --- Section 4: logistic models (effect estimates on the odds scale) ---------

df$condition <- factor(df$prompt_condition, levels = c(AO, FA))
tidy_glm <- function(fit, label) {
  ci <- suppressMessages(confint(fit))["conditionformalised_argumentation", ]
  co <- coef(summary(fit))["conditionformalised_argumentation", ]
  data.frame(model = label, or = exp(co["Estimate"]), lo = exp(ci[1]), hi = exp(ci[2]),
             p = co["Pr(>|z|)"])
}
models <- bind_rows(
  tidy_glm(glm(auditable_correct_answer_human ~ condition, binomial, df),
           "Strict correct ~ condition (confirmatory, total causal effect)"),
  tidy_glm(glm(identifies_nurse_as_samis_father_human ~ condition, binomial, df),
           "Recognition ~ condition (exploratory, total causal effect)"),
  tidy_glm(glm(auditable_correct_answer_human ~ condition, binomial,
               df[df$identifies_nurse_as_samis_father_human == 1, ]),
           "Commitment ~ condition | recognisers (exploratory, DESCRIPTIVE: conditions on post-treatment variable)"))

# --- Write results -----------------------------------------------------------

dir.create("results", showWarnings = FALSE)
results <- list(
  run = run_label, dataset = dataset_path, generated_by = "analysis/study1_analysis.R",
  note = paste("Primary analysis prespecified/confirmatory. Diagnostic contrasts and",
               "decomposition EXPLORATORY (selected after observing the primary result).",
               "Decomposition conditions on post-treatment variables: descriptive only."),
  primary = primary, exploratory_diagnostics = diagnostics,
  decomposition = decomp, waterfall_pp = waterfall, logistic_models = models)
write_json(results, "results/study1_results.json", pretty = TRUE, digits = 10)
message("Wrote results/study1_results.json")

# --- Figures -----------------------------------------------------------------
# Palette: validated 2-slot categorical (blue #2a78d6 = answer-only,
# orange #eb6834 = formalised); diverging blue/red for signed components.

col_ao <- "#2a78d6"; col_fa <- "#eb6834"
col_pos <- "#2a78d6"; col_neg <- "#e34948"; col_net <- "#52514e"
txt1 <- "#0b0b0b"; txt2 <- "#52514e"; surface <- "#fcfcfb"

thm <- theme_minimal(base_size = 12) +
  theme(plot.background = element_rect(fill = surface, colour = NA),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(colour = "#e8e7e3", linewidth = 0.3),
        plot.title = element_text(colour = txt1, face = "bold", size = 13),
        plot.subtitle = element_text(colour = txt2, size = 10),
        plot.caption = element_text(colour = txt2, size = 8, hjust = 0),
        axis.text = element_text(colour = txt2),
        axis.title = element_text(colour = txt2, size = 10),
        legend.position = "top", legend.title = element_blank(),
        legend.text = element_text(colour = txt1))
wrap_txt <- function(s, w = 95) {
  s <- gsub("\u2014", "-", gsub("\u2212", "-", s))  # keep strwrap ASCII-safe
  paste(strwrap(s, width = w), collapse = "\n")
}
cap <- function(extra = "") wrap_txt(paste0(run_label, ". Randomised prompt experiment, n = 288 per arm, one riddle, one model configuration.", extra), 95)
dir.create("figures", showWarnings = FALSE)

# Fig 1: primary outcome rates with Wilson CIs
prim_rates <- data.frame(
  condition = c("Answer-only", "Formalised"),
  k = c(primary$answer_only, primary$formalised)) %>%
  rowwise() %>% mutate(rate = k / n_arm, lo = wilson_ci(k, n_arm)[1], hi = wilson_ci(k, n_arm)[2]) %>% ungroup()
p_fig1 <- ggplot(prim_rates, aes(condition, rate, fill = condition)) +
  geom_col(width = 0.45) +
  geom_errorbar(aes(ymin = lo, ymax = hi), width = 0.1, linewidth = 0.5, colour = txt1) +
  geom_text(aes(y = hi, label = percent(rate, accuracy = 0.1)), vjust = -0.9, colour = txt1, size = 3.6) +
  scale_fill_manual(values = c("Answer-only" = col_ao, "Formalised" = col_fa), guide = "none") +
  scale_y_continuous(labels = percent, limits = c(0, 1), expand = expansion(mult = c(0, 0.02))) +
  labs(title = wrap_txt("Strict committed-correct rate by prompt condition (confirmatory)", 55),
       subtitle = wrap_txt(sprintf("Causal risk difference %+.2f pp, Newcombe 95%% CI [%+.2f, %+.2f], Fisher p = %.3f - no support for improvement",
                          100 * primary$rd, 100 * primary$lo, 100 * primary$hi, primary$fisher_p), 85),
       x = NULL, y = "Human-verified strict correct", caption = cap()) + thm
ggsave("figures/fig1_primary_effect.png", plot = p_fig1, width = 8, height = 5, dpi = 150)

# Fig 2: forest plot of exploratory diagnostic effects
forest <- diagnostics %>%
  mutate(label = sprintf("%s\n%d vs %d of 288", contrast, formalised, answer_only)) %>%
  arrange(rd) %>% mutate(label = factor(label, levels = label))
p_fig2 <- ggplot(forest, aes(x = 100 * rd, y = label)) +
  geom_vline(xintercept = 0, colour = txt2, linetype = "dashed", linewidth = 0.35) +
  geom_errorbar(aes(xmin = 100 * lo, xmax = 100 * hi), orientation = "y",
                width = 0.12, linewidth = 0.5, colour = txt1) +
  geom_point(size = 3, colour = col_fa) +
  geom_text(aes(label = sprintf("%+.1f pp", 100 * rd)), vjust = -1.1, size = 3.3, colour = txt1) +
  scale_x_continuous(limits = c(-25, 25)) +
  labs(title = wrap_txt("Exploratory: how the formal prompt changed response behaviour", 60),
       subtitle = wrap_txt("Formalised minus answer-only risk differences, Newcombe 95% CIs. All four survive Holm correction.", 85),
       x = "Risk difference (percentage points)", y = NULL,
       caption = cap(" Contrasts selected after observing the primary result: hypothesis-generating, not confirmatory.")) + thm
ggsave("figures/fig2_exploratory_forest.png", plot = p_fig2, width = 8.5, height = 5, dpi = 150)

# Fig 3: waterfall decomposition of the primary effect
wf <- waterfall %>%
  mutate(component = factor(component, levels = component)) %>%
  mutate(end = cumsum(pp), start = lag(end, default = 0),
         fill = ifelse(pp >= 0, "pos", "neg"))
wf_net <- data.frame(component = "Net primary effect", start = 0, end = sum(wf$pp), fill = "net")
wf_all <- bind_rows(wf %>% select(component, start, end, fill), wf_net) %>%
  mutate(component = factor(component, levels = component))
p_fig3 <- ggplot(wf_all, aes(component)) +
  geom_hline(yintercept = 0, colour = txt2, linewidth = 0.35) +
  geom_rect(aes(xmin = as.numeric(component) - 0.28, xmax = as.numeric(component) + 0.28,
                ymin = start, ymax = end, fill = fill)) +
  geom_text(data = subset(wf_all, abs(end - start) > 0.05),
            aes(x = as.numeric(component), y = pmax(start, end),
                label = sprintf("%+.1f pp", end - start)), vjust = -0.6, size = 3.4, colour = txt1) +
  scale_fill_manual(values = c(pos = col_pos, neg = col_neg, net = col_net), guide = "none") +
  scale_x_discrete(labels = label_wrap(16)) +
  labs(title = wrap_txt("Why the primary effect is negative: a descriptive decomposition", 60),
       subtitle = wrap_txt("The formal prompt raised recognition of the solution but suppressed unqualified commitment, which the strict outcome scored as failure. Components sum to the primary risk difference by identity.", 90),
       x = NULL, y = "Contribution (percentage points)",
       caption = cap(" Decomposition conditions on post-treatment variables: arithmetic, not identified mediation.")) + thm
ggsave("figures/fig3_waterfall.png", plot = p_fig3, width = 8.5, height = 5, dpi = 150)

# Fig 4: DAG (drawn, not fitted) - causal structure and where identification stops
nodes <- data.frame(
  name = c("Prompt condition\n(randomised)", "Recognises\nfather solution", "Epistemic\nqualification", "Strict committed\ncorrect (primary)"),
  x = c(0, 1.4, 1.4, 2.8), y = c(0.5, 1, 0, 0.5))
edges <- data.frame(
  x    = c(0.32, 0.32, 1.78, 1.78),
  y    = c(0.62, 0.38, 0.93, 0.07),
  xend = c(1.03, 1.03, 2.44, 2.44),
  yend = c(0.95, 0.05, 0.57, 0.43),
  sign = c("+", "+", "+", "-"))
p_fig4 <- ggplot() +
  geom_segment(data = edges, aes(x, y, xend = xend, yend = yend),
               arrow = arrow(length = unit(6, "pt"), type = "closed"),
               colour = txt2, linewidth = 0.5) +
  geom_label(data = nodes, aes(x, y, label = name), size = 3.4, colour = txt1,
             fill = "#f0efec", linewidth = 0, label.padding = unit(0.35, "lines")) +
  geom_text(data = edges, aes((x + xend) / 2, (y + yend) / 2 + 0.06, label = sign),
            colour = txt1, size = 4.2) +
  annotate("text", x = 1.4, y = -0.42, colour = txt2, size = 3,
           label = "Randomisation identifies total effects of the prompt on each node.\nThe recognition/commitment split conditions on post-treatment variables, so it is reported as descriptive, not causal mediation.") +
  xlim(-0.4, 3.2) + ylim(-0.55, 1.25) +
  labs(title = wrap_txt("Causal structure: the outcome penalises the qualification the treatment induces", 65),
       caption = cap()) +
  thm + theme(axis.text = element_blank(), axis.title = element_blank(),
              panel.grid.major = element_blank(), panel.grid.minor = element_blank())
ggsave("figures/fig4_dag.png", plot = p_fig4, width = 8.5, height = 5, dpi = 150)


# --- Section 5: outcome-definition sensitivity (post hoc, evaluative) --------
# Three explicit scoring rules applied to the SAME frozen data. Rule A is the
# prespecified primary and remains the confirmatory result. Rules B and C were
# defined after observing the results: they are post hoc alternative outcome
# definitions, reported to show how the conclusion depends on what "success"
# means. See docs/05_outcome_definition_sensitivity.md. They do NOT replace
# the primary outcome.

df$rule_A <- df$auditable_correct_answer_human
df$rule_B <- df$identifies_nurse_as_samis_father_human
df$rule_C <- as.integer(df$identifies_nurse_as_samis_father_human == 1 &
                        df$answer_ambiguous_human == 0 &
                        df$answer_contradictory_human == 0)

rule_defs <- data.frame(
  rule = c("A", "C", "B"),
  label = c("Rule A - strict committed correct\n(prespecified primary)",
            "Rule C - identifies solution, no ambiguity\nor contradiction; hedging allowed (post hoc)",
            "Rule B - identifies intended solution\nat all (post hoc)"),
  col = c("rule_A", "rule_C", "rule_B"),
  status = c("confirmatory", "post hoc", "post hoc"))

rules <- do.call(rbind, lapply(seq_len(nrow(rule_defs)), function(i) {
  r <- contrast_row(rule_defs$label[i], rule_defs$col[i], rule_defs$status[i])
  r$rule <- rule_defs$rule[i]
  r
}))
message("Section 5: outcome-definition sensitivity")
for (i in seq_len(nrow(rules))) message(sprintf(
  "  Rule %s: RD %+.2f pp, 95%% CI [%+.2f, %+.2f], Fisher p = %.4f  [%s]",
  rules$rule[i], 100 * rules$rd[i], 100 * rules$lo[i], 100 * rules$hi[i],
  rules$fisher_p[i], rules$family[i]))

results$outcome_definition_sensitivity <- list(
  note = paste("Rule A is the frozen prespecified primary (confirmatory).",
               "Rules B and C are POST HOC alternative outcome definitions,",
               "reported as sensitivity of the conclusion to the success",
               "criterion. They must not be quoted as the primary result."),
  rules = rules)
write_json(results, "results/study1_results.json", pretty = TRUE, digits = 10)
message("Re-wrote results/study1_results.json with Section 5")

# Fig 5: effect estimate under each scoring rule
rules$label_f <- factor(rules$contrast, levels = rules$contrast)
p_fig5 <- ggplot(rules, aes(x = 100 * rd, y = label_f)) +
  geom_vline(xintercept = 0, colour = txt2, linetype = "dashed", linewidth = 0.35) +
  geom_errorbar(aes(xmin = 100 * lo, xmax = 100 * hi), orientation = "y",
                width = 0.1, linewidth = 0.5, colour = txt1) +
  geom_point(aes(colour = family), size = 3.2) +
  geom_text(aes(label = sprintf("%+.1f pp", 100 * rd)), vjust = -1.2, size = 3.3, colour = txt1) +
  scale_colour_manual(values = c("confirmatory" = col_ao, "post hoc" = col_fa)) +
  scale_x_continuous(limits = c(-16, 22)) +
  labs(title = wrap_txt("The conclusion depends on the success criterion", 60),
       subtitle = wrap_txt("Causal effect of the formal prompt under three explicit scoring rules, same frozen data. The stricter the decisiveness requirement, the worse the formal prompt performs. Only Rule A is confirmatory.", 72),
       x = "Formalised minus answer-only risk difference (pp)", y = NULL,
       caption = cap(" Rules B and C defined post hoc: sensitivity of the conclusion to the outcome definition, not replacement primaries.")) + thm
ggsave("figures/fig5_outcome_sensitivity.png", plot = p_fig5, width = 8.5, height = 5, dpi = 150)
message("Wrote figures/fig5_outcome_sensitivity.png")

message("Figures written to figures/. Run complete: ", run_label)
