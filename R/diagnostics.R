#' Produce statistical diagnostics for an lm-based hedonic model
#' @export
hv_diagnose_model <- function(model, vif_threshold = NULL) {
  fit <- if (inherits(model, "hv_model")) model$model else model
  if (!inherits(fit, "lm")) stop("hv_diagnose_model currently requires an lm model.")
  sm <- summary(fit); co <- sm$coefficients
  X <- stats::model.matrix(fit); p <- ncol(X)
  vif <- setNames(rep(NA_real_, max(0L, p - 1L)), colnames(X)[-1L])
  if (p > 2L) {
    for (j in 2L:p) {
      others <- X[, -j, drop = FALSE]
      if (ncol(others) > 0L && qr(others)$rank == ncol(others))
        vif[j - 1L] <- 1 / (1 - summary(stats::lm(X[, j] ~ others - 1))$r.squared)
    }
  }
  residuals <- as.numeric(stats::residuals(fit))
  n <- length(residuals); df <- stats::df.residual(fit)
  influence <- stats::influence.measures(fit)
  list(
    coefficients = data.frame(term = rownames(co), co, row.names = NULL,
                              check.names = FALSE),
    residuals = data.frame(row = seq_along(residuals), residual = residuals,
      standardized = as.numeric(stats::rstandard(fit)),
      studentized = as.numeric(stats::rstudent(fit)),
      fitted = as.numeric(stats::fitted(fit)),
      leverage = as.numeric(stats::hatvalues(fit)),
      cooks_distance = as.numeric(stats::cooks.distance(fit))),
    assumptions = list(
      heteroskedasticity = list(method = "exploratory_residual_pattern",
                                status = "PENDING_TECHNICAL_REVIEW"),
      normality = list(method = if (n >= 3L && n <= 5000L) "shapiro.test" else "not_run",
                       result = if (n >= 3L && n <= 5000L) stats::shapiro.test(residuals) else NULL),
      residual_structure = list(status = "PENDING_TECHNICAL_REVIEW")),
    multicollinearity = list(vif = vif, threshold = vif_threshold,
      singular = qr(X)$rank < ncol(X), condition_number = if (nrow(X) >= p)
        kappa(X) else NA_real_),
    influence = list(measures = as.data.frame(influence$is.inf),
                     any_influential = any(apply(influence$is.inf, 1L, any))),
    inferential_limits = c("Conventional p-values do not account for automated model selection.",
                           "Exploratory diagnostics are not proof that assumptions hold."),
    n = n, df_residual = df
  )
}

#' Check whether an evaluating property lies inside observed univariate domains
#' @export
hv_check_extrapolation <- function(data, newdata, predictors) {
  stopifnot(is.data.frame(data), is.data.frame(newdata), is.character(predictors))
  if (any(!predictors %in% names(data)) || any(!predictors %in% names(newdata)))
    stop("Predictors must be present in both data and newdata.")
  rows <- lapply(predictors, function(nm) {
    x <- data[[nm]]; z <- newdata[[nm]]
    if (is.numeric(x) && is.numeric(z)) {
      lo <- min(x, na.rm = TRUE); hi <- max(x, na.rm = TRUE); value <- z[1L]
      data.frame(variable = nm, value = value, lower = lo, upper = hi,
                 status = if (is.na(value)) "INDETERMINATE" else
                   if (value < lo || value > hi) "EXTRAPOLATION" else "INTERPOLATION",
                 stringsAsFactors = FALSE)
    } else {
      value <- as.character(z[1L]); observed <- unique(as.character(x))
      data.frame(variable = nm, value = value, lower = NA, upper = NA,
                 status = if (is.na(value)) "INDETERMINATE" else
                   if (value %in% observed) "OBSERVED_CATEGORY" else "UNSEEN_CATEGORY",
                 stringsAsFactors = FALSE)
    }
  })
  do.call(rbind, rows)
}
