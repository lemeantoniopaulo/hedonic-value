#' Select the best model on held-out data
#'
#' @param models Named list of `hv_model` objects.
#' @param test_data Held-out data frame.
#' @param truth Name of the numeric response column in `test_data`.
#' @param metric Metric to minimize: `rmse` or `mae`.
#' @param id Optional unique test observation identifier.
#' @return An object containing the selected model, comparison table and
#'   selection criterion.
#' @export
hv_select_model <- function(models, test_data, truth,
                            metric = c("rmse", "mae"), id = NULL) {
  metric <- match.arg(metric)
  comparison <- hv_benchmark(models, test_data, truth, id = id)
  winner <- comparison$model[which.min(comparison[[metric]])]
  structure(list(selected_name = winner,
                 selected_model = models[[winner]],
                 comparison = comparison,
                 criterion = metric), class = "hv_selection")
}

#' Compute quantitative screening items for regression fundamentação
#'
#' This helper applies the quantitative thresholds commonly shown in the
#' regression table of the IBAPE/SP 2011 recommendation. It does not classify
#' a complete report: characterization, identification, extrapolation and
#' professional evidence remain qualitative inputs for the evaluator.
#'
#' @param model An `hv_model` fitted by OLS or another supported estimator.
#' @return A list with sample thresholds, significance checks and a preliminary
#'   quantitative grade.
#' @export
hv_fundamentacao <- function(model) {
  stopifnot(inherits(model, "hv_model"))
  fit <- model$model
  k <- length(stats::coef(fit)) - 1L
  n <- stats::nobs(fit)
  thresholds <- c(Grau_I = 3L * (k + 1L), Grau_II = 4L * (k + 1L),
                  Grau_III = 6L * (k + 1L))
  quantity_grade <- if (n >= thresholds[["Grau_III"]]) "III" else
    if (n >= thresholds[["Grau_II"]]) "II" else
      if (n >= thresholds[["Grau_I"]]) "I" else "ABAIXO_DE_I"

  coef_table <- tryCatch(summary(fit)$coefficients, error = function(e) NULL)
  p_col <- if (!is.null(coef_table) && "Pr(>|t|)" %in% colnames(coef_table))
    "Pr(>|t|)" else if (!is.null(coef_table) && "p-value" %in% colnames(coef_table))
      "p-value" else NULL
  regressor_p <- if (is.null(p_col)) numeric() else coef_table[-1, p_col]
  max_regressor_p <- if (length(regressor_p)) max(regressor_p, na.rm = TRUE) else NA_real_
  regressor_grade <- if (is.na(max_regressor_p)) "NÃO AVALIADO" else
    if (max_regressor_p <= .10) "III" else if (max_regressor_p <= .20) "II" else
      if (max_regressor_p <= .30) "I" else "ABAIXO_DE_I"

  f_p <- tryCatch({
    fs <- summary(fit)$fstatistic
    if (is.null(fs)) NA_real_ else stats::pf(fs[1], fs[2], fs[3], lower.tail = FALSE)
  }, error = function(e) NA_real_)
  model_grade <- if (is.na(f_p)) "NÃO AVALIADO" else
    if (f_p <= .01) "III" else if (f_p <= .02) "II" else
      if (f_p <= .05) "I" else "ABAIXO_DE_I"

  rank <- c("ABAIXO_DE_I" = 0L, "I" = 1L, "II" = 2L, "III" = 3L)
  numeric_grades <- c(quantity = unname(rank[[quantity_grade]]),
                      regressors = unname(rank[[regressor_grade]]),
                      model = unname(rank[[model_grade]]))
  preliminary <- names(which.min(numeric_grades))
  list(k = k, n = n, thresholds = thresholds,
       max_regressor_p = max_regressor_p, model_f_p = f_p,
       items = data.frame(item = names(numeric_grades),
                          grade = c(quantity_grade, regressor_grade, model_grade),
                          stringsAsFactors = FALSE),
       quantitative_grade = names(rank)[match(min(numeric_grades), rank)],
       limiting_item = preliminary,
       qualitative_review_required = TRUE)
}
