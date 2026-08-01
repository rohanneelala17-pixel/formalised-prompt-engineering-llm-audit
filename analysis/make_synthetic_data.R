# Generate a SYNTHETIC response-level dataset matching the frozen marginal
# counts of the Sami-father experiment (final_analysis_statistics.json).
#
# Purpose: validate the analysis pipeline end-to-end without the real data.
# Marginals (per condition) match the frozen record exactly; the joint
# structure (which rows carry which code combinations) is constructed, not
# real. Decomposition results on this file are pipeline checks only.

make_arm <- function(cond, n, correct, recog, contra, unres, ambig) {
  df <- data.frame(
    prompt_condition = cond,
    pair_id = seq_len(n) - 1L,
    response_id = paste0(cond, "_", seq_len(n) - 1L),
    auditable_correct_answer_human = 0L,
    identifies_nurse_as_samis_father_human = 0L,
    answer_contradictory_human = 0L,
    unresolved_possibility_human = 0L,
    answer_ambiguous_human = 0L
  )
  df$auditable_correct_answer_human[seq_len(correct)] <- 1L
  df$identifies_nurse_as_samis_father_human[seq_len(recog)] <- 1L
  noncorrect <- (correct + 1):n
  df$unresolved_possibility_human[noncorrect[seq_len(unres)]] <- 1L
  df$answer_ambiguous_human[noncorrect[seq_len(ambig)]] <- 1L
  if (contra > 0) df$answer_contradictory_human[noncorrect[(length(noncorrect) - contra + 1):length(noncorrect)]] <- 1L
  df
}

n_arm_syn <- 288L
synthetic_df <- rbind(
  make_arm("answer_only", n_arm_syn, 182L, 184L, 104L, 2L, 1L),
  make_arm("formalised_argumentation", n_arm_syn, 170L, 214L, 72L, 49L, 28L)
)

out <- file.path("data", "synthetic_locked.csv")
write.csv(synthetic_df, out, row.names = FALSE)
cat("Wrote", out, "-", nrow(synthetic_df), "rows (SYNTHETIC)\n")
rm(make_arm, n_arm_syn, synthetic_df, out)
